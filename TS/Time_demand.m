function [ Tmax] = Time_demand( u_trank, u_tranx, A, R, d,lin_ass )
%Takes info of the evolution of the system and direction of goal facet.
%Returns the maximal time needed to make the transition
if d==1
    if lin_ass==1%if assumption for simple time calc have been made
        a=A(1,1)+u_tranx(1,1);
        C=u_trank(1);
        %C=@(x) u_trank(1)+(u_tranx(1,2)+A(1,2))*x;
        sf=a*R(2,1)+C;
        sfopp=a*R(1,1)+C;
        Tmax=log(sf/sfopp)/a;
    else %Belta
        ff=@(x) (A(1,1)+u_tranx(1,1))*R(2,1)+(A(1,2)+u_tranx(1,2))*x+u_trank(1);
        sf=min(ff(R(1,2)),ff(R(2,2)));
        ffopp=@(x) (A(1,1)+u_tranx(1,1))*R(1,1)+(A(1,2)+u_tranx(1,2))*x+u_trank(1);
        sfopp=min(ffopp(R(1,2)),ffopp(R(2,2)));
        Tmax=log(sf/sfopp)*(R(2,1)-R(1,1))/(sf-sfopp);
    end
elseif d==-1
    if lin_ass==1 %if assumption for simple time calc have been made
        a=A(1,1)+u_tranx(1,1);
        C=u_trank(1);
        sf=a*R(1,1)+C;
        sfopp=a'*R(2,1)+C;
        Tmax=log(sf/sfopp)/a;
    else %Belta
        ffopp=@(x) -((A(1,1)+u_tranx(1,1))*R(2,1)+(A(1,2)+u_tranx(1,2))*x+u_trank(1));
        sfopp=min(ffopp(R(1,2)),ffopp(R(2,2)));
        ff=@(x) -((A(1,1)+u_tranx(1,1))*R(1,1)+(A(1,2)+u_tranx(1,2))*x+u_trank(1));
        sf=min(ff(R(1,2)),ff(R(2,2)));
        Tmax=log(sf/sfopp)*(R(2,1)-R(1,1))/(sf-sfopp);
    end
elseif d==2
    if lin_ass==1%if assumption for simple time calc have been made
         a=A(2,2)+u_tranx(2,2);
         C=u_trank(2);
         sf=a*R(2,2)+C;
         sfopp=a*R(1,2)+C;
         Tmax=log(sf/sfopp)/a;
    else %Belta
        ff=@(x) (A(2,1)+u_tranx(2,1))*x+(A(2,2)+u_tranx(2,2))*R(2,2)+u_trank(2);
        sf=min(ff(R(1,1)),ff(R(2,1)));
        ffopp=@(x) (A(2,1)+u_tranx(2,1))*x+(A(2,2)+u_tranx(2,2))*R(1,2)+u_trank(2);
        sfopp=min(ffopp(R(1,1)),ffopp(R(2,1)));
        Tmax=log(sf/sfopp)*(R(2,2)-R(1,2))/(sf-sfopp);
    end
elseif d==-2
    if lin_ass==1%if assumption for simple time calc have been made
         a=A(2,2)+u_tranx(2,2);
         C=u_trank(2);
         sf=a*R(1,2)+C;
         sfopp=a*R(2,2)+C;
         Tmax=log(sf/sfopp)/a;
    else %Belta
        ffopp=@(x) -((A(2,1)+u_tranx(2,1))*x+(A(2,2)+u_tranx(2,2))*R(2,2)+u_trank(2));
        sfopp=min(ffopp(R(1,1)),ffopp(R(2,1)));
        ff=@(x) -((A(2,1)+u_tranx(2,1))*x+(A(2,2)+u_tranx(2,2))*R(1,2)+u_trank(2));
        sf=min(ff(R(1,1)),ff(R(2,1)));
        Tmax=log(sf/sfopp)*(R(2,2)-R(1,2))/(sf-sfopp);
    end
end
end

