function [ plan ] = learnh( Pold, k, GS, Current )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
% Update initial state in P and define Init to enforce the initial path
laststate=Current.laststate;
firststate=Current.firststate;
P=Pold;
laststep=P.trans(laststate,firststate);
Init=init4P(Current,P);
P.init=firststate;

inc=0.001;
delta=zeros(1, 1/inc+1);
time0=cputime;
for hind=1:1/inc+1
    h=(hind-1)*inc;
    Init.dh=h*Init.dc+(1-h)*Init.dd;
    gS=graphSearch( P,h, Init);
    dhstar=gS.Fdh;
    dhhat=zeros(1,k);cost=zeros(1,k);
    for i=1:k
        dhhat(i)= h*(sum(GS{i}.DC(Current.i+1:end))+Current.currdc)+(1-h)*(sum(GS{i}.DD(Current.i+1:end))+Current.currdd);%h*GS{i}.Fdc+(1-h)*GS{i}.Fdd;
        cost(i)=dhstar-dhhat(i);
        if cost(i)>0
            cost(i)=inf;
        end
    end
    delta(hind)=sum(cost);
end
[deltamin, hindmin]=min(delta);
hmin=(hindmin-1)*inc;
pt1=cputime-time0;
if deltamin==Inf
    %user isn't following assumption
    fprintf('\n --------\n You are not following the assumption that you have a h in mind.\n We will set h=0.5 as default.\n ----------\n');
end
%once again I need to enforce the initial path here
Init.dh=hmin*Init.dc+(1-hmin)*Init.dd;
gS=graphSearch(P, hmin, Init);
gS.path=[GS{k}.path(1:Current.i), gS.path];
gS.time_vector=[GS{k}.time_vector(1:Current.i), gS.time_vector];
gS.DD=[GS{k}.DD(1:Current.i), gS.DD];
gS.DC=[GS{k}.DC(1:Current.i), gS.DC];

plan.gS=gS;
plan.h=hmin;
plan.delta=delta;
plan.deltamin=deltamin;
plan.hind=hindmin;
plan.P=P;

end

