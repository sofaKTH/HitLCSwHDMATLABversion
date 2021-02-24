function [c, b]=constraints_general(B,R,U)
%Returns linear constraints regarding the limit on u
% umin<=ui<=umax, i=1,2
Binv=B\eye(2,2);
%Conditions regarding u1 not being greater than umax in any corner
c(1,:)=[Binv(1,1)*R(1,1) Binv(1,1)*R(1,2) Binv(1,1) Binv(1,2)*R(1,1) Binv(1,2)*R(1,2) Binv(1,2)];
c(2,:)=[Binv(1,1)*R(2,1) Binv(1,1)*R(1,2) Binv(1,1) Binv(1,2)*R(2,1) Binv(1,2)*R(1,2) Binv(1,2)];
c(3,:)=[Binv(1,1)*R(1,1) Binv(1,1)*R(2,2) Binv(1,1) Binv(1,2)*R(1,1) Binv(1,2)*R(2,2) Binv(1,2)];
c(4,:)=[Binv(1,1)*R(2,1) Binv(1,1)*R(2,2) Binv(1,1) Binv(1,2)*R(2,1) Binv(1,2)*R(2,2) Binv(1,2)];
b(1)=U(2);
b(2)=U(2);
b(3)=U(2);
b(4)=U(2);
%Conditions regarding u2 not being greater than umax in any corner
c(5,:)=[Binv(2,1)*R(1,1) Binv(2,1)*R(1,2) Binv(2,1) Binv(2,2)*R(1,1) Binv(2,2)*R(1,2) Binv(2,2)];
c(6,:)=[Binv(2,1)*R(2,1) Binv(2,1)*R(1,2) Binv(2,1) Binv(2,2)*R(2,1) Binv(2,2)*R(1,2) Binv(2,2)];
c(7,:)=[Binv(2,1)*R(1,1) Binv(2,1)*R(2,2) Binv(2,1) Binv(2,2)*R(1,1) Binv(2,2)*R(2,2) Binv(2,2)];
c(8,:)=[Binv(2,1)*R(2,1) Binv(2,1)*R(2,2) Binv(2,1) Binv(2,2)*R(2,1) Binv(2,2)*R(2,2) Binv(2,2)];
b(5)=U(2);
b(6)=U(2);
b(7)=U(2);
b(8)=U(2);
%Conditions regarding u1 not being less than umin in any corner
c(9,:)=-[Binv(1,1)*R(1,1) Binv(1,1)*R(1,2) Binv(1,1) Binv(1,2)*R(1,1) Binv(1,2)*R(1,2) Binv(1,2)];
c(10,:)=-[Binv(1,1)*R(2,1) Binv(1,1)*R(1,2) Binv(1,1) Binv(1,2)*R(2,1) Binv(1,2)*R(1,2) Binv(1,2)];
c(11,:)=-[Binv(1,1)*R(1,1) Binv(1,1)*R(2,2) Binv(1,1) Binv(1,2)*R(1,1) Binv(1,2)*R(2,2) Binv(1,2)];
c(12,:)=-[Binv(1,1)*R(2,1) Binv(1,1)*R(2,2) Binv(1,1) Binv(1,2)*R(2,1) Binv(1,2)*R(2,2) Binv(1,2)];
b(9)=-U(1);
b(10)=-U(1);
b(11)=-U(1);
b(12)=-U(1);
%Conditions regarding u2 not being less than umin in any corner
c(13,:)=-[Binv(2,1)*R(1,1) Binv(2,1)*R(1,2) Binv(2,1) Binv(2,2)*R(1,1) Binv(2,2)*R(1,2) Binv(2,2)];
c(14,:)=-[Binv(2,1)*R(2,1) Binv(2,1)*R(1,2) Binv(2,1) Binv(2,2)*R(2,1) Binv(2,2)*R(1,2) Binv(2,2)];
c(15,:)=-[Binv(2,1)*R(1,1) Binv(2,1)*R(2,2) Binv(2,1) Binv(2,2)*R(1,1) Binv(2,2)*R(2,2) Binv(2,2)];
c(16,:)=-[Binv(2,1)*R(2,1) Binv(2,1)*R(2,2) Binv(2,1) Binv(2,2)*R(2,1) Binv(2,2)*R(2,2) Binv(2,2)];
b(13)=-U(1);
b(14)=-U(1);
b(15)=-U(1);
b(16)=-U(1);

end