function [mouth3D] = myPoint3Dprojection(mouth2D, C)
% Date:     07/02/2019
% Author:   Alessio Xompero, Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

mouth2D( 1, : ) = mouth2D( 1, : ) - C.shift(1);
mouth2D( 2, : ) = mouth2D( 2, : ) - C.shift(2);

% Remove radial distortion
mouth2Dun = undoradial( [mouth2D;ones(1,size(mouth2D,2))], C.K, [C.kc 0]); 

X = [mouth2Dun(1:2,:); ones(1,size(mouth2D,2))];

% Get 3D point in camera coordinate system
iX = inv(C.K) * X;

if size(C.T,1) == 3
  T = [C.T; 0 0 0 1];
else
  T = C.T;
end

% Get mouth position in 3D in homogeneous coordinates
mouth3Dh = 	C.Align * (inv(T) * [iX; ones(1,size(mouth2D,2))]);

mouth3D = mouth3Dh(1:3,:);

end
