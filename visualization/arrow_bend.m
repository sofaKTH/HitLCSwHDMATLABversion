function [ x,y,u,v ] = arrow_bend( dir,size,s,Time,const )
%UNTITLED3 Summary of this function goes here
%   x,y,u,v are matrices. each row is an arrow, last element in each row is
%   the actual arrowhead, the others should be lines.
%const=100;
x=zeros(s-abs(dir),const);
y=zeros(s-abs(dir),const);
u=zeros(s-abs(dir),const);
v=zeros(s-abs(dir),const);
if dir>0
    for j=1:s-dir
        if Time(j,j+dir)~=0
            x0j=1+(j-1)*2*size+size/2;
            x0dir=1+(j+dir-1)*2*size+size/2;
            x0=(x0dir+x0j)/2;
            r=sqrt(2*(size*dir)^2);
            theta_diff=size/(2*r);
            theta=[-3*pi/4+theta_diff:(pi-2*theta_diff)/const:pi/4-theta_diff];
            for i=1:const
                x(j,i)=x0+r*cos(theta(i));
                y(j,i)=x0+r*sin(theta(i));
                u(j,i)=x0+r*cos(theta(i+1))-x(j,i);
                v(j,i)=x0+r*sin(theta(i+1))-y(j,i);
            end
        end
    end
else
    for j=1:s-abs(dir)
        if Time(j,j-dir)~=0
            x0j=1+(j-1)*2*size+size/2;
            x0dir=1+(j-dir-1)*2*size+size/2;
            x0=(x0dir+x0j)/2;
            r=sqrt(2*(size*dir)^2);
            theta_diff=size/(2*r);
            theta=[pi/4+theta_diff:(pi-2*theta_diff)/const:5*pi/4-theta_diff];
            for i=1:const
                x(j,i)=x0+r*cos(theta(i));
                y(j,i)=x0+r*sin(theta(i));
                u(j,i)=x0+r*cos(theta(i+1))-x(j,i);
                v(j,i)=x0+r*sin(theta(i+1))-y(j,i);
            end
        end
    end
end
end

