function [ gS ] = graphSearch( P,c, Init )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

if nargin==2
    T0=0;DH0=0;DD0=0; DC0=0;
else
    %init has been given!
    T0=Init.time;DH0=Init.dh;DD0=Init.dd; DC0=Init.dc;
end

init=P.init; final=P.final; S=P.S; Q=P.Q;trans=P.trans;Ix=P.Ix; Ih=P.Ih; X=P.X; Xv=P.Xv;
nq=length(Q); Ixup=P.Ixup;

time=ones(1,nq)*T0;hd=ones(1,nq)*DH0;dc=ones(1,nq)*DC0;dd=ones(1,nq)*DD0;
for q=Q
    if q~=init
        time(q)=inf;hd(q)=inf;dc(q)=inf;dd(q)=inf;
    end
end
Spool=[init];pathFound=false;
parent=zeros(nq); %no state has a parent

while pathFound==false && ~isempty(Spool)
    q1=Spool(1);
    for q=Spool
        if hd(q)<hd(q1)
            q1=q;
        end
    end
    if any(ismember(final,q1))
        pathFound=true;
    else
        succ=[];
        for q2=Q
            if trans(q1,q2)~=inf
                succ=[succ q2];
            end
        end
        for q2=succ
            violation=false;
            for x=X
                if Ix(q1,q2)==x
                    currTime=time(q1)+trans(q1,q2);
                    if currTime>=Xv(x)
                        violation=true;
                    end
                elseif Ixup(q1,q2)==x
                    currTime=time(q1)+trans(q1,q2);
                    if currTime<Xv(x)
                        violation=true;
                    end
                end
            end
            if violation==false
                %fprintf('true succ to %d is %d\n',q1,q2);
                %need to distinguish self-transitions in WTS
                if S(q1,1)==S(q2,1) && Ix(q2)~=0 && q1~=q2
                    temptrans=Xv(Ix(q1,q2))-time(q1);
                    fprintf('updated trans time for %d -> %d \t new time= %f\n', q1, q2, trans(q1,q2));
                else
                    temptrans=trans(q1,q2);
                end
                currDC=dc(q1)+(Ih(q1,1)+Ih(q2,1))*(trans(q1,q2)/2);
                currDD=dd(q1)+(Ih(q1,2)+Ih(q2,2))*trans(q1,q2)/2;
                currHD=c*currDC+(1-c)*currDD;
                if currHD<hd(q2)
                    %fprintf('we improved! old hd: %f new hd: %f\n', hd(q2), currHD);
                    hd(q2)=currHD;dc(q2)=currDC;dd(q2)=currDD;
                    parent(q2)=q1; time(q2)=time(q1)+trans(q1,q2);
                    Spool=[Spool q2]; trans(q1,q2)=temptrans;
                end
                fprintf('parent to %d is %d\n',q2,parent(q2));
            end
        end
        Spool=Spool(Spool~=q1);
                
    end
end
%fprintf('done searching\n');
if pathFound==false
 %   fprintf('fail\n');
    path=[];
    Ftime=inf; Fdc=inf; Fdd=inf; Fdh=inf; time_vector=[]; DD=[]; DC=[];
else
    %fprintf('found a path\n')
    path=[q1]; Ftime=time(q1); Fdc=dc(q1); Fdd=dd(q1);Fdh=hd(q1);time_vector=time(q1);
    DD=dd(q1); DC=dc(q1);
    while parent(q1)~=0
        path=[parent(q1), path];
        q1=parent(q1);
        time_vector=[time(q1) time_vector];
        DD=[dd(q1) DD]; DC=[dc(q1) DC];
    end
end
gS.path=path; gS.Fdh=Fdh;gS.Fdc=Fdc;gS.Fdd=Fdd; 
gS.Ftime=Ftime; gS.time_vector=time_vector;
gS.DD=DD; gS.DC=DC; gS.trans=trans;
end

