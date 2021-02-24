function [agent ] = partition_vizz(R,FT,AP, AP_label,a,b,c,init, agents,x)
%Plots rectangles R (R is a multi-dimensional matrix R(:,:,j), where each j
%represents a rectangle. Each rectangle is defined by the first and last
%corner.
agent=subplot(a,b,c);

if ~isempty(init)
    f=10;
    title(['Agent/s ' int2str(agents)]);
else
    f=1;
    title(['Agent ' int2str(x)]);
end
hold on
txt=[1:length(R)];
%plot rectangles with numbering
for i=1:length(R)
    rectangle('Position',f*[R(1,1,i) R(1,2,i) (R(2,1,i)-R(1,1,i)) (R(2,2,i)-R(1,2,i))],'LineStyle',':');
    hold on
    Rhold=[];
    for j=1:length(AP)
        %check if the rectangle is within the area where ap holds
        if (AP(1,1,j)<=R(1,1,i))&&(AP(1,2,j)<=R(1,2,i))&&(AP(2,1,j)>=R(2,1,i))&&(AP(2,2,j)>=R(2,2,i))
            Rhold=[Rhold j]; %if so, add the index to Rhold
        end
    end
    txt_ap='';
    for j=Rhold
        txt_ap=[txt_ap ' ' AP_label{j}];
    end
    message=sprintf('State: %d \n AP: %s' ,txt(i), txt_ap);
    text(f*(R(1,1,i)),f*(R(2,2,i)+R(1,2,i))/2, message);
    hold on
    for ini=init
        if i==ini
            pos=f*[(R(1,1,i)+R(2,1,i))/2 (R(1,2,i)+R(2,2,i))/2 (R(2,1,i)-R(1,1,i))/2 (R(2,2,i)-R(1,2,i))/2];
            rectangle('Position',pos,'Curvature',[1 1]);
            ind=find(init==ini);
            text(pos(1)+pos(3)/2, pos(2)+pos(4)/2,num2str(agents(ind)));
        end
    end
end

for j=1:size(FT{1}(:,1),1) %for each row
    plot(f*[FT{1}(j,1) FT{1}(j,1)],f*[FT{1}(j,2) FT{1}(j,3)],'r','LineWidth',2);
end

for j=1:size(FT{2}(:,1),1) %for each row
    plot(f*[FT{2}(j,2) FT{2}(j,3)],f*[FT{2}(j,1) FT{2}(j,1)],'r','LineWidth',2);
end

end

