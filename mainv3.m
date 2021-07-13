clear all

 if ~isempty(gcp('nocreate'))
     delete(gcp('nocreate'));
 end
%define number of pools the computer capacity have.
npools=str2num(getenv('NUMBER_OF_PROCESSORS'));
logname=['logs/logtimes' datestr(now,'mmddHHMM') '.txt'];
fileID=fopen(logname,'w');
%% environment settings
time0=cputime;
fprintf(fileID, 'Logfile %s \n ------------------------- \n Initial time= %f\n', logname, time0);
env=env2();
envAut=env3();
pt1=cputime-time0;
fprintf(fileID, ' Process \t Computation Time\n Environment setting \t %f\n', pt1);
%env=env1();
%% WTS
time0=cputime;
absSet.opt_c=33;absSet.eps=0.5;absSet.u_joint=0;absSet.lin_ass=0;absSet.rest=0.001;
T=TS_construction(env,absSet);
pt2=cputime-time0;
T2=TS_construction(envAut,absSet);
pt2b=cputime-pt2;
fprintf('WTS constructed.\n');
fprintf(fileID, ' Abstraction \t %f\t %f\n', pt2,pt2b);
%% Visualize the WTS
%Partition
time0=cputime;
figure;
Ttot={T,T2}; envTot={env, envAut};
partition_viz_simple(Ttot, envTot,1); % contains the plot
pt3=cputime-time0;
fprintf(fileID, ' Visualization of Workspace \t %f\n', pt3);
%% TAhd
time0=cputime;
TAhd=hybridTAsoftandhard([0.5 0.9]);
pt4=cputime-time0;
TAhd1=hybridTAsoftandhard([0.01 0.03]);
pt4b=cputime-pt4;
%name='log.txt'; %change to save data
fprintf('TAhd is constructed \n');
fprintf(fileID, ' TAhd Construction  \t %f\t %f\n', pt4, pt4b);
%% PA
time0=cputime;
P=product2(T,TAhd,2);
pt5=cputime-time0;
P2=product2(T2,TAhd1,2);
pt5b=cputime-pt5;
fprintf('PA is constructed \n');
tafpa=datestr(now);
fprintf(fileID, ' Product Construction \t %f\t %f\n', pt5,pt5b);
%% graph search
h0=0.5;

%human controlled agent (no subscript)
time0=cputime;
[gS ] = graphSearch( P,h0 );
pt6=cputime-time0; %computation time for graph searching
path_WTS=wtsProject(gS.path, P);
GS={};pWTS={}; Ps={};
GS{1}=gS;pWTS{1}=path_WTS;

%automatic agent (subscript 2)
time0=cputime;
[gS2 ] = graphSearch( P2,h0 );
pt7=cputime-time0;
path_WTS2=wtsProject(gS2.path, P2);
GS2={};pWTS2={}; Ps2={};
GS2{1}=gS2;pWTS2{1}=path_WTS2;
fprintf('Graph search completed\n');

%% viz derivative inside the states in the path
fastfig(T,path_WTS,env);
    
%% viz the actual path taken
truepath(env,gS, T, path_WTS);

%% see initial plans
[ x1init, xl1init, t1,tinit1, ~ ]=onlineRun(env, gS, T, path_WTS,ones(1,length(path_WTS)),env.x0, zeros(1,6),0, 0,envAut,T2,0,0);

[ x2init, xl2init, t2,tinit2, ~ ]=onlineRun(envAut, gS2, T2, path_WTS2,ones(1,length(path_WTS2)),envAut.x0, zeros(1,6),0, 0,env,T,2,0);


%% online run - initial settings

% what are the possible inputs for uh?
k=1; %number of suggested paths at this time
Ps{1}=P; Ps2{1}=P2;%product automata (initial settings)
time0=cputime;
Qd=hardConVio(P); Qd2=hardConVio(P2); %states in which the hard constraint is vioated
QT=timedQd(Qd,P); QT2=timedQd(Qd2,P2);%pairs of state/time of which the hard constarint cannot be satisfied
pt8=cputime-time0;

x1=env.x0'; x2=envAut.x0'; % initial positions
umax=3*env.U(2); %max allowed input
ds=0.1; eps=0.01; %safety margins
Tt=0; %initial time
dT=0.015; %time step
compl=0;%completion variable (1 when task is achieved)
it=1;it2=1; %current step in WTS path for each agent (i.e. number of states agent has visisted so far)
count=0;    % number of iterations performed of the onine run (number of possibilities for human to interefer) until now
hrun.eps=eps; hrun.dt=ds; hrun.QT=QT; %bundling settings to varaible hrun
follow1=P.init; follow2=P2.init; %current path (i.e. states visited so far in order)
Twodone=0; Onedone=0; % flag varaibles indicating that each agent has completed its task (1 if done)
stop1T=0; stop2T=0; %time each agent has been standing still sense last moving
hk=h0; %current guess for h (preference) 
allT1=[0];allT2=[0]; %total time which has passed sense start
a1.Init.dd=0; a2.Init.dd=0; %initial discrete distance
a1.Init.dc=0; a2.Init.dc=0; %initial continiuous distance
a1.Init.dh=0;a2.Init.dh=0;  %initial hybird distance
T1max=dT*5; T2max=dT+0.001; %maximal tome each agent is allowed to stand still before action is taken
xltot=[x1]; xltot2=[x2];  %complete discrete trajectory taken so far (as positions rather than states)
ttot=[0];ttot2=[0]; %array of time instances at which the agents reached the posiont of the xltot vectors
dummy=1; %flag variable used during testing to see which loop issued trouble

%% online run - the run!
partition_viz_simple({T,T2}, {env,envAut},1,'Online Run');

while compl~=1 %while taks is not completed
    pi1curr=P.S(follow1(end),1);pi2curr=P2.S(follow2(end),1); %current regions
    QT1temp=[]; QT2temp=[]; %states which are temporally violating
    succ1=find(P.trans(follow1(end),:)~=Inf);succ2=find(P2.trans(follow2(end),:)~=Inf);%possible successors (states we can move to)
    %update violating states to include any state which require the agent
    %to be in the region which the other agent is currently in
    for q=succ1
        if P.S(q,1)==pi2curr
            QT1temp=[QT1temp; q 0];
        end
    end
    for q=succ2
        if P.S(q,1)==pi1curr
            QT2temp=[QT2temp; q 0];
        end
    end
    hrun.QT=[QT; QT1temp]; %add tempo violating states to the set of violating states
    count=count+1; %add to the number of iterations
    if Onedone==0 %agent 1 has not completetd its task
        inputX=humanInput2(pWTS{k},it); %get input from user
        time0=cputime;
    else %agent 1 has completed its task
        inputX='1'; %no input needed
        dummy=dummy+1; %add to number of iterations when only agent 2 is moving
    end
    if strcmp(inputX, '1') %human gives no input
        %drive on
        if Onedone==0 %task is not completed
            step=pWTS{k}(it:it+1); %the current and next region accorfing to aut plan
            if pi2curr==pWTS{k}(it+1) %agent 2 is in the next region
                step=[pWTS{k}(it) pWTS{k}(it)]; %new plan is to stop and wait
                stop1=1; %flag indicating that we stopped
            else
                stop1=0;
            end
            % determine the trajectory given the input and the plan
            % outputs: trajectory, new position, process time, time vector,
            % current time, kappa(mic), flag =1 if new region entered
            [ x1d, xl, TIME,tsteps, outTime, K , exit1]=onlineRun(env, GS{end}, T, step,dT,x1(:,end), zeros(1,6) ,count-1, Tt,envAut,T2,min(1,count-1), 0);
             x1=[x1 x1d]; xltot=[xltot xl(:,2:end)]; %complete trajectories 
             ttot=[ttot TIME(2:end)];allT1=[allT1 tsteps+allT1(end)]; %complete time vectors
        end
        if Twodone==0 %agent 2 has not completed its task
            step=pWTS2{end}(it2:it2+1);
            if pi1curr==pWTS2{end}(it2+1)
                step=[pWTS2{end}(it2) pWTS2{end}(it2)];
                stop2=1;
            else
                stop2=0;
            end
            [ x2d, xl, TIME,tsteps, test,test,exit2 ]=onlineRun(envAut, GS2{end}, T2, step,dT,x2(:,end), zeros(1,6),count-1, Tt,env,T,2,0);
            x2=[x2 x2d];xltot2=[xltot2 xl(:,2:end)]; 
            ttot2=[ttot2 TIME(2:end)];allT2=[allT2 tsteps+allT2(end)];
        end
        %update current state given previous state, time elapsed and
        %current region
        [ q2,err] = currentStateCalc( follow1(end), Tt+dT,P, T,x1(:,end) ,TAhd);
        [q22,err]=currentStateCalc( follow2(end), Tt+dT,P2, T2,x2(:,end) ,TAhd1);
        %add current state to path
        follow1=[follow1 q2]; follow2=[follow2 q22];
        %update settings
        Current=easyCurr( follow1(length(follow1)-1),q2,it, Tt+dT, a1.Init.dd, a1.Init.dc);
        Current2=easyCurr( follow2(length(follow2)-1),q22,it2, Tt+dT, a2.Init.dd, a2.Init.dc );
        a1.Init= init4P(Current,P); a2.Init= init4P(Current2,P2);
        if Onedone==0 %agent 1 is not done
            if P.S(q2,1)==pWTS{k}(it+1) %current region is the planned successor
                it=it+1; %progress in plan one step
            end
        end
        if Twodone==0
            if P2.S(q22,1)==pWTS2{end}(it2+1)
                it2=it2+1;
            end
        end
        Tt=Tt+dT; %add elapsed time to current time
    else %human gives input!
        %determine Uh 
        [Uh, err]=easyControl(inputX, umax);
        %evolve
        %[t, x, K]=simEvo( pWTS{k}(it),pWTS{k}(it+1),env.A,T,x1(1,end),x1(2,end),dT,Uh,QT,Tt,ds,eps );
        
        step=pWTS{k}(it:it+1);
        if pi2curr==pWTS{k}(it+1)
            step=[pWTS{k}(it) pWTS{k}(it)];
            stop1=1;
        else
            stop1=0;
        end
        [ x1d, xl, TIME,tsteps,outTime, K,exit1 ]=onlineRun(env, GS{end}, T, step,dT,x1(:,end), Uh ,count-1, Tt,envAut,T2,min(1,count-1),0, hrun);
        x1=[x1 x1d]; xltot=[xltot xl(:,2:end)]; 
        ttot=[ttot TIME(2:end)];allT1=[allT1 tsteps+allT1(end)];
        if Twodone==0
            step=pWTS2{end}(it2:it2+1);
            if pi1curr==pWTS2{end}(it2+1)
                step=[pWTS2{end}(it2) pWTS2{end}(it2)];
                stop2=1;
            else
                stop2=0;
            end
            [ x2d, xl, TIME ,tsteps, test,test,exit2]=onlineRun(envAut, GS2{end}, T2, step,dT,x2(:,end), zeros(1,6),count-1, Tt,env,T,2,0);
            x2=[x2 x2d];xltot2=[xltot2 xl(:,2:end)]; 
            ttot2=[ttot2 TIME(2:end)];allT2=[allT2 tsteps+allT2(end)];
        end
    
        %check state
        if 0==0
            [ q2,err] = currentStateCalc( follow1(end), Tt+dT,P, T,x1(:,end) ,TAhd);
        end
        if 0==0
            [q22,err]=currentStateCalc( follow2(end), Tt+dT,P2, T2,x2(:,end) ,TAhd1);
        end
        follow1=[follow1 q2]; follow2=[follow2 q22];
        %update settings
        Data.X=x1(1,:); Data.Y=x1(2,:); Data.Tb=T; Data.follow=follow1; Data.p=P;Data.allT=allT1;Data.A=env.A;
        GS{k}.index=length(x1);
        GS{k}.lastit=it;
        Current=easyCurr( follow1(length(follow1)-1),q2,it, Tt+dT, a1.Init.dd, a1.Init.dc, GS, Data );
        Current2=easyCurr( follow2(length(follow2)-1),q22,it2, Tt+dT, a2.Init.dd, a2.Init.dc );
        a1.Init= init4P(Current,P); a2.Init= init4P(Current2,P2);
        %if new state and not previous goal state learn!
        pt9=cputime-time0;
        %fprintf(fileID, ' Matlab Spec. determining where to go \t %f\n', pt9);
        if P.S(q2,1)~=pWTS{k}(it) && P.S(q2,1)~=pWTS{k}(it+1) %current region is not the start or goal of the current step from plan
            time0=cputime;
            [ plan ] = learnh( Ps{end}, k, GS, Current ); %replan and find new h
            pt10=cputime-time0;
            %fprintf(fileID, 'Learning h \t %f\n', pt10);
            plan.Current=Current;
            %add new plan to log
            k=k+1;
            GS{k}=plan.gS;
            Ps{k}=plan.P;
            pWTS{k}=wtsProject(plan.gS.path, P);
            hk=plan.h;
            %increase it (the new plan will begin with the path we
            %followed)
            it=it+1;
        elseif P.S(q2,1)==pWTS{k}(it+1)
            %we followed robots plan, increase it
            it=it+1;
        end
        if Twodone==0
            if P2.S(q22,1)==pWTS2{end}(it2+1)
                it2=it2+1;
            end
        end
        Tt=Tt+dT;
    end
    if it==length(pWTS{k}) %the number of states we visited=number of states in th eplan
        Onedone=1;
    end
    if it2==length(pWTS2{end})
        Twodone=1;
    end
    if Onedone==1 && Twodone==1 %both agents are done
        compl=1;
    end
    if stop1==1 %agent 1 is waiting due to agents 2 being in the way
        stop1T=stop1T+dT;%add to time it has been waiting
    else %agent 1 is not waiting
        stop1T=0; %reset time it has been waiting
    end
    if stop2==1
        stop2T=stop2T+dT;
    else
        stop2T=0;
    end
    if stop1T> T1max %the allowed time to wait has passed
        time0=cputime;
        Ptemp=P; %copy product
        for q=QT1temp(:,1)' %all temporally violating states (due to agent 2 being in them)
            Ptemp.trans(q,:)=ones(1,length(P.Q))*Inf; %make all trans from q impossible
        end
        k=k+1;
        Ptemp.init=q2;
        a1.Init.dh=hk*a1.Init.dc+(1-hk)*a1.Init.dd;
        GS{k}=graphSearch(Ptemp,hk, a1.Init); %re plan with the vio states excluded
        pt11=cputime-time0;
        %fprintf(fileID, 'Collision Avoidance Re-planning \t %f\n', pt11);
        GS{k-1}.index=length(x1);
        GS{k-1}.lastit=it;
        if GS{end}.Ftime==Inf %no path found == need to pass through the state at some time
            %new task: move out of the way!
            time0=cputime;
            succ=find(Ptemp.trans(q2,:)~=Inf); %all possible states we can move to
            goal=[];
            for s=succ
                if ~timeMember(s,QT1temp,Tt)&& Ptemp.S(s,1)~=Ptemp.S(q2,1)
                    goal=[goal s]; %all successors of current state which are not forbidden (and means moving)
                end
            end
            Ptemp.final=goal;
            GS{k}=graphSearch(Ptemp,hk,a1.Init);
            pt12=cputime-time0;
            %fprintf(fileID, 'Temporary task (move out of the way) \t %f\n', pt12);
            GS{k}.index=length(x1);
            GS{k}.lastit=it;
            GS{end}.path=[GS{length(GS)-1}.path(1:it), GS{end}.path(2:end)];
            GS{end}.time_vector=[GS{length(GS)-1}.time_vector(1:it), GS{end}.time_vector(2:end)];
            GS{end}.DD=[GS{length(GS)-1}.DD(1:it), GS{end}.DD(2:end)];
            GS{end}.DC=[GS{length(GS)-1}.DC(1:it), GS{end}.DC(2:end)];
            Ps{end+1}=P;
            Ps{end}.init=GS{end}.path(end);
            a1.InitPlan.time=GS{end}.Ftime;
            a1.InitPlan.dd=GS{end}.Fdd;
            a1.InitPlan.dc=GS{end}.Fdc;
            a1.InitPlan.dh=hk*a1.InitPlan.dc+(1-hk)*a1.InitPlan.dd;
            time0=cputime;
            gSnew=graphSearch(Ps{end},hk,a1.InitPlan);
            pt13=cputime-time0;
            %fprintf(fileID, 'New plan after temporary task \t %f\n', pt13);
            GS{end}.path=[GS{end}.path gSnew.path(1:end)];
            GS{end}.time_vector=[ GS{end}.time_vector gSnew.time_vector(1:end)+dT];
            GS{end}.DD=[GS{end}.DD gSnew.DD(1:end)+GS{end}.DD(end)-GS{end}.DD(length(GS{end}.DD)-1)];
            GS{end}.DC=[ GS{end}.DC gSnew.DC(1:end)+GS{end}.DC(end)-GS{end}.DC(length(GS{end}.DC)-1)];
            pWTS{end+1}=wtsProject(GS{end}.path, Ps{end});
        else %new path exists wich doesn't use the occupied one
            GS{end}.path=[GS{length(GS)-1}.path(1:it), GS{end}.path(2:end)];
            GS{end}.time_vector=[GS{length(GS)-1}.time_vector(1:it), GS{end}.time_vector(2:end)];
            GS{end}.DD=[GS{length(GS)-1}.DD(1:it), GS{end}.DD(2:end)];
            GS{end}.DC=[GS{length(GS)-1}.DC(1:it), GS{end}.DC(2:end)];
            pWTS{end+1}=wtsProject(GS{end}.path, Ptemp);
        end
    end
    if stop2T> T2max
        Ptemp=P2;
        time0=cputime;
        for q=QT2temp(:,1)'
            Ptemp.trans(q,:)=ones(1,length(P2.Q))*Inf;
        end
        Ptemp.init=q22;
        a2.Init.dh=h0*a2.Init.dc+(1-h0)*a2.Init.dd;
        GS2new=graphSearch(Ptemp,h0,a2.Init);
        pt14=cputime-time0;
        %fprintf(fileID, 'Collision Avoidance Re-planning(2) \t %f\n', pt14);
        if GS2new.Ftime==Inf
            %no path found == need to pass through the state at some time
            %new task: move out of the way!
            time0=cputime;
            succ=find(Ptemp.trans(q22,:)~=Inf);
            goal=[];
            for s=succ
                if ~timeMember(s,QT2temp,Tt)&& Ptemp.S(s,1)~=Ptemp.S(q22,1)
                    goal=[goal s]; %all successors of current state which are not forbidden (and means moving)
                end
            end
            Ptemp.final=goal;
            GS2getAway=graphSearch(Ptemp,h0,a2.Init);
            pt15=cputime-time0;
            %fprintf(fileID, 'Temporary task (moving out of the way)(2) \t %f\n', pt15);
            GS2{end+1}=GS2getAway;
            GS2{end}.path=[GS2{length(GS2)-1}.path(1:it2), GS2{end}.path(2:end)];
            GS2{end}.time_vector=[GS2{length(GS2)-1}.time_vector(1:it2), GS2{end}.time_vector(2:end)];
            GS2{end}.DD=[GS2{length(GS2)-1}.DD(1:it2), GS2{end}.DD(2:end)];
            GS2{end}.DC=[GS2{length(GS2)-1}.DC(1:it2), GS2{end}.DC(2:end)];
            Ps2{end+1}=P2;
            Ps2{end}.init=GS2{end}.path(end);
            a2.InitPlan.time=GS2{end}.Ftime;
            a2.InitPlan.dd=GS2{end}.Fdd;
            a2.InitPlan.dc=GS2{end}.Fdc;
            a2.InitPlan.dh=h0*a2.InitPlan.dc+(1-h0)*a2.InitPlan.dd;
            time0=cputime;
            gSnew=graphSearch(Ps2{end},h0,a2.InitPlan);
            pt16=cputime-time0;
            %fprintf(fileID, 'New plan after a temporary task (2) \t %f\n', pt16);
            deltaT=dT;
            GS2{end}.path=[GS2{end}.path gSnew.path(1:end)];
            GS2{end}.time_vector=[ GS2{end}.time_vector gSnew.time_vector(1:end)+deltaT];
            GS2{end}.DD=[GS2{end}.DD (GS2{end}.DD(end)-GS2{end}.DD(length(GS2{end}.DD)-1))+ gSnew.DD(1:end)];
            GS2{end}.DC=[ GS2{end}.DC (GS2{end}.DC(end)-GS2{end}.DC(length(GS2{end}.DC)-1))+ gSnew.DC(1:end)];
            pWTS2{end+1}=wtsProject(GS2{end}.path, Ps2{end});
        else
            GS2{end+1}=GS2new;
            GS2{end}.path=[GS2{length(GS2)-1}.path(1:it2), GS2{end}.path(2:end)];
            GS2{end}.time_vector=[GS2{length(GS2)-1}.time_vector(1:it2), GS2{end}.time_vector(2:end)];
            GS2{end}.DD=[GS2{length(GS2)-1}.DD(1:it2), GS2{end}.DD(2:end)];
            GS2{end}.DC=[GS2{length(GS2)-1}.DC(1:it2), GS2{end}.DC(2:end)];
            pWTS2{end+1}=wtsProject(GS2{end}.path, Ptemp);
        end
    end
end
fprintf('Task completeted!\n');

%fclose(fileID);
%% the final paths ploted
X={x1(1,:),x2(1,:)}; Y={x1(2,:), x2(2,:)}; 
XL={xltot(1,:), xltot2(1,:)};YL={xltot(2,:), xltot2(2,:)};
TIME={ttot, ttot2}; Tb={T, T2}; envb={env2, envAut};
 plotPath( X,Y,XL,YL,TIME,Tb,envb );
 %% animate final
 r=0.1;ColOr={[0.9100    0.4100    0.1700],[1 0 1]}; del=10;
 stamp=datestr(now,'mmddHHMM');
 stamp='4Animation';
 for step=1:del:length(X{2})+3
     f=figure;
     XI={x1init(1,:),x2init(1,:)}; YI={x1init(2,:), x2init(2,:)}; 
     XL={xl1init(1,:), xl2init(1,:)};YL={xl1init(2,:), xl2init(2,:)};
     TIME={t1, t2}; Tb={T, T2}; envb={env2, envAut};
     plotPath2( XI,YI,XL,YL,TIME,Tb,envb );
     hold on
     if step>length(X{1})
        c1=[X{1}(end) Y{1}(end)];
     else
        c1=[X{1}(step) Y{1}(step)]; 
     end
     if step>length(X{2})
        c2=[X{2}(end) Y{2}(end)];
     else
    c2=[X{2}(step) Y{2}(step)]; 
     end
     pos1 = [c1-r 2*r 2*r]; pos2=[c2-r 2*r 2*r];
     rectangle('Position',pos1,'Curvature',[1 1], 'FaceColor', ColOr{1}, 'Edgecolor','none')
     hold on
     rectangle('Position',pos2,'Curvature',[1 1], 'FaceColor', ColOr{2}, 'Edgecolor','none')
     axis equal
     if step>length(X{1})
         plot(X{1},Y{1},'Color', ColOr{1});
     else
        plot(X{1}(1:step),Y{1}(1:step),'Color', ColOr{1});
     end
     if step>length(X{2})
         plot(X{2},Y{2}, 'Color', ColOr{2});
     else
        plot(X{2}(1:step),Y{2}(1:step), 'Color', ColOr{2});
     end
     saveas(f,['figures/FIG' stamp int2str(step)],'png');
 end
 close all;
 
 %% initial paths plotted
 X={x1init(1,:),x2init(1,:)}; Y={x1init(2,:), x2init(2,:)}; 
XL={xl1init(1,:), xl2init(1,:)};YL={xl1init(2,:), xl2init(2,:)};
TIME={t1, t2}; Tb={T, T2}; envb={env2, envAut};
 plotPath( X,Y,XL,YL,TIME,Tb,envb );
 %% Resulting values of dist
 X={x1(1,:),x2(1,:)}; Y={x1(2,:), x2(2,:)}; 
 allT={allT1, allT2}; follow={follow1,follow2};p={P,P2};H={hk,h0};
 [dd_real, dc_real, dh_real, trans]=realDistances(X,Y,Tb,follow, allT,p,H);
 
 %% the actual initial distances
  X={x1init(1,:),x2init(1,:)}; Y={x1init(2,:), x2init(2,:)}; 
  allT={tinit1, tinit2}; follow={gS.path, gS2.path}; p={P,P2}; H={h0,h0};
 [dd_realI, dc_realI, dh_realI, trans]=realDistances(X,Y,Tb,follow, allT,p,H);

%% 
% x=env.x0; ds=0.1; eps=0.01;Tt=0;round=1;
% while i<length(pWTS{end})
%     choice=humaninputoptions(pWTS{end}, i, T,env); 
%     inputX=humanInput(choice);
%     if i<force
%         round=force;
%     else
%         round=i;
%     end
%     if strcmp(inputX,'follow') || strcmp(inputX, '1')
%         drive on!
%         fprintf('\n Following the robots plan!\n');
%         [x, Tt]= onlineRun(env, GS{k}, T, pWTS{k}(i:i+1),i+1,x, zeros(1,6), round-1, Tt);
%         i=i+1;
%     else
%         Current=setUpCurr(P, inputX, i,env, GS,choice,k);
%         if timeMember(Current.firststate,QT, Current.time)
%             if Current.dir=='u'
%                 dist=abs(x(2)-T.R(1,2,P.S(Current.firststate,2)));
%             elseif Current.dir=='d'
%                 dist=abs(x(2)-T.R(2,2,P.S(Current.firststate,2)));
%             elseif Current.dir=='l'
%                 dist=abs(x(1)-T.R(2,1,P.S(Current.firststate,2)));
%             else
%                 dist=abs(x(1)-T.R(1,1,P.S(Current.firststate,2)));
%             end
%         else dist=Inf;
%         end
%         K=rhofunc(dist,ds,eps);
%         Uh=K*[choice.AH{Current.opt}(1,:) choice.AH{Current.opt}(2,:) choice.BH{Current.opt}'];
%         [x, Tt]=onlineRun(env, GS{k}, T, wtsProject([Current.laststate Current.firststate], P),i+1,x, Uh, round-1, Tt);
%         if containedIn(x,wtsProject(Current.firststate, P), T) %if we managed to reach the state the user intended
%             [ plan ] = learnh( Ps{end}, k, GS, Current );
%             k=k+1;
%             GS{k}=plan.gS;
%             Ps{k}=plan.P;
%             pWTS{k}=wtsProject(plan.gS.path, P);i=i+1; 
%         else
%             force=i+1;
%         end %otherwise it may be unsafe, we don't learn from this but continue and see what happens
%         
%         end
%     end
% end
% fprintf('\n path ended! \n');
% viz
% truepath(env,GS{k}, T, pWTS{k});

