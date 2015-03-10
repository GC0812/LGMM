function [node] = point_neighbors(bw, pt, R, seed, NeighborNum, labelmap)

% This function search the linked neighbor of the seed
% Node structure: seed, neighbor numbers, neigh1, link1,neigh2,...
% Featurevec structure: length1, angs1(1:4), length2,..

if (nargin == 5)
    labelmap = points_show(bw, pt, R, false);
end

[M, N]= size(bw);
imdim = M*N + 1;

Neighbor = [-M, 1, M, -1, -1-M, 1-M,  1+M, -1+M];
Len = numel(Neighbor);

% bworigin = bw;
link = zeros(1, NeighborNum); % neighbor and its link point


% assign seed and its border as 0
labelmap(labelmap==labelmap(seed))= 0; %把labelmap的seed中心位置及周围24个值变为0
bw(seed) = 0; 
stackmap = seed;
sphead = 1;
sptail = 1;
count = 0;
while (sphead <= sptail) && (count< NeighborNum)
    localidx = stackmap(sphead);
    neighidx = localidx + Neighbor; %localidx周围的8个数
    for i=1:Len
        idx = neighidx(i);
        if (idx>0) && (idx<imdim) && (bw(idx)==1)
            bw(idx) = 0;
            if find(idx==pt)~=0
                count = count + 1;
                link(count)=idx;
                
                if (count>= NeighborNum) 
                    break; 
                end
                labelmap(labelmap==labelmap(idx))= 0;%分叉点的8邻域值都变为0
                neighidx1 = idx+ Neighbor;
                for j=1:numel(neighidx1)
                    idx1= neighidx1(j);
                    if (idx1>0) && (idx1<imdim)
                        bw(idx1) = 0;
                    end
                end
            else
                sptail = sptail + 1;
                stackmap(sptail)= idx;
            end
        end
    end
    sphead = sphead + 1;
end

node=[seed, count, link];
