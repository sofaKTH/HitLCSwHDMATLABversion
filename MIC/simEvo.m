function [ t ,xq, K] = simEvo( q1,q2,A,TS,x0,y0,T, Uh,QT,T0,dt,eps,umax )
%UNTITLED Summary of this function goes here

 Ua11=full(TS.ux_11);Ua12=full(TS.ux_12);Ua21=full(TS.ux_21);Ua22=full(TS.ux_22);
 Ub2=full(TS.uk_1);Ub1=full(TS.uk_2);
 a11=A(1,1);%+Ua11(q1,q2);
 a12=A(1,2);%+Ua12(q1,q2);
 a21=A(2,1);%+Ua21(q1,q2);
 a22=A(2,2);%+Ua22(q1,q2);
 b1=Ub1(q1,q2);b2=Ub2(q1,q2);
 Astar=[a11 a12;a21 a22];
 Bstar=[b1; b2];
 high=length(TS.S)/TS.N1;
 max=length(TS.S);
 [t,xq, K]=ode45(@myfun,[0,T],[x0;y0]);
    function [dx,K]=myfun(t,x)
    dx1=[a11 a12; a21 a22]*x;%+[b1;b2];
    dx2=[Uh(1:2); Uh(3:4)]*x+[Uh(5); Uh(6)];
    dx3=[Ua11(q1,q2) Ua12(q1,q2); Ua21(q1,q2) Ua22(q1,q2)]*x+[b1; b2];
    ds=ones(1,4)*Inf;
    if q1-high>0
        if timeMember(q1-high,QT, T0+T)
            ds(1)=abs(x(1)-TS.R(1,1,q1));% left
            fprintf('dtleft: %f\t',ds(1));
        end
    end
    if q1+high<max+1
        if timeMember(q1+high,QT, T0+T)
            ds(2)=abs(x(1)-TS.R(2,1,q1));%right
            fprintf('dtright: %f\t',ds(2));
        end
    end
    if q1-1>0
        if timeMember(q1-1,QT, T0+T)
            ds(3)=abs(x(2)-TS.R(1,2,q1));%down
            fprintf('dtdown: %f\t',ds(3));
        end
    end
    if q1+1<max+1
        if timeMember(q1+1,QT, T0+T)
            ds(4)=abs(x(2)-TS.R(2,2,q1));%up
            fprintf('dtup: %f\t',ds(4));
        end
    end
    DS=min(ds);
    K=rhofunc(DS,dt,eps );
    fprintf('K is: %f\n', K);
    du=dx3+K*dx2;
    du=du/norm(du)*umax;
    dx=dx1+du;
    
    end

end

