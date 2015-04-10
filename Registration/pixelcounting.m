function [pixelnum, pixelsequence]=pixelcounting(bw,seed1,externalbifu)

%计算两点之间的距离(即像素个数)，externalbifu=0表明环上的分叉点没有外接分叉点

[M, N]= size(bw);
imdim = M*N + 1;

bw1=bw;
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

targetbifu=zeros(1,bifunum);node(bifunum).sequence=[];outerflag=0;
for m = 1:bifunum
    if outerflag==1
        break;
    end
    sphead = 1;
    sptail = 1;
    stackmap = stacknodes(m+1);
    innerflag=0;
    while (sphead <= sptail) && innerflag~=1  
        localidx = stackmap(sphead);
        neighidx = localidx + Neighbor;
        neighidx = setdiff(neighidx,stacknodes);
        for i=1:numel(neighidx)
            idx = neighidx(i);           
            if (idx>0) && (idx<imdim) && (bw(idx)==1)
                bw(idx) = 0;  
                if find(idx == setdiff(seed1,seed))~=0
                    targetbifu(m)= idx;%记录环外接或环上的分叉点，若已知有外接分叉点，则只记录外接分叉点
                    stackmap(end+1) = idx;%将分叉点也加入像素矩阵中                   
                    innerflag = 1;
                    if idx==externalbifu %如果找到外接分叉点，则不再继续寻找
                        outerflag=1; 
                    end
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
if isequal(externalbifu,[1 1])
    nn=find(targetbifu==0);%若无外接分叉点，则选择没有求得分叉点的路径
    if numel(nn)~=2
        return;
    end
    pixelsequence=[];
    for i=1:numel(nn)
        pixelnum(i) = numel(node(nn(i)).sequence)+1;%加上最初的分叉点
        pixelsequence=[pixelsequence seed node(nn(i)).sequence];
    end
else
    nn=zeros(1,numel(externalbifu));
    for i=1:numel(externalbifu)
        if externalbifu(i)~=0 && externalbifu(i)~=1          
            nn(i) = find(targetbifu==externalbifu(i));%确定哪一部分才是要找的外接血管
            if isempty(nn(i))
                return;
            end
        else
            nn(i)= find(targetbifu==0); %若无外接分叉点，则选择没有求得分叉点的路径
        end
    end   
    pixelsequence=[];
    for i=1:numel(nn)
        pixelnum(i) = numel(node(nn(i)).sequence)+1;%加上最初的分叉点
        pixelsequence=[pixelsequence seed node(nn(i)).sequence];
    end   
end