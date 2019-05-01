function [wv,Ver]=myVideo_Gaussian(Xcart,mouth3D,Upstd,camData)
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

N=size(Xcart,2);

X           =   AV3T_Particle_cart2sph(Xcart,camData.Cam_pos);             % transfer to sph coordinates
mouth3D     =   AV3T_Particle_cart2sph(mouth3D,camData.Cam_pos);
Ver         =   X-mouth3D*ones(1,N);                                    % error square
Ver(1,:)    =   AV3T_ADiff_correct(Ver(1,:),'deg');
Ver         =   sum((Ver.^2)/2./(Upstd.^2*ones(1,N)));
wv          =   exp(-Ver);


end