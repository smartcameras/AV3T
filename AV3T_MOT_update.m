function [TrackObj,Er]=myMOT_update(TrackObj,GT,Er,Info,i,i0,ID)
% Description:
%   update the particle weights
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

disp('updating..')

for id=ID
        
	wc                          =   PFnearWchange(TrackObj,TrackObj{id}.X,i,id,ID);
    [w,Xest3d,XestImg]          =   myUpdate(TrackObj{id}.wa,TrackObj{id}.wv.DH, wc,TrackObj{id}.X,Info.camData);
     
    TrackObj{id}.w              =	w;
    TrackObj{id}.Xest3d(i,:)    =   Xest3d';
    TrackObj{id}.XestImg(i,:)   =   XestImg';
    Er{id}.er(i)                =	norm(Xest3d'-GT.GT3d{id}(i,:));         % instant error
    Er{id}.mae(i)               =	mean(Er{id}.er(i0:i));                  % cummulative error
end
        
disp('updating finish')


end

%%

function [w,Xest3d,XestImg]=myUpdate(wa,wv,wc,X,camData)
N=length(wa); % particle number

wa(wa<0)=   0;

% update
w       =   wa.*wv.*wc;
w(w<0)  =   0;
w       =   w./sum(w);

if isnan(sum(w))||~sum(w)
    w   =   1/N*ones(1,N);
    disp('particle weights not valid: set to equal weights......')
end

Xest3d  =   X(1:3,:)*w';                    % est 3D
ImgEst  =   AV3T_project(Xest3d, camData);
XestImg =   ImgEst(1:2);                    % est Img

end


%% 

function wc=PFnearWchange(TrackObj,X,i,id,ID,er)
% Description:
%   change the particle weights when the two identities are close to each other
% Input:
%   X:      particles
% Output:
%   wc:     weights of particle w.r.t the other identity (when they are close)

N=length(X);
wc=ones(1,N);

if length(ID)==1 || i<=1
    return
end

if nargin<6
    er=0.2; % when distance between particle and the other estimate is bigger than er => safe
end

c=log(2)/er; % exponential constant


IDrst=ID(ID~=id); % other speakers
for idx=1:length(IDrst)
    idr=IDrst(idx);
    
    Xest3did    =   TrackObj{idr}.Xest3d(i-1,:)';   % target 3D estimate at previous frame of the other identity
    Xest3did    =   repmat(Xest3did,[1,N]);
    er3d        =   sqrt(sum((X-Xest3did).^2));
    
    xc=er3d<=er;                                    % particle weights need to be changed
    
    if sum(xc)
        disp(['Speaker ID-',num2str(id),'  ',num2str(sum(xc)),' PARTICLEs close to the other ID',num2str(ID(ID~=id)),', reduce their weights influence'])
        wc(idx,xc)=exp(c*er3d(xc))-1;
    end
    
end

 wc=min(wc,[],1);

end