function objfrt=isVisible(TrackObj,ObsV,Info,ID,i)
% Description:
%   check whether the identity is in front of the others
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

objfrt=ones(1,length(ID));

if length(ID)==1                                                                % single speaker, always infront
    return
end


for id=ID
    Xr(id)=norm(TrackObj{id}.Xest3d(max(i-1,1),:)'-Info.camData.Cam_pos);       % distance to camera center
    refs(id)=norm([size(ObsV{id}.RefImg{1},1),size(ObsV{id}.RefImg{1},2)]);     % face diagonal size
end

% check whether is visible
for id=ID
    IDrst=ID(ID~=id);                                                           % rest identities
    
    for idx=IDrst
        distImg=norm(TrackObj{id}.XestImg(max(i-1,1),:)-TrackObj{idx}.XestImg(max(i-1,1),:)); % image distance of the two estimates
        faceDig=max(refs([id idx]))/2;
        
        if distImg<=faceDig && Xr(id)>Xr(idx)                                   % if the two detection overlapped, distant speaker is not visible
            objfrt(id)=0;
            disp(['Obj ',num2str(id),'  is BEHIND the  object',num2str(idx)])
        end
        
    end
    
end



end