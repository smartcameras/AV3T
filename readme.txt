%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%           
% Please go through the readme.m and License.doc files before using the software.
%
% Requested citation acknowledgement when using this software:
% [1] X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This folder contains the MATLAB code of our proposed 'AV3T' tracker for multi-speaker tracking in 3D
% using the multi-modal signals captured by a small-size co-located audio-visual sensing platform.
%
%
% The evaluation is made on two datasets: 
%   (1) CAV3D  - collected and annotated by ourselves
%   (2) AV16.3 - 
%       G. Lathoud, J.-M. Odobez, and D. Gatica-Perez, “AV16.3:an audio-visual corpus for speaker localization and tracking,” in Machine Learning for Multimodal Interaction. Martigny, Switzerland: Springer, Jun 2004.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To execute the tracker, you need to
%   (1) download the CAV3D dataset:                 https://ict.fbk.eu/units/speechtek/cav3d/
%   (2) download our re-arranged AV16.3 dataset:    https://drive.google.com/drive/folders/1mRmQsQQvz3xICIKqtd8KvTr5Dl7n02Zh?usp=sharing 
%   (3) change the 'datapath' in 'test_main.m' to the data directory
%   (4) run 'test_main.m' 
%   In the 'test_main.m' file, you can change the parameters to specify 
%       (i)     the test dataset i.e. either AV16.3 or CAV3D and sequences
%       (ii)    tracking mode i.e. audio-visual audio-only or video-only
%       (iii) 	face detection removal index => to test the system robustness of the face detection inputs
%       (iv)  	the number of particle (per target), and the experiment iterations
%       (v)     visualization and saving flag
%
% 
% Note: 
% The camera projection MEX-files ('projectin/mex/*.mex') were compiled from C++ code,
% which are not compatible to different machines (especially if you have the linux environment). If you cannot execute
% the default '.mex' files, you need to compile them by yourself by running the code 'projection/mex/cpp2mex.m'
% Some attention points:
%   (1) make sure you have the right compiler: https://uk.mathworks.com/support/requirements/supported-compilers.html
%   (2) make sure you have installed OpenCV
%   (3) make sure you have installed the MATLAB Computer Vision System Toolbox and it's OpenCV Interface:
%   https://uk.mathworks.com/matlabcentral/fileexchange/47953-computer-vision-system-toolbox-opencv-interface
%   (you may follow compilation instructions in the enclosed video.)
% If you still have problems during the compilation, please ask for the MathWorks technical support, 
% probably by creating a service request here: https://uk.mathworks.com/support/contact_us.html
%
%
% The proposed 3D multi-speaker tracker can be adapted to any audio-visual sensing platforms
% as long as signals are synchronized and calibration parameters are available.
% To execute on a new audio-visual data, you need to 
%   (1) compute and update the synchronization information, camera calibration parameters and microphone position in 'readParas.m' 
%   (2) compute the face detection results, save the results, and update the filename in 'readParas/readfaceDetect.m' 
%       the face detector we used in [1] can be found in https://github.com/tornadomeet/mxnet-face
%	the detection bounding box should be saved in format: [#frame, #detection, topleft_x, topleft_y, bottomright_x, bottomright_y, probability, ...]
%   (3) compute the GCC-PHAT results, save the results, and update 'readParas/extractGCF3Dres.m'
% 
% For any questions, please contact x.qian@qmul.ac.uk
 



