function [TrackObj,ObsV,Er]=MOTinitialisation(GT,Info,Par,Obs)
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
%
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

GT3d    =   GT.GT3d;
GTimg   =	GT.GTimg;

camData =	Info.camData;
ImgSize =   camData.ImgSize;
seq_name=   Info.seq_name;

ID      =	Par.ID;
i0      =	Par.i0;
Fr      =	Par.Fr;

Prestd  =   Par.PF.Prestd;
N       =   Par.PF.N;
Nbins   =   Par.V.Nbins;
Fw      =   Par.V.Face3DSz(1);
Fh      =   Par.V.Face3DSz(2);
Ih      =   Par.V.ImgSize(1); % Image height
Iw      =   Par.V.ImgSize(2); % Image width
fmt     =   Par.V.fmt;
Vfr     =   Par.V.Vfr;

% initialise
IDlen   =   length(ID);
TrackObj=   cell(IDlen,1);
ObsV    =   cell(IDlen,1);
Er      =   cell(IDlen,1);

%% Initialisation
for id=ID
    Er{id}.er                   =   zeros(Fr,1);
    Er{id}.mae                  =   zeros(Fr,1);
    
    % track obj
    TrackObj{id}.X              =   GT3d{id}(i0,:)'*ones(1,N)+randn(3,N).*(Prestd*ones(1,N));  % initialize at ground truth + noise
    TrackObj{id}.Xest3d         =   zeros(Fr,3);
    TrackObj{id}.Xest3d(i0,:)   =   GT3d{id}(i0,:);             % initialize at 3D ground truth
    TrackObj{id}.XestImg        =   zeros(Fr,2);
    TrackObj{id}.XestImg(i0,:)  =   GTimg{id}(i0,:);            % initialize at image ground truth
    TrackObj{id}.vad            =   false(Fr,1);
    
    % ObsV
    ObsV{id}.Mimg               =   zeros(size(Obs.MOUTHimg));  % mouth on image plane
    ObsV{id}.M3d                =   zeros(size(Obs.MOUTH3d));   % mouth in 3D
    ObsV{id}.FoV                =   zeros(Fr,1);                % FoV flag
    ObsV{id}.fbb                =   zeros(size(Obs.FBB));       % face detection
    ObsV{id}.detn               =   zeros(Fr,1);                % number of detection
    ObsV{id}.fd                 =   zeros(Fr,1);                % detection or not
    ObsV{id}.Zp                 =   GT3d{id}(i0,3);
    
    switch Par.flag
        case 1 % audio-only
            ObsV{id}.fdstr.D        =   [];
            ObsV{id}.fdstr.H        =   [];
            ObsV{id}.fdstr.DH       =   'AO-mode';
            ObsV{id}.Vmap           =   ones(length(Par.Y_g), length(Par.X_g));
            ObsV{id}.Hmap{1}        =   0; % face
            ObsV{id}.Hmap{2}        =   0; % torso
            
        otherwise % AV or video-only
            
            
            fbb     =   zeros(4,2);         % facebb vector
            
            for mb=1:2                      % multi-body part use both face & torso
                
                bodypart=mb-1;
                
                notImgbder= GTimg{id}(:,1)>ImgSize(2)*0.1 & GTimg{id}(:,1)<ImgSize(2)*0.9...
                    & GTimg{id}(:,2)>ImgSize(2)*0.1 & GTimg{id}(:,2)<ImgSize(1)*0.9;% not at image border
                
                irf                 =   find((~isnan(GTimg{id})& notImgbder)==1,1); % reference image = 1st (not at image border) detection
                if ~isempty(irf)            % detection exist
                    fbb(:,mb)   	=   AV3T_VirtualBoxCreation(GT3d{id}(irf,:)', camData, Fw, Fh, Iw, Ih, bodypart);
                    Y_k                 =   imread(fullfile(seq_name,fmt{1}, [fmt{2} num2str(irf+Vfr(1)-1,fmt{3}) fmt{4}]));
                    ObsV{id}.RefImg{mb} =   Y_k(fbb(2,mb):fbb(2,mb)+fbb(4,mb),fbb(1,mb):fbb(1,mb)+fbb(3,mb),:); % reference image
                else                        % no detection
                    ObsV{id}.RefImg{mb} = imread(['RefImg',num2str(id),'_cam5.PNG']);
                end
                
                ObsV{id}.Hmap{mb}   =   ObsV{id}.RefImg{mb};
                
                % spatiogram
                [H,mu,sigma]            =   AV3T_Hist(ObsV{id}.RefImg{mb},Nbins);
                ObsV{id}.Hr{mb}.H       =   H/sum(H);
                ObsV{id}.Hr{mb}.mu      =   mu;
                ObsV{id}.Hr{mb}.sigma   =   sigma;
                ObsV{id}.Hr{mb}.par.Nbins   =   Nbins;
            end
            
    end
    
end


disp('finish initialise')


end