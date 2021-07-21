function [sWTS] = sparseWTS(dWTS, AP)
%converts a dense WTS into a sparse WTS

%error check to make sure AP and dWTS match
if ismember(AP, dWTS.Pi)
    match=1;
else
    match=0;
end

%functions
    function [nB]=successors(state)
    nB=[]; N2=length(dWTS.S)/dWTS.N1;
    if mod(state,N2)~=1 %possible to move down
        nB=[nB state-1];
    end
    if mod(state,N2)~=0 %possible to move up
        nB=[nB state+1];
    end
    if state>N2 %possible to move left
        nB=[nB state-N2];
    end
    if state<=(dWTS.N1-1)*N2 % possible to ove right
        nB=[nB state+N2];
    end
    end

function [lastin, lastout, lastpath]=transSearch(S1,S2)
    % searches for the shortest path to any state in S2 in the dWTS given that we start
    % anywhere in S1. (S1 and S2 are sets of states)
    lastpath=[]; lastin=0; lastout=0;
    for st1=S1
        set=st1; found=0; tranTime=inf*ones(length(dWTS.S),1); tranTime(st1)=0;
        parent=zeros(length(dWTS.S), 1);
        while found==0 && ~isempty(set)
            curr=set(1); ind=1; count=0;
            for elem=set
                count=count+1;
                if tranTime(elem)<tranTime(curr)
                    curr=elem; ind=count;
                end
            end
            if ismember(curr,S2)
                found=1;
            else
                possSucc=successors(curr); succ=[];
                for ps=possSucc
                    if dWTS.L(ps)==dWTS.L(curr) || dWTS.L(ps)==1 || dWTS.L(ps)==dWTS.L(S2(1))
                        succ=[succ, ps];
                    end
                end
                for new=succ
                    if tranTime(new)> tranTime(curr)+ dWTS.adj(curr,new)
                        tranTime(new)=tranTime(curr)+dWTS.adj(curr,new);
                        parent(new)=curr;
                        set=[set new];
                    end
                end
                set(ind)=[];
            end
        end
        if found==1
            % the transition exists
            path=curr;
            while parent(curr)~=0
                curr=parent(curr);
                path=[curr path];
            end
            p=path(1); step=1;
            while ~isempty(dWTS.L(p)) && step<length(path)
               step=step+1;
               p=path(step);
            end
            in=tranTime(p); out=tranTime(path(end))-in;
        else %the transition does not exists
            in=inf; out=inf; path=[];
        end
        if in+out>lastin+lastout %this initial dense satte gives a slower transition and must be considered!
            lastpath=path; lastin=in; lastout=out;
        end
    end
end


if match==0
    fprintf('The task is considering a property which is not in the environment.\n');
    sWTS=0;
else
    Pi=[];
    for pi=dWTS.Pi
        if ismember(pi,AP)
            Pi=[Pi, pi];
        end
    end
    sWTS.Pi=Pi;
    mapInit=[dWTS.current]; %mapping from sWTS state to dWTS state map(state(sWTS))=state(dWTS)
    sWTS.current=1;
    for s=dWTS.S
        if ~isempty(dWTS.simple_label{s})
            for l=dWTS.simple_label{s}
                if ismember(l, Pi)&& s~=dWTS.current
                    mapInit=[mapInit s];
                end
            end
        end
    end
    %merge states that are labelled the same and adjecent
    merge=zeros(length(mapInit),length(mapInit));
    map=cell(length(mapInit),1); map{end}=mapInit(end);
    remove=[];
    for s1=1:length(mapInit)-1
        map{s1}=mapInit(s1);
        nb=successors(mapInit(s1));
        for s2=s1+1:length(mapInit)
            if ismember(mapInit(s2),nb)&& dWTS.L(mapInit(s1))==dWTS.L(mapInit(s2))
                    merge(s1,s2)=1; 
                    remove=[remove, s2];
                    if any(merge(:,s1))
                        i=find(merge(:,s1));
                        map{i(1)}=[map{i(1)} , mapInit(s2)];
                        merge(i(1),s2)=1;
                    else
                        map{s1}=[map{s1}, mapInit(s2)];
                    end
            end
        end
    end
    for i=flip(remove)
        map(i,:)=[];
    end  
    sl=cell(length(map),1);
    L=zeros(length(map),1);
    sWTS.S=1:length(map);sWTS.map=map;
    for s=sWTS.S
        sl{s}=dWTS.simple_label{map{s}(1)};
        L(s)=dWTS.L(map{s}(1));
    end
    sWTS.simple_label=sl;sWTS.L=L;
    
    timeIn=zeros(length(map),length(map));
    timeOut=timeIn; dtraj=cell(length(map),length(map));
    for s1=sWTS.S
        for s2=sWTS.S
            if s1==s2 %self trans
                timeIn(s1,s2)=dWTS.adj(map{s1}(1),map{s2}(1));
                timeOut(s1,s2)=0; dtraj{s1,s2}=[];
            else
                [timeIn(s1,s2), timeOut(s1,s2), dtraj{s1,s2}]=transSearch(map{s1},map{s2});
            end
        end
    end
    sWTS.time.in=timeIn; sWTS.time.out=timeOut;sWTS.traj=dtraj;
end

end

