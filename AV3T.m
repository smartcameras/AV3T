function AV3T(dataset,seq,cam,flag,K,R,V,p,savfig,savrst)
% Description
%       multiple speakers tracking in 3D using audio-visual signals with parallel PFs
%   video:
%       (1) discriminative likelihood:  image-3D projection + Gaussian error model
%       (2) generative likelihood:      3D-image projection + spatiogram color histogram comparison
%   audio:
%       GCF compuation on video estimated speaker height plane (set almode=1)

% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
%
% Please have a look at the 'readme.txt' and the software license file 'License.doc'
% By exercising any rights to the work provided here, you accept and agree to be bound by the terms of the license.
% The licensor grants you the rights in consideration of your acceptance of such terms and conditions.
%
% Input:
%   dataset:    'AV16.3' or 'CAV3D'
%   seq:        sequence index
%   cam:        camera index
%   flag:       0 - audio-visual (AV), 1 - audio-only (AO), 2 - video-only (VO)
%   almode:     audio likelihood mode
%               1 - GCF at given Z plane
%               2 - 3D SSL rst
%   K:          randomly remove K percentage of face detections, 0<=K<=1
%   R:          tracking iteration
%   N:          number of particles (per target)
%   p:          display flag
%   savfig:     save last frame?
%   savrst:     save the tracking results to txt file?

almode=1;   % 1 - video-suggested audio likelihood (proposed), 2- 3D GCF likelihood

disp([dataset,' seq',num2str(seq),':  almode',num2str(almode),'  flag',num2str(flag)])


addpath(genpath(fullfile('..', 'AV3Tcode')));                                   % add source code path


%% initialise data
i0              =   1;                                                              % start frame
mpair           =   'all';                                                          % mic pair selection e.g. 'all' means using all possible mic pairs
[Info,Par,GT]   =   readParas(seq,dataset,cam,mpair,almode,flag,R,i0);
[Obs,Par]       =   visual_preprocessing(Info,Par,K,flag);                          % global visual information
Info.Sav        =   SavFile_info(Info,Par,R,V,savfig,savrst);
[ObsA,Par]      =   extractGCF3Dres(Info,Par);                                      % extract audio obs

PrtImg          =   [];
if p||savfig
    s = get(0, 'ScreenSize');
    PrtImg = figure('Position', [0 0 s(3) s(4)]);
end

%% PF framework
for iter=1:R
    
    disp('Initilisation.....')
    [TrackObj,ObsV,Er]  =   MOTinitialisation(GT,Info,Par,Obs);                     % initialisation
    
    if iter>1
        for id=Par.ID
            ObsA{id}=rmfield(ObsA{id},{'AM','AMmax','Amap','vad','Za'});
        end
    end
    
    tic
    for i=Par.i0:Par.Fr
        disp([Info.dataset,' ',Info.seq_name,': ',Obs.Kstr,'  cam',num2str(cam),'  ',num2str(i),'/',num2str(Par.Fr),...
            '  flag',num2str(flag),'  almode',num2str(almode)])
        
        ObsV            =   AV3T_MOT_greedy(TrackObj,Obs,ObsV,i,Par,Info);             % visual data association
        
        [TrackObj,ObsV] =   AV3T_MOT_VL(TrackObj,ObsV,Info,Par,GT,i);                  % video likelihood
        
        [TrackObj,ObsA] =   AV3T_MOT_AL(TrackObj,ObsA,ObsV,Par,Info,i,p);              % audio likelhood
        
        [TrackObj,Er]   =   AV3T_MOT_update(TrackObj,GT,Er,Info,i,i0,Par.ID);          % update
        
        AV3T_Visualisation(TrackObj,ObsA,ObsV,Obs,GT,Er,Info,Par,i,p,PrtImg,iter);     % display the results
        visualisation_2IDsimple(TrackObj,ObsA,ObsV,Obs,GT,Er,Info,Par,i,p,PrtImg,iter);  % multiple speaker
        
        TrackObj        =   AV3T_MOT_resampling(TrackObj,Info,Par);                    % resampling
        
        ObsV            =   AV3T_MOT_FoV(TrackObj,Par,Info,ObsV,i);                    % FoV justification
        
        TrackObj        =   AV3T_MOT_prediction(TrackObj,Par,ObsV{1}.FoV(i),GT,i);     % perdiction
        
        
        for id=Par.ID
            disp(['R',num2str(iter),'  Flag',num2str(flag),'  SpeakerID-',num2str(id),...
                '  AL=',num2str(TrackObj{id}.wa(1)),'    VL=',num2str(TrackObj{id}.wv.DH(1)),'(',ObsV{id}.fdstr.DH,')    AVL=',num2str(TrackObj{id}.w(1)),...
                '     mae=',num2str(Er{id}.er(i),'%.3f'),'  MAE3d=',num2str(Er{id}.mae(i),'%.3f')])
        end
        
    end    
    
    
    for id=Par.ID
        disp(['Finish -R',num2str(iter),'  Flag',num2str(flag),'  SpeakerID-',num2str(id),...
            '     mae=',num2str(Er{id}.er(i),'%.3f'),'  MAE3d=',num2str(Er{id}.mae(i),'%.3f')])
    end
  
end


close all
end