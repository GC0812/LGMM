function [ real_points ] = verifystructure( linktable1,loop_points,path_points )

points=[loop_points path_points];
points=points';
n=1;
for i=1:numel(points)
    row(n)=find(linktable1(1,:)==points(i));
    n=n+1;
end
temp(:,row) = linktable1(:,row);
for z=1:numel(points)
    [x,y]=find(temp==points(z));
    for a=1:numel(x)
        temp(x(a),y(a))=1;
    end
end
points=[];
d=1;
for b=1:size(temp,2)
    c = find(temp(:,b)==1);
    if(numel(c)>=3)
        points(d)=linktable1(1,b);
        d=d+1;
    end
    
end
if(numel(loop_points)==numel(points))
    if(isempty(path_points))
        real_points=points;
    else
        real_points = intersect(points,path_points);
    end
else
    real_points=[];
end


