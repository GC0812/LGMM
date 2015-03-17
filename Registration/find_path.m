function [path] = find_path(linktable,loop_points)

path_num=1;
for j=1:numel(loop_points)
    if(~isempty(find(linktable(:,loop_points(1))==linktable(1,loop_points(j)), 1))) %看找到的数是否与第一个数相连，相连则作为路径，存放在path中
        if(~isempty(find(linktable(:,loop_points(j))==linktable(1,loop_points(1)), 1)))
            path(path_num) = linktable(1,loop_points(j)); 
            path_num=path_num+1;
        end
    end
end


