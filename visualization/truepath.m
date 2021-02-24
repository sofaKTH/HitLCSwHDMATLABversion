function [  ] = truepath(env, gS, T, path_WTS,x0 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if nargin==5
    x0=env.x0;
end

time_vector=gS.time_vector;
FT=env.FT;Lap=env.Lap;AP_label=env.AP_label;A=env.A;
laps=0; Astar=cell(length(path)-1,1);Bstar=cell(length(path)-1,1);
for i=1:length(time_vector)-1
    time_vector2(i)=time_vector(i+1)-time_vector(i);
end
FigHandle=figure(1);
set(FigHandle, 'Position', [100, 100, 1000, 400]);
partition_viz_simple(T, env);
hold on
x=[x0(1)];y=[x0(2)];xl=x; yl=y; Time=[0];
for path_length=1:length(time_vector2)
    blend=[];
    [t,xq, Astar{path_length},Bstar{path_length}]=systevolution(path_WTS(path_length),path_WTS(path_length+1),A,T.ux_11,T.ux_12,T.ux_21,T.ux_22,T.uk_1,T.uk_2,x(end),y(end),time_vector2(path_length),blend);
    stateend=size(xq,1);
    k=1;
    
    while stateend~=k
        if xq(k,1)>T.R(2,1,path_WTS(path_length))
            stateend=k;
        elseif xq(k,1)<T.R(1,1,path_WTS(path_length))
            stateend=k;
        elseif xq(k,2)<T.R(1,2,path_WTS(path_length))
            stateend=k;
        elseif xq(k,2)>T.R(2,2,path_WTS(path_length))
            stateend=k;
        else
            k=k+1;
        end
    end
%     if stateend+5<length(xq(:,1))
%         stateend=stateend+5; %add some margin
%     else
%         stateend=length(xq(:,1));
%     end
    TransTime(path_length)=t(stateend);
    laps=laps+1;
    x=[x xq(2:stateend,1)']; 
    %x=[x xq(:,1)'];y=[y xq(:,2)'];
    y=[y xq(2:stateend,2)'];
    xl=[xl xq(stateend,1)]; yl=[yl xq(stateend,2)];
    if t(stateend)~=t(end)
        Timex(path_length+1)=t(end);
    end
    Time=[Time t(stateend)];
end
%plot(x,y);
plot(x,y,xl,yl,'*');
print('before gca');
set(gca,'Position',[.05 .05 .45 .9]);
print('after gca');
%hold on
i=1;
limitreached=0;
while i<1+length(xl)
    addtxt=num2str(i-1);
    if i<length(xl)
        while xl(i)==xl(i+1)&&yl(i)==yl(i+1)
            addtxt=[addtxt '-' num2str(i)];
            if i<length(xl)-1
                i=i+1;
            else
                limitreached=1;
                break;
            end
        end
    end
    numbers=text(xl(i),yl(i),addtxt);
    set(numbers,'fontsize',18);
    i=i+1;
    if limitreached==1
        break;
    end
end
px=T.R(2,1,T.S(end))+0.1;
py=T.R(2,2,T.S(end));
for g=1:length(xl)
    num=num2str(g-1);
    time=num2str(sum(Time(1:g)));
    sidebar=text(px,py,[num ' - ' time]);
    set(sidebar,'fontsize',18);
    py=py-0.3;
    
end



