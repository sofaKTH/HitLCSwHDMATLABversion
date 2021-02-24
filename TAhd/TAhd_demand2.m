function [ A, MITL] = TAhd_demand2( ap )
%TAHD_DEMAND constructs and returns a TAhd and the corresponding MITL
%formula
%ap=number of aps

%MITL: always(not a) eventually_within 5s (b)

n=6; %number of states
c=1; %number of clocks
AP=[1:ap];
A.C=[1:c]; %clocks
A.Q = [1:n]; %states
A.Sigma = [2:2^(ap+c+1)]; %actions -- encoded subsets of 2^T.Pi
A.F = [6]; %final state
A.current = 1; %initial
A.ddc=zeros(1,n); %continuous derivative setting
A.ddc(4)=1; A.ddc(5)=1;
A.ddd=zeros(1,n); %discrete derivative setting
A.ddd(2)=1; A.ddd(3)=1; A.ddd(4)=1;
A.dom=cell(2,n);%ap domain of each state 
%(1,s): aps that have to hold in s, (2,s): aps that has to be false in s
%don't count time constraints here!
A.dom{2,1}=[1 2];
A.dom{1,2}=1; 
A.dom{1,3}=[1]; A.dom{2,3}=2;
A.dom{1,4}=1; A.dom{2,4}=2;
A.dom{2,5}=[1 2];
A.dom{2,6}=1;

%Initialization: set that all actions cause self-loop transitions.
for i=A.Q
    for j=A.Sigma
        A.trans{i,j}= i;
    end
end
        
%Transitions
%Def as:    trans{q,2^ap}=q', and 
%           foo=[2^AP]\2^ap, trans{q,2^ap+bar(foobar)}=q'
%If neg(ap), remove ap from foo, add the other AP\ap to the transition.

%Propostion x=1,4 and 2, yields transition from 1 to 2
A.trans{1, 2^1+2^2} = 2;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)       
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{1, 2^1+2^2+ + bar(foobar)} = 2;
    end
end
A.trans{1, 2^4+2^2} = 2;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(4)=[];
foo(2)=[];
for j = 1:length(foo)       
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{1, 2^4+2^2+ + bar(foobar)} = 2;
    end
end
%Proposition x=1or4, and not 2 and ap+1 yields transition from 1 to 3
A.trans{1, 2^1+2^(ap+1)} = 3;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(ap+1)=[];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{1, 2^(1+ap)+2 + bar(foobar)} = 3;
    end
end
A.trans{1, 2^4+2^(ap+1)} = 3;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(ap+1)=[];
foo(4)=[];
foo(2)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{1, 2^(1+ap)+2^4 + bar(foobar)} = 3;
    end
end
%Proposition x=1or4 and not ap+1 and not 2 yields transition from 1 to 4
A.trans{1, 2^1} = 4;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(ap+1)=[];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{1, 2^(1)+ bar(foobar)} = 4;
    end
end
A.trans{1, 2^4} = 4;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(ap+1)=[];
foo(4)=[];
foo(2)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{1, 2^(4)+ bar(foobar)} = 4;
    end
end
%Proposition not ap+1 and not 1nor 4 nor 2 yields transition from 1 to 5
 A.trans{1, 2^(3)} = 5;
    foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
    foo(ap+1)=[];
    foo(4)=[];
    foo(3)=[];
    foo(2)=[];
    foo(1)=[];
    for j = 1:length(foo)        
        bar = sum(nchoosek(foo,j),2);
        for foobar = 1:size(bar,1)
            A.trans{1, 2^(3) + bar(foobar)} = 5;
        end
    end

%Proposition not 1 nor 4 and 2 yields transition from 1 to 6
A.trans{1, 2^2} = 6;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(4)=[];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{1, 2^(2) + bar(foobar)} = 6;
    end
end

%Proposition not 1 nor 4 yields transition from 2 to 6
 A.trans{2, 2^(ap+1)} = 6;
    foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
    foo(4)=[];
    foo(2)=[];
    foo(1)=[];
    for j = 1:length(foo)        
        bar = sum(nchoosek(foo,j),2);
        for foobar = 1:size(bar,1)
            A.trans{2, 2^(2) + bar(foobar)} = 6;
        end
    end
for x=2:3
    A.trans{2, 2^(x)} = 6;
    foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
    foo(4)=[];
    foo(x)=[];
    foo(1)=[];
    for j = 1:length(foo)        
        bar = sum(nchoosek(foo,j),2);
        for foobar = 1:size(bar,1)
            A.trans{2, 2^(x) + bar(foobar)} = 6;
        end
    end
end

%ap not 1 nor 4, not 2, and ap+1 3->1
A.trans{3, 2^(ap+1)} = 1;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(ap+1)=[];
foo(4)=[];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{3, 2^(ap+1) + bar(foobar)} = 1;
    end
end
%ap 1or 4,2 3->2
A.trans{3, 2^1+2^2} = 2;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{3, 2^(1) +2^2+ bar(foobar)} = 2;
    end
end
A.trans{3, 2^4+2^2} = 2;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(4)=[];
foo(2)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{3, 2^(4) +2^2+ bar(foobar)} = 2;
    end
end
%ap 1or4,not 2, not ap+1 3->4
A.trans{3, 2^1} = 4;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(ap+1)=[];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{3, 2^(1)+ bar(foobar)} = 4;
    end
end
A.trans{3, 2^4} = 4;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(ap+1)=[];
foo(4)=[];
foo(2)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{3, 2^(4)+ bar(foobar)} = 4;
    end
end
%ap not1 nor 4,not2,not ap+1 3->5
for x=3
    A.trans{3, 2^x} = 5;
    foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
    foo(ap+1)=[];
    foo(4)=[];
    foo(x)=[];
    foo(2)=[];
    foo(1)=[];
    for j = 1:length(foo)        
        bar = sum(nchoosek(foo,j),2);
        for foobar = 1:size(bar,1)
            A.trans{3, 2^(x)+ bar(foobar)} = 5;
        end
    end
end
%ap not1nor4,2 3->6
A.trans{3, 2^2} = 6;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(4)=[];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{3, 2^2+ bar(foobar)} = 6;
    end
end

%ap 1or4,2 from 4 to 2
A.trans{4, 2^(2)+2} = 2;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{4, 2^2+2 + bar(foobar)} = 2;
    end
end
A.trans{4, 2^(2)+2^4} = 2;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(4)=[];
foo(2)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{4, 2^2+2^4 + bar(foobar)} = 2;
    end
end
%Proposition not1nor4,not2 4->5
for x=3
    A.trans{4, 2^x} = 5;
    foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
    foo(4)=[];
    foo(x)=[];
    foo(2)=[];
    foo(1)=[];
    for j = 1:length(foo)
        bar = sum(nchoosek(foo,j),2);
        for foobar = 1:size(bar,1)
            A.trans{4, 2^x + bar(foobar)} = 5;
        end
    end
end
%ap not1nor4,2 4->6
A.trans{4, 2^2} = 6;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(4)=[];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{4, 2^2+ bar(foobar)} = 6;
    end
end
%ap 1or4,2 5->2
A.trans{5, 2+2^2} = 2;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{5, 2+2^2+ bar(foobar)} = 2;
    end
end
A.trans{5, 2^4+2^2} = 2;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(4)=[];
foo(2)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{5, 2^4+2^2+ bar(foobar)} = 2;
    end
end
%ap 1or4,not2 5->4
A.trans{5, 2^1} = 4;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{5, 2^1+ bar(foobar)} = 4;
    end
end
A.trans{5, 2^4} = 4;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(4)=[];
foo(2)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{5, 2^4+ bar(foobar)} = 4;
    end
end
%ap not1nor4,2 5->6
A.trans{5, 2^2} = 6;
foo=[2.^(AP) 2.^(A.C+ap) 2^(c+ap+1)];
foo(4)=[];
foo(2)=[];
foo(1)=[];
for j = 1:length(foo)        
    bar = sum(nchoosek(foo,j),2);
    for foobar = 1:size(bar,1)
        A.trans{5, 2^2+ bar(foobar)} = 6;
    end
end

%Clock-constraints

%Define in which states each clock is activated
A.clockset=sparse(n,c);
A.clockset(1,1)=1; %Clock 1 is started in state 1

%Define in which state (if any) each clock is inactivated
A.clockoff=sparse(n,c);
A.clockoff(6,1)=1; %Clock 1 is inactivated in state 2

%Define for which transitions (if any) each clock is reset - no reset
A.clockreset=cell(1,c);
for k=1:c
    A.clockreset{k}=sparse(n,n);
end

%Define the value of each clock, must be greater than the time, not equal.
A.clockvalue=zeros(1,c);
A.clockvalue(1)=0.005;

%Define MITL-formula (only used in printing)
MITL=['Phi=(Ev(<' num2str(A.clockvalue(1)) ') b and A -a)'];

end


