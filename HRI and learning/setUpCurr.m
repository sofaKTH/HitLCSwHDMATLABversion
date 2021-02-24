function [ Current ] = setUpCurr( P, inputX, i,env , GS, choice,k)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
path=GS{k}.path;
path_WTS=wtsProject(path,P);
last_WTS=path_WTS(i);
stru=''; strd=''; strl='';
for opt=1:length(choice.uL)
    if strcmp(choice.uL{opt}, 'up')
        stru=num2str(opt);
        Current.dir='u';
        Current.opt=opt;
    elseif strcmp(choice.uL{opt}, 'down')
        strd=num2str(opt);
        Current.dir='d';
        Current.opt=opt;
    elseif strcmp(choice.uL{opt},'left')
        strl=num2str(opt);
        Current.dir='l';
        Current.opt=opt;
    else
        Current.dir='r';
        Current.opt=opt;
    end
end

if strcmp(inputX,'left') || strcmp(inputX, strl)
    first_WTS=last_WTS-env.n/5;
elseif strcmp(inputX,'up')|| strcmp(inputX, stru)
    first_WTS=last_WTS+1;
elseif strcmp(inputX,'down')|| strcmp(inputX, strd)        
    first_WTS=last_WTS-1;
else
    first_WTS=last_WTS+env.n/5;
end
Current.laststate=path(i);

qpos=[]; %all states corresponding to the right region
for q=1:length(P.Q)
    if P.S(q,1)==first_WTS
        qpos=[qpos q];
    end
end
state=[];Time=[];
for q=qpos
    if P.trans(path(i), q)~= Inf
        trans=1; %okej
        currTime=GS{k}.time_vector(i)+P.trans(Current.laststate,q);
        for x=P.X
            if P.Ix(path(i),q)==x
                if currTime>=P.Xv(x)
                    trans=0; %if we went over guard
                end
            elseif P.Ixup(path(i),q)==x
                if currTime<P.Xv(x)
                    trans=0; %we went under guard
                end
            end
        end
        if trans==1 %no violations by doing the trans
            state=[state q];
            Time=[Time currTime];
        end
    end
end
%check
if length(state)==1
    %good!
    Current.firststate=state;
    Current.time=Time;
else
    %something has gone wrong :(
    if length(state)>1
        Current.firststate=state(1);
        Current.time=Time(1);
        fprintf('\n ---------------------------------------\n error! The new state could not be determined! Multiple options remain\n --------------------------------\n' );
    else
        Current.firststate=path(i+1);
        Current.time=time_vector(i+1);
        
        fprintf('\n ---------------------------------------\n error! The new state could not be determined! No option found\n --------------------------------\n' );
    end
end
Current.i=i;


end

