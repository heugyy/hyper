function d = dist2(a,b)
% Computes Euclidean distance matrix.
%
% E = dist2(A,B)
%
%    A - (m x p) matrix 
%    B - (n x p) matrix
% 
% Returns:
%    E - (m x n) Euclidean distances between vectors in A and B
%
%
% Description : 
%    This fully vectorized (VERY FAST!) m-file computes the 
%    Euclidean distance between two vectors by:
%
%                 ||A-B|| = sqrt ( ||A||^2 + ||B||^2 - 2*A.B )
%
% Example : 
%    A = rand(400,100); B = rand(400,200);
%    d = dist2(A,B);

% Author   : Roland Bunschoten
%            University of Amsterdam
%            Intelligent Autonomous Systems (IAS) group
%            Kruislaan 403  1098 SJ Amsterdam
%            tel.(+31)20-5257524
%            bunschot@wins.uva.nl
% Last Rev : Wed Oct 20 08:58:08 MET DST 1999
% Tested   : PC Matlab v5.2 and Solaris Matlab v5.3

% Copyright notice: You are free to modify, extend and distribute 
%    this code granted that the author of the original code is 
%    mentioned as the original author of the code.


if (nargin < 2)
   error('Not enough input arguments');
end

if (size(a,2) ~= size(b,2))
   error('A and B should be of same dimensionality');
end

if ~(isreal(a)*isreal(b))
   disp('Warning: running distance.m with imaginary numbers.  Results may be off.'); 
end

aa=sum(a.*a,2); bb=sum(b.*b,2); ab=a*b'; 
d = sqrt(repmat(aa,[1 size(bb,1)]) + repmat(bb',[size(aa,1) 1]) - 2*ab);

% make sure result is all real
d = real(d); 