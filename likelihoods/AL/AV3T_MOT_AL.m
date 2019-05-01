function [TrackObj,ObsA]=myMOT_AL(TrackObj,ObsA,ObsV,Par,Info,i,p)
% Description:
%   MOT audio likelihood
%
% Date:     07/02/2019
% Author:   Alessio Xompero, Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

Mic_pos=    Info.Mic_pos;
savfig=     Info.Sav.savfig;

X_g=        Par.X_g;
Y_g=        Par.Y_g;
almode=     Par.almode;
flag=       Par.flag;

Upstd=      Par.PF.Upstd;


Afr=        Par.A.Afr;
Mic_pair=   Par.A.Mic_pair;
fa=         Par.A.fa;
c=          Par.A.c;


for id=Par.ID % for multiple speakers
    

    X=      TrackObj{id}.X;
    Zp=     ObsV{id}.Zp;
    CM=     ObsA{id}.CM;
    SSL=    ObsA{id}.SSL;
    AMvad=  Par.A.AMvad{id};
    
    [wa,AM,AMmax,Amap,vad,~,Za]=AV3T_AL(X,CM,Mic_pair,Mic_pos,c,fa,i,Afr,Zp,almode,p,X_g,Y_g,AMvad,flag,SSL,Upstd,savfig);
    
    TrackObj{id}.wa=    wa; 
    ObsA{id}.AM=        AM;
    ObsA{id}.AMmax=     AMmax;
    ObsA{id}.Amap=      Amap;
    ObsA{id}.vad(i)=    vad;
    ObsA{id}.Za=        Za;
    
end


end