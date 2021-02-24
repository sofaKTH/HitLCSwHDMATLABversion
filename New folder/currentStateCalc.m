function [ q2,err] = currentStateCalc( q1, t,P, T,x ,A)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
pi1=P.S(q1,1); loc1=P.S(q1,2);
%fprintf('previous state=%d\n', q1);
%fprintf('start loc is: %d\t', loc1);
for pi=1:length(T.S)
    xmin=T.R(1,1,pi);ymin=T.R(1,2,pi);xmax=T.R(2,1,pi);ymax=T.R(2,2,pi);
    if x(1)<=xmax && x(1)>xmin && x(2)>ymin && x(2)<=ymax
        pi2=pi;
    end
end
%fprintf('x is: (%f, %f)\t current WTS state: %d\t',x(1), x(2), pi2);
ap=T.L(pi2);loc2=zeros(1, size(A.trans,3));
%fprintf('act/label is: %d\n', ap);
for i=1:size(A.trans,3)
    loc2(i)=A.trans(loc1,ap,i);
end
newloc=0;

for l=loc2
    if l~=0
 %       fprintf('succ locations under that act is: %d\t', l)
        if A.Ix(loc1,l)==0 && A.Ixup(loc1,l)==0
            %no clocks
            newloc=l;
        elseif A.Ix(loc1,l)==0 && t>A.Xv(A.Ixup(loc1,l))
            %t must be greater to enter
            newloc=l;
        elseif A.Ixup(loc1,l)==0 && t<=A.Xv(A.Ix(loc1,l))
            %t must be less to enter
            newloc=l;
        elseif A.Ix(loc1,l)~=0 && A.Ixup(loc1,l)~=0 && t<=A.Xv(A.Ix(loc1,l)) && t> A.Xv(A.Ixup(loc1,l))
            %both upper and lower bounded
            newloc=l;
        else
            %couldn't enter :(
  %          fprintf('t is: %f\t', t);
            if A.Ixup(loc1,l)~=0
   %             fprintf('The maxclock is: %d \t with value: %d\t', A.Ixup(loc1,l), A.Xv(A.Ixup(loc1,l)));
            end
            if A.Ix(loc1,l)~=0
    %            fprintf('The minclock is: %d\t with value: %d', A.Ix(loc1,l),A.Xv(A.Ix(loc1,l)));
            end
     %       fprintf('\n');
        end
    end
end

err=0;q2=0;
if newloc==0
    %error!
    fprintf('Something is Fd up!\n\n');
    err=1;
else
    %fprintf('winner is %d\n', newloc);
    q2=find(P.S(:,1)==pi2 & P.S(:,2)==newloc);
    %fprintf('That is:\t loc=%d\t pi=%d\t q=%d\n------------------------------\n',newloc,pi2,q2 );
end


end