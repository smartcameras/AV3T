function TrackObj=AV3T_MOT_resampling(TrackObj,Info,Par)
% Description:
%   particle resampling
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

disp('re-sampling...')

for id=Par.ID
    w               =   TrackObj{id}.w;
    Xw              =  	AV3T_Ptl_killRoomRg(TrackObj{id}.X,Info.Mic_c,Par.RoomRg,'cart');  % particles outside the room
    w(logical(~Xw)) =   0;                                                              % kill
    
    C               =   cumsum(w);                                                      % cumulative sum
    T               =   rand(1, Par.PF.N);                                              % generate 1 by N uniformly distributed random numbers between (0,1)
    [~, I]          =   histc(T, C);                                                    % histogram count
    
    TrackObj{id}.X  =   TrackObj{id}.X(:, I + 1);
    TrackObj{id}.w  =   w(I+1);
end

end