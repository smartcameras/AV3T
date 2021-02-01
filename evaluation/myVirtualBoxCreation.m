%% MYVIRTUALBOXCREATION(X, C, Fw, Fh, Iw, Ih)
%
% MYVIRTUALBOXCREATION creates a 3D face rectangle for each particle assuming
%       the person always facing the camera and assuming the mouth is at 1/4
%       distance to the bottom line.
%
% Parameters:
%   - X:    particle positions in 3D Cartesian coordinates.
%   - C:
%   - Fw:   Face width.
%   - Fh:   Face height.
%   - Iw:   image width.
%   - Ih:   image height.
%
% Output:
%   VBimg: projected virtual bounding box position on image plane 8 by N.
%   matrix, which corresponds to the four corner points of the virtual box.
%   VBcart: virtual bounding box position vector in Cartesian coordinates.
%%        Author: Xinyuan Qian
%        Author: Alessio Xompero
%   Create Date: 2017/04/09
% Modified Date: 2017/07/22
%
function [bboxes, pStatus, p2d, S,bboxes2,bb2v] = myVirtualBoxCreation(X, C, Fw, Fh, Iw, Ih, bodypart)

X   =   X(1:3,:); % only take the position
N   =   size(X,2); % number of particles

pStatus =   ones(N,1);
bboxes  =	zeros(4,N);
VBimg	=	zeros(4,N);
S       =	zeros(5,4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% X2 = X;

X2 = [X; ones(1,size(X,2))];

% Convert the 3D points from world to camera coordinates
% X = C.RT * X;
X = C.RT * [X; ones(1,size(X,2))];


% Check bodypart value. If wrong set it to 0 (face).
if nargin<7 || bodypart < 0 || bodypart > 2
    bodypart = 0;
end

% Define the four corners of the 3D face rectangle in the camera
% coordinates, each row of F corresponds to (x,y,z,1) in camera coordinates
switch bodypart
    case 0 % face
        F = [Fw/2,  3*Fh/4,0, 1; % top left
            -Fw/2,  3*Fh/4,0, 1; % top right
            -Fw/2,  -Fh/4,0, 1; % bottom right
            Fw/2,   -Fh/4,0, 1]; % bottom left
    case 1 % body/torso
        F = [Fw/2,  -Fh,0, 1; % (x,y,z,1) in camera coordinates
            -Fw/2,  -Fh,0, 1;
            -Fw/2,  -2*Fh,0, 1;
            Fw/2,   -2*Fh,0, 1];
    case 2 % Upperbody
        F = [Fw/2,  Fh/2,0, 1;
            -Fw/2,  Fh/2,0, 1;
            -Fw/2,  -Fh/2,0, 1;
            Fw/2,   -Fh/2,0, 1];
end


if(strcmp(C.dataset,'AV16.3'))  % camera coordinates difference
    F(:,1)= -F(:,1);
    F(:,2)= -F(:,2);
end

% bb2v=ones(1,N);  % bboxes 2 valid index
for n=1:N
    dx = X(1,n);
    dy = X(3,n);
    
    % Create 3D face rectangle in the world coordinates to return as output
    th = atan2(dx,dy);
    
    R = [cos(th), 0, sin(th); 0 1 0;-sin(th) 0 cos(th)];
    
    S = inv([C.RT; 0,0,0,1]) * [R, X(1:3,n); 0 0 0 1] * F';  % transfer to world coordinates
    S = [S, S(:,1)]';     % ( each row: top-left,top-right,bot-right,bot-left)
    
    % Check if the point lies in front of the camera (positive z-axis)
    % Value of the viewvingCosLimit set as ORB-SLAM 0.5
    if ~isInFrustum(X2(1:3,n), C, 0.5, Iw, Ih)
        pStatus(n) = 0;
        %         bb2v(n)=0;
        
        continue;
    end
    
    
    % Project 3D face rectangle to image plane
    [bbimg(1:2),ps1]=   AV3T_project( S(1,1:3)', C); % top-left corner point
    [bbimg(3:4),ps2]=   AV3T_project( S(3,1:3)', C); % bottom right corner point
    VBimg(:,n)  =   bbimg;
    pStatus(n)=ps1&ps2;
    
    % Define bounding box as [x,y,w,h]
    bbox        =	zeros(4,1);
    bbox(1:2)   =   bbimg(1:2)';   % virtual bounding box on image plane
    bbox(3)     =   bbimg(3)-bbimg(1);
    bbox(4)     =   bbimg(4)-bbimg(2);
    
    bbox = round(bbox); % round values for pixel
    
    % Check if bbox is out of FoV or if is it valid
    if (bbox(1) >= Iw) || (bbox(2) >= Ih) || ...
            ((bbox(1) + bbox(3)) <= 0) || ((bbox(2) + bbox(4)) <= 0) || ...
            (bbox(3) <= 0) || (bbox(4) <= 0) || isnan(sum(bbox)) % bbox contains NaN
        pStatus(n) = 0;
        continue;
    end
    
    % if bbox partially outside the image, cut the borders
    if bbox(1) < 1
        bbox(1) = 1;
    end
    
    if bbox(2) < 1
        bbox(2) = 1;
    end
    
    if (bbox(1) + bbox(3)) > Iw
        bbox(3) = bbox(3) - ((bbox(1) + bbox(3)) - Iw);
    end
    
    if (bbox(2) + bbox(4)) > Ih
        bbox(4) = bbox(4) - ((bbox(2) + bbox(4)) - Ih);
        %         bb2v(n)=0; % bboxes2 valid index
    end
    
    bboxes(:,n) = bbox;
end

% %----- XQ added: body part of the object --------------
% bboxes2=bboxes;
% bboxes2(2,:)=bboxes(2,:)+bboxes(4,:);
%
% Bcut=bboxes2(2,:)+bboxes2(4,:)>Ih; % bottom cut
% bboxes2(4,Bcut)=bboxes2(2,Bcut)+bboxes2(4,Bcut)-Ih;
%
% Ximg = myproject( X2, C ); % project mouth position
% p2d = [Ximg(1:2,:) VBimg(1:2,:) VBimg(3:4,:)];

bboxes(isnan(bboxes))=0;

bboxes2=[];
bb2v=[];
p2d=[];

end
