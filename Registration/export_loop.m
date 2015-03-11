function [ loop_points ] = export_loop(linktable1,end_points,net,net_num)

path_struct_num=1;
path_struct=[];


link_points=linktable1(:,linktable1(1,:)==end_points);
loop_points=intersect(link_points,net(net_num-1).edge,'legacy');%往上回一步
if(numel(loop_points)==2)
    for c=1:2
        path_struct(path_struct_num)=loop_points(c);
        path_struct_num=path_struct_num+1;
    end
    [loop_points] = find_loop(loop_points, linktable1,  net, net_num-2,end_points,path_struct );
    if(numel(loop_points)==2)
        for c=1:2
            path_struct(path_struct_num)=loop_points(c);
            path_struct_num=path_struct_num+1;
        end
        [loop_points] = find_loop(loop_points, linktable1,  net, net_num-3,end_points,path_struct );
    end
elseif(numel(loop_points)==1)
    path_struct(path_struct_num)=loop_points;
    path_struct_num=path_struct_num+1;
    link_points=linktable1(:,linktable1(1,:)==loop_points);%往上回一步
    loop_points=intersect(link_points,net(net_num-2).edge,'legacy');
    for b=1:numel(loop_points)
        path_struct(path_struct_num)=loop_points(b);
        path_struct_num=path_struct_num+1;
    end
    if(numel(loop_points)==2)
        [loop_points] = find_loop(loop_points, linktable1,  net, net_num-3,end_points,path_struct );
        if(numel(loop_points)==2)
            [loop_points] = find_loop(loop_points, linktable1,  net, net_num-4,end_points,path_struct );
        end
    end
else
    return
end



