function [ Init ] = init4P(Current,P)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
laststate=Current.laststate;
firststate=Current.firststate;
laststep=P.trans(laststate,firststate);
Init.time=Current.T+laststep;%current.i=step in the path
Init.dd=Current.DD+laststep*(P.Ih(laststate,2)+P.Ih(firststate,2))/2;
Init.dc=Current.DC+laststep*(P.Ih(laststate,1)+P.Ih(firststate,1))/2;
end

