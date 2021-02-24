function [ c,b ] = constraints_specific(R,d,A,eps)
%Returns linear constraints regarding the systems speed towards the facets
%depending on which facet is the goal.
%i.e. the constraints which ensure that only the goal facet is reached
if abs(d)==1
    %constraints stating that no other facet is reached
    c(1,:)=[0 0 0 -R(2,1) -R(1,2) -1];
    c(2,:)=[0 0 0 R(1,1) R(2,2) 1];
    c(3,:)=[0 0 0 R(2,1) R(2,2) 1];
    c(4,:)=[0 0 0 -R(1,1) -R(1,2) -1];
    b(1)=A(2,2)*R(1,2)+A(2,1)*R(1,2)-eps;
    b(2)=-A(2,2)*R(2,2)-A(2,1)*R(1,1)-eps;
    b(3)=-A(2,2)*R(2,2)-A(2,1)*R(1,2)-eps;
    b(4)=A(2,2)*R(1,2)+A(2,1)*R(1,1)-eps;
    if d==-1
        %constraints stating that the speed towards the goal facet is
        %positive in the entire rectangle
        c(5,:)=[R(1,1) R(2,2) 1 0 0 0];
        c(6,:)=[R(2,1) R(2,2) 1 0 0 0];
        c(7,:)=[R(1,1) R(1,2) 1 0 0 0];
        c(8,:)=[R(2,1) R(1,2) 1 0 0 0];
        b(5)=-(A(1,1)*R(1,1)+A(1,2)*R(2,2))-eps;
        b(6)=-(A(1,1)*R(2,1)+A(1,2)*R(2,2))-eps;
        b(7)=-(A(1,1)*R(1,1)+A(1,2)*R(1,2))-eps;
        b(8)=-(A(1,1)*R(2,1)+A(1,2)*R(1,2))-eps;
    else %d=1
        %constraints stating that the speed towards the goal facet is
        %positive in the entire rectangle
        c(5,:)=-[R(1,1) R(2,2) 1 0 0 0];
        c(6,:)=-[R(2,1) R(2,2) 1 0 0 0];
        c(7,:)=-[R(1,1) R(1,2) 1 0 0 0];
        c(8,:)=-[R(2,1) R(1,2) 1 0 0 0];
        b(5)=A(1,1)*R(1,1)+A(1,2)*R(2,2)-eps;
        b(6)=A(1,1)*R(2,1)+A(1,2)*R(2,2)-eps;
        b(7)=A(1,1)*R(1,1)+A(1,2)*R(1,2)-eps;
        b(8)=A(1,1)*R(2,1)+A(1,2)*R(1,2)-eps;
    end
else %absd=2
    %constraints stating that no other facet is reached
    c(1,:)=[-R(1,1) -R(2,2) -1 0 0 0];
    c(2,:)=[R(2,1) R(1,2) 1 0 0 0];
    c(3,:)=[R(2,1) R(2,2) 1 0 0 0];
    c(4,:)=[-R(1,1) -R(1,2) -1 0 0 0];
    b(1)=A(1,1)*R(1,1)+A(1,2)*R(2,2)-eps;
    b(2)=-A(1,1)*R(2,1)-A(1,2)*R(1,2)-eps;
    b(3)=-A(1,1)*R(2,1)-A(1,2)*R(2,2)-eps;
    b(4)=A(1,2)*R(1,2)+A(1,1)*R(1,1)-eps;
    if d==-2
        %constraints stating that the speed towards the goal facet is
        %positive in the entire rectangle
        c(5,:)=[0 0 0 R(1,1) R(2,2) 1];
        c(6,:)=[0 0 0 R(2,1) R(2,2) 1];
        c(7,:)=[0 0 0 R(1,1) R(1,2) 1];
        c(8,:)=[0 0 0 R(2,1) R(1,2) 1];
        b(5)=-(A(2,1)*R(1,1)+A(2,2)*R(2,2))-eps;
        b(6)=-(A(2,1)*R(2,1)+A(2,2)*R(2,2))-eps;
        b(7)=-(A(2,1)*R(1,1)+A(2,2)*R(1,2))-eps;
        b(8)=-(A(2,1)*R(2,1)+A(2,2)*R(1,2))-eps;
    else %d=2
        %constraints stating that the speed towards the goal facet is
        %positive in the entire rectangle
        c(5,:)=-[0 0 0 R(1,1) R(2,2) 1];
        c(6,:)=-[0 0 0 R(2,1) R(2,2) 1];
        c(7,:)=-[0 0 0 R(1,1) R(1,2) 1 ];
        c(8,:)=-[0 0 0 R(2,1) R(1,2) 1];
        b(5)=A(2,1)*R(1,1)+A(2,2)*R(2,2)-eps;
        b(6)=A(2,1)*R(2,1)+A(2,2)*R(2,2)-eps;
        b(7)=A(2,1)*R(1,1)+A(2,2)*R(1,2)-eps;
        b(8)=A(2,1)*R(2,1)+A(2,2)*R(1,2)-eps;
    end
end
end

