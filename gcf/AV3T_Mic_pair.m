function Mic_pair=my_Mic_pair(name)
% Description:
%   Extract microphone pair combinations
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
%   name:       'adjacent8'/'longest4'/'gap1'/'gap2'/'all'
% Output:
%   Mic_pair:   microphone pair index

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
    
    index               =   Mic_pair(:,1)>Mic_pair(:,2);
    Micp2               =   Mic_pair(index,1);
    Mic_pair(index,1)   =   Mic_pair(index,2);
    Mic_pair(index,2)   =   Micp2;
end




