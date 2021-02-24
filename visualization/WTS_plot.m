function  WTS_plot( N,T,AP_set,AP_label,FT,init,Nx)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    identical{1}=[1];
    for z=2:N
        ident=0;
        for x=1:length(identical)
            if T{z}.R==T{x}.R
                identical{x}=[identical{x} z];
            else 
                ident=ident+1;
            end
        end
        if ident==length(identical)
            identical{length(identical)+1}=[z];
        end
    end
    if length(identical)>1
        b=2;
        a=round(N/2);
    else
        b=1;a=1;
    end
    pdx=0.9/b;pdy=0.9/a;
    p3=0.9/b-(b-1)*0.05;p4=0.9/a-(a-1)*0.07;
    for z=1:length(identical)
        current=[];
        f=1;
        if init==1
            for x=1:length(identical{z})
                current=[current T{identical{z}(x)}.current];
            end
            f=10;
            Nx=[];
        end
        agent=partition_vizz(T{identical{z}(1)}.R, FT, AP_set{z}, AP_label,a,b,z,current,identical{z},Nx);
        if length(identical)>1
            p1=0.05+(1-mod(z,a))*pdx;
            p2=0.95-round(z/b)*pdy;
            set(agent,'Position',[p1 p2 p3 p4]);
        end
    end

end

