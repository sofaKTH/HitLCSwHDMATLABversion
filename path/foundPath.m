function [ pathPA, pathTAhd, pathTS, hybridDistance, distanceVector, completionTime, dcTotal, ddTotal, dcVector, ddVector, timeStep] = foundPath( PA,c )
%FOUNDPATH finds the path with smallest hybrid distance, returns the path
%and the corresponding distance.
Q=PA.Q;F=PA.final;init=PA.init;
nq=length(Q);

distanceToStart=zeros(1,nq); timeToStart=zeros(1,nq);
dcToStart=zeros(1,nq); ddToStart=zeros(1,nq);
pred=zeros(1,nq);
for i=1:nq
    if i~=init
        distanceToStart(i)=inf;
        timeToStart(i)=inf;
        dcToStart(i)=inf;
        ddToStart(i)=inf;
    end
end
searchPool=init;processedStates=[];pathFound=false;

while pathFound==false && ~isempty(searchPool)
    currentState=searchPool(1);
    for i=searchPool
        if distanceToStart(i)<distanceToStart(currentState)
            currentState=i;
        end
    end
    %at this point currentState is the state closest to the initial state
    %wrt hd
    if any(currentState==F)
        pathFound=true;
    else
        for elem=1:length(PA.X)+1
            succState=find(PA.trans{elem}(currentState, :)); %successors to currentState
            for i=succState
                falseSucc=false;
                timeToStartNow=timeToStart(currentState)+PA.adj{elem}(currentState,i);
                for j=PA.C
                    if j==elem
                        if timeToStartNow>PA.clockvalue(j)+0.001
                            falseSucc=true;
                        end
                    else
                        if timeToStartNow<=PA.clockvalue(j)
                            falseSucc=true;
                        end
                    end
                end
                if falseSucc==false
                    dc=PA.ddc(currentState)*PA.adj{elem}(currentState,i);
                    dd=PA.ddd(currentState)*PA.adj{elem}(currentState,i);
                    dh=c*dc+(1-c)*dd;
                    if dh+distanceToStart(currentState)<distanceToStart(i)
                        pred(i)=currentState;
                        distanceToStart(i)=dh+distanceToStart(currentState);
                        dcToStart(i)=dcToStart(currentState)+dc; 
                        ddToStart(i)=ddToStart(currentState)+dd;
                        timeToStart(i)=timeToStartNow;
                        searchPool=[searchPool i];
                    end
                end
            end
        end
        processedStates=unique([processedStates currentState]);
        searchPool = setdiff(searchPool, processedStates);
    end    
end
hybridDistance=distanceToStart(currentState);
pathPA=currentState;
pathTS=PA.S(currentState, 1);
pathTAhd=PA.S(currentState, 2);
distanceVect=hybridDistance;
completionTime=timeToStart(currentState);
timeSteps=completionTime;
dcTotal=dcToStart(currentState);
ddTotal=ddToStart(currentState);
dcVec=dcTotal;ddVec=ddTotal;

if currentState~=init
    while pred(currentState)~=0
        currentState=pred(currentState);
        pathPA=[currentState pathPA];
        pathTS=[PA.S(currentState,1) pathTS];
        pathTAhd=[PA.S(currentState,2) pathTAhd];
        distanceVect=[distanceVect distanceToStart(currentState)];
        dcVec=[dcVec dcToStart(currentState)];
        ddVec=[ddVec ddToStart(currentState)];
        timeSteps=[timeSteps timeToStart(currentState)];
    end
end
distanceVector=zeros(1,length(distanceVect));
dcVector=zeros(1, length(dcVec));ddVector=zeros(1, length(ddVec));
timeStep=zeros(1, length(timeSteps));
for elem=1:length(distanceVect)-1
    distanceVector(length(distanceVect)+1-elem)=distanceVect(elem)-distanceVect(elem+1);
    dcVector(length(dcVec)+1-elem)=dcVec(elem)-dcVec(elem+1);
    ddVector(length(ddVec)+1-elem)=ddVec(elem)-ddVec(elem+1);
    timeStep(length(timeSteps)+1-elem)=timeSteps(elem)-timeSteps(elem+1);
end
distanceVector(1)=distanceVect(end);
dcVector(1)=dcVec(end);ddVector(1)=ddVec(end);
timeStep(1)=timeSteps(end);
end

