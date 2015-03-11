function [ptbest, anglemat] = points_select(bw, pt, R)

% This function selects the optimal bifurcation points in the binary image
% R: the raius of search window for each candidates
% Numangle: the number of local point-branch angle within the region
% 1: terminal, 2: branch, 3: bifurcation 

seeds = pt;
npix = numel(seeds); %有三个连通的点的像素个体的个数

ptbest =[];
anglemat=[];
for k =1:npix
    anglevec = point_anglevec(bw, seeds(k), R); 
    if (numel(findangle(anglevec))== 3||numel(findangle(anglevec))==4) %若区域边界有三个角度，则认为是ptbest
        ptbest=[ptbest; seeds(k)];
        anglemat=[findangle(anglevec)/360];
    end
end