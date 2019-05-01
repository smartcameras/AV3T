function mouth3D=myFBBto3D(Fbb,mouth2D,W, C,dataset,S1,wdg,ws)
% Description:
%   project the mouth estiamtes from FBB to 3D
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

if(nargin<6)
    S1=0;           % set scaling factor to 1
    wdg=false;      % use detection width
    ws=0;           % no smooth of face detections
end

Vg=     Fbb(:,3)>0;
N=      size(Fbb,1);    % number of detection
mouth3D=zeros(3,N);

if sum(Vg)              % detection exist
    
    if isempty(mouth2D)
        mouth2D = [(Fbb(:,1) + Fbb(:,3)/2) (Fbb(:,2) + Fbb(:,4)*3/4)]';
    end
    % estimate scaling factor
    BRimg=[Fbb(:,1)+Fbb(:,3),Fbb(:,2)+Fbb(:,4)]';                           % bottom right
    if wdg                                                                  % use detection diagonal size?
        TLimg=[Fbb(:,1),Fbb(:,2)]';                                         % top left
    else
        BLimg=[Fbb(:,1),Fbb(:,2)+Fbb(:,4)]';                                % bottom left
    end
    
    switch dataset
        case 'AV16.3'
            
            BR3d=AV3T_Point3Dprojection(BRimg, C);                             % 3D bottom right
            if wdg && ~S1                                                   % diagonal size
                TL3d=AV3T_Point3Dprojection(TLimg, C);                         % 3D top left
                Ws=smoothW(TL3d,BR3d,Vg,ws);
                s = W./Ws;
            else
                BL3d=AV3T_Point3Dprojection(BLimg, C);                         % 3D bottom left
                Ws=smoothW(BL3d,BR3d,Vg,ws);
                s = W./Ws;
            end
            
            if(S1)
                s=1; % uniform scaling factor
            end
            
            % Mouth image position from the boudning box; 2x1;
            
            % Remove shift
            mouth2D( 1, : ) = mouth2D( 1, : ) - C.shift(1);
            mouth2D( 2, : ) = mouth2D( 2, : ) - C.shift(2);
            
            % Remove radial distortion
            mouth2Dun = undoradial( [mouth2D;ones(1,N)], C.K, [C.kc 0]);
            X = ones(3,1)*s .* [mouth2Dun(1:2,:); ones(1,N)];
            
            % Get 3D point in camera coordinate system
            iX = inv(C.K) * X;
            if size(C.T,1) == 3
                T = [C.T; 0 0 0 1];
            else
                T = C.T;
            end
            % Get mouth position in 3D in homogeneous coordinates
            mouth3Dh = 	C.Align * (inv(T) * [iX; ones(1,N)]);
            mouth3D = mouth3Dh(1:3,:);
            
        case 'FBK'  % missing distortion code
            
            p3d1=NaN(3,N);
            p3d2=NaN(3,N);
            p3d=NaN(3,N);
            
            % estimate scaling factor
            p3d1(:,Vg)=backProjectPoints(BRimg(:,Vg)-1,C.R',C.T,C.K,C.kc);
            if wdg
                p3d2(:,Vg)=backProjectPoints(TLimg(:,Vg)-1,C.R',C.T,C.K,C.kc);
            else
                p3d2(:,Vg)=backProjectPoints(BLimg(:,Vg)-1,C.R',C.T,C.K,C.kc);
            end
              Ws=smoothW(p3d1,p3d2,Vg,ws);
              s = W./Ws(Vg);                                                % scaling factor

            % mouth Image-to-3D projection
            p3d(:,Vg)=backProjectPoints(mouth2D(1:2,Vg)-1,C.R',C.T,C.K,C.kc);
            mouth3D(:,Vg)=SFcorrection(p3d(:,Vg),s,C);
    end
end

mouth3D(isnan(mouth3D))=0;

end

function p3ds=SFcorrection(p3d,sf,C)
% Description:
%   correct the scaling factor
%   p3d: 3 by N 3D pts
%   sf: 1 by N scaling factor

N=size(p3d,2);

% world to camera coords
Xc = C.RT * [p3d;ones(1,N)];

% apply scaling factor
Xs=Xc.*repmat(sf,[3 1]);

% camera to world coords
p3ds=C.R'*(Xs-repmat(C.T,[1 N]));

end


function  Ws=smoothW(p3d1,p3d2,Vg,ws)
% instead of using the detection diagonal/width size for 3D projection, we
% use the history information
% 23/11/17
% XQ
% Input:
%   p3d1: 3 by Fr
%   p3d2: 3 by Fr
% Output:
%   Ws: smoothed width

Ws=zeros(1,length(Vg));
Ws(~Vg)=NaN;

D3d=sqrt(sum((p3d1-p3d2).^2));  % Euclidean distance between the two points

FrVg=find(Vg==1);               % frame with face detection

for i=1:sum(Vg)
    fr=FrVg(i);
    
    if fr<3 || ~sum(ws)         % in the beginning 3 frames or no smoothing needed
        Ws(fr)=D3d(fr);
    else                        % average in last 3 frames
        d3d=D3d(fr-2:fr);
        vg=Vg(fr-2:fr);
        Ws(fr)=sum(d3d(vg).*ws(vg)/sum(ws(vg)));
    end
    
end

end