function Xw=myPtl_killRoomRg(X,Origin,RoomRg,mode)
% Description:
%   kill the partiles outside the room range
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
%   X:          3 by N particles
%   Origin:     origin position
%   RoomRg:     room range [X;Y;Z]
%   mode:       X coordinates - 'sph' or 'cart'
% Output:
%   Xw:         binary index whether the particles are INSIDE the room or not

if nargin<4
    mode='sph' ;
end

if strcmp(mode,'sph')
    X = myParticle_sph2cart(X, Origin);
end

Xw = prod((X >= repmat(RoomRg(:,1),1,length(X))) & (X <= repmat(RoomRg(:,2),1,length(X))));

end
