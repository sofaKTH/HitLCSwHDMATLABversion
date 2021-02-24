function [ c,ceq ] = constraint_general_joint(y,B,R,U,lin_ass,k)
%Returns non-linear constraints to the optimization problem.
%Constraints regarding u limit for the option (u1^2+u2^2)^(1/2)<=umax
Binv=B\eye(2,2);
if lin_ass==1 %if assumption of simplified time calculation is used
    c(1)=([Binv(1,1)*R(1,1)  Binv(1,1)  Binv(1,2)*R(1,2) Binv(1,2)]*y'+Binv(1,1)*R(1,2)*k(1)+Binv(1,2)*R(1,1)*k(2))^2+([Binv(2,1)*R(1,1)  Binv(2,1)  Binv(2,2)*R(1,2) Binv(2,2)]*y'+Binv(2,1)*R(1,2)*k(1)+Binv(2,2)*R(1,1)*k(2))^2-U(2)^2;
    c(2)=([Binv(1,1)*R(2,1)  Binv(1,1)  Binv(1,2)*R(1,2) Binv(1,2)]*y'+Binv(1,1)*R(1,2)*k(1)+Binv(1,2)*R(2,1)*k(2))^2+([Binv(2,1)*R(2,1)  Binv(2,1)  Binv(2,2)*R(1,2) Binv(2,2)]*y'+Binv(2,1)*R(1,2)*k(1)+Binv(2,2)*R(2,1)*k(2))^2-U(2)^2;
    c(3)=([Binv(1,1)*R(1,1)  Binv(1,1)  Binv(1,2)*R(2,2) Binv(1,2)]*y'+Binv(1,1)*R(2,2)*k(1)+Binv(1,2)*R(1,1)*k(2))^2+([Binv(2,1)*R(1,1)  Binv(2,1)  Binv(2,2)*R(2,2) Binv(2,2)]*y'+Binv(2,1)*R(2,2)*k(1)+Binv(2,2)*R(1,1)*k(2))^2-U(2)^2;
    c(4)=([Binv(1,1)*R(2,1)  Binv(1,1)  Binv(1,2)*R(2,2) Binv(1,2)]*y'+Binv(1,1)*R(2,2)*k(1)+Binv(1,2)*R(2,1)*k(2))^2+([Binv(2,1)*R(2,1)  Binv(2,1)  Binv(2,2)*R(2,2) Binv(2,2)]*y'+Binv(2,1)*R(2,2)*k(1)+Binv(2,2)*R(2,1)*k(2))^2-U(2)^2;
else 
    c(1)=([Binv(1,1)*R(1,1) Binv(1,1)*R(1,2) Binv(1,1) Binv(1,2)*R(1,1) Binv(1,2)*R(1,2) Binv(1,2)]*y')^2+([Binv(2,1)*R(1,1) Binv(2,1)*R(1,2) Binv(2,1) Binv(2,2)*R(1,1) Binv(2,2)*R(1,2) Binv(2,2)]*y')^2-U(2)^2;
    c(2)=([Binv(1,1)*R(2,1) Binv(1,1)*R(1,2) Binv(1,1) Binv(1,2)*R(2,1) Binv(1,2)*R(1,2) Binv(1,2)]*y')^2+([Binv(2,1)*R(2,1) Binv(2,1)*R(1,2) Binv(2,1) Binv(2,2)*R(2,1) Binv(2,2)*R(1,2) Binv(2,2)]*y')^2-U(2)^2;
    c(3)=([Binv(1,1)*R(1,1) Binv(1,1)*R(2,2) Binv(1,1) Binv(1,2)*R(1,1) Binv(1,2)*R(2,2) Binv(1,2)]*y')^2+([Binv(2,1)*R(1,1) Binv(2,1)*R(2,2) Binv(2,1) Binv(2,2)*R(1,1) Binv(2,2)*R(2,2) Binv(2,2)]*y')^2-U(2)^2;
    c(4)=([Binv(1,1)*R(2,1) Binv(1,1)*R(2,2) Binv(1,1) Binv(1,2)*R(2,1) Binv(1,2)*R(2,2) Binv(1,2)]*y')^2+([Binv(2,1)*R(2,1) Binv(2,1)*R(2,2) Binv(2,1) Binv(2,2)*R(2,1) Binv(2,2)*R(2,2) Binv(2,2)]*y')^2-U(2)^2;
end
ceq=[];
end

