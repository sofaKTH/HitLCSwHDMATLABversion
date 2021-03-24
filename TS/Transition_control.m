
function [ K1, K2] = Transition_control( A,B,U,R,d ,opt_c,eps,lin_ass,u_joint)
%Takes A,B which describes the system, U which is the limit of control, R
%which is the rectangle and d which indicates the direction of the facet 
%(1(x), -1(-x), -2(-y) or 2(y)).
%Returns the optimal control input which yields the transition.
%The system dynamics are: xdot=Ax+Bu, u=K1x+K2-> xdot=(A+BK1)x+BK2
%This code returns the optimal values on K1 and K2 such that the velocity
%inthe transition direction is maximized, while constraints are put on the
%edges of the current region s.t. the velocity is negative in the directio
%towards other edges on said edge. 

%set options to remove print outs
options=optimoptions('fmincon','display','none');
    function k=setConstants()
        if lin_ass==1 %assumes that the diagonal of K1 cancels the diagonal of A
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
    function y=solveOptimization()
        if u_joint==1
            [y,~] = fmincon(f,y0,con_tot,b_tot,[],[],[],[],@(y)constraint_general_joint(y,B,R,U,lin_ass,k),options);
        else
            [y,~] = fmincon(f,y0,con_tot,b_tot,[],[],[],[],[],options);
        end
    end
    function [K1,K2]=getControlMatrices()
        if lin_ass==1
            K1=[y(1) k(1); k(2) y(3)];
            K2=[y(2);y(4)];
        else
            K1=[y(1) y(2); y(4) y(5)];
            K2=[y(3);y(6)];
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

%solve problem and create matrices K1 and K2
y=solveOptimization();
[K1,K2]=getControlMatrices();
end

