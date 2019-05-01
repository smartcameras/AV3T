function [Obs,Par]=visual_preprocessing(Info,Par,K,flag)
% Description:
%   1. read face detection parameters
%   2. remove K % of face detections
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'


if Par.V.wdg                            % use diagonal size of detection
    W       =      Par.V.Wdiag;
else
    W       =      Par.V.W;
end

[FBB,DetN,~,MOUTHimg,MOUTH3d]   =   readfaceDetect(Info.seq,Par.V.Vfr,Info.camData,W,Info.cam,flag~=1,Par.V.wdg,Par.V.ws);
[FBB,DetN,MOUTHimg,MOUTH3d]     =   removFBB(FBB,DetN,MOUTHimg,MOUTH3d,K);


Kstr=['K',num2str(K)];                  % remove % of face detections
disp(['Remove ',num2str(K),' FBB'])

Obs.FBB     =   FBB;
Obs.DetN    =   DetN;                   % detection number
Obs.MOUTH3d =   MOUTH3d';               % 3D mouth projection
Obs.MOUTHimg=   MOUTHimg;               % image estimate from face detection
Obs.FD      =   DetN>0;                 % with detection or not
Obs.Kstr    =   Kstr;

Par.K       =   K;
Par.Kstr    =   Kstr;

end


function [FBB,detN,mouthImg,mouth3D]=removFBB(FBB,detN,mouthImg,mouth3D,K)
% Description:
%   randomly remove K (range [0 1]) of FBB 
% Input:
%       FBB:        face bounding box 
%       mouthImg:   mouth image estimate from face detection
%       mouth3D:    image-3D mouth projection 
% Date: 25/10/2017
% Author: XQ

disp(['Start Remove  ',num2str(K),' FBB'])
if(K==0)                            % use original face detection rst
    return
end

FrD     =   find(detN>0);                   % detect frame index
Nrm     =   round(length(FrD)*K);           % remove frame number

% FBB Fr for remove
Ri      =   randperm(length(FrD));           % non-repetitive random integers
Rv      =   Ri(1:Nrm);
Rf      =   FrD(Rv);                         % remove frame index

% remove FBB information
detN(Rf,:)      =   0;
FBB(Rf,:)       =   0;
mouthImg(Rf,:)  =   0;
mouth3D(:,Rf)   =   0;

disp(['Finish FBB Removing '])

end

