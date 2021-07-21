function [] = visWTScombo(dWTS, sWTS, cm)
%visualize WTSs, color is a color-mapping connecting labels with colors
figure;

%sparse part
for ss=sWTS.S
    L=sWTS.L(ss);
    col=cm.color{cm.colormap(L)};
    dS=sWTS.map{ss};
    for ds=dS
        R=dWTS.R(:,:,ds);
        x=[R(1,1), R(1,1), R(2,1), R(2,1)];
        y=[R(1,2), R(2,2), R(2,2), R(1,2)];
        fill(x,y,col,'LineStyle','none');
        hold on;
    end
    cx=(R(1,2)+R(1,1))/2; cy=(R(2,2)+R(2,1))/4;
    txt=['s_s=' num2str(ss)];
    t=text(cx,cy,txt);
    t.FontSize=12;
    hold on;
    if ~isempty(dWTS.simple_label{ds})
        txt2=' L=';
        for l=dWTS.simple_label{ds}
            txt2=[txt2 num2str(l) ', '];
        end
    else 
        txt2='L=0';
    end
    t2=text(cx, cy-(R(2,2)+R(2,1))/8, txt2);
    t2.FontSize=11;
    hold on;
end
%dense WTS part
for ds=dWTS.S
    R=dWTS.R(:,:,ds);
    x=[R(1,1), R(1,1), R(2,1), R(2,1), R(1,1)];
    y=[R(1,2), R(2,2), R(2,2), R(1,2), R(1,2)];
    plot(x,y,':k');
    hold on
    cx=(R(1,2)+R(1,1))/2; cy=(R(2,2)+R(2,1))/2;
    txt=['s_d=' num2str(ds)];
    t=text(cx,cy,txt);
    t.FontSize=8;
end



end

