function AM=myAL_GCF(Gridcart,CM,afr,Mic_pair,Mic_pos,c,fa)
% Description:
%   compute the GCF value for each particle
%
% Date:     07/02/2019
% Author:   Alessio Xompero, Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'


AM=0;

for m=1:size(Mic_pair,1) % for each mic pair
    a   =   Mic_pair(m,1);
    b   =   Mic_pair(m,2);
    
    idealTDOA   =AV3T_IdealTDOA_Cart_3D(Gridcart,Mic_pos(a,:),Mic_pos(b,:),c,fa); % compute ideal TDOA

    Tmx =   floor(size(CM{a,b},1)/2); % maximum delay
    ga  =   ones(2*Tmx+1,1);
    AM  =   AM+AV3T_AM(idealTDOA,repmat(ga,[1 size(CM{a,b},2)]).*CM{a,b},afr);
end

AM=AM/m;


end