function [P] = sparseProduct( T,A,set )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

P.S=cartesian_product(T.S,A.S);
q=length(P.S);
P.Q=1:q;

P.trans.in=inf*ones(q,q);
P.trans.out=inf*ones(q,q);
for q1=1:q
    for q2=1:q
        sta1=P.S(q1,1); sta2=P.S(q2,1);
        loc1=P.S(q1,2); loc2=P.S(q2,2);
        if T.time.in(sta1,sta2)~=inf%sta2 is a succ of sta1
            for ind=1:size(A.trans,3)
                if A.trans(loc1,T.L(sta2),ind)==loc2
                    P.trans.in(q1,q2)=T.time.in(sta1,sta2);
                    P.trans.out(q1,q2)=T.time.out(sta1,sta2);
                end
            end
        end
    end
end

P.final=[];


for x=1:q
    loc=P.S(x,2); sta=P.S(x,1);
    if loc==A.final
        P.final=[P.final x];
    end
    if set==1
        P.Ix(x)=A.Ix(loc);
    else
        for x2=1:q
            loc2=P.S(x2,2);
            P.Ix(x,x2)=A.Ix(loc,loc2);
            P.Ixup(x,x2)=A.Ixup(loc,loc2);
        end
    end
    P.Ih(x,1)=A.Ih(1,loc);
    P.Ih(x,2)=A.Ih(2,loc);
    if loc==A.init && sta==T.current
        P.init=x;
    end
end
P.X=A.X;
P.Xv=A.Xv;


end

