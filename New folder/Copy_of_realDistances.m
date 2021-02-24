function [DD,DC,DH, Trans]=realDistances(X,Y,Tb,follow, allT,p,H)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

DD={0,0}; DC={0,0}; DH={0,0};Trans={};
for k=1:2
    x=X{k};  y=Y{k}; P=p{k}; h=H{k};
    T=Tb{k}; path=follow{k}; t=allT{k};
    
    uniPath=path(1); %path where all duplicates are removed
    for q=2:length(path)
        if path(q)~=uniPath(end)
            uniPath=[uniPath path(q)];
        end
    end
    wtsPath=wtsProject(uniPath, P);
    taPath=taProject(uniPath,P);
    stateTrans=[x(1) y(1) t(1) uniPath(1) wtsPath(1) taPath(1)];
    
    step=2;
    for i=2:length(t)
        if wtsPath(step)~=wtsPath(step-1)
            %transition requires entering new region
            if x(i)>=T.R(1,1,wtsPath(step)) &&x(i)<=T.R(2,1,wtsPath(step))&&y(i)>=T.R(1,2,wtsPath(step))&&y(i)<=T.R(2,2,wtsPath(step))
                %x is in the right region!
                stateTrans=[stateTrans; x(i) y(i) t(i) uniPath(step) wtsPath(step) taPath(step)]; step=step+1;
            end
        else
            %transition is change in ta - i.e. time-based
            if P.Ix(uniPath(step-1),uniPath(step))~=0 && t(i)<=P.Xv(P.Ix(uniPath(step-1),uniPath(step)))
                %t must be less than
                stateTrans=[stateTrans; x(i) y(i) t(i) uniPath(step) wtsPath(step) taPath(step)];step=step+1;
            elseif t(i)>P.Xv(P.Ixup(uniPath(step-1),uniPath(step)))
                %t must be greater
                stateTrans=[stateTrans; x(i) y(i) t(i) uniPath(step) wtsPath(step) taPath(step)];step=step+1;
            end
        end
        if step>length(uniPath)
            break;
        end
    end
    %stateTrans now contain all transitionspoints
    dc=0; dd=0;
    for i=1:size(stateTrans,1)-1
        q=stateTrans(i,4); dT=stateTrans(i+1,3)-stateTrans(i,3);
        dc=dc+P.Ih(q,1)*dT;
        dd=dd+P.Ih(q,2)*dT;
    end
    dh=h*dc+(1-h)*dd;
    DC{k}=dc; DD{k}=dd; DH{k}=dh;
    Trans{k}=stateTrans;
end


end

