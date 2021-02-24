function [ inputX ] = humanInput2( path,it )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fprintf('\n The current plan is: ' );
for x=path
    if x==path(end)
        fprintf('%d\n',x);
    else
        fprintf('%d ->',x);
    end
end
fprintf('\n --------------------------------------\n The robot is in region %d.\n The next planned step is to go to region %d.\n', path(it),path(it+1) );
fprintf('\n Do you wish to \n');
fprintf('1) Do nothing\n 2) Apply control upwards\n 3) Apply control downwards\n 4) Apply control leftwards\n 5) Apply control rightwards\n');

prompt='Indicate your choice by number and the system will find and apply the needed controller.\n ';
inputX=input(prompt, 's');
end

