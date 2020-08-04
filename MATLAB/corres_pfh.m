function [TR, TT,p_idx,q_idx, ER, t] = corres_pfh(q,p,varargin)
% Perform the Iterative Closest Point algorithm on three dimensional point
% clouds.
%
% [TR, TT] = icp(q,p)   returns the rotation matrix TR and translation
% vector TT that minimizes the distances from (TR * p + TT) to q.
% p is a 3xm matrix and q is a 3xn matrix.
%
% [TR, TT] = icp(q,p,k)   forces the algorithm to make k iterations
% exactly. The default is 10 iterations.
%
% [TR, TT, ER] = icp(q,p,k)   also returns the RMS of errors for k
% iterations in a (k+1)x1 vector. ER(0) is the initial error.
%
% [TR, TT, ER, t] = icp(q,p,k)   also returns the calculation times per
% iteration in a (k+1)x1 vector. t(0) is the time consumed for preprocessing.
%
% Additional settings may be provided in a parameter list:
%
% EdgeRejection
%       {false} | true
%       If EdgeRejection is true, point matches to edge vertices of q are
%       ignored. Requires that boundary points of q are specified using
%       Boundary or that a triangulation matrix for q is provided.
%
% Matching
%       {bruteForce} | Delaunay | kDtree
%       Specifies how point matching should be done. 
%       bruteForce is usually the slowest and kDtree is the fastest.
%       Note that the kDtree option is depends on the Statistics Toolbox
%       v. 7.3 or higher.
%
% Minimize
%       {point} | plane | lmaPoint
%       Defines whether point to point or point to plane minimization
%       should be performed. point is based on the SVD approach and is
%       usually the fastest. plane will often yield higher accuracy. It 
%       uses linearized angles and requires surface normals for all points 
%       in q. Calculation of surface normals requires substantial pre
%       proccessing.
%       The option lmaPoint does point to point minimization using the non
%       linear least squares Levenberg Marquardt algorithm. Results are
%       generally the same as in points, but computation time may differ.
%
% Weight
%       {@(match)ones(1,m)} | Function handle
%       For point or plane minimization, a function handle to a weighting 
%       function can be provided. The weighting function will be called 
%       with one argument, a 1xm vector that specifies point pairs by 
%       indexing into q. The weighting function should return a 1xm vector 
%       of weights for every point pair.
%
% Martin Kjer and Jakob Wilm, Technical University of Denmark, 2012

% Use the inputParser class to validate input arguments.
inp = inputParser;

inp.addRequired('q', @(x)isreal(x) && size(x,1) == 125);
inp.addRequired('p', @(x)isreal(x) && size(x,1) == 125);

inp.addParamValue('EdgeRejection', false, @(x)islogical(x));

inp.addOptional('iter', 1, @(x)x > 0 && x < 10^5);

validMatching = {'bruteForce','Delaunay','kDtree'};
inp.addParamValue('Matching', 'bruteForce', @(x)any(strcmpi(x,validMatching)));

validMinimize = {'point','plane','lmapoint'};
inp.addParamValue('Minimize', 'point', @(x)any(strcmpi(x,validMinimize)));

inp.addParamValue('ReturnAll', false, @(x)islogical(x));

inp.addParamValue('Weight', @(x)ones(1,length(x)), @(x)isa(x,'function_handle'));


inp.parse(q,p,varargin{:});
arg = inp.Results;
clear('inp');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Actual implementation

% Allocate vector for RMS of errors in every iteration.
t = zeros(arg.iter+1,1); 

% Start timer
tic;

Np = size(p,2);

% Transformed data point cloud
pt = p;

% Allocate vector for RMS of errors in every iteration.
ER = zeros(arg.iter+1,1); 

% Initialize temporary transform vector and matrix.
T = zeros(125,1);
R = eye(125,125);

% Initialize total transform vector(s) and rotation matric(es).
TT = zeros(125,1, arg.iter+1);
TR = repmat(eye(125,125), [1,1, arg.iter+1]);

t(1) = toc;

% Go into main iteration loop
for k=1:arg.iter
       
    % Do matching
    switch arg.Matching
        case 'bruteForce'
            [match mindist] = match_bruteForce(q,pt);
    end

    % If matches to edge vertices should be rejected
    if arg.EdgeRejection
        p_idx = not(ismember(match, bdr));
        q_idx = match(p_idx);
        mindist = mindist(p_idx);
    else
        p_idx = true(1, Np);
        q_idx = match;
    end
     
    if k == 1
        ER(k) = sqrt(sum(mindist.^2)/length(mindist));
    end
    
    switch arg.Minimize
        case 'point'
            % Determine weight vector
            weights = arg.Weight(match);
            [R,T] = eq_point(q(:,q_idx),pt(:,p_idx), weights(p_idx));
        case 'plane'
            weights = arg.Weight(match);
            [R,T] = eq_plane(q(:,q_idx),pt(:,p_idx),arg.Normals(:,q_idx),weights(p_idx));
        case 'lmaPoint'
            [R,T] = eq_lmaPoint(q(:,q_idx),pt(:,p_idx));
    end    
    
    % Root mean of objective function 
    ER(k+1) = rms_error(q(:,q_idx), pt(:,p_idx));
    
    t(k+1) = toc;
end

if not(arg.ReturnAll)
    TR = TR(:,:,end);
    TT = TT(:,:,end);
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [match mindist] = match_bruteForce(q, p)
    m = size(p,2);
    n = size(q,2);    
    match = zeros(1,m);
    mindist = zeros(1,m);
    for ki=1:m
        d=zeros(1,n);
        for ti=1:125
            d=d+(q(ti,:)-p(ti,ki)).^2;
        end
        [mindist(ki),match(ki)]=min(d);
    end
    
    mindist = sqrt(mindist);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [R,T] = eq_point(q,p,weights)

m = size(p,2);
n = size(q,2);

% normalize weights
weights = weights ./ sum(weights);

% find data centroid and deviations from centroid
q_bar = q * transpose(weights);
q_mark = q - repmat(q_bar, 1, n);
% Apply weights
q_mark = q_mark .* repmat(weights, 125, 1);

% find data centroid and deviations from centroid
p_bar = p * transpose(weights);
p_mark = p - repmat(p_bar, 1, m);
% Apply weights
%p_mark = p_mark .* repmat(weights, 125, 1);

N = p_mark*transpose(q_mark); % taking points of q in matched order

[U,~,V] = svd(N); % singular value decomposition

diaf([1:125])=1;
X=diag(diaf);
X(125,125)=det(U*V');

R = V*X*transpose(U);

T = q_bar - R*p_bar;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [R,T] = eq_plane(q,p,n,weights)

n = n .* repmat(weights,3,1);

c = cross(p,n);

cn = vertcat(c,n);

C = cn*transpose(cn);

b = - [sum(sum((p-q).*repmat(cn(1,:),3,1).*n));
       sum(sum((p-q).*repmat(cn(2,:),3,1).*n));
       sum(sum((p-q).*repmat(cn(3,:),3,1).*n));
       sum(sum((p-q).*repmat(cn(4,:),3,1).*n));
       sum(sum((p-q).*repmat(cn(5,:),3,1).*n));
       sum(sum((p-q).*repmat(cn(6,:),3,1).*n))];
   
X = C\b;

cx = cos(X(1)); cy = cos(X(2)); cz = cos(X(3)); 
sx = sin(X(1)); sy = sin(X(2)); sz = sin(X(3)); 

R = [cy*cz cz*sx*sy-cx*sz cx*cz*sy+sx*sz;
     cy*sz cx*cz+sx*sy*sz cx*sy*sz-cz*sx;
     -sy cy*sx cx*cy];
    
T = X(4:6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [R,T] = eq_lmaPoint(q,p)

Rx = @(a)[1     0       0;
          0     cos(a)  -sin(a);
          0     sin(a)  cos(a)];
      
Ry = @(b)[cos(b)    0   sin(b);
          0         1   0;
          -sin(b)   0   cos(b)];
      
Rz = @(g)[cos(g)    -sin(g) 0;
          sin(g)    cos(g)  0;
          0         0       1];

Rot = @(x)Rx(x(1))*Ry(x(2))*Rz(x(3));

myfun = @(x,xdata)Rot(x(1:3))*xdata+repmat(x(4:6),1,length(xdata));


options = optimset('Algorithm', 'levenberg-marquardt');
x = lsqcurvefit(myfun, zeros(6,1), p, q, [], [], options);


R = Rot(x(1:3));
T = x(4:6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine the RMS error between two point equally sized point clouds with
% point correspondance.
% ER = rms_error(p1,p2) where p1 and p2 are 3xn matrices.

function ER = rms_error(p1,p2)
dsq = sum(power(p1 - p2, 2),1);
ER = sqrt(mean(dsq));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%