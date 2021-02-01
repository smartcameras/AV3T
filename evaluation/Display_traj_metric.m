% Display the trajectory and metric

clear all
close all
clc

dbstop if error
restoredefaultpath

dataset='AV16.3';
% dataset='CAV3D';

% version='AV3T-NL';
% date='08.18';

version='AV3T';
date='10.13';

R=3;
V=1;

datapath=fullfile('/home/xinyuan/Documents/Dataset/',dataset);
rstpath=fullfile(['/home/xinyuan/Documents/Code/res/',version],dataset,['2019.',date,'_R',num2str(R),'_V',num2str(V),'_',dataset]);


addpath(genpath(['/home/xinyuan/Documents/Code/AV3Tcode'])) % code path
addpath(genpath(datapath))% data path

switch dataset
    case 'CAV3D'
        SEQs=[22:26];
        CAMs=5;
        ma=0;
    case 'AV16.3'
        %         SEQs=[18,19,24,25,30];
        SEQs=[24,25,30,45];
        CAMs=1:3;
        ma=1;
end

for r=1:R % for each iteration
    idx=1;
    for s=1:length(SEQs)
        for c=1:length(CAMs)
            seq=SEQs(s);
            cam=CAMs(c);
            seq_name=AV163seq_ses(seq,dataset,cam);
%             load(fullfile(rstpath,['AVPF-',num2str(version)],[seq_name,'_F0C',num2str(cam),'MA',num2str(ma),'_K0_N50_R',num2str(r),'.mat']))
            load(fullfile(rstpath,'AVPF',[seq_name,'_F0C',num2str(cam),'MA',num2str(ma),'_K0_N50_R',num2str(r),'.mat']))

            er=[];
            for id=1:length(Er)
                er=[er,Er{1}.mae(end)];
            end
            Er3d(idx,r)=mean(er);

            MOTA3d(idx,r)=ClearMOT3d.MOTA*100;
            MOTAimg(idx,r)=ClearMOTimg.MOTA*100;
            
            MOTP3d(idx,r)=ClearMOT3d.MOTP*100;
            MOTPimg(idx,r)=ClearMOTimg.MOTP*100;
            Opsa(idx,r)=OPSA;
            idx=idx+1;
        end
    end
end

MOTA3d=mean(MOTA3d,2);
MOTAimg=mean(MOTAimg,2);
Opsa=mean(Opsa,2);
Er3d=mean(Er3d,2);

disp(['OSPA=',num2str(mean(Opsa),'%.01f')])
disp(['MOTAimg=',num2str(mean(MOTAimg),'%.01f')])
disp(['MOTA3d=',num2str(mean(MOTA3d),'%.01f')])


% seq=8;
% cam=2;
% ma=1;
%
% [seq_name,camData]=AV163seq_ses(seq,dataset,cam);
% load(fullfile(rstpath,'AVPF',[seq_name,'_F0C',num2str(cam),'MA',num2str(ma),'_al1_K0_N50.mat']))
%
% ClearMOT3d
% ClearMOTimg
%
% cstr=Par.V.cstr;
% Fw=Par.V.Face3DSz(1);
% Fh=Par.V.Face3DSz(2);
%
% % BBOX computation
% for idgt=1:length(GT.GT3d)
%     GTbb{idgt}= myVirtualBoxCreation(GT.GT3d{idgt}', Info.camData, Fw, Fh, Info.camData.ImgSize(2), Info.camData.ImgSize(1), false);
% end
%
% for id=1:length(Track.Obj)
%     Tckbb{id}=myVirtualBoxCreation(Track.Obj{id}.Xest3d', Info.camData, Fw, Fh, Info.camData.ImgSize(2), Info.camData.ImgSize(1), false);
% end
%
% % display the tracker
% Vfr=Par.V.Vfr;
% figure
% for i=1:Par.Fr
%
%     vfr=Vfr(1)+i-1;
%
%     Img=imread(fullfile(datapath,seq_name,Par.V.fmt{1},[Par.V.fmt{2},num2str(vfr,Par.V.fmt{3}),Par.V.fmt{4}]));
%     for gtid=1:length(GT.GT3d)
%         Img=insertObjectAnnotation(Img,'rectangle',round(GTbb{idgt}(:,i))',['gt',num2str(gtid)],'Color','y');
%     end
%
%     for id=Track.ID{i}
%         cidx=max(mod(id,length(cstr)),1);
%         Img=insertObjectAnnotation(Img,'rectangle',round(Tckbb{id}(:,i))',['trk',num2str(gtid)],'Color',cstr{cidx});
%     end
%     clf
%     imshow(Img)
%     hold on
%
%     for id=Track.ID{i}
%         plot(Track.Obj{id}.XestImg(i,1),Track.Obj{id}.XestImg(i,2),[cstr{cidx},'+'],'MarkerSize',4,'LineWidth',3)
%     end
%
%     title(['Img fr-',num2str(vfr),'       TP=',num2str(ClearMOTimg.TPs(i)),' FP=',num2str(ClearMOTimg.FPs(i)),...
%         ' FN=',num2str(ClearMOTimg.FNs(i)),' IDs=',num2str(ClearMOTimg.IDs(i))])
%     pause(0.01)
%
% end
