function points = points_transform(node, dim, startorder)

% This function extract the bifurcation coordinate from the node

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