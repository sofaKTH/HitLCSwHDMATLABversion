function  WTS_plot_single( T,AP,AP_label,FT,init,Nx)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
 
    b=1; a=1;
    pdx=0.9/b;pdy=0.9/a;
    p3=0.9/b-(b-1)*0.05;p4=0.9/a-(a-1)*0.07;
    current=[];
    f=1;
    if init==1
        current=[current T.current];
        f=10;
        Nx=[];
    end
    agent=partition_vizz(T.R, FT, AP, AP_label,a,b,1,current,1,Nx);
end

