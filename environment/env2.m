function[env]=env2()
%set up one version of an environment which can be used as input to my WTS
%abstractor.

n=15;% number of regions
env.n=n;
pi=4; % number of atomic propositions
env.Pi=1:pi; %set of atomic propositions
env.Lap=cell(1,pi); % labeling function
env.Lap{1}=[8 9]; env.Lap{2}=[5 11]; %states labelled with each ap
env.Lap{3}=[12]; env.Lap{4}=[6];
init=1; %initial state
env.init=init;
env.AP_label{1}='a'; env.AP_label{2}='b'; % label correspondans (number to letter for viz)
env.AP_label{3}='c'; env.AP_label{4}='d';


env.color={'r', 'y', 'g', [0, 0.5, 0]};

env.A=[2 1; 0 2];env.B=[1 0; 0 1]; % dynamics xdot=Ax+Bu
x1_min=1;x2_min=1;x1_max=6;x2_max=4;env.X=[x1_min x2_min;x1_max x2_max]; %state space
u_max=20;u_min=-u_max;env.U=[u_min u_max]; %limits of control input

%AP=cell(2,2,n);
x1_start=x1_min; x2_start=x2_min;
for i=1:n
    AP(1,1,i)=x1_start; AP(1,2,i)=x2_start; AP(2,1,i)=x1_start+(x1_max-x1_min)/5;
    AP(2,2,i)=x2_start+(x2_max-x2_min)/(n/5);
    if x2_start+(x2_max-x2_min)/(n/5)==x2_max
        x1_start=x1_start+(x1_max-x1_min)/5;
        x2_start=x2_min;
    else
        x2_start=x2_start+(x2_max-x2_min)/(n/5);
    end
end

env.x0=[(AP(2,1,init)+AP(1,1,init))/2 (AP(2,2,init)+AP(1,2,init))/2];
env.AP=AP;
FT2=[x2_min x1_min x1_max; x2_max x1_min x1_max];FT1=[x1_min x2_min x2_max; x1_max x2_min x2_max];
FT{1}=FT1;FT{2}=FT2;
env.FT=FT;
end