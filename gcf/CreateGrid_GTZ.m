function GridZ=CreateGrid_GTZ(gtZ,X_g,Y_g)
% Description:
%   create grid at speaker height
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

GridZ=gtZ*ones(3,length(X_g)*length(Y_g));

index=1;
for x=1:length(X_g)
    for y=1:length(Y_g)
        GridZ(1,index)=X_g(x);
        GridZ(2,index)=Y_g(y);
        index=index+1;
    end
end

end