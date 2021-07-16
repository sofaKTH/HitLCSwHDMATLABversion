clear all

 if ~isempty(gcp('nocreate'))
     delete(gcp('nocreate'));
 end
%define number of pools the computer capacity have.
npools=str2num(getenv('NUMBER_OF_PROCESSORS'));
logname=['logs/logtimes' datestr(now,'mmddHHMM') '.txt'];
fileID=fopen(logname,'w');
%% environment settings
% test both with some circles and he same setup as CASE
env=env2(); %CASE
absSet.opt_c=11;absSet.eps=0.05; absSet.lin_ass=1;absSet.u_joint=0; absSet.rest=0.1;
fprintf('Environment buildt\n');

%% Dense WTS
% dense WTS (as CASE)
dWTS=TS_construction(env, absSet);
fprintf('Dense WTS constructed\n');
%% TAhd
TAhd=hybridTAsoftandhard([0.5 0.9]);

fprintf('TAhd is constructed \n');

%% Sparse WTS

%% Visualize the WTS
%sparse and dense in one image would be nice


%% PA
%needs upadtes to match new WTS
P=product2(T,TAhd,2);

fprintf('Product Construction\n');
%% initial graph search
h0=0.5;

%may need some upadtes to match new P
[gS ] = graphSearch( P,h0 );
path_WTS=wtsProject(gS.path, P);

fprintf('Graph search completed\n');

%% viz derivative inside the states in the path
fastfig(T,path_WTS,env); %dense path
    
%% viz the actual path taken
truepath(env,gS, T, path_WTS);

%% online run - initial settings

%% online run - the run!
%have in mind that if human press 1 the actual transition should occur
%before asking again
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
 

 %% Resulting values of dist
 X={x1(1,:),x2(1,:)}; Y={x1(2,:), x2(2,:)}; 
 allT={allT1, allT2}; follow={follow1,follow2};p={P,P2};H={hk,h0};
 [dd_real, dc_real, dh_real, trans]=realDistances(X,Y,Tb,follow, allT,p,H);
 
 %% the actual initial distances
  X={x1init(1,:),x2init(1,:)}; Y={x1init(2,:), x2init(2,:)}; 
  allT={tinit1, tinit2}; follow={gS.path, gS2.path}; p={P,P2}; H={h0,h0};
 [dd_realI, dc_realI, dh_realI, trans]=realDistances(X,Y,Tb,follow, allT,p,H);

