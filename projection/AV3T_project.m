function [p2d,onimg] = AV3T_project(p3d, C)
% Description:
%   project 3D points to the image plane
%
% Date:     07/02/2019
% Author:   Alessio Xompero, Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'
%
% Input:
%	p3d:    4xN points in 3D (homogenoeus coordinates) -> [X, Y, Z, 1]'
%	C:      camera data structure
%           - f: nominal focal length
%           - m: pixels/mm (m_x, m_y)
%           - pp: principal point, (p_x,p_y)
%           - K: camera calibration matrix
%           - RT: roto-translation from world to camera coordinates
%           - kc: distortion parameters (Tsai model), [k1,k2,k3,p1,p1]
% Output:
%   p2d:    2xN points on the image plane
%   onimg:  binary index: whether point is on the image


mode = C.dataset;

switch mode
    case 'AV16.3'
        [p2d,onimg] = projectionAV163(p3d, C);
    case 'CAV3D'
        [p2d,onimg] = projectionCHIL(p3d(1:3,:), C);
end

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p2d,onimg] = projectionCHIL(p3d, C)
% Author: Francesco Tobia, FBK-TeV
%   Date:
%
% Author: Alessio Xompero, QMUL/FBK-TeV
%   Date: 2017/08/01
%
% modified:
%   Date: 05/06/2018
%   Xinyuan, Oswald
%   3D-to-image distortion problem-> apply binary mask

p2d         =   NaN(2,size(p3d,2));
onimg       =   false(size(p3d,2),1);

switch C.seq
    case 'SOT'
        [pts,ptsv]  =   safeProjectPointsSOT(p3d,C.R,C.T,C.K,C.kc,C.map);
        % pts: 2 by N projected image points
        % ptsv: validated points index of p3d, corresponds to pts
    case 'MOT'
        [pts,ptsv]  =   safeProjectPointsMOT(p3d,C.R,C.T,C.K,C.kc,C.map);
end


% C starts at 0 while MATLAB starts at 1
pts         =   pts+1;
ptsv        =   ptsv+1;

% check pts within image size
idx         =   (pts(1,:)>0) & (pts(1,:)<= C.ImgSize(2)) & (pts(2,:)>0) & (pts(2,:)<=C.ImgSize(1));
ptsv(~idx)  =   [];
pts(:,~idx) =   [];

onimg(ptsv)	=   true;
p2d(:,ptsv) =   pts;

% check p3d infront of camera
Xc          =   C.RT * [p3d;ones(1,size(p3d,2))];                               % word to camera coords
bckcam      =   Xc(3,:)<0;
p2d(:,bckcam)=  NaN;                                                            % points at back of the camera
onimg(bckcam)=  false;

end
