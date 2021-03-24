
function [ u_tranx, u_trank] = Transition_control( A,B,U,R,d ,opt_c,eps,lin_ass,u_joint)
%Takes A,B which describes the system, U which is the limit of control, R
%which is the rectangle and d which indicates the direction of the facet 
%(1, -1, -2 or 2).
%Returns the optimal control input which yields the transition.
%options = optimoptions('fmincon','TolX',1e-10);
options=optimoptions('fmincon','display','none');
y0=[1 1 -A(1,2) -A(2,1) 1 1]; %optimization guess

    function [c,b]=controlLimits(type)
        if type==0
            [c,b]=constraints_general_lin(B,R,U,k);
        else
            c=[];b=[];
        end
    end

if u_joint==0 %if umin<=ui<=umax for i=1,2 is used
    [con2, b2]=constraints_general(B,R,U);
else %if (u1^2+u2^2)^(1/2)<=umax is used
    con2=[];b2=[];
end
%set which position in the rectangle to optimize for
if opt_c==11 %min,min
    x1=R(1,1);x2=R(1,2);
elseif opt_c==12 %min,max
    x1=R(1,1);x2=R(2,2);
elseif opt_c==21 %max,min
    x1=R(2,1);x2=R(1,2);
elseif opt_c==22 %max,max
    x1=R(2,1);x2=R(2,2);
else  %middle
    x1=(R(2,1)+R(1,1))/2;x2=(R(2,2)+R(1,2))/2;
end
if d==1
    if opt_c==0 %update postion depending on direction, min,min
        x1=R(1,1);x2=R(1,2);
    end
    f=@(y) max(-[A(1,1)+y(1) A(1,2)+y(2)]*[x1; x2])-y(3); %function to minimize
    [con, b]=constraints_specific(R,d,A,eps); %constraints depending on direction
    if lin_ass==1 %if assumption: k12=-A(1,2), k21=-A(2,1)
       f=@(y) max(-(A(1,1)+y(1))*x1)-y(2);
       [con, b]=constraints_specific_lin(R,d,A,eps); %update constraints
       k=[-A(1,2) -A(2,1)];
       [con2,b2]=controlLimit(u_joint);
       y0=[1 1 1 1]; %decrease number of unknown
    else
        k=[0 0];
    end
    con_tot=[con2;con];b_tot=[b2';b'];%build together linear constraints
    gs=GlobalSearch;gs.Display='off';
    if u_joint==1 %if unlinear constr are used
        problem=createOptimProblem('fmincon','x0',y0,'objective',f,'nonlcon',@(y)constraint_general_joint(y,B,R,U,lin_ass,k),'Aineq',con_tot,'bineq',b_tot,'options',options);
        [y,fmin,flag,outpt,allmins]=run(gs,problem);
    else %if all constr are linear
        [y,feval,flag,output,lambda] = fmincon(f,y0,con_tot,b_tot,[],[],[],[],[],options);
    end
elseif  d==-1
    if opt_c==0
        x1=R(2,1);x2=R(2,2);
    end
    f=@(y) max([A(1,1)+y(1) A(1,2)+y(2)]*[x1; x2])+y(3);
    [con,b]=constraints_specific(R,d,A,eps);
    if lin_ass==1 %k12=0, k21=A(2,1)
       f=@(y) max((A(1,1)+y(1))*x1)+y(2);
       [con, b]=constraints_specific_lin(R,d,A,eps);
       k=[-A(1,2) -A(2,1)];
       [con2,b2]=controlLimit(u_joint);
       y0=[1 1 1 1];
    else
        k=[0 0];
    end
    con_tot=[con2;con];b_tot=[b2';b'];
    gs=GlobalSearch;gs.Display='off';
    if u_joint==1
        problem=createOptimProblem('fmincon','x0',y0,'objective',f,'nonlcon',@(y)constraint_general_joint(y,B,R,U,lin_ass,k),'Aineq',con_tot,'bineq',b_tot,'options',options);
        [y,fmin,flag,outpt,allmins]=run(gs,problem);
    else
        [y,feval,flag,output,lambda] = fmincon(f,y0,con_tot,b_tot,[],[],[],[],[],options);
    end
elseif d==2
    if opt_c==0
        x1=R(1,1);x2=R(1,2);
    end
    f=@(y) -(min([A(2,1)+y(4) A(2,2)+y(5)]*[x1;x2])+y(6));
    [con,b]=constraints_specific(R,d,A,eps);
    if lin_ass==1 %k12=-A(1,2), k21=0
       f=@(y) -min((A(2,2)+y(3))*x2)-y(4);
       [con, b]=constraints_specific_lin(R,d,A,eps);
       k=[-A(1,2) -A(2,1)];
       [con2,b2]=controlLimit(u_joint);
       y0=[1 1 1 1];
    else
       k=[0 0];
    end
    con_tot=[con2;con];b_tot=[b2';b'];
    if u_joint==1
        [y,feval,flag,output,lambda] = fmincon(f,y0,con_tot,b_tot,[],[],[],[],@(y)constraint_general_joint(y,B,R,U,lin_ass,k),options);
    else
        [y,feval,flag,output,lambda] = fmincon(f,y0,con_tot,b_tot,[],[],[],[],[],options);
    end
else % d=-2
    if opt_c==0
        x1=R(2,1);x2=R(2,2);
    end
%     x1=[R(1,1) R(2,1) R(1,1) R(2,1)];
%     x2=[R(1,2) R(2,2) R(2,2) R(1,2)];
    f=@(y) max([A(2,1)+y(4) A(2,2)+y(5)]*[x1;x2])+y(6);
    [con,b]=constraints_specific(R,d,A,eps);
    if lin_ass==1 %k12=-A(1,2), k21=0
       f=@(y) max((A(2,2)+y(3))*x2)+y(4);
       [con, b]=constraints_specific_lin(R,d,A,eps);
       k=[-A(1,2) -A(2,1)];
       [con2,b2]=controlLimit(u_joint);
       y0=[1 1 1 1];
    else
        k=[0 0];
    end
    con_tot=[con2;con];b_tot=[b2';b'];
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

