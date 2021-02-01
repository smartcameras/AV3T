function wv= visualLikelihood_Spatio(Y_k, Xcart, C, Face3DSz,Hr,bodypart,cspace)
% Description:
%   compute the video spatiogram likelihood
%
% Date:     07/02/2019
% Author:   Alessio Xompero, Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

disp(' - Search-based visual likelihood..');

if(nargin<6)
    bodypart=0;
end

N = size(Xcart,2); % Number of particles
wv=zeros(1,N);

if isempty(Hr.H)
   return % no reference image 
end



% Number of bins for the color histogram
Nbins = 8;

Fw = Face3DSz(1);
Fh = Face3DSz(2);

Ih = size(Y_k,1); % Image width
Iw = size(Y_k,2); % Image height

% For each particle state create a 3D face rectangle and project it onto the
% image
[bboxes, idx] = AV3T_VirtualBoxCreation(Xcart, C, Fw, Fh, Iw, Ih, bodypart);

if sum(idx) == 0
    disp('All particles outside FoV!')
end

% Compute RGB Color Histograms and the square of the Bhattacharrya distance for
% all bounding boxes within the FoV
for i=1:N
    if idx(i) == 0
        continue
    end
    
    x1 = bboxes(2,i);
    x2 = bboxes(2,i) + bboxes(4, i);
    
    y1 = bboxes(1,i);
    y2 = bboxes(1,i) + bboxes(3, i);
    
    if prod([x1,y1,x2,y2] ~= 0)==0
        disp('Zero size!!!')
        continue
    end
    
    im_patch = Y_k(x1:x2,y1:y2,:);
    [HtF,muF,sigmaF]=AV3T_Hist(im_patch,Nbins);
    
    if isempty(Hr.H)
       a=1; 
    end
    wv(i)= compareSpatiograms_new_fast(HtF,muF,sigmaF,Hr.H,Hr.mu,Hr.sigma);
    clear HtF muF sigmaF
end

disp([cspace,' spatiogram! '])

end
