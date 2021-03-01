function [ k ] = rhofunc(dt,ds,eps )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%fprintf('dt is: %f\t ds is: %f\t eps is: %f\n',dt,ds,eps);
if dt-ds>0
    tail=exp(-1/(dt-ds));
    fprintf('tail is nonzero: %f\t',tail);
else
    tail=0;
    fprintf('tail is zero\t');
end

if eps+ds-dt>0
    floor=exp(-1/(eps-dt+ds));
    fprintf('floor is nonzero: %f\t',floor);
else
    fprintf('floor is zero\t');
    floor=0;
end
k=tail/(tail+floor);
fprintf('k is %f\t',k);
%fprintf('floor is: %f\t tail is: %f\t K is then: %f\n', tail,floor,k);
end

