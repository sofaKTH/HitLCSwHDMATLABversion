function []=TS_viz( S,ux,uk,Time,N1)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
figure;
hold on;
%set values
side=1/2;
%Print circle for each state
for i=1:length(S)
    pos=[1+(i-1)*2*side 1+(i-1)*2*side side side];
    rectangle('Position',pos,'Curvature',[1 1]);
    text(i+side/2,i+side/2,int2str(i));
end

%Print edges 
%straight arrows (for edges i to i-1 or i to i+1)
[x1, y1, u1, v1]=arrow(1,side,length(S),Time );
[x2, y2, u2, v2]=arrow(-1,side,length(S),Time );
%add up all straight arrow-types
x=[x1 x2];
y=[y1 y2];
u=[u1 u2];
v=[v1 v2];
quiver(x,y,u,v, 'AutoScale','off','Color','blue','MaxHeadSize',0.05);
str={'$u_{1}$'; '$u_{2}$'; '$u_{3}$'; '$u_{4}$'; '$u_{5}$'; '$u_{6}$'; '$u_{7}$'; '$u_{8}$';'$u_{9}$';'$u_{10}$';'$u_{11}$';'$u_{12}$'};
j=1;
for i=1:length(S)-1
    if x1(i)~=0
    text(x1(i)+u1(i)/2,y1(i)+v1(i)/3,str{j},'Interpreter','latex');
    hold on
        j=j+1;
    end
    if x2(i)~=0
    text(x2(i)+u2(i),y2(i)+v2(i)/5,str{j},'Interpreter','latex');
    hold on
        j=j+1;
    end
end

%bend arrows (tarnsitions through facets in +-x1 dir)
const=3;
[x,y,u,v]=arrow_bend(N1,side,length(S),Time,const);
[x2,y2,u2,v2]=arrow_bend(-N1,side,length(S),Time,const);

str_2={'$u_{13}$', '$u_{14}$', '$u_{15}$', '$u_{16}$'};
j2=1;
for i=1:length(x(:,1))
    if x(i,1)~=0
        line(x(i,:),y(i,:),'Color','blue');
        hold on
        text(3*x(i,3)/4+x(i,2)/4, 3*y(i,2)/4+y(i,3)/4, str_2{j2},'Interpreter','latex');
        j2=j2+1;
        quiver(x(i,end),y(i,end),u(i,end),v(i,end),'AutoScale','off', 'Color','blue');
        hold on
    end
end
for i=1:length(x2(:,1))
    if x2(i,1)~=0
        line(x2(i,:),y2(i,:),'Color','blue');
        hold on
        text((3*x2(i,3)+x2(i,2))/4, (y2(i,3)+3*y2(i,2))/4, str_2{j2},'Interpreter','latex');
        j2=j2+1;
        quiver(x2(i,end),y2(i,end),u2(i,end),v2(i,end),'AutoScale','off', 'Color','blue');
        hold on
    end
end

%add text box


end

