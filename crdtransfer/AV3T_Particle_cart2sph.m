function Xsph=myParticle_cart2sph(Xcart,OriginSph_Cart)
% Description:
%   Cartesian coordinates => Spherical coordinates
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'
%
% Input:
%   Xcart:              3D position in Cartesian coordinates
%   OriginSph_Cart:     Spherical coordinates center in Cartesian coordinates
% Output:
%   Xsph:               3 by N matrix each row corresponds to a sph coordinate componenets


Xsph                            =   zeros(size(Xcart));
[Xsph(1,:),Xsph(2,:),Xsph(3,:)] =   cart2sph(Xcart(1,:)-OriginSph_Cart(1),Xcart(2,:)-OriginSph_Cart(2),Xcart(3,:)-OriginSph_Cart(3));
Xsph(1:2,:)                     =   Xsph(1:2,:)/pi*180;

end