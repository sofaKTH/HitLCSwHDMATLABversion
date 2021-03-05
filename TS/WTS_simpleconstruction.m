function [ WTS ] = WTS_simpleconstruction( n, a, b, Pi, Lap, up, down, left, right, init)
%WTS_SIMPLECONSTRUCTION returns a WTS constructed without dynamics.
% n=number of states, a, b= sidelength of rectangles
%Pi=atomic propositions, 
%Lap=cell for each ap containing states the are true in

WTS.S=1:n;
if mod(n,5)==0
    N1=5;
elseif mod(n,4)==0
    N1=4;
elseif mod(n,3)==0
    N1=3;
elseif mod(n,2)==0
    N1=2;
else
    N1=1;
end
WTS.N1=N1;

R=[0 0; 0 0];
x1=0; x2=0; N=1;
for j=1:n
    R(:,:,j)=[x1 x2; x1+a x2+b];
    if N==N1
        x1=0;x2=x2+b;N=1;
    else
        x1=x1+a;N=N+1;
    end
end
WTS.R=R;
WTS.Pi=Pi;
WTS.current=init;
simple_label=cell(1,n);
for i=1:n
    simple_label{i}=[];
end
for i=Pi
    for j=Lap{i}
        simple_label{j}=[simple_label{j} i];
    end
end
WTS.simple_label=simple_label;
L=zeros(1,n);
for i=1:n
    L(i)=sum(2.^simple_label{i});
end
WTS.L=L;

adj=sparse(n,n);
for i=1:n
    %right
    if mod(i,N1)~=0
        adj(i,i+1)=right;
    end
    %left
    if mod(i,N1)~=1
        adj(i,i-1)=left;
    end
    %up
    if i<=n-N1
        adj(i,i+N1)=up;
    end
    %down
    if i>N1
        adj(i,i-N1)=down;
    end
end
WTS.adj=adj;

min1=0; min2=0; max1=R(2,2,n); max2=R(2,1,n);
FT1=[min2 min1 max1; max2 min1 max1];FT2=[min1 min2 max2; max1 min2 max2];
FT{1}=FT1;FT{2}=FT2;
WTS.FT=FT;
end