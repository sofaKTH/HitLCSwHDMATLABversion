function [xq,t] = followPlan(s1,s2,env, dWTS,x0)
%returns trajectory xq and time vector t describing how the system evolves 
%s1=current region, s2=next region, T=time duration, x0=initial
%position=[x1;x2]

%control input
 Ua11=full(dWTS.ux_11);Ua12=full(dWTS.ux_12);
 Ua21=full(dWTS.ux_21);Ua22=full(dWTS.ux_22);
 Ub1=full(dWTS.uk_1);Ub2=full(dWTS.uk_2);
 
 %system dyn
 A=env.A+[Ua11(s1,s2) Ua12(s1,s2); Ua21(s1,s2) Ua22(s1,s2)];
 B=[Ub1(s1,s2); Ub2(s1,s2)];

 fprintf('A is [%f, %f; %f, %f]\n B is [%f; %f]\n',A(1,1), A(1,2), A(2,1), A(2,2),B(1), B(2));
 
 %function (go until new region is reached)
 T=0.1; %any number is fine but too large is uneccessary
 xq=x0'; t=0;
 Opt    = odeset('Events', @myEvent);
 fprintf('\n-----------------\n Transition: %d-> %d\n------------\n',s1,s2);
 while checkRegion(xq(end,:),dWTS)==s1
    tinit=t(end); xinit=xq(end,:);
    [tstep,xstep]=ode45(@myfun,[tinit,T+tinit],xinit, Opt);
    xq=[xq; xstep(2:end,:)]; t=[t; tstep(2:end)];
    fprintf('(x,y)=(%d,%d), t=%d\n',xq(end,1), xq(end,2),t(end));
 end
fprintf('Done!\n');

    function [dx]=myfun(t,x)
    dx=A*x+B;
    end
    function [value, isterminal, direction] = myEvent(t, x)
        value      = (checkRegion(x,dWTS) ~=s1);
        isterminal = 1;   % Stop the integration
        direction  = 0;
    end
end

