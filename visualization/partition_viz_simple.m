function [ ] = partition_viz_simple( T, env,initial,tit)
%Plots rectangles R (R is a multi-dimensional matrix R(:,:,j), where each j
%represents a rectangle. Each rectangle is defined by the first and last
%corner.
if nargin==2
    tit='Workspace'; initial=0;
elseif nargin == 3
    tit='Workspace';
end

%1 or 2 agents allowed
if size(T,2)==2
    T2=T{2}; env2=env{2}; T1=T{1}; env1=env{1}; agents=2;
else
    T1=T{1}; env1=env{1};T2=T{1}; env2=env{1}; agents=1;
end

R2=T2.R; FT2=env2.FT; Lap2=env2.Lap; AP_label2=env2.AP_label; init2=T2.current;
colorL2=env2.color;
R=T1.R; FT=env1.FT; Lap=env1.Lap; AP_label=env1.AP_label; init=T1.current;
colorL=env1.color;
%agent=subplot(a,b,c);
title([tit]);
hold on
if ~isempty(init)
    f=10;
else
    f=1;
end
f=1;
txt=[1:length(R)];
%plot rectangles with numbering
for i=1:length(R)
    Rhold=[];
    for j=1:length(Lap)
        %check if ap holds in the rectangle
        if any(i==Lap{j})
            Rhold=[Rhold j]; %if so, add the index to Rhold
        end
    end
    Rhold2=[];
    for j=1:length(Lap2)
        %check if ap holds in the rectangle
        if any(i==Lap2{j})
            Rhold2=[Rhold2 j]; %if so, add the index to Rhold
        end
    end
    if ~isempty(Rhold)
        colortext=colorL{Rhold};
    elseif agents==2 && ~isempty(Rhold2)
        colortext=colorL2{Rhold2};
    else
        colortext='w';
    end
    rectangle('Position',f*[R(1,1,i) R(1,2,i) (R(2,1,i)-R(1,1,i)) (R(2,2,i)-R(1,2,i))],'LineStyle',':', 'FaceColor', colortext);
    hold on
    
%     xc=f*[R(1,1,i) R(1,1,i) R(2,1,i) R(2,1,i)];
%     yc=f*[R(1,2,i) R(2,2,i) R(2,2,i) R(1,2,i)];
%     patch(xc,yc,colortext);
    
    txt_ap='';
    for j=Rhold
        txt_ap=[txt_ap ' ' AP_label{j}];
    end
    for j=Rhold2
        if AP_label2{j}~=AP_label{j}
            txt_ap=[txt_ap ' ' AP_label2{j}];
        end
    end
    if isempty(Rhold) && isempty(Rhold2)
        txt_ap='0';
    end
    
    message=sprintf('%d [%s]' ,txt(i), txt_ap);
    text(f*(R(1,1,i)),f*(R(2,2,i)+R(1,2,i))/2, message);
    
    hold on
    if initial==1
        for ini=[init init2]
            if i==ini
                pos=f*[(R(1,1,i)+R(2,1,i))/2 (R(1,2,i)+R(2,2,i))/2 (R(2,1,i)-R(1,1,i))/4 (R(2,2,i)-R(1,2,i))/4];
                rectangle('Position',pos,'Curvature',[1 1], 'FaceColor', [0.7 0.7 0.7]);%0.5843    0.8157    0.9882
                ind=find([init init2]==ini);
                text(pos(1)+pos(3)/2, pos(2)+pos(4)/2,num2str(ind));
            end
        end
    end
end

for j=1:size(FT{1}(:,1),1) %for each row
    plot(f*[FT{1}(j,1) FT{1}(j,1)], f*[FT{1}(j,2) FT{1}(j,3)],'r','LineWidth',2);
end

for j=1:size(FT{2}(:,1),1) %for each row
    plot(f*[FT{2}(j,2) FT{2}(j,3)],f*[FT{2}(j,1) FT{2}(j,1)],'r','LineWidth',2);
end

end

