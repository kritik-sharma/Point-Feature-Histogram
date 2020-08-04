function [d] = dist_pfh(q,p)
inp = inputParser;

inp.addRequired('q', @(x)isreal(x) && size(x,1) == 125);
inp.addRequired('p', @(x)isreal(x) && size(x,1) == 125);

inp.parse(q,p);
arg = inp.Results;
clear('inp');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Actual implementation
d=0;
for ti=1:125
    d=d+((q(ti)-p(ti))^2);
end
d=sqrt(d);
