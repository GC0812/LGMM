function [linktable] = points_link(bw, ptcore, R)

% This function links the current point and its neighbour points
% The structure of node: current point, number of neighbors, neighbor 1,
% linkpoint, neighbour 2, linkpoint,...

% if (nargin == 3)
%    NeighborNum = 4; 
% end

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
