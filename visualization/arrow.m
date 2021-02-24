function [ x, y, u, v ] = arrow( dir,size,s,Time )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
d_tot=sqrt(2*size^2);
d_diff=(d_tot-size)/2;
d_xy=sqrt(d_diff^2/2);
%define starting point for arrows and angle/length of arrows
 x=zeros(s-1);
 y=zeros(s-1);
 u=zeros(s-1);
 v=zeros(s-1);
 theta=pi/6;
for i=1:s-1
    if dir==1
        if Time(i,i+1)~=0
            x(i)=1+(i-1)*2*size+size-d_xy+size/2*(cos(theta)-cos(pi/4));
            y(i)=1+(i-1)*2*size+size-d_xy+size/2*(sin(theta)-sin(pi/4));
            u(i)=size+2*d_xy;
            v(i)=u(i);
        end
    elseif dir==-1
        if Time(i+1,i)~=0
            x(i)=1+(i)*2*size+d_xy+size/2*(cos(pi+theta)-cos(5*pi/4));
            y(i)=1+(i)*2*size+d_xy+size/2*(sin(pi+theta)-sin(5*pi/4));
            u(i)=-size-2*d_xy;
            v(i)=u(i);
        end
    end
end

end

