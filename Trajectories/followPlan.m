function [xq,t] = followPlan(s1,s2,env, dWTS, T, x0)
%returns trajectory xq and time vector t describing how the system evolves 
%s1=current region, s2=next region, T=time duration, x0=initial
%position=[x1;x2]

%control input
 Ua11=full(dWTS.ux_11);Ua12=full(dWTS.ux_12);
 Ua21=full(dWTS.ux_21);Ua22=full(dWTS.ux_22);
 Ub2=full(dWTS.uk_1);Ub1=full(dWTS.uk_2);
 
 %system dyn
 A=env.A+[Ua11(s1,s2) Ua12(s1,s2); Ua21(s1,s2) Ua22(s1,s2)];
 B=[Ub1(s1,s2); Ub2(s1,s2)];

[t,xq]=ode45(@myfun,[0,T],x0);

    function [dx]=myfun(x)
    dx=A*x+B;
    end
end

