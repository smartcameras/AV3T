function [Info,Par,GT,Fr]=readParas(seq,dataset,cam,mpair,almode,flag,R,i0)
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'


disp(['Start Read parameters:    ',dataset,' dataset'])
ID      =ID4seq(dataset,seq);                                   % known speaker number

[seq_name,camData]=AV163seq_ses(seq,dataset,cam);

switch  dataset
    case 'CAV3D'
        ma      =   0;                                          % mic index
        cam     =   5;                                          % cam index
        fv      =   15;                                         % video frame rate
        nfft    =   2^15;                                       % STFT window length
        fa      =   96000;                                      % audio sampling frequency
        AMvad   =   {0.03,0.03,0.03};                           % VAD threshold
        fmt     =   {['cam' num2str(cam)],[],'%06d','.jpg'};    % image format
        Par.savFer3d    =   0.2;                                % when error is bigger than 0.3 m, save the frame
        
    case 'AV16.3'      
        ma      =   1;
        fv      =   25;
        nfft    =   2^12;
        fa      =   16000;
        AMvad   =   {0.1,0.1,0.1};
        fmt     =   {['C' num2str(cam)],'img','%04d','.png'};
        Par.savFer3d    =   0.1;
end

load([dataset,'_RoomRg.mat']);      % room range
load(['MA',num2str(ma),'_pos']);    % microphone position

T           =   load('table.txt');  % table position
Mic_pair    =   AV3T_Mic_pair(mpair);
Mic_pos     =   Mic_pos';
Mic_c       =   mean(Mic_pos);
c           =   342;

Face3DSz    =   [0.15 0.2];
wdg         =   1;                  % use diagonal of fbb or not
W           =   Face3DSz(1);        % 3D projection by width
Wdiag       =   0.25;               % 3D projection by diagonal size
Nbins       =   8;

% ground truth
disp('AV-sync...')
[GTimg, GT3d, Afr, Vfr,FoV,Fr] = AV3T_AVsync_AV163(seq_name,cam,fv,nfft,fa,dataset,camData,ID);
disp('Finish AV sync')

% PF paramters
N           =   100;                 % particle number per (target)
Pmtx        =   eye(3);             % prediction matrix
Prestd      =   [1;1;0.5]/fv;       % standard deviation in prediction
Upstd       =   [2;2;0.4];          % Video likelihood in Sph coordinates

if(flag==1&&almode==1)              % audio only and 2D GCF
    Prestd(3)=0;                    % standard deviation in prediction
    disp('Only do 2D GCF tracking')
end


%% parameter settings
Par.ID          =   ID;
Par.RoomRg      =   RoomRg;
Par.Fr          =   Fr;
Par.flag        =   flag;

Par.almode      =   almode;
Par.R           =   R;
Par.i0          =   i0;

Par.Nstr        =   ['N',num2str(N)];
Par.PF.Pmtx     =   Pmtx;
Par.PF.Prestd   =   Prestd;
Par.PF.Upstd    =   Upstd;
Par.PF.N        =   N;                          % particle number

Par.V.Face3DSz  =   Face3DSz;
Par.V.ImgSize   =   camData.ImgSize;
Par.V.wdg       =   wdg;                        % binary index, use diagonal size?
Par.V.W         =   W;
Par.V.Wdiag     =   Wdiag;
Par.V.Nbins     =   Nbins;
Par.V.cstr      =   {'red','cyan','blue'};      % color display

Par.V.Vfr       =   Vfr;
Par.V.fmt       =   fmt;
Par.V.fv        =   fv;
Par.V.ws        =   [0.2,0.3,0.5];              % smooth weights e.g. [0.2,0.3,0.5]

Par.A.Mic_pair  =   Mic_pair;
Par.A.fa        =   fa;
Par.A.nfft      =   nfft;
Par.A.Afr       =   Afr;
Par.A.AMvad     =   AMvad;
Par.A.c         =   c;
Par.A.MP        =   mpair;

Info.dataset    =   dataset;
Info.seq_name   =   seq_name;
Info.seq        =   seq;
Info.cam        =   cam;
Info.ma         =   ma;

Info.camData    =   camData;
Info.Mic_pos    =   Mic_pos;
Info.Mic_c      =   Mic_c;
Info.T          =   T;

GT.GTimg        =   GTimg;
GT.GT3d         =   GT3d;
GT.Afr          =   Afr;
GT.Vfr          =   Vfr;
GT.FoV          =   FoV;

disp('Finish reading parameters....')

end

