function [wv,Zp,fdstr,Vmap,Hmap,RefImg,Hr,wvD,wvH,fdstrD,fdstrH]=myVL(X,detN,mouth3D,fd,i,Zp,X_g,Y_g,Upstd,FBB,seq_name,Vfr,Xest3d,Face3DSz,camData,RefImg,Hr,FoV,flag,fmt)
% Descrition:
%   visual likelihood
%
% Date:     07/02/2019
% Author:   Alessio Xompero, Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

disp(' video likelihood computation')
N   =   size(X,2);

if flag==1   % audio only
    fdstr   =   [];
    Vmap    =   ones(length(Y_g), length(X_g));
    wv      =   ones(1,N)/N;
    Hmap    =   0;
    wvD     =   zeros(1,N); % detection
    wvH     =   zeros(1,N); % visual feature
    fdstrD  =   'AO';
    fdstrH  =   'AO';
    return
end

X	=   X(1:3,:);
cspc=   'hsv'; % colour space


%% Generate Reference Image from face detection

if  (i>1 && fd(i-1) && ~fd(i) && i<length(fd))
    disp('---------------Generate Ref Image from detection-------------------')
    Y_k                     =   imread(fullfile(seq_name,fmt{1}, [fmt{2} num2str(i-1+Vfr(1)-1,fmt{3}) fmt{4}]));
    disp('read image')
    
    % from 3D mouth projection (virtual box in 3D, project back to image)
    fi                      =   myCloestMouth3d(Xest3d,mouth3D,i-1);
    
    % face | torso ref img
    for mb=1:2
        
        Nbins               =   Hr{mb}.par.Nbins;
        fbb                 =   round(FBB(i-1,4*(fi-1)+1:4*fi)); % current face detection
        RefImg{mb}          =   Y_k(fbb(2)+2*(mb-1)*fbb(4):fbb(2)+fbb(4)+2*(mb-1)*fbb(4),fbb(1):fbb(1)+fbb(3),:); % face/torso region
        
        [H,mu,sigma]        =   AV3T_Hist(RefImg{mb} ,Nbins);
        Hr{mb} .H           =   H/sum(H);
        Hr{mb} .mu          =   mu;
        Hr{mb} .sigma       =   sigma;
        
    end
    
    disp('----------------Finish generating ref image-------------------------')
end

%% Vide likelihood
wvD=zeros(1,N);         % discriminative likelihood
wvH=zeros(2,N);         % generative liklihood

% -----------------------discriminative likelihood: detection based ---------------

if fd(i)
    fdstrD  =   [' ',num2str(detN),' dets'];
    Vmap    =   0;                      % visual map
    Zp      =   zeros(1,detN);
    for d=1:detN
        mouth   =   mouth3D(i,3*(d-1)+1:3*d)';
        Zp(d)   =   mouth(3);
        GridZ   =   CreateGrid_GTZ(Zp(d),X_g,Y_g);
        wvD     =   wvD+AV3T_Video_Gaussian(X,mouth,Upstd,camData);
        Vmap    =   Vmap+AV3T_Video_Gaussian(GridZ,mouth,Upstd,camData);
    end
    Vmap    =   reshape(Vmap,[length(Y_g), length(X_g)]);
else
    fdstrD  =   '0det ';
    Vmap    =   ones(length(Y_g), length(X_g));
end

% -----------------------generative likelihood: color histogram based ---------------
Hmap    =   cell(2,1);
for mb=1:2
    Hmap{mb}    =   0;
end

if  ~fd(i)
    
    if ~isempty(RefImg) && FoV
        Y_k     =   imread(fullfile(seq_name,fmt{1}, [fmt{2} num2str(i+Vfr(1)-1,fmt{3}) fmt{4}]));
        fdstrH  =  'hsvspatio';
        
        for mb=1:2
            bodypart=mb-1;
            Hmap{mb}  =   RefImg{mb};
            
            wvH(mb,:) = visualLikelihood_Spatio(Y_k, X, camData, Face3DSz,Hr{mb},bodypart,cspc); % compute spatiogram
            
        end
        
    else
        fdstrH  =   '0Hist|outFoV';
    end
else
    fdstrH      =   'No feature';
end

wvTF    =   mean(wvH,1);                    % torso and face color spatiogram
wv      =   wvD+wvTF;                       % Detection based likelhood + torso & face has similar weights
fdstr   =   [fdstrD,fdstrH];

if sum(wv)==0
    wv=1/N*ones(1,N);
    disp('No video likelihood to use.....')
end


end

%% Other functions
function [fi,Er3d]=myCloestMouth3d(Xest3d,mouth3D,i)

detN=sum(mouth3D(i,:)~=0)/3;
if(i>3)
    Xest3d  =   mean(Xest3d(i-3:i-1,:))'; % avg.est on Img
else
    fi      =   1;
    Er3d    =   NaN;
    return
end

est     =   Xest3d*ones(1,detN);
m3d     =   reshape(mouth3D(i,1:3*detN),[3,detN]);
Er3d    =   sqrt(sum((est-m3d).^2));
[~,fi]  =   min(Er3d);
end


