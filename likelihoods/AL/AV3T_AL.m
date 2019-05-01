function [wa,AM,AMmax,Amap,vad,sslc,Za]=myAL(X,CM,Mic_pair,Mic_pos,c,fa,i,Afr,Zp,almode,p,X_g,Y_g,AMvad,flag,SSL,Upstd,savfig)
% Description:
%   compute audio likelihood
%
% Date:     07/02/2019
% Author:   Alessio Xompero, Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'


Mic_c   =   mean(Mic_pos);
X       =   X(1:3,:); % only use position

N       =   size(X,2);
afr     =   i+Afr(1)-1;

wa      =   ones(1,N);
AM      =   0;
AMmax   =   0;

if(flag==2) % only use video information
    Amap    =   ones(length(Y_g),length(X_g));
    vad     =   false;
    sslc    =   NaN*ones(3,1);
    Za      =   [];
    return
end

switch almode
    case 1 % GCF at given Z plane
        disp(['Audio Likelihood: GCF at estimated XY plane   Zp=',num2str(Zp),' m'])
        Xz      =   X;                                                                   % particles projected on XY plane
        [~,z]   =   min(abs(ones(length(Zp),1)*X(3,:)-Zp'*ones(1,N)),[],1);
        Xz(3,:) =   Zp(z);
        AM      =   AV3T_AL_GCF(Xz,CM,afr,Mic_pair,Mic_pos,c,fa);
        vad     =   max(AM(:))>=AMvad;
        
        if vad
            wa=AM;
            [~,z]   =   min(abs(Zp-mean(X(3,:))));
            GridZ   =   CreateGrid_GTZ(Zp(z),X_g,Y_g);                                  % create audio grid
            am      =   AV3T_AL_GCF(GridZ,CM,afr,Mic_pair,Mic_pos,c,fa);
            sslc    =   mean(GridZ(:,am==max(am)),2);
        end
        
    case 2 % 3D SSL rst
        vad         =   SSL(i,4);
        if vad
            disp('3D GCF localisation rst!')
            sslc    =   SSL(i,1:3)';
            
            Xsph    =   AV3T_Particle_cart2sph(X,Mic_c);                                   % 3D Gaussian error in spherical coordinates
            sslsph  =   AV3T_Particle_cart2sph(sslc,Mic_c);
            Ver     =   Xsph-sslsph*ones(1,N);
            wa      =   prod(exp(-(Ver.^2)/2./(Upstd.^2*ones(1,N))));
            
            AM          =   wa;
        end
        
end
AMmax=max(AM(:));

% VAD
if ~vad
    sslc    =   NaN*ones(3,1);
    wa      =   ones(1,N);
end

%% Display
if (p || savfig) && vad
    
    [~,z]       =   min(abs(Zp-mean(X(3,:))));% in case of multiple speakers
    Za          =   Zp(z);
    GridZ       =   CreateGrid_GTZ(Za,X_g,Y_g);  % create audio grid
    
    switch almode
        case 2  % 2D/ 3D GCF localisation
            GridZsph    =   AV3T_Particle_cart2sph(GridZ,Mic_c);
            Ver         =   GridZsph-sslsph*ones(1,length(GridZsph));  % error square
            am          =   prod(exp(-(Ver.^2)/2./(Upstd.^2*ones(1,length(GridZsph)))));
            
        otherwise
            am              =   AV3T_AL_GCF(GridZ,CM,afr,Mic_pair,Mic_pos,c,fa);
    end
    Amap                    =   reshape(am,[length(Y_g) length(X_g)]);
    
else
    Amap                    =   ones(length(Y_g),length(X_g));
    Za                      =   [];
end

disp('finish AL computing')

end