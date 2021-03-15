%Sofie Andersson, 7/3-16
%updated 8/2-19
%Constructing a WTS from a continuous linear system

function T = TS_construction(env,absSet)
Lap=env.Lap; A=env.A; B=env.B; X=env.X; U=env.U; AP=env.AP; x0=env.x0; FT=env.FT;
opt_c=absSet.opt_c;eps=absSet.eps; lin_ass=absSet.lin_ass;u_joint=absSet.u_joint; rest=absSet.rest;
N=1;%Number of locations (initial)
x1_limits=[X(1,1) X(2,1)]; %state space 1
x2_limits=[X(1,2) X(2,2)]; %state space 2
for i=1:length(AP) %for all ap's
    if ~any(AP(1,1,i)==x1_limits)% if the lower limit of ap is not in x1_limits
        N=N+1; %add 1 to number of states
        x1_limits=[x1_limits AP(1,1,i)]; %add the limit to x1_limit
    end
    if ~any(AP(2,1,i)==x1_limits) %if the upper limit of ap is not in x1_limit
        N=N+1;
        x1_limits=[x1_limits AP(2,1,i)];
    end
end
N1=N; %partitions in direction 1
for i=1:length(AP)
    if ~any(AP(1,2,i)==x2_limits)
        N=N+N1; %add N1 to the number of states
        x2_limits=[x2_limits AP(1,2,i)];
    end
    if ~any(AP(2,2,i)==x2_limits)
        N=N+N1;
        x2_limits=[x2_limits AP(2,2,i)];
    end
end
T.S = [1:N];  %locations
T.N1=N1; %save partitions in direction 1 (used for visualization)
R=[0 0;0 0];%Defining rectangles, R is a 2x2xN matrix (N rectangles)
x1_limits=sort(x1_limits);%sort lists of values for which there will be a limit
x2_limits=sort(x2_limits);
for j=1:N1
    a1=x1_limits(j);
    b1=x1_limits(j+1);
    for k=1:N/N1 %the rectangle corners
        R(:,:,(j-1)*N/N1+k)=[a1 x2_limits(k);b1 x2_limits(k+1)];
    end
end
T.R=R;%save rectangles
% setting initial location (check if the coordinate of the initial position
% is within the intervals of each rectangle)
for i=1:N
    if (R(1,1,i)<=x0(1)) && (R(2,1,i)>=x0(1))
        if (R(1,2,i)<=x0(2)) && (R(2,2,i)>=x0(2))
            initial=i;
        end
    end
end

T.current = initial; %initial
T.Pi = [1:length(Lap)]; %AP

%Labels
% for k=1:N
%     Rhold=[];
%     for j=1:length(AP)
%         %check if the rectangle is within the area where ap holds
%         if (AP(1,1,j)<=R(1,1,k))&&(AP(1,2,j)<=R(1,2,k))&&(AP(2,1,j)>=R(2,1,k))&&(AP(2,2,j)>=R(2,2,k))
%             Rhold=[Rhold j]; %if so, add the index to Rhold
%         end
%     end
%     T.simple_label{k}=Rhold;
%     T.L(k)=sum(2.^Rhold);
% end
T.simple_label=cell(N,1);
for i=1:length(Lap)
    for n=1:N
        if any(ismember(Lap{i},n))
            T.simple_label{n}=[T.simple_label{n} i];
        end
    end
end

for n=1:N
    if isempty(T.simple_label{n})
       T.L(n)=1; 
    else
        T.L(n)=sum(2.^T.simple_label{n});
    end
end

%Constructing transition matrix (FT=forbidden transitions)
T.adj=sparse(N,N);
%Control matrices for all transitions
T.ux_11=sparse(N,N);
T.ux_12=sparse(N,N);
T.ux_21=sparse(N,N);
T.ux_22=sparse(N,N);
T.uk_1=sparse(N,N);
T.uk_2=sparse(N,N);

%Self transitions (staying in a place) set time of trans to rest
for i=1:N
    T.ux_11(i,i)=-A(1,1);
    T.ux_12(i,i)=-A(1,2);
    T.ux_21(i,i)=-A(2,1);
    T.ux_22(i,i)=-A(2,2);
    T.uk_1(i,i)=0;
    T.uk_2(i,i)=0;
    T.adj(i,i)=rest;
end
%Forbidden transitions
FT1=FT{1};FT2=FT{2};

%For each rectangle compute u and time for all transitions which are not
%forbidden
for i=1:N
    facet1=[R(1,1,i) R(1,2,i) R(2,2,i); R(2,1,i) R(1,2,i) R(2,2,i)];%facets in direction x1 and -x1
    facet2=[R(1,2,i) R(1,1,i) R(2,1,i); R(2,2,i) R(1,1,i) R(2,1,i)];%facets in direction x2 and -x2
    %for each facet in x1
    for j=1:2
        forbidden=0;
        for k=1:size(FT1,1)
            if (facet1(j,1)==FT1(k,1)) &&(facet1(j,2)>=FT1(k,2)) && (facet1(j,3)<=FT1(k,3))%if the facet is forbidden
                forbidden=1;%if the facet is part of a forbidden edge
            end
        end
        if forbidden~=1%the facet is allowed
            %determine direction
            if j==1
                d=-1;
            else %j=2
                d=1;
            end
            [u_tranx, u_trank]=Transition_control( A,B,U,R(:,:,i),d,opt_c,eps ,lin_ass,u_joint);
            %set index
            q1=i;
            if d==1
                q2=i+N/N1;
            elseif d==-1 && i>N/N1 %second statement exist to ensure to matlab that the code is runnable, it will always hold if d=-1
                q2=i-N/N1;
            else 
                q2=i+N/N1;
            end
            %set Tmax and u
            T.adj(q1,q2)=Time_demand( u_trank, u_tranx, A, R(:,:,i), d,lin_ass);
            T.ux_11(q1,q2)=u_tranx(1,1);
            T.ux_12(q1,q2)=u_tranx(1,2);
            T.ux_21(q1,q2)=u_tranx(2,1);
            T.ux_22(q1,q2)=u_tranx(2,2);
            T.uk_1(q1,q2)=u_trank(1);
            T.uk_2(q1,q2)=u_trank(2);
        end
    end
    %for each facet in direction x2
    for j=1:2
        forbidden=0;
        for k=1:size(FT2,1)
            if (facet2(j,1)==FT2(k,1)) &&(facet2(j,2)>=FT2(k,2)) && (facet2(j,3)<=FT2(k,3))
                forbidden=1; %if the facet is part of a forbidden edge
            end
        end
        if forbidden~=1
            %determine dircetion
            if j==1
                d=-2;
            else %j=2
                d=2;
            end
            [u_tranx, u_trank]=Transition_control( A,B,U,R(:,:,i),d ,opt_c,eps,lin_ass,u_joint);
            %Set index
            q1=i;
            if d==2
                q2=i+1;
            elseif d==-2 && i>1
                q2=i-1;
            else 
                q2=i+1;
            end
            %set T and u
            T.adj(q1,q2)=Time_demand( u_trank, u_tranx, A, R(:,:,i), d,lin_ass);
            T.ux_11(q1,q2)=u_tranx(1,1);
            T.ux_12(q1,q2)=u_tranx(1,2);
            T.ux_21(q1,q2)=u_tranx(2,1);
            T.ux_22(q1,q2)=u_tranx(2,2);
            T.uk_1(q1,q2)=u_trank(1);
            T.uk_2(q1,q2)=u_trank(2);
        end
    end
end
