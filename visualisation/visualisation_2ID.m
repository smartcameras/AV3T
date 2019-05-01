function visualisation_2ID(TrackObj,ObsA,ObsV,Obs,GT,Er,Info,Par,i,p,PrtImg,iter)
% visualise the tracking rst for multiple speakers case
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.

savfig=     Info.Sav.savfig;
Fr=         Par.Fr;

if p || (savfig && i==Fr) 
else
    return                                                                          % visualisation: not riggered
end

% extact information
seq_name=   Info.seq_name;
Mic_pos=    Info.Mic_pos;
T=          Info.T;
dirF=       Info.Sav.dirF;

ID=         Par.ID;
RoomRg=     Par.RoomRg;
X_g=        Par.X_g;
Y_g=        Par.Y_g;

flag=       Par.flag;
N=          Par.PF.N;
Vfr=        Par.V.Vfr;
fmt=        Par.V.fmt;
cstr=       Par.V.cstr;

GTimg=      GT.GTimg;
GT3d=       GT.GT3d;

DetNi=      Obs.DetN(i);

%% image plane

Y_k = imread(fullfile(seq_name,fmt{1}, [fmt{2} num2str(i+Vfr(1)-1,fmt{3}) fmt{4}]));

if p
    set(0,'CurrentFigure',PrtImg)                                                   % avoid figure steal focus
else
    set(0,'CurrentFigure',PrtImg,'DefaultFigureVisible', 'off')
end
clf

subplot(2,3,1)
for id=ID
    if ObsV{id}.fd(i)
        fdn=round(sum(ObsV{id}.fbb(i,:)>0)/4);                                      % face detection number
        face=reshape(ObsV{id}.fbb(i,1:4*fdn),[4 fdn])';                             % face bounding box for current frame
        Y_k=insertObjectAnnotation(Y_k,'rectangle',face,'face','Color',cstr{id});
    end
end
imshow(Y_k)
hold on
for id=ID
    Mimg=ObsV{id}.Mimg(i,:);                                                        % mouth estimate
    XestImg=TrackObj{id}.XestImg(i,:);
    if(flag~=2)&&(ObsV{id}.fd(i))                                                   % face detection
        plot(Mimg(1:2:end),Mimg(2:2:end),[cstr{id},'.'],'LineWidth',2,'MarkerSize',5)
    end
    
    if isInFrustum(TrackObj{id}.Xest3d(i,:)', Info.camData, 0.5, Par.V.ImgSize(2), Par.V.ImgSize(1))    % estimate inside FoV
        plot(XestImg(1),XestImg(2),[cstr{id},'+'],'LineWidth',2,'MarkerSize',10)
    end
    
    if isInFrustum(GT3d{id}(i,:)', Info.camData, 0.5, Par.V.ImgSize(2), Par.V.ImgSize(1))               % GT inside FoV
        plot(GTimg{id}(i,1),GTimg{id}(i,2),'g+','LineWidth',2,'MarkerSize',5)
    end
    
end
title([seq_name,' (',num2str(i),'/',num2str(Fr),') ',num2str(DetNi),'dets ',[ObsV{1}.fdstr.H,' ',ObsV{2}.fdstr.H]])


% reference image
switch length(ID)
    case 2
        subplot(4,12,5)                                 % 1st ref image
        imshow(ObsV{1}.Hmap{1})
        title([ObsV{1}.fdstr.D,' ',ObsV{1}.fdstr.H])
        
        subplot(4,12,17)                                % 2nd
        imshow(ObsV{2}.Hmap{1})
        title([ObsV{2}.fdstr.D,' ',ObsV{2}.fdstr.H])
    case 3
        subplot(6,12,5)                                 % 1st
        imshow(ObsV{1}.Hmap{1})
        title([ObsV{1}.fdstr.D,' ',ObsV{1}.fdstr.H])
        
        subplot(6,12,17)                                % 2nd
        imshow(ObsV{2}.Hmap{1})
        title([ObsV{2}.fdstr.D,' ',ObsV{2}.fdstr.H])
        
        subplot(6,12,29)                                % 3rd
        imshow(ObsV{3}.Hmap{1})
        title([ObsV{3}.fdstr.D,' ',ObsV{3}.fdstr.H])
end

subplot(4,12,6)                                         % 1st
imshow(ObsV{1}.Hmap{2})

subplot(4,12,18)                                        % 2nd
imshow(ObsV{2}.Hmap{2})


%% 1st speaker: partilce weights
% --------------------- audio weights -------------------------------------
subplot(4,6,4)
plot(1:N,TrackObj{1}.wa,'m.-')
xlim([1 N])
ylim([min(0,min(TrackObj{1}.wa)) max(TrackObj{1}.wa)*1.1])
grid on
title(['\omega_{a}: max=',num2str(max(TrackObj{1}.wa),'%.3f')])

% -------------------- video weights --------------------------------------
subplot(4,6,5)
hold on
plot(1:N,TrackObj{1}.wv.D,'y.-')                                                        % weights from discriminative model
plot(1:N,TrackObj{1}.wv.H(1:N),'b:')                                                    % weights from generative model
plot(1:N,TrackObj{1}.wv.DH(1:N),'b.-')
plot(1:N,TrackObj{1}.wv.H(N+1:2*N),'b--')
xlim([1 N])
if sum(~isnan(TrackObj{id}.wv.DH))
    ylim([min(0,min(TrackObj{id}.wv.DH)) max(TrackObj{id}.wv.DH)*1.1])
else
    ylim([0 1])
end
grid on
title('\omega_{D} & \omega_{H} ')

% ------------------ audio-visual weights ---------------------------------
subplot(4,6,6)
plot(1:N,TrackObj{1}.w,[cstr{1},'.-'])
xlim([1 N])
grid on
title(['\omega: max=',num2str(max(TrackObj{1}.w),'%.3f')])


%% 1st speaker: likelihood map
% -----------------1st speaker: acoustic likelihood map -------------------------------
subplot(4,6,10)
imagesc(X_g,Y_g,ObsA{1}.Amap)
hold on
plot(GT3d{1}(i,1),GT3d{1}(i,2),'g*','LineWidth',2,'MarkerSize',5)
plot(Mic_pos(:,1),Mic_pos(:,2),'bo-')                                                   % microphone position
plot(T(:,1),T(:,2),'-k');
colorbar
set(gca,'Xdir','reverse')
daspect([1 1 1])
title({['Amap^1 H=',num2str(ObsA{1}.Za,'%.02f'),' m']})
ylabel('Y (m)')

% -----------------1st speaker: visual likelihood map ---------------------------------
subplot(4,6,11)
imagesc(X_g,Y_g,ObsV{1}.Vmap)
hold on
plot(GT3d{1}(i,1),GT3d{1}(i,2),'g*','LineWidth',2,'MarkerSize',5)
plot(Mic_pos(:,1),Mic_pos(:,2),'bo-')                                                   % microphone position
plot(T(:,1),T(:,2),'-k');
set(gca,'Xdir','reverse')
daspect([1 1 1])
title(['Vmap^1',ObsV{1}.fdstr.DH])

% ----------------1st speaker: audio-visual likelihood map ----------------------------
subplot(4,6,12)
AVmap=ObsA{1}.Amap.*ObsV{1}.Vmap;
imagesc(X_g,Y_g,AVmap)
hold on
plot(TrackObj{1}.X(1,:),TrackObj{1}.X(2,:),'k.')
plot(GT3d{1}(1:i,1),GT3d{1}(1:i,2),'g-')
plot(GT3d{1}(i,1),GT3d{1}(i,2),'g*','LineWidth',2,'MarkerSize',5)
plot(TrackObj{1}.Xest3d(1:i,1),TrackObj{1}.Xest3d(1:i,2),[cstr{1},'-'])
for id=ID
    plot(TrackObj{id}.Xest3d(i,1),TrackObj{id}.Xest3d(i,2),[cstr{id},'+'],'LineWidth',1,'MarkerSize',10)
end
plot(T(:,1),T(:,2),'-k');
set(gca,'Xdir','reverse')
daspect([1 1 1])
title('AVmap^1')

%% 2nd speaker: partilce weights
% --------------------- audio weights -------------------------------------
subplot(4,6,16)
plot(1:N,TrackObj{2}.wa,'m.-')
xlim([1 N])
ylim([min(0,min(TrackObj{2}.wa)) max(TrackObj{2}.wa)*1.1])
grid on
title(['\omega_{a}: max=',num2str(max(TrackObj{2}.wa),'%.3f')])

% -------------------- video weights --------------------------------------
subplot(4,6,17)
hold on
plot(1:N,TrackObj{2}.wv.D,'y.-')
plot(1:N,TrackObj{2}.wv.H(1:N),'b:')
plot(1:N,TrackObj{2}.wv.DH(1:N),'b.-')
plot(1:N,TrackObj{2}.wv.H(N+1:2*N),'b--')
xlim([1 N])

if sum(~isnan(TrackObj{id}.wv.DH))
    ylim([min(0,min(TrackObj{id}.wv.DH)) max(TrackObj{id}.wv.DH)*1.1])
else
    ylim([0 1])
end
grid on
title('\omega_{D} & \omega_{H} ')

% ------------------ audio-visual weights ---------------------------------
subplot(4,6,18)
plot(1:N,TrackObj{2}.w,[cstr{2},'.-'])
xlim([1 N])
grid on
title(['\omega: max=',num2str(max(TrackObj{2}.w),'%.3f')])

%% 2nd speaker: likelihood map
% -----------------2nd speaker: acoustic likelihood map -------------------------------
subplot(4,6,22)
imagesc(X_g,Y_g,ObsA{2}.Amap)
hold on
plot(GT3d{2}(i,1),GT3d{2}(i,2),'g*','LineWidth',2,'MarkerSize',5)
plot(Mic_pos(:,1),Mic_pos(:,2),'bo-')
plot(T(:,1),T(:,2),'-k');
colorbar
set(gca,'Xdir','reverse')
daspect([1 1 1])
title({['Amap^2 H=',num2str(ObsA{2}.Za,'%.02f'),' m']})
ylabel('Y (m)')

% -----------------2nd speaker: visual likelihood map ---------------------------------
subplot(4,6,23)
imagesc(X_g,Y_g,ObsV{2}.Vmap)
hold on
plot(GT3d{2}(i,1),GT3d{2}(i,2),'g*','LineWidth',2,'MarkerSize',5)
plot(Mic_pos(:,1),Mic_pos(:,2),'bo-')
plot(T(:,1),T(:,2),'-k');
set(gca,'Xdir','reverse')
daspect([1 1 1])
title(['Vmap^2',ObsV{2}.fdstr.DH])

% ----------------2nd speaker: audio-visual likelihood map ----------------------------
subplot(4,6,24)
AVmap=ObsA{2}.Amap.*ObsV{2}.Vmap;
imagesc(X_g,Y_g,AVmap)
hold on
plot(T(:,1),T(:,2),'-k');
plot(TrackObj{2}.X(1,:),TrackObj{2}.X(2,:),'k.')
plot(GT3d{2}(1:i,1),GT3d{2}(1:i,2),'g-')
plot(GT3d{2}(i,1),GT3d{2}(i,2),'g*','LineWidth',2,'MarkerSize',5)
plot(TrackObj{2}.Xest3d(1:i,1),TrackObj{2}.Xest3d(1:i,2),[cstr{2},'-'])
for id=ID
    plot(TrackObj{id}.Xest3d(i,1),TrackObj{id}.Xest3d(i,2),[cstr{id},'+'],'LineWidth',1,'MarkerSize',10)
end
set(gca,'Xdir','reverse')
daspect([1 1 1])
title('AVmap^2')

%% XYZ position and Error in 3D

if length(ID)<3 % only 2 speaker
    subplot(4,4,9) % X
    hold on
    grid on
    for id=ID
        plot(1:i,GT3d{id}(1:i,1),'g.-')
        plot(1:i,TrackObj{id}.Xest3d(1:i,1),[cstr{id},'.-'],'LineWidth',1)
        Xer(id)=TrackObj{id}.Xest3d(i,1)-GT3d{id}(i,1);
    end
    title(['X error (t)=',num2str(Xer(1),'%.02f'),' ',num2str(Xer(2),'%.02f')])
    ylabel('X position')
    ylim(RoomRg(1,:))
    xlim([1 Fr])
    
    subplot(4,4,10) % Y
    hold on
    grid on
    for id=ID
        
        plot(1:i,GT3d{id}(1:i,2),'g.-')
        plot(1:i,TrackObj{id}.Xest3d(1:i,2),[cstr{id},'.-'])
        Yer(id)=TrackObj{id}.Xest3d(i,2)-GT3d{id}(i,2);
    end
    title(['Y error (t)=',num2str(Yer(1),'%.02f'),' ',num2str(Yer(2),'%.02f')])
    ylabel('Y position')
    ylim(RoomRg(2,:))
    xlim([1 Fr])
    
    subplot(4,4,13)
    hold on
    grid on
    for id=ID
        plot(1:i,GT3d{id}(1:i,3),'g.-')
        plot(1:i,TrackObj{id}.Xest3d(1:i,3),[cstr{id},'.-'])
        Zer(id)=TrackObj{id}.Xest3d(i,3)-GT3d{id}(i,3);
    end
    title(['Z error (t)=',num2str(Zer(1),'%.02f'),' ',num2str(Zer(2),'%.02f')])
    ylabel('Z position')
    ylim(RoomRg(3,:))
    xlim([1 Fr])
    
    subplot(4,4,14)
    hold on
    grid on
    for id=ID
        plot(1:i,Er{id}.er(1:i),[cstr{id},'-'])
        plot(1:i,Er{id}.mae(1:i),[cstr{id},'.-'])
    end
    legend('error','MAE')
    xlabel('frames')
    ylabel('overall error')
    title(['er_{3D} (t)=',num2str(Er{1}.er(i),'%.02f'),' ',num2str(Er{2}.er(i),'%.02f'),...
        '  MAE_{3D}=',num2str(Er{1}.mae(i),'%.02f'),' ',num2str(Er{2}.mae(i),'%.02f'),])
    ylim([0 2])
    xlim([1 Fr])
    
else % display the 3rd speaker information
    
    subplot(4,6,13) % A weights
    plot(1:N,TrackObj{3}.wa,'m.-')
    xlim([1 N])
    ylim([min(0,min(TrackObj{3}.wa)) max(TrackObj{3}.wa)*1.1])
    grid on
    title(['\omega_{a}: max=',num2str(max(TrackObj{3}.wa),'%.3f')])
    
    subplot(4,6,14) % V weights
    hold on
    plot(1:N,TrackObj{3}.wv.D,'y.-')
    plot(1:N,TrackObj{3}.wv.H(1:N),'b:')
    plot(1:N,TrackObj{3}.wv.DH(1:N),'b.-')
    plot(1:N,TrackObj{3}.wv.H(N+1:2*N),'b--')
    xlim([1 N])
    if sum(~isnan(TrackObj{id}.wv.DH))
        ylim([min(0,min(TrackObj{id}.wv.DH)) max(TrackObj{id}.wv.DH)*1.1])
    else
        ylim([0 1])
    end
    grid on
    title('\omega_{D} & \omega_{H} ')
    
    subplot(4,6,15)  % AV
    plot(1:N,TrackObj{3}.w,[cstr{3},'.-'])
    xlim([1 N])
    grid on
    title(['\omega: max=',num2str(max(TrackObj{3}.w),'%.3f')])
    
    subplot(4,6,19) % Amap
    imagesc(X_g,Y_g,ObsA{3}.Amap)
    hold on
    plot(GT3d{3}(i,1),GT3d{3}(i,2),'g*','LineWidth',2,'MarkerSize',5)
    plot(Mic_pos(:,1),Mic_pos(:,2),'bo-')  % microphone position
    plot(T(:,1),T(:,2),'-k');
    set(gca,'Xdir','reverse')
    colorbar
    daspect([1 1 1])
    title({['Amap^2 H=',num2str(ObsA{3}.Za,'%.02f'),' m']})
    ylabel('Y (m)')
    
    subplot(4,6,20) % Vmap
    imagesc(X_g,Y_g,ObsV{3}.Vmap)
    hold on
    plot(GT3d{3}(i,1),GT3d{3}(i,2),'g*','LineWidth',2,'MarkerSize',5)
    plot(Mic_pos(:,1),Mic_pos(:,2),'bo-')  % microphone position
    plot(T(:,1),T(:,2),'-k');
    set(gca,'Xdir','reverse')
    daspect([1 1 1])
    title(['Vmap^2',ObsV{3}.fdstr.DH])
    
    
    subplot(4,6,21) % AVmap
    AVmap=ObsA{3}.Amap.*ObsV{3}.Vmap;
    imagesc(X_g,Y_g,AVmap)
    hold on
    plot(T(:,1),T(:,2),'-k');
    plot(TrackObj{3}.X(1,:),TrackObj{3}.X(2,:),'k.')
    plot(GT3d{3}(1:i,1),GT3d{3}(1:i,2),'g-')
    plot(GT3d{3}(i,1),GT3d{3}(i,2),'g*','LineWidth',2,'MarkerSize',5)
    plot(TrackObj{3}.Xest3d(1:i,1),TrackObj{3}.Xest3d(1:i,2),[cstr{3},'-'])
    for id=ID
        plot(TrackObj{id}.Xest3d(i,1),TrackObj{id}.Xest3d(i,2),[cstr{id},'+'],'LineWidth',1,'MarkerSize',10)
    end
    set(gca,'Xdir','reverse')
    daspect([1 1 1])
    title('AVmap^2')
end

pause(0.01)

if (savfig && i==Fr) 
    saveas(gcf,fullfile(dirF,[Info.Sav.Fname,'_fr',num2str(i,'%04d'),Par.Kstr,'_R',num2str(iter),'.png']))
end


end