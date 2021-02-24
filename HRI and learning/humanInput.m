function [ inputX ] = humanInput( choice )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
fprintf('\n The current plan is: ' );
for x=choice.path
    if x==choice.path(end)
        fprintf('%d\n',x);
    else
        fprintf('%d ->',x);
    end
end
fprintf('\n --------------------------------------\n The robot is in region %d.\n The next planned step is to go to region %d.\n', choice.q1,choice.q2 );
fprintf('\n Do you wish to \n');
for opt=1:length(choice.uL)
    str=choice.uL{opt};
   if ~strcmp(str, 'follow')
       str=['go ', str];
   end
   str1='';
   if opt>1
       str1='or ';
   end
   fprintf(' %s %d) %s\n ',str1 ,opt, str);
end
prompt='Indicate your choice and the system will find and apply the needed controller.\n ';
inputX=input(prompt, 's');
end

