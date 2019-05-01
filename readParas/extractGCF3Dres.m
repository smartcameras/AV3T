function [ObsA,Par]=extractGCF3Dres(Info,Par)
% Description:
%   extract the GCF 3D sound source localisation results and save them
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

disp('extract GCF SSL rst')
load(fullfile([Info.seq_name,'_GCFSSL_MA',num2str(Info.ma),'_all_blkman']));             % SSL results   
  
for id=Par.ID 
    ObsA{id}.SSL        =   Results.SSLcart(2:4,Par.A.Afr(1):Par.A.Afr(2))';
    ObsA{id}.SSL(:,4)   =   Results.AM_max(Par.A.Afr(1):Par.A.Afr(2))>=Par.A.AMvad{id}; % voice activity results
    ObsA{id}.CM         =   Results.CM;
end

Par.X_g=Results.par.X_g;
Par.Y_g=Results.par.Y_g;

disp('finish extract GCF SSL rst')

end


