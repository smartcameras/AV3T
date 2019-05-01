% undoradial    remove radial distortion
%
% [xl] = undoradial(x,K,kc)
%
% x ... 3xN coordinates of the distorted pixel points
% K ... 3x3 camera calibration matrix
% kc ... 4x1 vector of distortion parameters
% alpha_c ... scalar, skew distortion parameter (default value: zero)
%
% xl ... linearized pixel coordinates
%        these coordinates should obey the linear pinhole model
%
% It calls comp_distortion_oulu: undistort pixel coordinates.
% function taken from the CalTech camera calibration toolbox
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

function [xl] = undoradial(x_kk,K,kc,alpha_c)

if size(x_kk,1) ~= 3
    error( 'undoradial needs 3xN "xl" matrix of 2D points' );
end

if ~exist( 'alpha_c', 'var' )
    alpha_c = 0;
end

cc(1) = K(1,3);
cc(2) = K(2,3);
fc(1) = K(1,1);
fc(2) = K(2,2);

% First: Subtract principal point, and divide by the focal length:
x_distort = [(x_kk(1,:) - cc(1))/fc(1); (x_kk(2,:) - cc(2))/fc(2)];

% Second: compensate for skew
x_distort( 1,: ) = x_distort( 1,: ) - alpha_c * x_distort( 2,: );

if norm(kc) ~= 0
    % Third: Compensate for lens distortion:
    xn = comp_distortion_oulu(x_distort,kc);
else
    xn = x_distort;
end

% back to the linear pixel coordinates
xl = K*[xn;ones(size(xn(1,:)))];

end



function [x] = comp_distortion_oulu(xd,k)

%comp_distortion_oulu.m
%
%[x] = comp_distortion_oulu(xd,k)
%
%Compensates for radial and tangential distortion. Model From Oulu university.
%For more informatino about the distortion model, check the forward projection mapping function:
%project_points.m
%
%INPUT: xd: distorted (normalized) point coordinates in the image plane (2xN matrix)
%       k: Distortion coefficients (radial and tangential) (4x1 vector)
%
%OUTPUT: x: undistorted (normalized) point coordinates in the image plane (2xN matrix)
%
%Method: Iterative method for compensation.
%
%NOTE: This compensation has to be done after the subtraction
%      of the principal point, and division by the focal length.


if length(k) == 1
    
    [x] = comp_distortion(xd,k);
    
else
    
    k1 = k(1);
    k2 = k(2);
    k3 = k(5);
    p1 = k(3);
    p2 = k(4);
    
    x = xd; 				% initial guess
    
    for kk=1:20
        
        r_2 = sum(x.^2);
        k_radial =  1 + k1 * r_2 + k2 * r_2.^2 + k3 * r_2.^3;
        delta_x = [2*p1*x(1,:).*x(2,:) + p2*(r_2 + 2*x(1,:).^2); % 2 by N matrix
            p1 * (r_2 + 2*x(2,:).^2)+2*p2*x(1,:).*x(2,:)];
        x = (xd - delta_x)./(ones(2,1)*k_radial);
        
    end
    
end
end



