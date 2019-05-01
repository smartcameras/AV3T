function camData=readCameraData(cam,shift)
% Description:
%   structure the camera data
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

[K,kc,alpha_c]      = readradfile(['cam' num2str(cam) '.rad']);
load(['P',num2str(cam)]);
load(['cam',num2str(cam),'pos']);
align_mat           = dlmread('align010203.mat');

camData.Align   =   align_mat;
camData.Pmat    =   P;
camData.K       =   K;
camData.kc      =   kc;
camData.alpha_c =   alpha_c;
camData.shift   =   [shift.cam( cam ).delta_x shift.cam( cam ).delta_y]';
camData.Cam_pos =   Cam_pos;
camData.T       =   inv(K)*P;
camData.dataset =   'AV16.3';
camData.RT      =   inv(camData.K)*camData.Pmat;
camData.ImgSize =   [288 360];

end



function [K,kc,alpha_c] = readradfile(name)
% readradfiles    reads the BlueC *.rad files
%
% *.rad files contain paprameters of the radial distortion
% [K,kc,alpha_c] = readradfiles(name)
% name ... name of the *.rad file with its full path
%
% K ... 3x3 calibration matrix
% kc ... 4x1 vector of distortion parameters
% alpha_c ... scalar value: skew distortion parameter
%
% $Id: readradfile.m,v 2.0 2003/06/19 12:07:16 svoboda Exp $

fid = fopen(name,'r');
if fid<0
    error(sprintf('Could not open %s. Missing rad files?',name'))
end

for i=1:3
    for j=1:3
        buff = fgetl(fid);
        K(i,j) = str2num(buff(7:end));
    end
end

buff = fgetl(fid);
for i=1:4
    buff = fgetl(fid);
    kc(i) = str2num(buff(7:end));
end

buff = fgetl(fid);
buff = fgetl(fid);
if ischar( buff )
    alpha_c = str2num(buff(11:end));
else
    alpha_c = 0;
end

fclose(fid);

return

end