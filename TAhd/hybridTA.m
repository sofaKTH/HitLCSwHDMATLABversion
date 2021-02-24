function [ A ] = hybridTA( dead )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

apnumbers=2;
s=6;
A.S=1:s;
A.init=1;
A.final=5;
A.AP=1:apnumbers;
A.X=1;
A.Xv=dead;
A.Ix=zeros(6,1);
for x=1:2
    A.Ix(x)=1;
end
A.Ih=zeros(3,6);
for x=[2,3,6]
    A.Ih(2,x)=1;
end
for x=[3,4]
    A.Ih(1,x)=1;
end

sep_act=2.^A.AP;
act=[1];
for elem=1:length(sep_act)
    act=[act sum(nchoosek(sep_act, elem),2)'];
end

%A.trans(loc1,act,index)=loc2, index=1,2... if the same act can give
%multiple transitions depending on a clock
%self-loops
for x=1:s
    for a=act
        A.trans(x,a,1)=x;
    end
end

%trans
A.trans(1,act(2),1)=2;A.trans(1,act(2),2)=3;A.trans(1,act(1),2)=4;
A.trans(1,act(3),1)=5; A.trans(1,act(4),1)=6;
A.trans(2,act(1),1)=1;A.trans(2,act(2),2)=3; A.trans(2,act(1),2)=4;
A.trans(2,act(3),1)=5; A.trans(2,act(4),1)=6;
A.trans(3,act(1),1)=4; A.trans(3,act(3),1)=5; A.trans(3,act(4),1)=6;
A.trans(4,act(2),1)=3; A.trans(4,act(3),1)=5; A.trans(4,act(4),1)=6;
A.trans(5,act(2),1)=6; A.trans(5,act(4),1)=6;
A.trans(6,act(1),1)=5; A.trans(6,act(3), 1)=5;


end

