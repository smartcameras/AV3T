% compute GCCphat results

clear all
close all
clc
dbstop if error
restoredefaultpath

MicType='all';
dataset='AV16.3';               
datapath=fullfile('..','..','..','Dataset');
AV3T_gccphat_compute(dataset,MicType,datapath);
