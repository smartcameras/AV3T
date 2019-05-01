function [seq_name,camData]=AV163seq_ses(seq,dataset,cam)

% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'


switch dataset
    case 'AV16.3'
        
        switch seq
            case 8
                seq_name='seq08-1p-0100';   ses=10;
            case 11
                seq_name='seq11-1p-0100';   ses=9;
            case 12
                seq_name='seq12-1p-0100';   ses=10;
            case 18
                seq_name='seq18-2p-0101';   ses=10;
            case 19
                seq_name='seq19-2p-0101';   ses=9;
            case 24
                seq_name='seq24-2p-0111';   ses=10;
            case 25
                seq_name='seq25-2p-0111';   ses=10;
            case 30
                seq_name='seq30-2p-1101';   ses=11;
            otherwise
                disp('seq out of scope')
        end
        
        load(['session' num2str(ses,'%02d') '_shift.mat']);
        camData         = readCameraData(cam,shift);
        
    case 'CAV3D'
        
        seq_name=['seq', num2str(seq,'%02d')];
        
        if seq>21
            load(fullfile('C5MOT.mat')); % MOT calibration files
        else
            load(fullfile('C5SOT.mat')); % SOT calibration files
        end
        
end


end