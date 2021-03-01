function [ X, XL, TIME,tsteps, outTime, K,exit ] = onlineRun(env, gS, T, path_WTS,index,x0, U, it, preTime,envAut,T2,base,alltime,hrun)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%index is either an  array the length of WTS_path we consider or it is a
%value of the timestep
%base: 0 (first time used, background should be added - always agent 1)
% 1, no background, agent 1
%2, no background agent 2
if nargin==6
    U=[0 0 0 0 0 0]; it=0; preTime=0;
    envAut=0; T2=0; agents=1; base=0; hrun=0; alltime=0;
elseif nargin==9
    envAut=0; T2=0; agents=1; base=0; hrun.eps=0; alltime=0;
elseif nargin==13
    hrun.eps=0; agents=base;
else
    agents=2;
end
K=1;
time_vector=gS.time_vector;
FT=env.FT;Lap=env.Lap;AP_label=env.AP_label;A=env.A;
laps=0; Astar=cell(length(path)-1,1);Bstar=cell(length(path)-1,1);
% for i=1:length(time_vector)-1
%     time_vector2(i)=time_vector(i+1)-time_vector(i);
% end
FigHandle=figure(1);
hold on
FigHandle.Position=[100, 100, 1000, 500]; %FigHandle.InnerPosition= [100, 100, 800, 300];
if base==0
    partition_viz_simple({T,T2},{env,envAut},0,'Online Run');
end
hold on
x=[x0(1)];y=[x0(2)];xl=x; yl=y; Time=[0];tsteps=[0];
%for path_length=1:length(time_vector2)
blend=[];
if length(index)==1
    time_vector2=index; index=[index 0];
else
    for i=1:length(index)-1
        time_vector2(i)=time_vector(i+1)-time_vector(i);
    end
end
for i=1:length(time_vector2)
    %fprintf('round %d', i);
    %fprintf('Position is: %f, %f\t time to go: %f\n',x(end),y(end),time_vector2(i));
    if hrun.eps==0
       % fprintf('no human input\n');
        [t,xq, Astar{i},Bstar{i}]=systevolution(path_WTS(i),path_WTS(i+1),A,T.ux_11+U(1),T.ux_12+U(2),T.ux_21+U(3),T.ux_22+U(4),T.uk_1+U(5),T.uk_2+U(6),x(end),y(end),time_vector2(i),blend);
    else
        %fprintf('trying to do input..\n');
        [ t ,xq, K] = simEvo( path_WTS(i),path_WTS(i+1),A,T,x(end),y(end),time_vector2(i), U,hrun.QT,preTime,hrun.dt,hrun.eps,env.U(2) );
    end
    stateend=size(xq,1);
    k=1;

    while stateend~=k
        if xq(k,1)>T.R(2,1,path_WTS(i))%+0.1
            stateend=k;
        elseif xq(k,1)<T.R(1,1,path_WTS(i))%-0.1
            stateend=k;
        elseif xq(k,2)<T.R(1,2,path_WTS(i))%-0.1
            stateend=k;
        elseif xq(k,2)>T.R(2,2,path_WTS(i))%+0.1
            stateend=k;
        else
            k=k+1;
        end
    end
    if k==stateend
        exit=1;
    else
        exit=0;
    end
    if alltime==1
        if stateend+5<length(xq(:,1))
            stateend=stateend+5; %add some margin
        else
            stateend=length(xq(:,1));
        end
    elseif alltime==2
        stateend=length(xq(:,1));
    end
    x=[x xq(2:stateend,1)']; 
    %x=[x xq(:,1)'];y=[y xq(:,2)'];
    y=[y xq(2:stateend,2)'];
    xl=[xl xq(stateend,1)]; yl=[yl xq(stateend,2)];
    tsteps=[tsteps t(2:stateend)'+tsteps(end)];
    Time=[Time t(stateend)];
    
end
    %plot(x,y);
plot(x,y,xl,yl,'*', 'LineWidth', 5);
% print('before gca');
set(gca,'Position',[.05 .05 .45 .9]);
% print('after gca');
%hold on
i=1;
limitreached=0;
while i<1+length(xl)
    addtxt=num2str(i-1+it);
    if i<length(xl)
        while xl(i)==xl(i+1)&&yl(i)==yl(i+1)
            addtxt=[addtxt '-' num2str(i+it)];
            if i<length(xl)-1
                i=i+1;
            else
                limitreached=1;
                break;
            end
        end
    end
    
    pos=[xl(i)-0.015 yl(i)-0.1 0.25 0.2];
    if base==2
        col=[0.9 0.9 0.9];
    else
        col=[0.7 0.7 0.7];
    end
    rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', col);
    numbers=text(xl(i),yl(i),addtxt);
    set(numbers,'fontsize',12);
    i=i+1;
    if limitreached==1
        break;
    end
end
delta=0;
if base==2
    delta=3;
end

px=T.R(2,1,T.S(end))+0.1+delta;
py=T.R(2,2,T.S(end));
if it==0
    if base==2
        sidebar=text(px,py,'Agent 2');
        set(sidebar,'fontsize',14);
    else
        sidebar=text(px,py,'Agent 1');
        set(sidebar,'fontsize',14);
    end
    py=py-0.25;
    sidebar=text(px,py,'0  -  0');
    set(sidebar,'fontsize',12);
    py=py-0.2;
else
    py=py-0.45-(it)*0.2;
end
%-0.45, -0.65,-0.85...
i=1;
while i<length(index)
    num=num2str(it+i);
    time=num2str(round(sum(Time(1:i+1))+preTime,4));
    sidebar=text(px,py,[num ' - ' time]);
    set(sidebar,'fontsize',12);
    py=py-0.2;
    i=i+1;
end

X=[x; y];XL=[xl;yl];
xend=[x(end) y(end)];
outTime=Time+preTime;
TIME=Time;
hold on
end

