function ObsV=myMOT_greedy(TrackObj,Obs,ObsV,i,Par,Info)
% Description:
%   greedy data association
%   (1) compute the 3D error matrix
%   (2) sort the error
%   (3) associate 1 detection to 1 identity
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

ID          =       Par.ID;
fmt         =       Par.V.fmt;

disp(['start MOT data association ',num2str(ID)])

DetNi       =	double(Obs.DetN(i,:));
if Par.flag==1 || ~DetNi                        % audio only OR no detection
    disp('no association needed')
    return;
end

disp('extract frame-i information')
FBBi        =	Obs.FBB(i,:);
MOUTH3di    =	Obs.MOUTH3d(i,:);
MOUTHimgi   =   Obs.MOUTHimg(i,:);
ws          =   Par.V.ws;
i0          =   Par.i0;
ID          =   Par.ID;
Upstd       =   Par.PF.Upstd;


camData     =   Info.camData;
IDlen       =   length(ID);
Xest3d      =   cell(length(ID),1);
Mimg        =   zeros(1,size(MOUTHimgi,2));     % mouth on image
M3d         =   zeros(1,size(MOUTH3di,2));      % mouth in 3D
fbb         =   zeros(1,size(FBBi,2));

switch IDlen
    case 1                                      % single speaker & single detection
        DetN    =   1:DetNi;                    % detection index
        DetNID  =   ID*ones(DetNi,1);           % associated identity index
        disp('Only 1 target, no association needed')
        
    otherwise                                   % multiple speakers
        %% compute association matrix
        
        disp('3D association matrix')
        Ld=zeros(length(ID),DetNi);             % detection likelihood
        Lc=ones(length(ID),DetNi);              % color likelihood
        
        for id=ID                               % identity
            Xest3d{id}  =   TrackObj{id}.Xest3d(max(i0,i-1),:)';
            
            for dn=1:DetNi                      % detection index
                
                M3di            =   MOUTH3di(3*(dn-1)+1:3*(dn-1)+3);
                Ld(id,dn)       =   AV3T_Video_Gaussian(Xest3d{id},M3di',Upstd,camData);
                
                Y_k             =   imread(fullfile(Info.seq_name,fmt{1}, [fmt{2} num2str(i-1+Par.V.Vfr(1)-1,fmt{3}) fmt{4}]));
                for mb=1:2                      % multi-body histogram
                    wvH(mb,:) 	=   visualLikelihood_Spatio(Y_k, M3di', camData, Par.V.Face3DSz,ObsV{id}.Hr{mb},mb,'hsv');
                end
                Lc(id,dn)   	=   mean(wvH);
                
            end
        end
        Assot   =   Lc.*Ld;
        
        %% target-detection association
        DetN    =   zeros(DetNi,1);                                             % detection index
        DetNID  =   zeros(DetNi,1);                                             % associated identity index
        asN=1;                                                                  % number of associated pairs
        
        while (DetNi-asN)>=0                                                    % association unfinished
            [~,I]                   =   sort(Assot(:),'descend');
            [DetNID(asN),DetN(asN)] =   ind2sub(size(Assot), I(1));
            Assot(DetNID(asN),:)    =   0;
            Assot(:,DetN(asN))      =   0;
            asN                     =   asN+1;
        end
        
        
end

%% extract fbb info
disp('extract fbb info')
for id=ID
    detn   =   sum(DetNID==id);             % number of detection
    
    if detn                                 % associated detection
        detN   =  DetN(DetNID==id);         % associated detection ID to identity
        
        disp(['Face Association:  ID-',num2str(id),'  faceBBOX-',num2str(detN(:)')])
        for d=1:detn
            Mimg(2*(d-1)+1:2*d)     =   MOUTHimgi(2*(detN(d)-1)+1:2*detN(d));
            M3d(3*(d-1)+1:3*d)      =   MOUTH3di(3*(detN(d)-1)+1:3*detN(d));
            fbb(4*(d-1)+1:4*d)      =   max(FBBi(4*(detN(d)-1)+1:4*detN(d)),1);
        end
        
        % face validation
        [ObsV{ID(id)}.Mimg(i,:),...
            ObsV{ID(id)}.M3d(i,:),...
            ObsV{ID(id)}.fbb(i,:),...
            ObsV{ID(id)}.detn(i),...
            ObsV{ID(id)}.fd(i)] = AV3T_FBBvalidation(TrackObj{id}.XestImg,Mimg,M3d,detn,i,i0,fbb,ws);
    end
    
end

disp('Finish MOT data association')

end