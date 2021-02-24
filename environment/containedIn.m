function [ cont] = containedIn( xvec,pi, T )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
xmin=T.R(1,1,pi);
xmax=T.R(2,1,pi);
ymin=T.R(1,2,pi);
ymax=T.R(2,2,pi);

x=xvec(1); y=xvec(2);

cont=0;
if x>=xmin && x<=xmax && y<=ymax && y>=ymin
    cont=1;
end

end

