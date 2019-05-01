function Xcart=myParticle_sph2cart(Xsph,OriginCart)
% Description:
%   Spherical coordinates => Cartesian coordinates
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
%   Xsph:           3 by N matrix, each row corresponds to a Sph coordinate componenet
%   OriginCart:     Spherical coordinates center in Cartesian coordinates
% Output:
%   Xcart:          3D position in Cartesian coordinates


Xcart                               =   zeros(3,size(Xsph,2));
[Xcart(1,:),Xcart(2,:),Xcart(3,:)]  =   sph2cart(Xsph(1,:)/180*pi,Xsph(2,:)/180*pi,Xsph(3,:));
Xcart                               =   Xcart+ repmat(OriginCart,[1 size(Xcart,2)]);

end