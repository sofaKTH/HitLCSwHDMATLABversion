%% main.m
%Sofie Andersson, 23/2-17
%This script constructs a PA from a WTS and a TAhd and finds the shortest
%accepting run wrt hybrid distance.
%The environment setting are given in this file, the demand specifications
%are given in the demand.m file.
%The result is written to a file in logfiles
%% Preliminaries
clear all

 if ~isempty(gcp('nocreate'))
     delete(gcp('nocreate'));
 end
%define number of pools the computer capacity have.
npools=str2num(getenv('NUMBER_OF_PROCESSORS'));

%% environment settings
n=15;a=1; b=2; pi=2; Pi=1:pi; 
Lap=cell(1,pi);
Lap{1}=[8 9 13]; Lap{2}=[10 15];
up=1; down=3; left=1; right=2;
init=6;
AP_label{1}='a'; AP_label{2}='b'; AP_label{3}='c'; 
AP_label{4}='d';AP_label{5}='e';

%% env 2
A=[2 1; 0 2];B=[1 0; 0 1];
x1_min=1;x2_min=1;x1_max=6;x2_max=4;X=[x1_min x2_min;x1_max x2_max];
u_max=20;u_min=-u_max;U=[u_min u_max];

%AP=cell(2,2,n);
x1_start=x1_min; x2_start=x2_min;count=1;
for i=1:n
    AP(1,1,i)=x1_start; AP(1,2,i)=x2_start; AP(2,1,i)=x1_start+(x1_max-x1_min)/5;
    AP(2,2,i)=x2_start+(x2_max-x2_min)/(n/5);
    if x2_start+(x2_max-x2_min)/(n/5)==x2_max
        x1_start=x1_start+(x1_max-x1_min)/5;
        x2_start=x2_min;
    else
        x2_start=x2_start+(x2_max-x2_min)/(n/5);
    end
    count=count+1;
end

x0=[(AP(2,1,init)+AP(1,1,init))/2 (AP(2,2,init)+AP(1,2,init))/2];
FT1=[x2_min x1_min x1_max; x2_max x1_min x1_max];FT2=[x1_min x2_min x2_max; x1_max x2_min x2_max];
FT{1}=FT1;FT{2}=FT2;

%% Construct WTS

%simple
[ T] = WTS_simpleconstruction( n, a, b, Pi, Lap, up, down, left, right, init);
FT=T.FT;
%%
%Belta
opt_c=33;eps=0.5;u_joint=0;lin_ass=0;rest=0.001;
T=TS_construction(A,B,X,U,AP,x0,FT,opt_c,eps,lin_ass,u_joint,rest, Lap);



fprintf('WTS constructed.\n');
%% Visualize the WTS
%Partition
figure;
agent=partition_viz_simple(T.R, FT, Lap, AP_label,1,1,1,T.current,1);

%% Define the TBA from the MITL formula
% The parameters is manually given in the function, 
%To change MITL formula: create the corresponding TAhd and put the
%parameters for the TAhd and the MITL formula in the file TAhd_demand.m
%[TAhd, MITL]=TAhd_demand(pi);
TAhd=hybridTA(5);
name='log.txt'; %change to save data
fprintf('TAhd is constructed \n');

%% Function that construct the automata product
% tbfpa=datestr(now);
% if length(TAhd.C)+1<npools-1
%     npool=length(TAhd.C)+1;
% else
%     npool=npools-1;
% end
% P = product(T,TAhd,npool);
P=product2(T,TAhd,1);
fprintf('PA is constructed \n');
tafpa=datestr(now);
%% Control design
% DFS algorithm to find accepting run
%1
c=0.1;
[pathPA, pathTAhd, pathTS, hybridDistance, distanceVector, completionTime, dcTotal, ddTotal, dcVector, ddVector, timeStep] = foundPath(P,c);
Result{1}.pathPA=pathPA; Result{1}.pathTAhd=pathTAhd; 
Result{1}.pathWTS=pathTS;Result{1}.hybridDistance=hybridDistance;
Result{1}.distanceVector=distanceVector; Result{1}.completionTime=completionTime;
Result{1}.dcTotal=dcTotal; Result{1}.ddTotal=ddTotal; Result{1}.dcVector=dcVector;
Result{1}.ddVector=ddVector; Result{1}.timeStep=timeStep; Result{1}.c=c;
tafc1=datestr(now);
%2
c=0.6;
[pathPA, pathTAhd, pathTS, hybridDistance, distanceVector, completionTime, dcTotal, ddTotal, dcVector, ddVector, timeStep] = foundPath(P,c);
Result{2}.pathPA=pathPA; Result{2}.pathTAhd=pathTAhd; 
Result{2}.pathWTS=pathTS;Result{2}.hybridDistance=hybridDistance;
Result{2}.distanceVector=distanceVector; Result{2}.completionTime=completionTime;
Result{2}.dcTotal=dcTotal; Result{2}.ddTotal=ddTotal; Result{2}.dcVector=dcVector;
Result{2}.ddVector=ddVector; Result{2}.timeStep=timeStep; Result{2}.c=c;
tafc2=datestr(now);
%3
c=0.9;
[pathPA, pathTAhd, pathTS, hybridDistance, distanceVector, completionTime, dcTotal, ddTotal, dcVector, ddVector, timeStep] = foundPath(P,c);
Result{3}.pathPA=pathPA; Result{3}.pathTAhd=pathTAhd; 
Result{3}.pathWTS=pathTS;Result{3}.hybridDistance=hybridDistance;
Result{3}.distanceVector=distanceVector; Result{3}.completionTime=completionTime;
Result{3}.dcTotal=dcTotal; Result{3}.ddTotal=ddTotal; Result{3}.dcVector=dcVector;
Result{3}.ddVector=ddVector; Result{3}.timeStep=timeStep; Result{3}.c=c;
tafc3=datestr(now);

fprintf('Path searched \n');
%%
%above ok, below not done - run tests on part above to see if ther are any
%unknown problems.

%% Print path result
filename=['logs/' name];
fileID=fopen(filename,'w');
%print preliminaries to file
fprintf(fileID, 'Result of control synthesis for single agent motion planning with MITL specifications wrt hybrid distance.\n');
fprintf(fileID, '-----------------------------------------------------------\n');
fprintf(fileID, '\n \n MITL formula: \n %s \n -------------------------------------------------------------',MITL);
fprintf('The search was a success, the result is written to the file %s \n',filename);
for elem=1:3
    fprintf(fileID,'\n The shortest path in T which satisfies the MITL formula is:\n [ %d ',Result{elem}.pathWTS(1));
    repeat=0;
    for i=2:length(Result{elem}.pathWTS)
        if repeat==1
            fprintf(fileID,'...');
        end
        if Result{elem}.pathWTS(i)~=Result{elem}.pathWTS(i-1)
            fprintf(fileID,'%d ',Result{elem}.pathWTS(i));
            repeat=0;
        else
            repeat=repeat+1;
        end
    end
    fprintf(fileID,' ]\n');
    distance_final=Result{elem}.completionTime;
    fprintf(fileID,'The corresponding time is: %d', distance_final);
    fprintf(fileID,'\n');
end

%%
%continuous plots
laps=[0 0];
plotStyle = {'b','k','r','m','g','c','y'}; 
FigHandle=figure(1);
set(FigHandle, 'Position', [100, 100, 1000, 400]);
for i=1:3
    x=zeros(1, length(Result{i}.pathWTS));
    y=zeros(1, length(Result{i}.pathWTS));
    [ agent] = partition_viz_simple(T.R, FT, Lap, AP_label,2,2,i,T.current,1);
    for j=1:length(Result{i}.pathWTS)
        state=Result{i}.pathWTS(j);
        R=T.R(:,:,state); 
        max1=R(2,1); max2=R(2,2); min1=R(1,1); min2=R(1,2);
        x(j)=(max1+min1)/2; y(j)=(max2+min2)/2;
    end
    plot(x,y);
end


%%
% set(gca,'Position',[.05 .05 .45 .9]);
% %hold on
% i=1;
% limitreached=0;
% while i<1+length(xl)
%     addtxt=num2str(i-1);
%     if i<length(xl)
%         while xl(i)==xl(i+1)&&yl(i)==yl(i+1)
%             addtxt=[addtxt '-' num2str(i)];
%             if i<length(xl)-1
%                 i=i+1;
%             else
%                 limitreached=1;
%                 break;
%             end
%         end
%     end
%     numbers=text(xl(i),yl(i),addtxt);
%     set(numbers,'fontsize',18);
%     i=i+1;
%     if limitreached==1
%         break;
%     end
% end
% px=T.R(2,1,T.S(end))+0.1;
% py=T.R(2,2,T.S(end));
% sidebar=text(px,py,['Completion time']);
% py=py-0.3;
% for g=1:length(xl)
%     num=num2str(g-1);
%     time=num2str(sum(Time(1:g)));
%     if g>1
%         if Time(g)~=timeStep(g)
%             time=[time ' wait till ' num2str(sum(timeStep(2:g)))];
%             Time(g)=timeStep(g);
%         end
%     end
%     sidebar=text(px,py,[num ' - ' time]);
%     set(sidebar,'fontsize',18);
%     py=py-0.3;
% end
% %%
% py=py-0.3;
% sidebar=text(px,py,['Hybrid Distance']);
% py=py-0.3;
% for g=1:length(xl)
%     num=num2str(g-1);
%     hd=num2str(sum(distanceVector(1:g)));
%     dc=num2str(sum(dcVector(1:g)));dd=num2str(sum(ddVector(1:g)));
%     sidebar=text(px,py,[num ' - dc: ' dc ', dd:' dd '->dH:' hd]);
%     set(sidebar,'fontsize',18);
%     py=py-0.3;
% end
% 

