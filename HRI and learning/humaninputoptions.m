function [ choice] = humaninputoptions( path_WTS, k, T, env)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
n=env.n;
sk=path_WTS(k);sk1=path_WTS(k+1);
%robots plan
if sk1-sk==1
    %going right
    ur='u';
elseif sk-sk1==1
    %going left
    ur='d';
elseif sk-sk1==n/5
    %going down
    ur='l';
else
    %going up
    ur='r';
end

%fprintf('robot plan to go %s\n ', ur);
AR=[T.ux_11(sk,sk1) T.ux_12(sk,sk1); T.ux_21(sk,sk1) T.ux_22(sk,sk1)];
BR=[T.uk_1(sk,sk1); T.uk_2(sk,sk1)];

% do as robot suggest
AH{1}=[0 0; 0 0]; BH{1}=[0; 0];
i=2; uL{1}='follow';
% redirecting
if ~strcmp(ur, 'r') && T.R(2,1,sk)<env.X(2,1)
    AH{i}=[T.ux_11(sk,sk+n/5) T.ux_12(sk,sk+n/5); T.ux_21(sk,sk+n/5) T.ux_22(sk,sk+n/5)]-AR;
    BH{i}=[T.uk_1(sk,sk+n/5); T.uk_2(sk,sk+n/5)]-BR;
    uL{i}='right';i=i+1;
end
if ~strcmp(ur, 'l') && T.R(1,1,sk)> env.X(1,1)
    AH{i}=[T.ux_11(sk,sk-n/5) T.ux_12(sk,sk-n/5); T.ux_21(sk,sk-n/5) T.ux_22(sk,sk-n/5)]-AR;
    BH{i}=[T.uk_1(sk,sk-n/5); T.uk_2(sk,sk-n/5)]-BR;
    uL{i}='left'; i=i+1;
end
if ~strcmp(ur, 'd') && T.R(1,2,sk)> env.X(1,2)
    AH{i}=[T.ux_11(sk,sk-1) T.ux_12(sk,sk-1); T.ux_21(sk,sk-1) T.ux_22(sk,sk-1)]-AR;
    BH{i}=[T.uk_1(sk,sk-1); T.uk_2(sk,sk-1)]-BR;
    uL{i}='down'; i=i+1;
end
if ~strcmp(ur, 'u') && T.R(2,2,sk)< env.X(2,2)
    AH{i}=[T.ux_11(sk,sk+1) T.ux_12(sk,sk+1); T.ux_21(sk,sk+1) T.ux_22(sk,sk+1)]-AR;
    BH{i}=[T.uk_1(sk,sk+1); T.uk_2(sk,sk+1)]-BR;
    uL{i}='up';
end
choice.uL=uL;
choice.AH=AH;
choice.BH=BH;
choice.q1=sk; choice.q2=sk1;
choice.path=path_WTS;
end

