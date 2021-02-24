%product.m
% Original code: A. Nikou,
%Changes made by S. Andersson 22/3-16, to add clock-constraints
function P = product(T,A,npools)
%Creates a product of a deterministic weighted transition system T and a Timed Buchi automaton A
P.S=[T.current A.current];
Q=A.Q; S=T.S; Lab=T.simple_label; dom=A.dom;
% for q=Q
%     good=dom{1,q}; bad=dom{2,q};
%     for s=S
%         goodin=true;
%         for i=good
%             if not(any(i==Lab{s}))
%                 goodin=false;
%                 break;
%             end
%         end
%         badin=false;
%         for i=bad
%             if any(i==Lab{s})
%                 badin=true;
%                 break;
%             end
%         end
%         if goodin==true && badin==false
%             if not(q==A.current && s==T.current)
%                 P.S=[P.S; s q];
%             end
%         end
%     end
% end
P.S=cartesian_product(S,Q);

st_no=size(P.S,1); %number of states
P.Q = [1:st_no]; %numbering the states
P.C=A.C; %clocks
P.Pi=T.Pi;

for k=1:st_no
    P.simple_label{k}=T.simple_label{P.S(k,1)};
    P.clockset(k,:)=A.clockset(P.S(k,2),:); %clock activation setting
    P.clockoff(k,:)=A.clockoff(P.S(k,2),:); %clock inactivation setting
    for c=1:length(P.C)
        for j=1:st_no
            P.clockreset{c}(k,j)=A.clockreset{c}(P.S(k,2),P.S(j,2)); %clock reseting setting
        end
    end
end
P.clockvalue=A.clockvalue; %clock values

%current state
P.current = 1;
%final states
P.F = find(ismember(P.S(:,2)', A.F)); 

% hybrid distance settings
P.ddc=zeros(1,st_no);
P.ddd=zeros(1,st_no);
for i=1:st_no
    P.ddc(i)=A.ddc(P.S(i,2));
    P.ddd(i)=A.ddd(P.S(i,2));
end

%Transitions 
P.adj{1}=sparse(st_no,st_no);
for i=1:length(A.C)
    P.adj{i+1}=sparse(st_no,st_no);
end

%Labelling
P.L(1,:)=T.L; %Original labelling
for j=1:length(A.C) %Clock-constraint exceeded labelling
    P.L(j+1,:)=T.L+2^(length(T.Pi)+j);
end
L=P.L;
%S=P.S;

fprintf('Everything but transitions have been determined.\n');
%more effective run
%parpool( 'local', npools);
%For each state find all outgoing transitions
for j=1:length(A.C)+1
    for i=1:st_no 
        succ_T = find(T.adj(P.S(i,1),:)); %successors in T
        act_A = find(~cellfun('isempty',A.trans(P.S(i,2),:))); %actions enabled in A 
        for state_T = 1:length(succ_T) %for each succ in T
            for act=1:length(act_A) %for each enabled act
                if isequal(P.L(j,succ_T(state_T)),act_A(act)) %the labeling of succ_T complies with the action in A
                    succ_A = A.trans{P.S(i,2),act_A(act)}; %successors in A under act
                    for state_A = 1:length(succ_A) %for every succ in A given act
                        ind = (P.S(:,1)== succ_T(state_T)) & (P.S(:,2) == succ_A(state_A));  %index of state
                        adj{j}(i,ind) = T.adj(P.S(i,1),succ_T(state_T)); %set cost for transition in P equal with cost of the corresponding trasition in T
                    end
                end
            end
        end
    end
    fprintf('One trans-matrix is done!\n');
end
P.adj=adj;
delete(gcp('nocreate'));
