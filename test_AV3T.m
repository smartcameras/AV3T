% Description:
%   test the proposed AV3T tracker for multi-speaker tracking in 3D using
%   audio-visual signals on AV16.3 and CAV3D dataset, the available
%   sequences are:
%   (1) AV16.3- seq=8,11,12,18,19,24,25,30
%   (2) CAV3D-  seq=6-20(SOT),22-26(MOT)
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
%
% Please have a look at the 'readme.txt' and the software license file 'License.doc'
% By exercising any rights to the work provided here, you accept and agree to be bound by the terms of the license. 
% The licensor grants you the rights in consideration of your acceptance of such terms and conditions.

clear all
close all
clc

dbstop if error
restoredefaultpath

addToolbarExplorationButtons(gcf)

datapath=fullfile('..', '..','Dataset');                          % PLEASE SPECIFY THE DATAPATH!   

data=1;                                                 % please specify the dataset, 0 - AV16.3, 1 - CAV3D              
switch data
    case 1
        dataset='CAV3D';
        SEQs=6:26;  
        CAMs=5;
    case 0
        dataset='AV16.3';
        SEQs=[8,11,12,18,19,24,25,30];
        CAMs=1:3;
end
addpath(genpath(fullfile(datapath,dataset)));           % add dataset path

flag=0;     % 0 - audio-visual, 1 - audio-only, 2 - video-only
K=0;        % remove K percent of face detections
R=1;        % iteration
V=1;

p=0;        % visualization
savRst=0;   % save tracking results to file (in '../res/')
savfig=0;   % save last frame of the visualization

idx=0;
for seq=SEQs
    for cam=CAMs
        idx=idx+1;
        AV3T(dataset,seq,cam,flag,K,R,V,p,savfig,savRst);
    end
end


