function [s] = checkRegion(x,dWTS)
%returns the state of dWTS which x belongs to

xmin=dWTS.R(1,1,:);
xmax=dWTS.R(2,1,:);
ymin=dWTS.R(1,2,:);
ymax=dWTS.R(2,2,:);

for is=dWTS.S
    if xmin(is)<=x(1) && xmax(is)>=x(1) && ymin(is)<=x(2) && ymax(is)>=x(2)
        s=is;
    end
end
end

