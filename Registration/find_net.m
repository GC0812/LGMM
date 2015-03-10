function [ net_points] = find_net( linktable,linktable1,row_array )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

loop_points = find_position(linktable,row_array);
linktable_points=linktable1(1,loop_points);  
first=find(linktable_points==row_array(1));
if(first~=1)
    temp=loop_points(1);
    loop_points(1)=loop_points(first);
    loop_points(first)=temp;
end    
net_points=find_path(linktable,loop_points);
net_points=net_points(2:numel(net_points));

