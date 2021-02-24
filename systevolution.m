function [ t,xq, Astar, Bstar ] = systevolution( q1,q2,A,Ua11,Ua12,Ua21,Ua22,Ub1,Ub2,x0,y0,T,blend,step )
 
 Ua11=full(Ua11);Ua12=full(Ua12);Ua21=full(Ua21);Ua22=full(Ua22);
 Ub2=full(Ub2);Ub1=full(Ub1);
 a11=A(1,1)+Ua11(q1,q2);
 a12=A(1,2)+Ua12(q1,q2);
 a21=A(2,1)+Ua21(q1,q2);
 a22=A(2,2)+Ua22(q1,q2);
 b1=Ub1(q1,q2);b2=Ub2(q1,q2);
 Astar=[a11 a12;a21 a22];
 Bstar=[b1; b2];
 
 if isempty(blend)
    [t,xq]=ode45(@myfun,[0,T],[x0;y0]);
 else
     a11old=A(1,1)+Ua11(blend(1),q1);
     a12old=A(1,2)+Ua12(blend(1),q1);
     a21old=A(2,1)+Ua21(blend(1),q1);
     a22old=A(2,2)+Ua22(blend(1),q1);
     b1old=Ub1(blend(1),q1);b2old=Ub2(blend(1),q1);
     [t,xq]=ode45(@myfunblend,0:step:blend(2),[x0;y0]);
 end
    function [dx]=myfun(t,x)
    dx=[a11 a12; a21 a22]*x+[b1;b2];
    end

    function [dx]=myfunblend(t,x)
        [xx]=myfunblend2(x);
        [xxx]=myfun(t,x);
        if abs(q2-q1)==3 %sign(xx(1))~=sign(xxx(1))&& abs(q2-q1)==3 
            const1=0.8;
            const2=0;
        elseif abs(q2-q1)==1 %sign(xx(2))~=sign(xxx(2)) &&abs(q2-q1)==1 
            const2=0.8;
            const1=0;
        elseif q1==q2
            const1=1;
            const2=1;
        else
            const1=0;const2=0;
        end
        c1=@(t) const1+(1-const1)*t/(blend(2));
        c2=@(t) const2+(1-const2)*t/blend(2);
        dx=diag(([a11 a12; a21 a22]*x+[b1;b2])*[c1(t) c2(t)]+([a11old a12old; a21old a22old]*x+[b1old;b2old])*[1-c1(t) 1-c2(t)]);
    end
    function [dx]=myfunblend2(x)
        dx=([a11old a12old; a21old a22old]*x+[b1old;b2old]);
    end
end


