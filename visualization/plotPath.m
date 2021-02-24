function [  ] = plotPath( X,Y,XL,YL,TIME,Tb,envb  )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
FigHandle=figure(2);
hold on
FigHandle.Position=[100, 100, 1000, 700];

T=Tb{1}; T2=Tb{2}; env=envb{1}; envAut=envb{2};

partition_viz_simple(T,env,0,2,envAut,T2,'Final trajectories');
hold on;
d=1;
px=T.R(2,1,T.S(end))+0.1;
py=T.R(2,2,T.S(end)); 
sidebar=text(px,py,'i - Time of arrival at position i');
set(sidebar,'fontsize',16);
d1=0.1; d2=0.13; ColOr={[0.9100    0.4100    0.1700],[1 0 1]};
%d1=0;
for k=[1:2]
    x=X{k}; y=Y{k}; xl=XL{k};yl=YL{k};Time=TIME{k};
    plot(x,y,xl,yl,'*','Color',ColOr{k}, 'LineWidth', 2);
    nonumber=[]; xln=[]; yln=[];
    % print('before gca');
    set(gca,'Position',[.05 .05 .45 .9]);
    % print('after gca');
    hold on;
    delta=0;
    if k==2
        delta=col*d+d;
    end

    px=T.R(2,1,T.S(end))+0.1+delta;
    py=T.R(2,2,T.S(end))-0.3; col=1;
    count=1;
    for it=0:length(xl)-1
        posx=xl(it+1); posy=yl(it+1);
        if it==0
            if k==2
                sidebar=text(px,py,'Agent 2');
                set(sidebar,'fontsize',12);
            else
                sidebar=text(px,py,'Agent 1');
                set(sidebar,'fontsize',12);
            end
            py=py-0.15;
            sidebar=text(px,py,'0  -  0');
            set(sidebar,'fontsize',11);
            py=py-0.1;
            mark=text(posx,posy, '0', 'Color',[0.2 0.2 0.2],'FontWeight','bold' );
            set(mark,'fontsize',8);
        else
            if 1%xl(it+1)~=xl(it) || yl(it+1)~=yl(it)
                %py=py-0.45-(it)*0.2;
                num=num2str(count);
                time=num2str(round(sum(Time(1:count+1)),4));
                sidebar=text(px,py,[num ' - ' time]);
                set(sidebar,'fontsize',11);
                if count<22*col+col-1
                    py=py-0.1;
                else
                    col=col+1;
                    py=py+0.1*22;
                    px=px+d;
                end
                if norm([xl(it+1) yl(it+1)]-[xl(it) yl(it)])> d1 || abs(xl(it+1)-xl(it))>d1
                    mark=text(posx,posy, num, 'Color',[0.2 0.2 0.2],'FontWeight','bold' );
                    set(mark,'fontsize',8);
%                 elseif ismember(count-1, nonumber) && count-2>0
%                      if norm([xl(it+1) yl(it+1)]-[xln(count-2) yln(count-2)])> d1 || abs(xl(it+1)-xln(count-2))>d1
%                         mark=text(posx,posy, num, 'Color',[0.2 0.2 0.2],'FontWeight','bold' );
%                         set(mark,'fontsize',8);
%                      else
%                         nonumber=[nonumber count];
                     %end
                else
                   nonumber=[nonumber count];
                end
                count=count+1;
                xln=[xln posx];yln=[yln posy];
            else
               % fprintf('x(it+1)=(%f, %f)\t x(it)=(%f, %f)\n',xl(it+1),yl(it+1),xl(it),yl(it));
            end
            
        end
    end
%     for i=nonumber
%          if i+1<=count
%             if norm([xln(i+1) yln(i+1)]-[xln(i) yln(i)])>d1 || abs(xln(i+1)-xln(i))>d1
%                 num=['-' num2str(i)];
%                 posx=xln(i-1)+d2; posy=yln(i-1);
%                 mark=text(posx,posy, num, 'Color',[0.2 0.2 0.2],'FontWeight','bold' );
%                 set(mark,'fontsize',8);
%             else
%                 fprintf('Number %s will not be printed.\n', num);
%             end
%          end
%     end
nonumber
    for i=nonumber
        if i<count-1 %count-1=end, checking if i=end
            if ~ismember(i+2,nonumber)
                if xl(i+1)==xl(i)
                    num=['-' num2str(i)];
                    posx=xln(i)+d2; posy=yln(i);
                else
                    num=num2str(i);
                    posx=xl(i+1); posy=yl(i+1);
                end
                mark=text(posx,posy, num, 'Color',[0.2 0.2 0.2],'FontWeight','bold' );
                set(mark,'fontsize',8);
            end
        else
            if xl(i+1)==xl(i)
                num=['-' num2str(i)];
                posx=xln(i)+d2; posy=yln(i);
            else
                num=num2str(i);
                posx=xl(i+1); posy=yl(i+1);
            end
            mark=text(posx,posy, num, 'Color',[0.2 0.2 0.2],'FontWeight','bold' );
            set(mark,'fontsize',8);
        end
    end
    
    hold on;
end


end

