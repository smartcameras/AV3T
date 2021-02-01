function SavInfo=SavFile_info(Info,Par,R,V,savfig,savRst)
% Description:
%   saving file information
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

almode  =   Par.almode;
flag    =   Par.flag;

cam     =   Info.cam;
ma      =   Info.ma;
seq     =   Info.seq;
dataset =   Info.dataset;

disp('sav fig info')
if ~savRst && ~savfig                                                       % don't save results
    SavInfo.PF      =   [];
    SavInfo.Version =   [];
    SavInfo.dirRst  =   [];
    SavInfo.dirF    =   [];
    SavInfo.savfig  =   savfig;
    SavInfo.savRst  =   savRst;
    return
end

formatOut = 'yy.mm.dd';
DTstr=datestr(now,formatOut);
Version=['20',DTstr,'_R',num2str(R),'_V',num2str(V),'_',dataset];

switch flag
    case 1
        PF= 'APF';
        dirRst=fullfile('..','res', 'AV3T',dataset,Version,'APF');       % audio-only
    case 2
        PF= 'VPF';
        dirRst=fullfile('..','res', 'AV3T',dataset,Version,'VPF');       % video-only
    otherwise
        PF= 'AVPF';
        dirRst=fullfile('..','res', 'AV3T',dataset,Version,'AVPF');      % audio-visual
end

if ~exist(dirRst,'dir')
    mkdir(dirRst)
end


if savfig   % saving figures
    dirF=fullfile('..','res', dataset,Version,'figures',['seq',num2str(seq,'%02d')]);
    if ~exist(dirF,'dir')
        mkdir(dirF);
    end
    clear dir
else
    dirF=[];
end

SavInfo.Fname=[Info.seq_name,'_F',num2str(flag),'C',num2str(cam),'MA',num2str(ma),'_',Par.Kstr,'_',Par.Nstr];

SavInfo.PF      =   PF;
SavInfo.Version =   Version;
SavInfo.dirRst  =   dirRst;
SavInfo.dirF    =	dirF;
SavInfo.savfig  =   savfig;
SavInfo.savRst  =   savRst;
SavInfo.Kstr    =   Par.Kstr;


end

