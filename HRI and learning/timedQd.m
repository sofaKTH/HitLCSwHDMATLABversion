function [ QT ] = timedQd( Qd, P)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

QT=zeros(length(Qd), 2);
for ind=1:length(Qd)
    limits=[];q=Qd(ind);
    for x=P.X
        if ismember(x,P.Ixup(:,q))
            %t>x to enter q
            limits=[limits P.Xv(x)];
        end
    end
    if ~isempty(limits)
        T=min(limits);
    else
        T=0;
    end
    QT(ind,1)=q; 
    QT(ind,2)=T;
end

end

