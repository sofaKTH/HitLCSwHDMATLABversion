function [ A ] = hybridTAsoftandhard( dead )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%start
%soft: E_[0, dead]b and A not a
%hard:-
%goal
%soft: E_[0,c1]a3 and E_[0,c2] a4 and A not a2
%hard: A not a1

apnumbers=4;
s=17;
A.S=1:s;
A.init=1;
A.final=4;
A.AP=1:apnumbers;
A.X=1:2;
A.Xv=dead;
A.Ix=zeros(s,s);
A.Ixup=zeros(s,s);
%clock guards on transitions
for x=[1,2,4,6,7,8,9]
    A.Ix(1,x)=1;
    A.Ix(9,x)=1;
end
A.Ix(1,3)=2;
A.Ix(10,2)=2;
A.Ix(9,3)=1;
for x=[2,4,6,8]
    A.Ix(2,x)=2;
    A.Ix(6,x)=2;
end
for x=[3,4,7,8]
    A.Ix(3,x)=1;
    A.Ix(7,x)=1;
end
for x=[4, 5,6,8,10,14,15]
    A.Ix(5,x)=2;
    A.Ix(10,x)=2;
end
for x=[5,10]
    A.Ix(9,x)=2;
end

%upper time constraints on trans
A.Ixup(1,5)=1;A.Ixup(2,13)=2;
A.Ixup(1,10)=1;A.Ixup(3,15)=1;
A.Ixup(2,12)=2;A.Ixup(5,17)=2;
A.Ixup(3,14)=1;A.Ixup(5,16)=2;
A.Ixup(6,12)=2;A.Ixup(6,13)=2;
A.Ixup(7,15)=1;A.Ixup(7,14)=1;
A.Ixup(9,5)=1;A.Ixup(9,10)=1;
A.Ixup(10,17)=2;A.Ixup(10,16)=2;
% hybrid
A.Ih=zeros(3,s);
for x=[6,7,8,9,10,11,13,15,16] %dd
    A.Ih(2,x)=1;
end
for x=[5,10,11,12,13,14,15] %dc
    A.Ih(1,x)=1;
end
for x=[16,17] %dc
    A.Ih(1,x)=2;
end

sep_act=2.^A.AP;
act=[1];
for elem=1:length(sep_act)
    act=[act sum(nchoosek(sep_act, elem),2)'];
end
% for i=1:length(act)
%     fprintf('act= %d\n', act(i));
% end
%A.trans(loc1,act,index)=loc2, index=1,2... if the same act can give
%multiple transitions depending on a clock
%self-loops
for x=1:s
    for a=act
        A.trans(x,a,1)=x;
    end
end
A.act=act;

%trans that are not self-loops
A.trans(1,act(4),1)=2;A.trans(1,act(5),1)=3;A.trans(1,act(11),1)=4;
A.trans(1,act(1),2)=5; A.trans(1,act(9),1)=6;
A.trans(1,act(10),1)=7;A.trans(1,act(15),1)=8;A.trans(1,act(3),1)=9;
A.trans(1,act(3),2)=10;

A.trans(2,act(5),1)=4;A.trans(2,act(11),1)=4;
A.trans(2,act(3),1)=6; A.trans(2,act(9),1)=6;
A.trans(2,act(10),1)=8; A.trans(2,act(15),1)=8;
A.trans(2,act(1),2)=12; A.trans(2,act(4),2)=12;
A.trans(2,act(3),2)=13; A.trans(2,act(9),2)=13;

A.trans(3,act(4),1)=4; A.trans(3,act(11),1)=4; 
A.trans(3,act(3),1)=7; A.trans(3,act(10),1)=7; 
A.trans(3,act(9),1)=8; A.trans(3,act(15),1)=8; 
A.trans(3,act(1),2)=14; A.trans(3,act(5),2)=14; 
A.trans(3,act(3),2)=15; A.trans(3,act(10),2)=15; 

A.trans(4,act(3),1)=8; A.trans(4,act(9),1)=8;
A.trans(4,act(10),1)=8; A.trans(4,act(15),1)=8;

A.trans(5,act(4),1)=2; A.trans(5,act(11),1)=4;
A.trans(5,act(9),1)=6; A.trans(5,act(15),1)=8;
A.trans(5,act(3),1)=10; A.trans(5,act(4),2)=12;
A.trans(5,act(9),2)=13; A.trans(5,act(5),1)=14;
A.trans(5,act(10),1)=15; A.trans(5,act(3),2)=16;
A.trans(5,act(1),2)=17;

A.trans(6,act(1),1)=2; A.trans(6,act(4), 1)=2;
A.trans(6,act(5),1)=4; A.trans(6,act(11), 1)=4;
A.trans(6,act(10),1)=8; A.trans(6,act(15), 1)=8;
A.trans(6,act(1),2)=12; A.trans(6,act(4), 2)=12;
A.trans(6,act(3),2)=13; A.trans(6,act(9), 2)=13;

A.trans(7,act(1),1)=3; A.trans(7,act(5), 1)=3;
A.trans(7,act(4),1)=4; A.trans(7,act(11), 1)=4;
A.trans(7,act(9),1)=8; A.trans(7,act(15), 1)=8;
A.trans(7,act(1),2)=14; A.trans(7,act(5), 2)=14;
A.trans(7,act(3),2)=15; A.trans(7,act(10), 2)=15;

A.trans(8,act(1),1)=4; A.trans(8,act(5), 1)=4;
A.trans(8,act(4),1)=4; A.trans(8,act(11), 1)=4;

A.trans(9,act(1),1)=1; A.trans(9,act(4), 1)=2;
A.trans(9,act(5),1)=3; A.trans(9,act(11), 1)=4;
A.trans(9,act(1),2)=5; A.trans(9,act(9),1)=6;
A.trans(9,act(10),1)=7;A.trans(9,act(15),1)=8;
A.trans(9,act(3),2)=10;

A.trans(10,act(4),1)=2; A.trans(10,act(11), 1)=4;
A.trans(10,act(1),1)=5; A.trans(10,act(9), 1)=6;
A.trans(10,act(11),1)=8; A.trans(10,act(4), 2)=12;
A.trans(10,act(9),2)=13; A.trans(10,act(5), 1)=14;
A.trans(10,act(10),1)=15; A.trans(10,act(3), 2)=16;
A.trans(10,act(1),2)=17;

A.trans(12,act(5),1)=4; A.trans(12,act(11), 1)=4;
A.trans(12,act(10),1)=8; A.trans(12,act(15), 1)=8;
A.trans(12,act(3),1)=13; A.trans(12,act(9), 1)=13;

A.trans(13,act(5),1)=4; A.trans(13,act(11), 1)=4;
A.trans(13,act(10),1)=8; A.trans(13,act(15), 1)=8;
A.trans(13,act(1),1)=12; A.trans(13,act(4), 1)=12;

A.trans(14,act(4),1)=4; A.trans(14,act(11), 1)=4;
A.trans(14,act(9),1)=8; A.trans(14,act(15), 1)=8;
A.trans(14,act(3),1)=15; A.trans(14,act(10), 1)=15;

A.trans(15,act(4),1)=4; A.trans(15,act(11), 1)=4;
A.trans(15,act(9),1)=8; A.trans(15,act(15), 1)=8;
A.trans(15,act(5),1)=14; A.trans(15,act(1), 1)=14;

A.trans(16,act(11),1)=4; A.trans(16,act(15), 1)=8;
A.trans(16,act(4),1)=12; A.trans(16,act(9), 1)=13;
A.trans(16,act(5),1)=14; A.trans(16,act(10), 1)=15;
A.trans(16,act(1), 1)=17;

A.trans(17,act(11),1)=4; A.trans(17,act(15), 1)=8;
A.trans(17,act(4),1)=12; A.trans(17,act(9), 1)=13;
A.trans(17,act(5),1)=14; A.trans(17,act(10), 1)=15;
A.trans(17,act(3), 1)=16;

%all trans to the dump state=all actions with a1
for a=[2,6,7,8,12,13,14,16]
    for x=1:17
        A.trans(x,act(a),1)=11;
    end
end
end

