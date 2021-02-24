function [ nb] = neighboors( envAut,T2,pi )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
nb=[];
if pi+1<=envAut.N
    nb=[nb pi+1];
end
if pi-1>=1 
    nb=[nb pi-1];
end
if  pi+envAut.N/T2.N1<=envAut.N 
    nb=[nb  pi+envAut.N/T2.N1];
end
if  pi-envAut.N/T2.N1>=1 
    nb=[nb  pi-envAut.N/T2.N1];
end

end

