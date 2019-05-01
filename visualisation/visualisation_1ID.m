function visualisation_1ID(TrackObj,ObsA,ObsV,Obs,GT,Er,Info,Par,i,p,PrtImg,iter)
% visualise the tracking rst
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.

savfig=     Info.Sav.savfig;
Fr=         Par.Fr;

if p || (savfig && i==Fr)
else
    return                                      % visualisation: not riggered
end

% extact information,
seq_name=   Info.seq_name;
Mic_pos=    Info.Mic_pos;
T=          Info.T;
dirF=       Info.Sav.dirF;

id=         Par.ID;
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

Y_k = imread(fullfile(seq_name,fmt{1}, [fmt{2} num2str(i+Vfr(1)-1,fmt{3}) fmt{4}]));

%% image plane
if p
    set(0,'CurrentFigure',PrtImg)                                                       % avoid figure steal focus
else
    set(0,'CurrentFigure',PrtImg,'DefaultFigureVisible', 'off')
end
clf

subplot(2,3,1)
if ObsV{id}.fd(i)                                                                       % face detection
    Mimg=ObsV{id}.Mimg(i,:);                                                            % mouth extraction
    fdn=round(sum(ObsV{id}.fbb(i,:)>0)/4);
    face=reshape(ObsV{id}.fbb(i,1:4*fdn),[4 fdn])';                                     % face bounding box for current frame
    Y_k=insertObjectAnnotation(Y_k,'rectangle',face,'face','Color',cstr{id});           % image with face detection
end
imshow(Y_k)
hold on
XestImg=TrackObj{id}.XestImg(i,:);
if flag~=1 && ObsV{id}.fd(i)                                                            % face detection
    plot(Mimg(1:2:end),Mimg(2:2:end),[cstr{id},'.'],'LineWidth',2,'MarkerSize',5)       % mouth extraction
end
plot(XestImg(1),XestImg(2),[cstr{id},'+'],'LineWidth',2,'MarkerSize',10)                % mouth image location estimate
plot(GTimg{id}(i,1),GTimg{id}(i,2),'g+','LineWidth',2,'MarkerSize',5)                   % mouth image location ground truth
title([seq_name,' (',num2str(i),'/',num2str(Fr),') ',num2str(DetNi),'dets ',ObsV{id}.fdstr.H])


%% reference image
subplot(4,6,3)                                                                          % 1st, face
imshow(ObsV{id}.Hmap{1})
title([ObsV{id}.fdstr.D,' ',ObsV{id}.fdstr.H])

subplot(4,6,9)                                                                          % 1st, multibody part
imshow(ObsV{id}.Hmap{2})
title([ObsV{id}.fdstr.D,' ',ObsV{id}.fdstr.H])



%% partilce weights
% --------------------- audio weights -------------------------------------
subplot(6,6,19)
plot(1:N,TrackObj{id}.wa,'m.-')
xlim([1 N])
ylim([min(0,min(TrackObj{id}.wa)) max(TrackObj{id}.wa)*1.1])
grid on
title(['\omega_{a}: max=',num2str(max(TrackObj{id}.wa),'%.3f')])

% -------------------- video weights --------------------------------------
subplot(6,6,20)
hold on
plot(1:N,TrackObj{id}.wv.D,'y.-')                                                       % weights from discriminative model
plot(1:N,TrackObj{id}.wv.H(1:N),'b:')                                                   % weights from generative model
plot(1:N,TrackObj{id}.wv.DH(1:N),'b.-')

plot(1:N,TrackObj{id}.wv.H(N+1:2*N),'b--')
xlim([1 N])

if sum(~isnan(TrackObj{id}.wv.DH))
    ylim([min(0,min(TrackObj{id}.wv.DH)) max(TrackObj{id}.wv.DH)*1.1])
else
    ylim([0 1])
end

grid on
title('\omega_{D} & \omega_{H} ')

% ------------------ audio-visual weights ---------------------------------
subplot(6,6,21)
plot(1:N,TrackObj{id}.w,[cstr{id},'.-'])
xlim([1 N])
grid on
title(['\omega: max=',num2str(max(TrackObj{id}.w),'%.3f')])

%% likelihood map
% ----------------- acoustic likelihood map -------------------------------
subplot(3,6,13)
imagesc(X_g,Y_g,ObsA{id}.Amap)
hold on
plot(GT3d{id}(i,1),GT3d{id}(i,2),'g*','LineWidth',2,'MarkerSize',5)                     % mouth 3D ground truth
plot(Mic_pos(:,1),Mic_pos(:,2),'bo-')                                                   % microphone position
plot(T(:,1),T(:,2),'-k');                                                               % table location
set(gca,'Xdir','reverse')
daspect([1 1 1])
title({['Amap^1 H=',num2str(ObsA{id}.Za),' m']})
ylabel('Y (m)')

% ----------------- visual likelihood map ---------------------------------
subplot(3,6,14)
imagesc(X_g,Y_g,ObsV{id}.Vmap)
hold on
plot(GT3d{id}(i,1),GT3d{id}(i,2),'g*','LineWidth',2,'MarkerSize',5)                     % mouth 3D ground truth
plot(Mic_pos(:,1),Mic_pos(:,2),'bo-')                                                   % microphone position
plot(T(:,1),T(:,2),'-k');
set(gca,'Xdir','reverse')
daspect([1 1 1])
title(['Vmap^1',ObsV{id}.fdstr.DH])

% ---------------- audio-visual likelihood map ----------------------------
subplot(3,6,15)
AVmap=ObsA{id}.Amap.*ObsV{id}.Vmap;
imagesc(X_g,Y_g,AVmap)
hold on
plot(TrackObj{id}.X(1,:),TrackObj{id}.X(2,:),'k.')
plot(GT3d{id}(1:i,1),GT3d{1}(1:i,2),'g-')
plot(GT3d{id}(i,1),GT3d{1}(i,2),'g*','LineWidth',2,'MarkerSize',5)
plot(TrackObj{id}.Xest3d(1:i,1),TrackObj{id}.Xest3d(1:i,2),[cstr{id},'-'])
plot(TrackObj{id}.Xest3d(i,1),TrackObj{id}.Xest3d(i,2),[cstr{id},'+'],'LineWidth',2,'MarkerSize',10)
set(gca,'Xdir','reverse')
daspect([1 1 1])
title('AVmap^1')

%% XYZ position vs. GT comparison, and overall Error in 3D
subplot(4,2,2)  % X
hold on
grid on
plot(1:i,TrackObj{id}.Xest3d(1:i,1),[cstr{id},'.-'])
plot(1:i,GT3d{id}(1:i,1),'g.-')
Xer(id)=TrackObj{id}.Xest3d(i,1)-GT3d{id}(i,1);                                         % error in X
title(['X error (t)=',num2str(Xer,'%.02f')])
ylabel('X position')
ylim(RoomRg(1,:))
xlim([1 Fr])

subplot(4,2,4) % Y
hold on
grid on
plot(1:i,TrackObj{id}.Xest3d(1:i,2),[cstr{id},'.-'])
plot(1:i,GT3d{id}(1:i,2),'g.-')
Yer(id)=TrackObj{id}.Xest3d(i,2)-GT3d{id}(i,2);                                         % error in Y
title(['Y error (t)=',num2str(Yer,'%.02f')])
ylabel('Y position')
ylim(RoomRg(2,:))
xlim([1 Fr])

subplot(4,2,6) % Z
hold on
grid on
plot(1:i,TrackObj{id}.Xest3d(1:i,3),[cstr{id},'.-'])
plot(1:i,GT3d{id}(1:i,3),'g.-')
Zer(id)=TrackObj{id}.Xest3d(i,3)-GT3d{id}(i,3);                                         % error in Z
title(['Z error (t)=',num2str(Zer,'%.02f')])
ylabel('Z position')
ylim(RoomRg(3,:))
xlim([1 Fr])

subplot(4,2,8)
hold on
grid on
plot(1:i,Er{id}.er(1:i),'b.-')                                                          % instant error
plot(1:i,Er{id}.mae(1:i),'k.-')                                                         % cummunative error
legend('error','MAE')
xlabel('frames')
ylabel('overall error')
title(['er3D (t)=',num2str(Er{id}.er(i),'%.02f'),'  MAE3D=',num2str(Er{id}.mae(i),'%.02f'),])
ylim([0 2])
xlim([1 Fr])

pause(0.01)

if  (savfig && i==Fr) 
    saveas(gcf,fullfile(dirF,[Info.Sav.Fname,'_fr',num2str(i,'%04d'),Par.Kstr,'_R',num2str(iter),'.png']))
end


end