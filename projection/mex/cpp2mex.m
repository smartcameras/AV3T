% Description:
%   compile the C++ camera projection code to MEX-file with MATLAB
%   To execute this file, you should first download:
%   https://uk.mathworks.com/matlabcentral/fileexchange/47953 and follow
%   the instructions.
% Date: 05/02/19
% Author: Xinyuan Qian 

clear all
close all
clc


mexOpenCV backProjectPoints.cpp

mexOpenCV safeProjectPointsSOT.cpp

mexOpenCV safeProjectPointsMOT.cpp
