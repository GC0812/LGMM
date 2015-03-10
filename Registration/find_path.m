function [path] = find_path(linktable,loop_points)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
path_num=1;
for j=1:numel(loop_points)
        if(~isempty(find(linktable(:,loop_points(1))==linktable(1,loop_points(j))))) %看找到的数是否与第一个数相连，相连则作为路径，存放在path中
            if(~isempty(find(linktable(:,loop_points(j))==linktable(1,loop_points(1)))))
                path(path_num) = linktable(1,loop_points(j)); %有可能只找到3个以下的path吗？怎么确保path的第一个数是第一行的第一个数？
                path_num=path_num+1;
            end    
        end   
end


