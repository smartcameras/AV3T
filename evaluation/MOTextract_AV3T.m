function [gt,result]=MOTextract_AV3T(GT,Track,Info,Par)
% extract for the MOT metric computation
% Output:
%
%   gt{time frame}[target id, x,y,w,h]
%   result(time frame).trackerData.idTracks: active tracker identity
%   result(time frame).trackerData.target(tracker identity).bbox=[x,y,w,h]

% Fr=Par.Fr;
Frange=Par.V.Vfr;
Fw=Par.V.Face3DSz(1);
Fh=Par.V.Face3DSz(2);

IDgt=length(GT.GT3d);
for idgt=1:IDgt % create BBOX for GT3d
    GTbb{idgt}= myVirtualBoxCreation(GT.GT3d{idgt}', Info.camData, Fw, Fh, Info.camData.ImgSize(2), Info.camData.ImgSize(1), false);
end

for t=1:Frange(1)-1 % for each time frame
    gt.pimg{t}=zeros(1,5);
    gt.p3d{t}=zeros(1,4);
    gt.Mimg{t}=zeros(1,3);
    
    result(t).trackerData.idxTracks=[];
    result(t).trackerData.target=[];
end

for t=Frange(1):Frange(2) % for each time frame
    
    
    t_rst=t-Frange(1)+1;  % result
    
    % GT result
    for idgt=1:IDgt
        gt.pimg{t}(idgt,:)=[idgt;GTbb{idgt}(:,t_rst)];
        gt.p3d{t}(idgt,:)=[idgt,GT.GT3d{idgt}(t_rst,:)];
        gt.Mimg{t}(idgt,:)=[idgt,GT.GTimg{idgt}(t_rst,:)];
    end
    
    
    % Tracking result
    %     Track.ID{t_rst}=Par.ID;
    result(t).trackerData.idxTracks=Track.ID{t_rst};
    
    %     for idtck=Track.ID{t}
    for x=1:length(Track.ID{t_rst})
        idtck=Track.ID{t_rst}(x);
        
        pos3d=Track.Obj{idtck}.Xest3d(t_rst,:);
        result(t).trackerData.target(idtck).est3d=pos3d;
        
        bboxes= myVirtualBoxCreation(pos3d', Info.camData, Fw, Fh, Info.camData.ImgSize(2), Info.camData.ImgSize(1), false);
        result(t).trackerData.target(idtck).bbox=bboxes';
        result(t).trackerData.target(idtck).Mimg=Track.Obj{idtck}.XestImg(t_rst,:);
    end
    
end