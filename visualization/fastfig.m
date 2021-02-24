function [  ] = fastfig( T,path, env )
%FASTFIG Summary of this function goes here
%   Detailed explanation goes here
R=T.R; ux_11=T.ux_11;ux_12=T.ux_12;ux_21=T.ux_21;ux_22=T.ux_22;
uk1=T.uk_1; uk2=T.uk_2;A=env.A;
a=0.1; %step

ind=[1];
for z=2:length(path)
    for x=ind
        if path(z)==path(x) && z-x>1
            ind=[ind z];
        end
    end
end
ind=[ind length(path)];
col=['r','b','y'];

for k=1:length(ind)-1
    figure(k);
    legend_info=[];
    l=1;
    for z=ind(k):ind(k+1)-1
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
        %xvec{l}=x;
        %yvec{l}=y;
        u{l}=Sol(1,:)+uk1(path(z),path(z+1));
        v{l}=Sol(2,:)+uk2(path(z),path(z+1));
        q(l)=quiver(x',y',u{l},v{l}, 'color',col(l));
        strleg=sprintf('Transition from state %s to state %s',int2str(path(z)), int2str(path(z+1)));
        %set(h,'Location','NorthOutside');
        legend_info=[legend_info,  strleg];
        l=l+1;
        if l>3
            l=1;
        end
    end
    %h=legend(legend_info);
    %set(h,'Location','NorthOutside');
end
end

