function ID=ID4seq(dataset,seq)
% Description:
%   give default ID to sequences
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

disp('associate ID')

switch dataset
    case 'CAV3D'
        if seq<=21                  % SOT
            ID=1;
        else
            if seq<=24              % SOT-2
                ID=[1 2];
            else
                if seq<=26          % MOT
                    ID=[1 2 3];
                end
            end
        end

    case 'AV16.3'
        switch seq
            case {8,11,12}
                ID=1;
            case {18,19,24,25,30}
                ID=[1 2];
            otherwise
                disp('seq No not correct')
        end
        
        disp('finish ID association')
end