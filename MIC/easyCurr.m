function [ curr ] = easyCurr( q1,q2,it,T,DD,DC,GS, Data )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
curr.firststate=q2; curr.laststate=q1; curr.i=it;
curr.T=T; curr.DD=DD; curr.DC=DC;

if nargin==6
    stop=1;
else
    stop=0;
end


%h doesn't matter here  (only used to calc DH which is not used)
if stop==0
    H=0; X=Data.X; Y=Data.Y; Tb=Data.Tb; follow=Data.follow; allT=Data.allT; p=Data.p;
    currdc=zeros(1,length(GS));currdd=zeros(1,length(GS));A=Data.A;

    for i=1:length(GS)
        index=GS{i}.index; lastit=GS{i}.lastit; t0=allT(index);
        x=X(index); y=Y(index);xsim=[x];ysim=[y]; tsim=[t0];
        for l=GS{i}.lastit+1:length(GS{i}.path)-1
            q1=wtsProject(GS{i}.path(l),p);q2=wtsProject(GS{i}.path(l+1),p);
            time=GS{i}.time_vector(l+1)-GS{i}.time_vector(l);
            [t,xq, ~]=systevolution(q1,q2,A,Tb.ux_11,Tb.ux_12,Tb.ux_21,Tb.ux_22,Tb.uk_1,Tb.uk_2,xsim(end),ysim(end),time,[]);
            
            stateend=size(xq,1);
            k=1;
            while stateend~=k
                if xq(k,1)>Tb.R(2,1,q1)
                    stateend=k;
                elseif xq(k,1)<Tb.R(1,1,q1)
                    stateend=k;
                elseif xq(k,2)<Tb.R(1,2,q1)
                    stateend=k;
                elseif xq(k,2)>Tb.R(2,2,q1)
                    stateend=k;
                else
                    k=k+1;
                end
            end
            if stateend+5<length(xq(:,1))
                stateend=stateend+5; %add some margin
            else
                stateend=length(xq(:,1));
            end
            xsim=[xsim xq(2:stateend,1)' ];ysim=[ysim xq(2:stateend,2)' ];
            tsim=[tsim t(2:end)'+tsim(end)];
        end
        X=[X xsim]; Y=[Y ysim]; allT=[allT tsim]; 
        [DD,DC,~]=realDistances(X,Y,Tb,follow, allT,p,H,1);
        currdc(i)=DC{1}; currdd(i)=DD{1};
    end
    curr.currdc=currdc;
    curr.currdd=currdd;
end
end

