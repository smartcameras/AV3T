function Info=SavRst(TrackObj,GT,Info,Par,Er,iter)
% Description:
%   save the tracking rst
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

savRst=     Info.Sav.savRst;
savfig=     Info.Sav.savfig;
dirRst=     Info.Sav.dirRst;
seq_name=   Info.seq_name;

flag=       Par.flag;
almode=     Par.almode;
i0=         Par.i0;
R=          Par.R;


for id=Par.ID
    Info.MAE{id}(iter)      =   mean(Er{id}.er(i0:end));
    Info.MAEstd{id}(iter)   =   std(Er{id}.er(i0:end));
    disp([seq_name,'SpeakerID-',num2str(id),'-iter',num2str(iter),'  flag=',num2str(flag),...
        ' almode=',num2str(almode)])
    disp([    '  MAE3d=',num2str(Info.MAE{id}(iter),'%.3f'),'  MAEstd=',num2str(Info.MAEstd{id}(iter),'%.3f')])
end

if  savfig||savRst && iter==R
    
    Info.MAE{id}(R+1)     =	  mean(Info.MAE{id});
    Info.MAEstd{id}(R+1)  =   mean(Info.MAEstd{id});
    disp(['SpeakerID-',num2str(id),Info.seq_name,'   Finish all iterations!'])
    
    disp(['SpeakerID-',num2str(id),Info.seq_name,'  flag=',num2str(flag),' almode=',num2str(almode),...
        '  Average er=',num2str(Info.MAE{id}(R+1)),'   std=',num2str(Info.MAEstd{id}(R+1))])
    save(fullfile(dirRst,'..',['Paras_F',num2str(flag),'_',Par.Kstr,'.mat']),'Info','Par') % save parameters
end

if(~savRst)
    return
end
disp('start saving results')


for id=Par.ID
    GT3d    =   GT.GT3d{id};
    GTimg   =   GT.GTimg{id};
    Xest3d  =   TrackObj{id}.Xest3d;
    XestImg =   TrackObj{id}.XestImg;
    FoV     =   GT.FoV{id};
    
    res = [(Par.V.Vfr(1):Par.V.Vfr(2))', GT3d, Xest3d,GTimg,XestImg,FoV];
    fName = ['trackRes_S' Info.Sav.Fname '_ID',num2str(id),'_iter',num2str(iter),'.dat'];
    
    f1 = fopen(fullfile(dirRst,fName),'w');
    fprintf(f1, '%d %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %d\n', res');
    fclose(f1);
end
disp('Saved!');


end