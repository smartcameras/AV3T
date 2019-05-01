function AV3T_gccphat_compute(dataset,MicType,datapath)
% compute GCCPHAT and 3D SSL for tracking


datapath=fullfile(datapath,dataset);
addpath(genpath(datapath));

switch dataset
    case 'CAV3D'
        MA=0;
        SEQ=['seq22';'seq23';'seq24';'seq25';'seq26'];
        AVsyncInfo=dlmread(fullfile(datapath,'sync','CAV3D_AVsync_content.txt'));
        fv=     15;
        fa=     96000;
        nfft=   2^15;
    case 'AV16.3'
        MA=[1 2];
        SEQ='seq08-1p-0100';
        fv=     25;
        fa=     16000;
        nfft=   2^12;
%----------- you can add your own dataset information here---------
end


FrPoint=fa/fv;
ov_lap= 1-FrPoint/nfft;
win=    blackman(nfft);
c=      342;  % sound speed

for ma=MA
    
    Mic_pair=	AV3T_Mic_pair(MicType);
    
    load(['MA',num2str(ma),'_pos.mat']);  % the microphone array position
    Mic_pos=	Mic_pos';
    
    for sq=1:size(SEQ,1)
        seq_name=SEQ(sq,:);
        disp([dataset,'  ',seq_name])
        
        sav_name=[seq_name,'_GCFSSL_MA',num2str(ma),'_all_blkman.mat'];
        
        
        sav_dir=fullfile(datapath,seq_name);
        if(~exist(sav_dir,'dir'))
            mkdir(sav_dir)
            disp('creating directory...')
        end
        
        switch dataset % read audio data
            case 'AV16.3'
                s=[];
                for i=1:8  % av16.3
                    s(i,:)=audioread([seq_name,'_array',num2str(ma),'_mic',num2str(i),'.wav']); % individual audio channel
                end
            case 'CAV3D'
                [s,fa]=audioread(fullfile(datapath,seq_name,[seq_name,'_MA',num2str(ma),'.wav'])); % fbk
                st=AVsyncInfo(AVsyncInfo(:,1)==str2double(seq_name(4:5)),5);  % audio SSL start sec
                ed=AVsyncInfo(AVsyncInfo(:,1)==str2double(seq_name(4:5)),6);  % audio SSL end sec
                stFr=round(fa*st)-nfft/2;
                edFr=round(fa*ed)+nfft/2;
                s=s(stFr:edFr,:)';
                
% --- you can specify which audio segments you would like to compute the GCCphat --------
        end
        Results=GCCphat_results(s,c,fa,win,nfft,ov_lap,Mic_pos,Mic_pair);
        
        save(fullfile(sav_dir,[sav_name,'.mat']),'Results','-v7.3')
        
    end
end



end


function [Results,gccphat]=GCCphat_results(s,c,fa,win,nfft,ov_lap,Mic_pos,Mic_pair)

disp('GCCphat computing....')
Mic_N=          size(Mic_pos,1);

gccphat=cell(Mic_N);
m=1;
for i=1:Mic_N-1
    for j=i+1:Mic_N
        if(sum(Mic_pair(:,1)==i&Mic_pair(:,2)==j))
            disp([num2str(m),'/',num2str(length(Mic_pair))])
            d=norm(Mic_pos(i,:)-Mic_pos(j,:));
            gccphat{i,j}=AV3T_gccphat(d,c,ov_lap,nfft,win,s(i,:),s(j,:),fa);
            m=m+1;
        end
    end
end

Results.CM=gccphat;

end

function gccphat=AV3T_gccphat(d,c,ov_lap,nfft,win,s1,s2,fa)
% Input:
%     d: microphone distance
%     ov_lap: overlapping factor
%     nfft: length of processing window in samples / number of FFT points
%     input audio signal pairs: s1 and s2
%     c: sound speed
%     win: window function
%     fa: audio sampling frequency

wlen 	=   length(win);

%% ------Parameters--------------------------------------------------------
nlap    =   ov_lap*wlen;                           % number of overlapping points e.g.75% overlapping
Max_TD  =   round(d/c*fa);
N_TDOA  =   2*Max_TD+1;                          % total number of distinguished TDOA

%% -----Spectra calculation------------------------------------------------
[S1,~,~,~]  =   spectrogram(s1,win,nlap,nfft,fa,'twosided');
[S2,~,~,~]  =   spectrogram(s2,win,nlap,nfft,fa,'twosided');

%% ---- CSP based GCCphat-------------------------------------------------------
NCP         =   S1.*conj(S2)./(abs(S1).*abs(S2));           % normalized crosspower-spectrum
CM          =   ifft(NCP,nfft);                              % coherence measure for all delays
gccphat     =   zeros(N_TDOA,size(CM,2));               % GCCphat for feasible delays
gccphat(1:Max_TD,:)     =   CM(end-Max_TD+1:end,:);     % due to periodicity of FFT
gccphat(Max_TD+1:end,:) =   CM(1:Max_TD+1,:);

end


function Mic_pair=AV3T_Mic_pair(name)
% Input:
%   name='adjacent8'/'longest4'/'all'
%   M: total microphone number


switch name
    case 'wall'
        for m=1:3:21
            Mic_pair(m:m+2,:)=nchoosek(m:m+2,2);
        end
        
        
    case 'longest4'
        Mic_pair=zeros(4,2);
        Mic_pair(:,1)=1:4;
        Mic_pair(:,2)=5:8;
    case 'gap1'
        Mic_pair=zeros(8,2);
        Mic_pair(:,1)=1:8;
        Mic_pair(1:6,2)=3:8;
        Mic_pair(7:8,2)=1:2;
        
    case 'gap2'
        Mic_pair=zeros(8,2);
        Mic_pair(:,1)=1:8;
        Mic_pair(1:5,2)=4:8;
        Mic_pair(6:8,2)=1:3;
        
    case 'adjacent8'
        Mic_pair=zeros(8,2);
        Mic_pair(1:7,1)=1:7;
        Mic_pair(1:7,2)=2:8;
        Mic_pair(8,1)=1;
        Mic_pair(8,2)=8;
        
    case 'all'
        Mic_pair=zeros(28,2);
        i=1;
        
        for a=1:7
            for b=a+1:8
                Mic_pair(i,1)=a;
                Mic_pair(i,2)=b;
                i=i+1;
            end
        end
        
end

index=Mic_pair(:,1)>Mic_pair(:,2);
Micp2=Mic_pair(index,1);
Mic_pair(index,1)=Mic_pair(index,2);
Mic_pair(index,2)=Micp2;
end
