function [ member ] = timeMember( q,QT, T)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
member=0;
for ind=1:size(QT,1)
    if q==QT(ind,1) && T>QT(ind,2)
        % q is part of Qd and the current time is big enough for the trans
        % to occur (should always be the case)
        member=1;
    end
end

end

