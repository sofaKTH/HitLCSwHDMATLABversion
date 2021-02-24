function [ Qd ] = hardConVio( P)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
Qdinv=P.final;
set=P.final;
while ~isempty(set)
    new=[];
    for q1=P.Q
        clockhigh=zeros(1,length(P.X));clocklow=zeros(1,length(P.X));
        if ~ismember(q1,Qdinv)
            for q2=set
                if P.trans(q1,q2)~=Inf && P.Ix(q1,q2)==0 && P.Ixup(q1,q2)==0
                    %reach(q1)=set for any time
                    new=[new q1];
                elseif P.trans(q1,q2)~=Inf && P.Ix(q1,q2)~=0
                    clocklow(P.Ix(q1,q2))=1;
                elseif P.trans(q1,q2)~=Inf && P.Ixup(q1,q2)~=0
                    clockhigh(P.Ixup(q1,q2))=1;
                end
            end
            for i=1:length(P.X)
                if clockhigh(i)==1 && clocklow(i)==1
                    %there is a trans to Qdinv for all time (but to diff
                    %states)
                    new=[new q1];
                end
            end
        end
    end
    Qdinv=[Qdinv new];
    set=new;
end
%Qdinv should now contain all states which are predecessors to the accepting
%states for any time, this can be optimized some by looking for the locations in TAhd
%instead and then checking which states in P they corr to
Qd=[];
for q=P.Q
    if ~ismember(q,Qdinv)
        Qd=[Qd q];
    end
end
%Qd should now include all states which can never reach accepting states
end

