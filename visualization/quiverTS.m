function [pathmovie, quivermovie] = quiverTS( R, ux_11,ux_12,ux_21,ux_22,uk1,uk2,path,A )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
a=0.1; %step
n=2;
visited=zeros(1,length(R));

%movie of the path which was found
F(length(path)) = struct('cdata',[],'colormap',[]);
for z=1:length(path)
    for i=1:length(R)%plot state space and edges
        rectangle('Position',[R(1,1,i) R(1,2,i) (R(2,1,i)-R(1,1,i)) (R(2,2,i)-R(1,2,i))]);
        hold on
    end
    dx=(R(2,1,path(z))-R(1,1,path(z)))/n;
    dy=(R(2,2,path(z))-R(1,2,path(z)))/n;
    %circle at the state
    if visited(path(z))==n^2
        visited(path(z))=0;
    end
    ytimes=floor(visited(path(z))/n);
    xtimes=mod(visited(path(z)),n);
    pos=[R(1,1,path(z))+xtimes*dx R(1,2,path(z))+ytimes*dy (R(2,1,path(z))-R(1,1,path(z)))/n (R(2,2,path(z))-R(1,2,path(z)))/n];
    if z>1
        plot([prevpos(1) + prevpos(3)/2, pos(1)+pos(3)/2],[prevpos(2) + prevpos(4)/2, pos(2)+pos(4)/2]);
        rectangle('Position',prevpos,'Curvature',[1,1],'FaceColor',[.75 .25 .5]);
        text(prevpos(1)+prevpos(3)/2, prevpos(2)+prevpos(4)/2,int2str(z-1));
    end
    rectangle('Position',pos,'Curvature',[1,1],'FaceColor',[.75 .25 .5]);
    visited(path(z))=visited(path(z))+1;
    text(pos(1)+pos(3)/2, pos(2)+pos(4)/2,int2str(z));
    prevpos=pos;
    F(z)=getframe(gcf);
end
pathmovie=F;
%movie(pathmovie,F,1,1);
figure;
%movie of the direction of the closed-loop system in the states of the path
G(length(path)-1) = struct('cdata',[],'colormap',[]);
for z=1:length(path)-1
    for i=1:length(R)%plot state space and edges
        rectangle('Position',[R(1,1,i) R(1,2,i) (R(2,1,i)-R(1,1,i)) (R(2,2,i)-R(1,2,i))]);
        hold on
    end
    %quivers
    xstep=[R(1,1,path(z)):a:R(2,1,path(z))];
    ystep=[R(1,2,path(z)):a:R(2,2,path(z))];
    x=zeros(length(xstep)*length(ystep),1);
    y=zeros(length(xstep)*length(ystep),1);
    for j=1:length(ystep)
        x(1+(j-1)*length(xstep):j*length(xstep))=xstep;
    end
    for j=1:length(ystep)
        y(1+(j-1)*length(xstep):j*length(xstep))=ystep(j);
    end
    U=@(q,w) [ux_11(path(z),path(z+1))+A(1,1) ux_12(path(z),path(z+1))+A(1,2);ux_21(path(z),path(z+1))+A(2,1) ux_22(path(z),path(z+1))+A(2,2)]*[q;w]; %+[uk1(path(z),path(z+1));uk2(path(z),path(z+1))];
    Sol=U(x',y');
    u=Sol(1,:)+uk1(path(z),path(z+1));
    v=Sol(2,:)+uk2(path(z),path(z+1));
    q(z)=quiver(x',y',u,v);
    strleg=['Transition from state ' int2str(path(z)) ' to state ' int2str(path(z+1))];
    h=legend(q(z),strleg);
    set(h,'Location','NorthOutside');
    legend_info{z}=[strleg];
    G(z)=getframe(gcf);
end
h=legend(legend_info);
set(h,'Location','NorthOutside');
G(length(path))=getframe(gcf);
quivermovie=G;
%movie(quivermovie,G,2,1);

end

