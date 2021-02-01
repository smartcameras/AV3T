function TrackObj=AV3T_MOT_prediction(TrackObj,Par,fovi,GT,i)
% Description:
%   particle prediction
%
% Date:     07/02/2019
% Author:   Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

Pstd=       Par.PF.Prestd;
N=          Par.PF.N;
Nsp=        N*0.9;

if ~fovi                        % not inside camer's FoV
    Pstd(3)=Pstd(3)/10;
end

for id=Par.ID
    X=TrackObj{id}.X;           % particles
    
    [~,idx]=sort(TrackObj{id}.w,'descend');
    TrackObj{id}.X(:,idx(1:Nsp))    =Par.PF.Pmtx*X(:,idx(1:Nsp))     +    Pstd*ones(1,Nsp).*randn(3,Nsp);
    TrackObj{id}.X(:,idx(Nsp+1:end))=Par.PF.Pmtx*X(:,idx(Nsp+1:end)) +  3*Pstd*ones(1,N-Nsp).*randn(3,N-Nsp);  % 10% particles with heigher speed

if Par.flag==1 && Par.almode==1 % audio only/2D GCF=> set audio height to GT ground truth
    TrackObj{id}.X(3,:)=GT.GT3d{id}(i,3);
end

end



end