function [pixelnum, pixelsequence]=pixelcounting(bw,seed1,externalbifu)

%计算两点之间的距离(即像素个数)，externalbifu=0表明环上的分叉点没有外接分叉点

[M, N]= size(bw);
imdim = M*N + 1;

seed=seed1(1);
Neighbor = [-M, 1, M, -1, -1-M, 1-M,  1+M, -1+M];
Len = numel(Neighbor);
bw(seed) = 0; 

k = 1;
neighidx2 = seed + Neighbor; %8邻域像素
stacknodes = zeros(1,5);stacknodes(1) = seed;
%先得出环上分叉点的8邻域内像素值为1的点，
%（代表不同搜索路径上的起始点），stacknodes的第一个点是环上的分叉点
for i=1:Len
    idx2 = neighidx2(i);
    if (idx2>0) && (idx2<imdim) && (bw(idx2)==1)
        k = k + 1;
        stacknodes(k)= idx2;
    end
end
bifunum = numel(setdiff(stacknodes,0))-1;

targetbifu=zeros(1,bifunum);
for m = 1:bifunum
    sphead = 1;
    sptail = 1;
    stackmap = stacknodes(m+1);
    flag=0;n=1;dist=0;
    while (sphead <= sptail) && flag~=1
        localidx = stackmap(sphead);
        if externalbifu~=0
            localxy=points_transform(localidx',[M, N]);%求取localidx的坐标
            dist(n)=(externalcoord(1)-localxy(1))^2+(externalcoord(2)-localxy(2))^2;%计算搜索的路径中的点与要找的点的距离
            n=n+1;
            if sphead~=1 && dist(end)>dist(end-1) && dist(end)>dist(1)%若两者距离变大，则说明该逐渐路径远离目标点，则放弃此路径
                break;
            end
        end
        neighidx = localidx + Neighbor;
        neighidx = setdiff(neighidx,stacknodes);
        for i=1:numel(neighidx)
            idx = neighidx(i);           
            if (idx>0) && (idx<imdim) && (bw(idx)==1)
                bw(idx) = 0;  
                if find(idx == setdiff(seed1,seed))~=0
                    targetbifu(m)= idx;%记录环外接或环上的分叉点，若已知有外接分叉点，则只记录外接分叉点
                    stackmap(end+1) = idx;%将分叉点也加入像素矩阵中
                    flag = 1;
                    break;
                else
                    sptail = sptail + 1;
                    stackmap(sptail) = idx;
                end
            end
        end
        sphead = sphead + 1;
    end
   node(m).sequence=stackmap;
end
pixelnum=NaN;pixelsequence=NaN;

if externalbifu~=0
    nn = find(targetbifu==externalbifu);%确定哪一部分才是要找的外接血管
    if isempty(nn)
        return
    else
    pixelnum = numel(node(nn).sequence)+1;%加上最初的分叉点
    pixelsequence = [seed node(nn).sequence];%若已知外接分叉点，则应只有一条路径保留
    end
else
    nn= find(targetbifu==0); %若无外接分叉点，则选择没有求得分叉点的路径
    pixelnum = numel(node(nn).sequence)+1;
    pixelsequence = [seed node(nn).sequence];
end



