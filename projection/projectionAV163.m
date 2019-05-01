function [p2d,onimg] = projectionAV163( p3d, C)
% Date:     07/02/2019
% Author:   Alessio Xompero, Xinyuan Qian (x.qian@qmul.ac.uk)
%
% Requested citation acknowledgement when using this software:
% X. Qian, A. Brutti, O. Lanz, M. Omologo and A. Cavallaro, "Multi-speaker tracking from an audio-visual sensing device" in IEEE Transactions on Multimedia, Feb 2018, accepted.
% 
% Please have a look at the 'readme.txt' and the software license file 'License.doc'

align_mat   =   C.Align;
Pmat        =   C.Pmat;
K           =   C.K;
kc          =   C.kc;
alpha_c     =   C.alpha_c;
shift       =   C.shift;

if size(p3d,1)==3
    p3d(4,:)=1;
end
% Project to 3D video referent
xyz = inv( align_mat ) * p3d;

% Euclidian projection
new_x = Pmat * xyz;
new_x = new_x ./ repmat( new_x( 3,:), 3, 1 ) ;

% Apply radial distortion
p2d = doradial( new_x, K, kc, alpha_c ); 

% Apply shift
p2d( 1, : ) = p2d( 1, : ) + shift(1);
p2d( 2, : ) = p2d( 2, : ) + shift(2);

p2d(3,:)=[];

% check pts on image
onimg=(p2d(1,:)>0) & (p2d(1,:)<=C.ImgSize(2)) & (p2d(2,:)>0) & (p2d(2,:)<=C.ImgSize(1));

end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [xd] = doradial(xl,K,kc, alpha_c)
% Input:
%   xl:     3xN linear pixel coordinates in the linear image (1..M, 1...N)
%           these are (col,row,1) image coordinates,
%   K:      3x3 camera calibration matrix
%   kc:     4x1 vector of distortion parameters
%   alpha_c:scalar, skew distortion parameter (default: 0 )
%   
% Output:
%   xd:     3xN coordinates of the distorted pixel points

  if size(xl,1) ~= 3
    error( 'doradial needs 3xN "xl" matrix of 2D points' );
  end
  
  if ~exist( 'alpha_c', 'var' )
    alpha_c = 0;
  end
  
  cc(1) = K(1,3);
  cc(2) = K(2,3);
  fc(1) = K(1,1);
  fc(2) = K(2,2);

  %%%%%%%
  % Project
  rays = inv( K ) * xl;
  x = [rays(1,:)./rays(3,:); rays(2,:)./rays(3,:)];

  
  %%%%%%%
  % First compute the coordinate relative to the principal point
  % before taking care of focal length
  x_distort = apply_distortion( x, kc, alpha_c );
  
  %%%%%%%%%%
  % Second multiply by focal length and add the principal point
  xd = [ fc( 1 ) * x_distort( 1,: ) + cc( 1 );
	 fc( 2 ) * x_distort( 2,: ) + cc( 2 ); 
	 ones( 1, size( xl, 2 ) ) ];
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function xd = apply_distortion(x,k,alpha)

  if ~exist( 'alpha', 'var' )
    % Default: no skew distorsion
    alpha = 0;
  end

  % Complete the distortion vector if you are using the simple distortion model:
  k = k(:);
  length_k = length(k);
  if length_k < 5 
    k = [k ; zeros(5-length_k,1)];
  end
  

  [m,n] = size(x);

  % Add distortion:

  r2 = x(1,:).^2 + x(2,:).^2;
  r4 = r2.^2;
  r6 = r2.^3;


  % Radial distortion:

  cdist = 1 + k(1) * r2 + k(2) * r4 + k(5) * r6;

  xd1 = x .* (ones(2,1)*cdist);

  coeff = (reshape([cdist;cdist],2*n,1)*ones(1,3));

  % tangential distortion:

  a1 = 2.*x(1,:).*x(2,:);
  a2 = r2 + 2*x(1,:).^2;
  a3 = r2 + 2*x(2,:).^2;

  delta_x = [k(3)*a1 + k(4)*a2 ;
	     k(3) * a3 + k(4)*a1];

  aa = (2*k(3)*x(2,:)+6*k(4)*x(1,:))'*ones(1,3);
  bb = (2*k(3)*x(1,:)+2*k(4)*x(2,:))'*ones(1,3);
  cc = (6*k(3)*x(2,:)+2*k(4)*x(1,:))'*ones(1,3);

  xd2 = xd1 + delta_x;

  % skew distortion

  xd2( 1,: ) = xd2( 1,: ) + alpha * xd2( 2, : );

  % Return value

  xd = xd2;
end


