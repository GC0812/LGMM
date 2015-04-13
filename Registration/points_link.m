function [linktable] = points_link(bw, ptcore, R)

%寻找分叉点的邻域点，Node结构: 分叉点, 邻接分叉点数目, 邻接分叉点1，邻接分叉点2,...

NeighborNum = 4; 
pt = ptcore(:);
labelmap = points_show(bw, pt, R, false);

seeds = ptcore;
npix = numel(seeds);
linktable = [];

for k =1:npix
    seed = seeds(k);
    [node] = point_neighbors(bw, pt, R, seed, NeighborNum, labelmap);
    linktable = [linktable; node];
end
