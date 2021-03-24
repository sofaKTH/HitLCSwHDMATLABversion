
function [ u_tranx, u_trank] = Transition_control( A,B,U,R,d ,opt_c,eps,lin_ass,u_joint)
%Takes A,B which describes the system, U which is the limit of control, R
%which is the rectangle and d which indicates the direction of the facet 
%(1(x), -1(-x), -2(-y) or 2(y)).
%Returns the optimal control input which yields the transition.

%set options to remove print outs
options=optimoptions('fmincon','display','none');
    function k=setConstants()
        if lin_ass==1
            k=[-A(1,2) -A(2,1)];
        else
            k=[0 0];
        end
    end
    function [c,b]=controlLimits()
        type=u_joint;
        if type==0
            if lin_ass==1
                [c,b]=constraints_general_lin(B,R,U,k);
            else
                [c,b]=constraints_general(B,R,U);
            end
        else
            c=[];b=[];
        end
    end
    function [c,b]=velocityLimits()
        type=lin_ass;
        if type==1
            [c,b]=constraints_specific_lin(R,d,A,eps);
        else
            [c,b]=constraints_specific(R,d,A,eps);
        end
    end
    function [x1,x2]=setOptimizationCorner()
        if opt_c==11 || (opt_c==0 && d>0)%min,min
            x1=R(1,1);x2=R(1,2);
        elseif opt_c==12 %min,max
            x1=R(1,1);x2=R(2,2);
        elseif opt_c==21 %max,min
            x1=R(2,1);x2=R(1,2);
        elseif opt_c==22 || (opt_c==0 && d<0)%max,max
            x1=R(2,1);x2=R(2,2);
        else  %middle
            x1=(R(2,1)+R(1,1))/2;x2=(R(2,2)+R(1,2))/2;
        end 
    end
    function y0=setInitialGuess()
        if lin_ass==1
            y0=ones(1,4);
        else
            y0=[1 1 -A(1,2) -A(2,1) 1 1];
        end
    end
    function xdot=setSystemFunction()
        if lin_ass==0
            xdot=@(y) [A(1,1)+y(1), A(1,2)+y(2);A(2,1)+y(4), A(2,2)+y(5)]...
                *[x1; x2]+[y(3); y(6)];
        else
            xdot=@(y) [A(1,1)+y(1), 0;0, A(2,2)+y(3)]...
                *[x1; x2]+[y(2); y(4)];
        end
    end
    function f=setOptimizationFunction()
        if d==1
            f=@(y) max([1 0]*xdot(y));
        elseif d==-1
            f=@(y) max([-1 0]*xdot(y));
        elseif d==2
            f=@(y) max([0 1]*xdot(y));
        else %d==-2
            f=@(y) max([0 -1]*xdot(y));
        end
    end

%set properties
k=setConstants(); %assumed values on diagonal of K1
[con,b]=velocityLimits(); %constraints on velocity
[con2,b2]=controlLimits(); %constraints on control
con_tot=[con2;con]; b_tot=[b2';b']; %merge constraints
[x1,x2]=setOptimizationCorner(); %corner to optimize for
y0=setInitialGuess(); %initial optimization guess
xdot=setSystemFunction(); %system dynamics
f=setOptimizationFunction(); %function to minimize

if d==1
    gs=GlobalSearch;gs.Display='off';
    if u_joint==1 %if unlinear constr are used
        problem=createOptimProblem('fmincon','x0',y0,'objective',f,'nonlcon',@(y)constraint_general_joint(y,B,R,U,lin_ass,k),'Aineq',con_tot,'bineq',b_tot,'options',options);
        [y,fmin,flag,outpt,allmins]=run(gs,problem);
    else %if all constr are linear
        [y,feval,flag,output,lambda] = fmincon(f,y0,con_tot,b_tot,[],[],[],[],[],options);
    end
elseif  d==-1
    gs=GlobalSearch;gs.Display='off';
    if u_joint==1
        problem=createOptimProblem('fmincon','x0',y0,'objective',f,'nonlcon',@(y)constraint_general_joint(y,B,R,U,lin_ass,k),'Aineq',con_tot,'bineq',b_tot,'options',options);
        [y,fmin,flag,outpt,allmins]=run(gs,problem);
    else
        [y,feval,flag,output,lambda] = fmincon(f,y0,con_tot,b_tot,[],[],[],[],[],options);
    end
elseif d==2
    if u_joint==1
        [y,feval,flag,output,lambda] = fmincon(f,y0,con_tot,b_tot,[],[],[],[],@(y)constraint_general_joint(y,B,R,U,lin_ass,k),options);
    else
        [y,feval,flag,output,lambda] = fmincon(f,y0,con_tot,b_tot,[],[],[],[],[],options);
    end
else % d=-2
    if u_joint==1
        [y,feval,flag,output,lambda] = fmincon(f,y0,con_tot,b_tot,[],[],[],[],@(y)constraint_general_joint(y,B,R,U,lin_ass,k),options);
    else
        [y,feval,flag,output,lambda] = fmincon(f,y0,con_tot,b_tot,[],[],[],[],[],options);
    end
end
%build matrices
if lin_ass==1
    u_tranx=[y(1) k(1); k(2) y(3)];
    u_trank=[y(2);y(4)];
else
    u_tranx=[y(1) y(2); y(4) y(5)];
    u_trank=[y(3);y(6)];
end
end

