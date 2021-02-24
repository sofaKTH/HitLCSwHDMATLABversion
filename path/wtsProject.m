function [ path_WTS ] = wtsProject( path, P )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
path_WTS=zeros(length(path),1);
for elem=1:length(path)
    path_WTS(elem)=P.S(path(elem),1);    
end

end

