function [loop_points] = find_loop(loop_points, linktable1,net,net_num,end_points,path_struct)

m=3;
for t=1:2
    link_points=linktable1(:,linktable1(1,:)==loop_points(t));
    path_points=intersect(link_points,net(net_num).edge,'legacy');
    if(isempty(path_points))
        return
    end    
    if(numel(path_points)~=1)
        real_points = verifystructure( linktable1,loop_points,path_points );
        if(numel(real_points(real_points~=link_points(1,1)))~=1)  %%%这个地方多斟酌一下，缺乏思考
            return 
        else
            loop_points(m)=real_points(real_points~=link_points(1,1));
        end    
    else
        loop_points(m)=path_points;
    end
    m=m+1;
end 
if(loop_points(3)==loop_points(4)) %往上回两步，若由同一个点往下分的，则能组成环
    loop_points=unique([loop_points path_struct end_points],'legacy');
else
    loop_points=loop_points(3:4);
end

