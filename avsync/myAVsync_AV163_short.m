function [GTimg,GT3d,Afr,Vfr,FoV,Fr]=myAVsync_AV163_short(seq_name, cam, fv, nfft, fa,dataset,camData,ID)
% Description:
%   synchronise the audio and video sequences, and ground truth
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
%
% Please have a look at the 'readme.txt' and the software license file 'License.doc'
%
% Input:
%   seq_name:   -
%   cam:        camera index
%   fv:         video framerate (e.g. 25 fps)
%   nfft:       STFT window length
%   fa:         Audio sampling frequency (e.g. 16 kHz)
%   dataset:    CAV3D/AV16.3 dataset
%   camData:    camera calibration
%   ID:         speaker identity
%
% Output:
%   GTimg:      mouth ground truth on image plane
%   GT3d:       mouth ground truth in 3D
%   Vfr:        [start frame, end frame], # the frame range are set according to Kilic's work: V. Kılıç, M. Barnard, W. Wang, and J. Kittler, “Audio assisted robust visual tracking with adaptive particle filtering,” IEEE Trans. on Multimedia, vol. 17, no. 2, pp. 186–200, Feb 2015.
%   Afr:        [start frame, end frame]
%   FoV:        FoV ground truth
%   Fr:         total frame number


if(nargin<6)
    dataset='AV16.3';
    disp('Default dataset: AV16.3')
end

switch dataset
    case 'AV16.3'
        disp('AV16.3 dataset')
        
        Vfr         =   myFrameRangeToCompare(seq_name, cam);
        Fr          =   Vfr(2)-Vfr(1)+1;
        
        % Read all timecodes and convert the first in seconds (h:m:s.fr, fr is the frame rate)
        fileID      =   fopen(fullfile(seq_name,[seq_name,'_timings_cam',num2str(cam)]), 'r');
        timecodes   =   textscan(fileID,'%s %.2f %d');
        fclose(fileID);
        
        timecode1   =   timecodes{1,1}{1};
        vf1_time    =   timecode_to_sec(timecode1);
        
        % global video framerate
        af1_timestamp = 10;
        af1_time    =   af1_timestamp + (nfft/fa/2);
        Afr         =   round(Vfr+(vf1_time-af1_time)*fv);                                  % audio-visual synchronisation
        
        % load ground-truth data and synchronise
        for id=ID
            gtfilename=['/home/xinyuan/Documents/Code/Github_src/Kilic_TMM16/Core_files/Data/',['data_av_',seq_name(1:5),'_cam',num2str(cam),'.mat']];
            if exist(gtfilename,'file')
                load(gtfilename); % Kilic rst
                GTimg{id}=Data.posGT.(['person',num2str(id)])(Vfr(1):Vfr(2),2:3);
                FoV{id}=GTimg{id}(:,1)>0 & GTimg{id}(:,2)>0 & GTimg{id}(:,2)<=camData.ImgSize(1) & GTimg{id}(:,1)<=camData.ImgSize(2);
                
                gt3d=Data.MouthGT3D.(['person',num2str(id)]);
                [Tmin,gt3dst_index]=min(abs(gt3d(:,1)-(Vfr(1)-1)/fv-vf1_time)); % start index
                if Tmin>1/fv
                    disp('No GT3D in the beginning')
                end
                gt3ded_index=min(gt3dst_index+Afr(2)-Afr(1),length(gt3d));
                GT3d{id}=   gt3d(gt3dst_index:gt3ded_index,3:5);
                
                gtfrdiff=gt3dst_index+Afr(2)-Afr(1)-gt3ded_index; % pad the ground truth
                if gtfrdiff>0
                    GT3d{id}(size(GT3d{id},1)+1:size(GT3d{id},1)+gtfrdiff,:)=repmat(gt3d(gt3ded_index,3:5),[gtfrdiff 1]);
                    disp('pad the ground truth')
                end
                
            else
                %======================= Below are the Qian's TMM data ========================
                % image GT
                gt      =   load(fullfile(seq_name,[seq_name,'-cam',num2str(cam),'-person',num2str(id),'-interpolated-reprojected.mouthgt']));
                st      =   find(gt(:,1)==Vfr(1));                                           % start #line
                ed      =   find(gt(:,1)==Vfr(2));                                           % end # line
                GTimg{id}   =   gt(st:ed,4:5);
                FoV{id}     =   gt(st:ed,3);
                
                % 3D GT
                gt3d    =   load(fullfile(seq_name,[seq_name,'-person',num2str(id),'-interpolated.3dmouthgt']));
                [Tmin,gt3dst_index]=min(abs(gt3d(:,1)-(Vfr(1)-1)/fv-vf1_time)); % start index
                if Tmin>1/fv
                    aa=1;
                    disp('No GT3D in the beginning')
                end
                gt3ded_index=min(gt3dst_index+Afr(2)-Afr(1),length(gt3d));
                GT3d{id}=   gt3d(gt3dst_index:gt3ded_index,3:5);
                
                gtfrdiff=gt3dst_index+Afr(2)-Afr(1)-gt3ded_index; % pad the ground truth
                if gtfrdiff>0
                    GT3d{id}(size(GT3d{id},1)+1:size(GT3d{id},1)+gtfrdiff,:)=repmat(gt3d(gt3ded_index,3:5),[gtfrdiff 1]);
                    disp('pad the ground truth')
                end
            end
            
        end
        
    case 'CAV3D'
        disp('CAV3D dataset')
        
        AVsync      =   dlmread('CAV3D_AVsync_content.txt');
        row         =   find(AVsync(:,1)==str2double(seq_name(4:end)));
        Vfr         =   AVsync(row,2:3);
        Afr         =   [1 Vfr(2)-Vfr(1)+1];
        
        % truncate the middle part for tracking
        diff        =   AVsync(row,8:9)-Vfr;
        Afr         =   Afr+diff;
        Vfr         =   Vfr+diff;
        Fr          =   Vfr(2)-Vfr(1)+1;
        
        for id=ID
            GTfname=[seq_name,'_id',num2str(id),'.3dmouthgt'];
            if exist(GTfname,'file')                                                        % manual annotation
                gt3d        =   load(GTfname);
                GT3d{id}    =   gt3d(Vfr(1)+1:Vfr(end)+1,3:5);
                [GTimg{id},FoV{id}]=AV3T_project(GT3d{id}', camData);
                GTimg{id}   =   GTimg{id}';
                disp('GT use MANUAL annotation!')
            else
                disp('missing ground truth files!')
            end
            
        end
end

disp('Finish AV sync')

end


function Vfr=myFrameRangeToCompare(seq_name,cam)
% Calculate the framerange to make comparison with
% The test frame range is set according to the reference
% V. Kılıç, M. Barnard, W. Wang, and J. Kittler, “Audio assisted robust visual tracking with adaptive particle filtering,” IEEE Trans. Multimedia, vol. 17, no. 2, pp. 186–200, Feb. 2015.

switch seq_name
    case 'seq08-1p-0100'
        if cam==1
            Vfr=[35 500];
        elseif cam==2
            Vfr=[25 495];
        elseif cam==3
            Vfr=[25 515];
        end
    case 'seq11-1p-0100'
        if cam==1
            Vfr=[20 549];
        elseif cam==2
            Vfr=[11 544];
        elseif cam==3
            Vfr=[49 578];
        end
    case 'seq12-1p-0100'
        if cam==1
            Vfr=[90 1160];
        elseif cam==2
            Vfr=[123 1190];
        elseif cam==3
            Vfr=[80 1155];
        end
    case 'seq18-2p-0101'
        if cam==1
            Vfr=[43 1326];
        elseif cam==2
            Vfr=[56 1339];
        elseif cam==3
            Vfr=[18 1301];
        end
        
    case 'seq19-2p-0101'
        if cam==1
            Vfr=[1 474];
        elseif cam==2
            Vfr=[19 492];
        elseif cam==3
            Vfr=[31 504];
        end
        
    case 'seq24-2p-0111'
        if cam==1
            Vfr=[315 500];
        elseif cam==2
            Vfr=[315 528];
        elseif cam==3
            Vfr=[260 481];
        end
        
    case 'seq25-2p-0111'
        if cam==1
            Vfr=[125 225];
        elseif cam==2
            Vfr=[210 351];
        elseif cam==3
            Vfr=[80 270];
        end
        
    case 'seq30-2p-1101'
        if cam==1
            Vfr=[128 248];
        elseif cam==2
            Vfr=[90 195];
        elseif cam==3
            Vfr=[60 145];
        end
        
        
        
    case 'seq45-3p-1111'
        
%         if cam ==1  % original 
%             Vfr=[302 1101];
%         elseif cam ==2
%             Vfr=[360 1070];
%         elseif cam ==3
%             Vfr=[1 725];
%         end

        if cam ==1 % XQ added
            Vfr=[302 900];
        elseif cam ==2
            Vfr=[360 900];
        elseif cam ==3
            Vfr=[360 900];
        end
    otherwise
        disp('seq out of scope')
end



end



function t = timecode_to_sec( timecode, frame_rate )

if nargin < 1
    error( 'timecode_to_sec needs at least one parameter.' );
end

if nargin < 2
    frame_rate = 25;
end

[hour, rest] = strtok( timecode, ':' );
hour = str2num( hour );
[minute, rest] = strtok( rest, ':' );
minute = str2num( minute );
[second, rest] = strtok( rest, ':.');
second = str2num( second );
[frame, rest] = strtok( rest, ':.' );
frame = str2num( frame );

t = hour * 3600 + minute * 60 + second + frame / frame_rate;

end

