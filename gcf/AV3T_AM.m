function [AM,gccphat]=AV3T_AM(idealTDOA,CM,i)
% Description:
%   compute the acoustic map
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
%   idealTDOA:  ideal TDOA at each room grid for each Mic pair
%   i:          audio frame index
%   CM:         coherence measure
% Output:
%   AM:         acoustic map
%   gccphat:    gccphat at time frame i

AM          =   zeros(size(idealTDOA));
Tmax        =   (size(CM,1)+1)/2;

gccphat     =   CM(:,i); 
AM(1:end)   =   gccphat(idealTDOA(1:end)+Tmax);  % this step is really time consuming

end
