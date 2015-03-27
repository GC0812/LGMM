function points = points_transform(node, dim, startorder)

%函数由序号得到对应的坐标

if (nargin == 2)
   startorder = 1; 
end

M = dim(1);

seeds=node;
if (startorder ~=1)
    seeds(2:end) = circshift(seeds(2:end), [startorder-1, 0]);
end

posi = mod(seeds, M); %seeds的行号和列号
posi(posi==0)= M; 
posj = 1 + (seeds-posi)/M;
points = [posj, posi]; 