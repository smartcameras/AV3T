function [FBB,detN,Conf,MOUTHimg,MOUTH3d]=readfaceDetect(seq,Vfr,camData,W,cam,comp,wdg,ws)
% Description:
%   read the face detection results
%   the face detection bounding boxes should be saved in the following format:
%   [#frame, #detection, topleft_x, topleft_y, bottomright_x, bottomright_y, probability, ...]
% 
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

if(nargin<6)
    comp=1;     % default compute mouth in3D
    wdg=false;  % 3D projection using detection width
    ws=1/3*ones(1,3);
end


disp('read MXNet data')
dataset=camData.dataset;

disp([dataset,':   read FBB results'])
filename=['facebb_',dataset,'seq',num2str(seq,'%02d'),'_C',num2str(cam),'.txt'];    % face detection file name

% read detection data
C=dlmread(filename);

st      =   1-C(1,1);               % first detection frame index
V_Rg    =   st+(Vfr(1):Vfr(2));     % video frame range
detN    =   C(V_Rg,2);              % detection number
Clen    =   size(C,2)-2;
Conf    =   C(V_Rg,7:5:Clen);       % confidence score
Nfb     =   1:Clen;
FBB     =   C(:,2+Nfb(repmat([true(1,4),false],[1 Clen/5])));

% face bbox
BR              =   Nfb(repmat([false(1,2),true(1,2)],[1 Clen/5]));                 % bottom right index
TL              =   Nfb(repmat([true(1,2),false(1,2)],[1 Clen/5]));                 % top left index
FBB(:,BR)       =   FBB(:,BR)-FBB(:,TL);
FBB             =   FBB(V_Rg,:);                        % synchronise
FBB(isnan(FBB)) =   0;

% mouth pos on image
mpos            =   [0.5,0;0,0.75];
mMtx            =   [eye(2);mpos];                      % extract mouth from FBB

switch Clen/5
    case 2
        mMtx    =   blkdiag(mMtx,mMtx);                 % Block diagonal concatenation of matrix
    case 3
        mMtx   	=   blkdiag(mMtx,mMtx,mMtx);            % Block diagonal concatenation of matrix
    case 4
        mMtx  	=   blkdiag(mMtx,mMtx,mMtx,mMtx);       % Block diagonal concatenation of matrix
end
MOUTHimg        =   FBB*mMtx;

% Image-3D mouth projectionst
if comp  
    for cl=1:Clen/5
        i3d     =   (cl-1)*3+1:3*cl;
        ifb     =   (cl-1)*4+1:4*cl;
        imi     =   (cl-1)*2+1:2*cl;
        MOUTH3d(i3d,:)=AV3T_FBBto3D(FBB(:,ifb), MOUTHimg(:,imi)',W, camData,dataset,0,wdg,ws);
    end
    disp([dataset,':   Finish reading MXNet data...'])
else
    MOUTH3d=[];
end


end