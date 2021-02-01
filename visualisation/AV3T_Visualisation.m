function AV3T_Visualisation(TrackObj,ObsA,ObsV,Obs,GT,Er,Info,Par,i,p,PrtImg,iter)
% Description:
%   display the tracking results
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.


if length(Par.ID)>1
        visualisation_2ID(TrackObj,ObsA,ObsV,Obs,GT,Er,Info,Par,i,p,PrtImg,iter);  % multiple speaker    
else
    visualisation_1ID(TrackObj,ObsA,ObsV,Obs,GT,Er,Info,Par,i,p,PrtImg,iter);  % dominant speaker
end
disp('visualisation finish')

end