function [idealTDOA,idealTDOA_org]=MyIdealTDOA_Cart_3D(Grid_cart,M1,M2,c,fa)
% Description:
%   estimate the idealTDOA between ONE Mic Pair
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.

d1              =   sqrt(sum((Grid_cart-M1(:)*ones(1,size(Grid_cart,2))).^2,1)); % distance to Mic1
d2              =   sqrt(sum((Grid_cart-M2(:)*ones(1,size(Grid_cart,2))).^2,1));

idealTDOA_org   =   (d1-d2)/c*fa;
idealTDOA       =   round(idealTDOA_org);

end