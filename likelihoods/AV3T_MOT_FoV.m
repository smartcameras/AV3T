function ObsV=myMOT_FoV(TrackObj,Par,Info,ObsV,i)
% Description:  
%    check whether targets are inside the camera's FoV
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

camData     =    Info.camData;

disp('FoV validation...')
for id=Par.ID
    Xest3d=         TrackObj{id}.Xest3d;
    XestImg=        TrackObj{id}.XestImg;
    
    ObsV{id}.FoV(i+1)=myFoV_sel(Xest3d,XestImg,i,camData.ImgSize,camData,Par.V.ws);  % define whether object is inside the camera's FoV
    
    if ObsV{id}.FoV(i+1)
       disp(['Speaker-',num2str(id),'   inside FoV!']) 
    else
       disp(['Speaker-',num2str(id),'   OUTSIDE FoV!'])
    end
end

end

%% 
function FoV=myFoV_sel(Xest3d,XestImg,i,ImgSize,camData,ws)

pct         =   0.1;

Ih(1)       =   ImgSize(1)*pct/2;               % image height range
Ih(2)       =   ImgSize(1)-ImgSize(1)*pct/2;
Iw(1)       =   ImgSize(2)*pct/2;               % image width range
Iw(2)       =   ImgSize(2)-ImgSize(2)*pct/2;    

if i>2                                          % previous target estimate:

    X3Dp    =   sum(Xest3d(i-2:i,:).*repmat(ws',[1,3]))';
    FoV     =   isInFrustum(X3Dp, camData, 0.5, ImgSize(2), ImgSize(1));
    
    if ~FoV
        return
    end
    XImg    =   XestImg(i,:)';              	
    FoV     =   (XImg(1)>=Iw(1)) & (XImg(1)<=Iw(2)) & (XImg(2)>=Ih(1)) & (XImg(2)<=Ih(2)); % estimated target inside FoV
    
else                                            % in the beginning frames
    
    FoV     =   isInFrustum(Xest3d(i,:)', camData, 0.5, ImgSize(2), ImgSize(1));
    
end

end