function angle=my_ADiff_correct(angle,unit)
% Description:
%   the difference between 2 angles should be smaller than pi
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
%   unit:   either 'rad' or 'deg'

if strcmp('rad',unit)   % in rad
    index           =   find(abs(angle)>pi);
    angle(index)    =   -sign(angle(index)).*(2*pi-abs(angle(index)));
else
    if strcmp('deg',unit)
        index       =   find(abs(angle)>180);
        angle(index)=   -sign(angle(index)).*(2*180-abs(angle(index)));
    else
        disp('Error: please specify the angle unit')
    end
end

end