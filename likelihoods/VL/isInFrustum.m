function s = isInFrustum(Xw, C, viewingCosLimit, Iw, Ih)
% Based on isInFrustrum function within ORB-SLAM2
%
% Date:     07/02/2019
% Author:   Alessio Xompero, Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

s = true;

if size(Xw,1) == 3
    Xw = [Xw; 1];
end

Xc = C.RT * Xw;                     % world => camera coordinates

if(Xc(3) < 0)                       % Check positive depth
    s = false;
    return;
end

Ximg = AV3T_project( Xw, C );          % world => image coordinates

if(Ximg(1)<0 || Ximg(1)>Iw)
    disp('Mouth outside FoV')
    s = false;
    return;
end

if(Ximg(2)<0 || Ximg(2)>Ih)
    disp('Mouth outside FoV')
    s = false;
    return;
end

% Check distance is in the scale invariance region of the MapPoint
PO      =   Xw(1:3) - C.Cam_pos;
dist    =   norm(PO);
Pn      =   PO/dist;               % Check viewing angle
viewCos =   dot(PO,Pn)/dist;

if(viewCos<viewingCosLimit)
    disp('Not good viewCos')
    s = false;
    return;
end

end
