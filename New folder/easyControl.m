function [ Uh, err ] = easyControl( str, umax,x)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
Uh=zeros(1,6); err=0;
if nargin==2
    x=1;
end
if strcmp(str,'2')%up
    Uh(6)=umax*x;
elseif strcmp(str,'3')%down
    Uh(6)=-umax*x;
elseif strcmp(str,'4')%left
    Uh(5)=-umax*x;
elseif strcmp(str,'5')%right
    Uh(5)=umax*x;
else %error
    err=1;
end
end

