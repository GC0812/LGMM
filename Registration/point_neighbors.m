function [node] = point_neighbors(bw, pt, R, seed, NeighborNum, labelmap)

% This function search the linked neighbor of the seed
% Node structure: seed, neighbor numbers, neigh1, link1,neigh2,...

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
    flag=0;
    for i=1:Len
        idx = neighidx(i);
        if (idx>0) && (idx<imdim) && (bw(idx)==1)
            bw(idx) = 0;
            if find(idx==pt)~=0
                count = count + 1;
                link(count)=idx;
                if flag~=0 
                stackmap(end-flag+1:end)=0; %确保当找到一个分叉点后停止寻找，该分叉点周围的点被排除
                end
                
                if (count>= NeighborNum) 
                    break; 
                end
                labelmap(labelmap==labelmap(idx))= 0;%分叉点的8邻域值都变为0
                neighidx1 = idx+ Neighbor; 
                tempidx=intersect(stackmap,neighidx1); %去除分叉点周围8个像素中在stackmap中的点
                if ~isempty(tempidx)
                    for k=1:numel(tempidx)
                    stackmap(stackmap==tempidx(k))=0;
                    end
                end     
                for j=1:numel(neighidx1)
                    idx1= neighidx1(j);
                    if (idx1>0) && (idx1<imdim)
                        bw(idx1) = 0;
                    end
                end
                break;
            else
                sptail = sptail + 1;
                stackmap(sptail)= idx;
                flag=flag+1;
            end
        end
    end
    sphead = sphead + 1;
end

node=[seed, count, link];
