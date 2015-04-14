function [node] = point_neighbors(bw, pt, seed, NeighborNum)

% 搜索分叉点的邻域，得到连接关系
% Node结构: 分叉点, 邻接分叉点数目, 邻接分叉点1，邻接分叉点2,...

[M, N]= size(bw);
imdim = M*N + 1;

Neighbor = [-M, 1, M, -1, -1-M, 1-M,  1+M, -1+M];
Len = numel(Neighbor);

k=1;
neighidx2 = seed + Neighbor; %8邻域像素
stacknodes = zeros(1,4);
for i=1:Len
    idx2 = neighidx2(i);
    if (idx2>0) && (idx2<imdim) && (bw(idx2)==1)
        stacknodes(k)= idx2;
        k=k+1;
    end
end
branchnum = k-1;%由分叉点8邻域出现像素数判断该分叉点有几个分支

% bworigin = bw;
link = zeros(1, NeighborNum);
 
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
                if flag~=0 && sphead~=1
                stackmap(end-flag+1:end)=0; %确保当找到一个分叉点后该分支停止寻找，该分叉点周围的点被排除
                end
                
                if (count>= NeighborNum) %分支数最大为4
                    break; 
                end
                neighidx1 = idx+ Neighbor; 
                tempidx=intersect(stackmap,neighidx1); %去除分叉点周围8个像素中在stackmap中的点
                if ~isempty(tempidx) && sphead~=1
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
if count<branchnum && branchnum<=4
    n=branchnum-count;
    link(end-n+1:end)=1;%分支存在，但末尾没有分叉点则赋值为1
end
node=[seed, count, link];
