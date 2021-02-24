function [ path_TA ] = taProject( path, P )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
path_TA=zeros(length(path),1);
for elem=1:length(path)
    path_TA(elem)=P.S(path(elem),2);    
end

end
