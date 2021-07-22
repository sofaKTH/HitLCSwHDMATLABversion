function [dpath] = denseWTSProject(path, sWTS, dWTS)
%Projects a sparse path onto the dense WTS resulting in a dense path

dpath=[];
for is=1:length(path)-1
    ss1=path(is);ss2=path(is+1);
    dp=sWTS.traj{ss1,ss2};
    if ~isempty(dp) %notself trabns
        dpath=[dpath dp(1:end-1)];
    elseif is==1
        dpath=dWTS.current;
    else
        dpath=[dpath sWTS.traj{path(is-1),path(is)}(end)];
    end

end
dpath=[dpath dp(end)];
end