clear all

 if ~isempty(gcp('nocreate'))
     delete(gcp('nocreate'));
 end
%define number of pools the computer capacity have.
npools=str2num(getenv('NUMBER_OF_PROCESSORS'));
logname=['logs/logtimes' datestr(now,'mmddHHMM') '.txt'];
fileID=fopen(logname,'w');
addpath('BWTS','environment','figures','HRI and learning', 'logs', 'MIC',...
    'path','TAhd','TS','visualization', 'Trajectories' );
%% environment settings
% test both with some circles and he same setup as CASE
env=env2(); %CASE
absSet.opt_c=33;absSet.eps=0.05; absSet.lin_ass=0;absSet.u_joint=1; absSet.rest=0.001;
fprintf('Environment buildt\n');

%% Dense WTS
% dense WTS (as CASE)
dWTS=TS_construction(env, absSet);
fprintf('Dense WTS constructed\n');
%% TAhd
TAhd=hybridTAsoftandhard([0.5 0.9]);

fprintf('TAhd is constructed \n');

%% Sparse WTS
sWTS=sparseWTS(dWTS, TAhd.AP);

fprintf('Sparse WTS constructed\n');
%% Visualize the WTS
%sparse and dense in one image would be nice
color={'b','g','y','c','m','r', 'w'};
colormap=zeros(max(sWTS.L),1);
colormap(1)=3; colormap(2)=1; colormap(4)=4; colormap(8)=5; colormap(16)=6;
cm.color=color; cm.colormap=colormap;
visWTScombo(dWTS,sWTS,cm);

%% PA
P=sparseProduct(sWTS,TAhd,2);

fprintf('Product Construction\n');
%% initial graph search
h0=0.5;

[gS ] = graphSearchSparse( P,h0 );
path_sWTS=wtsProject(gS.path, P);
path_WTS = denseWTSProject(path_sWTS, sWTS, dWTS.current);

fprintf('Graph search completed\n');

%% viz derivative inside the states in the path
fastfig(dWTS,path_WTS,env); %dense path
    
%% viz the actual path taken
truepath(env,gS, dWTS, path_WTS);

%% online run - initial settings
GS={};GS{1}=gS;%reset set of found paths
k=1; %current number of plans
Pr={}; Pr{1}=P;%reset product
h=h0;%set value of human preference
taskComplete=0;
qnow=P.init;%initial state
humanAbort=0; %human prompted stop
time=0;  %time vector
x=env.x0'; %trajectory
indp=1; %index of current state in the path

% online run - the run!
%have in mind that if human press 1 the actual transition should occur
%before asking again



while taskComplete==0 && humanAbort==0
    %create prompt text
    prompt=printPlan(GS{k},Pr{k}, indp, sWTS, dWTS);
    tit='Human feedback';
    %ask for feedback
    [list,rem]=printOptions(GS{k}, Pr{k}, indp, sWTS, dWTS);
    [uh, stat]=listdlg('ListString', list, 'PromptString', prompt,...
        'SelectionMode','single', 'InitialValue',1,'Name', tit,...
        'OKString', 'Apply', 'CancelString', 'Abort!');
    %check what feedback was given 
    if stat==0 %abort!
        humanAbort=1; break;
    elseif uh==1
        %no feedback -> execute first step of plan and go back to step 1
        %dense path
        dpath=denseWTSProject(wtsProject(GS{k}.path(indp:indp+1),Pr{k}),sWTS,checkRegion(x(:,end),dWTS));
        
        for i=1:length(dpath)-1
            s1=dpath(i); s2=dpath(i+1);
            [xstep,tstep]=followPlan(s1,s2,env,dWTS,x(:,end));
            x=[x xstep(2:end,:)'];
            time=[time tstep(2:end)'+time(end)];
            %error check
            if checkRegion(x(:,end),dWTS)~=s2
                fprintf('\n------------\nsomething went wrong, the agent should be in %d but is in %d!\n---------------\n',...
                    s2,checkRegion(x(:,end),dWTS));
                break;
            else
                fprintf('completed transition!\n');
            end
        end
        %at this point the agent should have made the complete sparse
        %transition!
        indp=indp+1; %indicate the progress in the product path!
    else
        %feedback -> apply MIC to move agent until new state is reached
        
        %convert uh to match specific action (2=up, 3=down, 4=left,
        %5=right) rem=index of option removed from poss feedback
        if uh>=rem
            uh=uh+1;
        end

        % Learn new h and replan, go back to step 1
    end

    %check if accepting state is reached if yes, stop
    if ismember(GS{end}.path(indp),Pr{end}.final) %agent is in an accepting state
        taskComplete=1;
    end

end

%% functions (must be at the end of the script)
function [txtcell]=printPlan(gs,p, ic, sWTS, dWTS)
qc=gs.path(ic);
txt='The current plan is: ';
wp=wtsProject(gs.path,p);
for i=1:length(wp)-1
    txt=[txt num2str(wp(i)) '->'];
end
txt=[txt num2str(wp(end)) ' (or projected on the dWTS: '];
wp=denseWTSProject(wtsProject(gs.path,p), sWTS, dWTS.current);
for i=1:length(wp)-1
    txt=[txt num2str(wp(i)) '->'];
end
txt=[txt num2str(wp(end)) '). The agent is currently at ' num2str(wtsProject(qc,p)),...
    ' (or ' num2str(sWTS.map{wtsProject(qc,p)}) '). Do you want to follow the plan and move to '...
    num2str(wtsProject(gs.path(ic+1),p)) '? (Pick one option!)'];
txtcell=[{txt},{''},{''},{''},{''},{''},{''}];
end

function [listop, rem]=printOptions(gs,p, ic, sWTS, dWTS)
listop={'Yes, continue with the plan!','No, move up.', 'No, move down', 'No, move left', 'No, move right'};
qc=gs.path(ic); qn=gs.path(ic+1);
ssc=wtsProject(qc,p);ssn=wtsProject(qn,p);
sdc=sWTS.map{ssc};sdn=sWTS.map{ssn};
if sdn==sdc+1 && mod(sdc,length(dWTS.S)/dWTS.N1)~=0
    %plan is to go up
    listop(2)=[]; %removing as feedback option to go up
    rem=2;
elseif sdn==sdc-1 && mod(sdn,length(dWTS.S)/dWTS.N1)~=0
    %plan is to go down
    listop(3)=[]; %removing as feedback option to go down
    rem=3;
elseif sdn==sdc-length(dWTS.S)/dWTS.N1 && sdc> length(dWTS.S)/dWTS.N1
    %plan is to go left
    listop(4)=[]; %removing as feedback option to go left
    rem=4;
else
    %plan is to go right
    listop(5)=[]; %removing as feedback option to go right
    rem=5;
end
end
