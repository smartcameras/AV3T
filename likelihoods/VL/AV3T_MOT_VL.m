function [TrackObj,ObsV]=myMOT_VL(TrackObj,ObsV,Info,Par,GT,i)
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

disp('MOT-video likelihood')

if(Par.flag==1) % audio-only likelihood
    N=Par.PF.N;
    disp('Audio-only, No video likelihood computation!! Set V.height to GT')
    for id=Par.ID
        TrackObj{id}.wv.DH  =   ones(1,N)/N;
        TrackObj{id}.wv.D   =   ones(1,N)/N;
        TrackObj{id}.wv.H   =   ones(1,N)/N;
        ObsV{id}.Zp         =   GT.GT3d{id}(i,3); % set Video suggested height to GT
    end
    return
end


seq_name=   Info.seq_name;
camData=    Info.camData;

flag=       Par.flag;

Upstd=      Par.PF.Upstd;

Face3DSz=   Par.V.Face3DSz;
Vfr=        Par.V.Vfr;
fmt=        Par.V.fmt;

X_g=        Par.X_g;
Y_g=        Par.Y_g;



% check whether object is behind the other
objfrt      =   isVisible(TrackObj,ObsV,Info,Par.ID,i);


for id=Par.ID   % for each speaker identity
    disp(['VL computation: ID ',num2str(id)])
    
    X       =   TrackObj{id}.X;
    detni   =   ObsV{id}.detn(i);
    M3d     =   ObsV{id}.M3d;
    fd      =   ObsV{id}.fd;
    Zp      =   ObsV{id}.Zp;
    fbb     =   ObsV{id}.fbb;
    Xest3d  =   TrackObj{id}.Xest3d;
    RefImg  =   ObsV{id}.RefImg;
    Hr      =   ObsV{id}.Hr;
    fovi    =   ObsV{id}.FoV(i); % target inside FoV or not
    
    fovi    =   fovi*objfrt(id);  % also consider object infront of the other target, if overlapped
    
    [wvDH,Zp,fdstrDH,Vmap,Hmap,RefImg,Hr,wvD,wvH,fdstrD,fdstrH]=AV3T_VL(X,detni,M3d,fd,i,Zp,X_g,Y_g,Upstd,fbb,seq_name,...
        Vfr,Xest3d,Face3DSz,camData,RefImg,Hr,fovi,flag,fmt);
    
    
    TrackObj{id}.wv.DH= wvDH;
    TrackObj{id}.wv.D=  wvD;
    TrackObj{id}.wv.H=  wvH;
    
    ObsV{id}.RefImg=    RefImg;
    ObsV{id}.Vmap=      Vmap;
    ObsV{id}.Hmap=      Hmap;
    ObsV{id}.Hr=        Hr;
    ObsV{id}.Zp=        Zp;
    ObsV{id}.fdstr.DH=  fdstrDH;
    ObsV{id}.fdstr.D=   fdstrD;
    ObsV{id}.fdstr.H=   fdstrH;
    
end



end