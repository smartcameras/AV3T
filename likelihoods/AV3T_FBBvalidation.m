function [Mimg,M3d,fbb,detn,fd,FBBi,AvgImg]=myFBBvalidation(XestImg,MOUTHimgi,MOUTH3di,DetNi,i,i0,FBBi,ws)
% Description:
%   valid the face detection bounding box according to our current
%   estimated target state
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'
%
% Input
%   Xest_Img:   estimated target on image plane 
%   MOUTHimgi:  mouth image position                  
%   MOUTH3di:   mouth 3D position                 
%   DetNi:      # det at frame i
%   i:          current frame
%   FBBi:       face detection bounding box 
%
% Output
%  Mimg:        validated mouth on image
%  M3d:         validated mouth in 3D
%  fbb:         validated face detection results
%  detn:        detection number
%  FBBi:        face detection results remove the previous allocation
%  AvgImg:      averaged image estimation

Mimg  = zeros(1,size(MOUTHimgi,2));                             % mouth on image
M3d    = zeros(1,size(MOUTH3di,2));                               % mouth in 3D
fbb     = zeros(1,size(FBBi,2));

% take the last 3 frames
if(i-i0>=3)&&(DetNi>0)
    AvgImg  =   sum(XestImg(i-3:i-1,:)'.*repmat(ws,[2,1]),2); % avg.est on Img
    est     =   AvgImg*ones(1,DetNi);
else                                                                                   % no detection/in the beginning
    AvgImg  =   XestImg(max(i0,i-1),:)';                                 % avg.est on Img
    est     =   AvgImg*ones(1,DetNi);
end

fbb_W   =   FBBi(3:4:end);
fbb_H   =   FBBi(4:4:end);
fbb_S   =   sqrt(fbb_W.^2+ fbb_H.^2);                                   % size
fbb_S   =   max(fbb_S);

mimg    =   MOUTHimgi(1:2*DetNi);
mimg    =   reshape(mimg,[2 DetNi]);                                       % 2 by detN matrix
ErImg   =   sqrt(sum((est-mimg).^2));                                       % er on image plane

lambda  =   2.5;

Fi      =   find(ErImg<=lambda*fbb_S);
detn    =   length(Fi);

if(detn<DetNi)
    disp(['FBB-validation:  remove ',num2str(DetNi-detn),'   FPs'])
else
   disp('FBB-validation: all successful!!') 
end

for d=1:detn
    fi=Fi(d);
    Mimg(2*(d-1)+1:2*(d-1)+2)   =  MOUTHimgi(2*(fi-1)+1:2*(fi-1)+2);
    M3d (3*(d-1)+1:3*(d-1)+3)   =  MOUTH3di (3*(fi-1)+1:3*(fi-1)+3);
    fbb (4*(d-1)+1:4*(d-1)+4)   =  FBBi     (4*(fi-1)+1:4*(fi-1)+4);
    FBBi(4*(fi-1)+1:4*(fi-1)+4) =  0; % remove detection from global file
end

fd=detn>0; % det?

end