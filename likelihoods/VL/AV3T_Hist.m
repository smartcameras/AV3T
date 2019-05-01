function [H,mu,sigma,Nc]=myHist(Img,nBins)
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

Nc=nBins^3;

Ih = rgb2hsv(Img); % HSV
Img=uint8(Ih*255);

Img=double(Img);
[H,mu,sigma] = getPatchSpatiogram_fast(Img,nBins);  % spatiogram


end
