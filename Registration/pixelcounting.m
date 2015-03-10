function [pixelnum, sequence, sidelength]=pixelcounting(bw,seed1,externalbifu)

%计算从环上某一个分叉点到环外的血管的分叉点距离

%NeighborNum = 4; 
[M, N]= size(bw);
imdim = M*N + 1;

bw1=bw;seed=seed1(1);
Neighbor = [-M, 1, M, -1, -1-M, 1-M,  1+M, -1+M];
Len = numel(Neighbor);
bw(seed) = 0; 
k=1;order=0;

neighidx2 = seed + Neighbor; 
stacknodes=zeros(1,5);stacknodes(1)=seed;%先算出从环上的分叉点得到的与几个方向交叉的三个或四个点，stacknodesde的第一个点是环上的分叉点
for i=1:Len
    idx2 = neighidx2(i);
    if (idx2>0) && (idx2<imdim) && (bw(idx2)==1) 
            k = k + 1;
            stacknodes(k)= idx2;
    end
end
bifunum=numel(stacknodes)-1;

for m=1:bifunum
    sphead = 1;
    sptail = 1;
    stackmap=stacknodes(m+1);
    flag=0;
    while (sphead <= sptail) && flag~=1
        localidx = stackmap(sphead);
        neighidx = localidx + Neighbor;
        neighidx=setdiff(neighidx,stacknodes);
        for i=1:numel(neighidx)
            idx = neighidx(i);
            if (idx>0) && (idx<imdim) && (bw(idx)==1)
                bw(idx) = 0;              
                if find(idx==setdiff(seed1,seed))~=0
                    order(m)=idx;%记录下这几个分叉点
                    stackmap(end+1)=idx;
                    flag=1;
                    break;
                else
                    sptail = sptail + 1;
                    stackmap(sptail)= idx;
                end
            end
        end
        sphead = sphead + 1;
    end
    node(m).sequence=stackmap;
end
pixelnum=NaN;sequence=NaN;sidelength=NaN;

if externalbifu~=0
    nn=find(order==externalbifu);%确定哪一部分才是要找的外接血管
    if isempty(nn)
        return
    else
    pixelnum=numel(node(nn).sequence)+1;%加上最初的分叉点
    end
else
    num=1:1:numel(find(seed1~=0));
    nn=setdiff(num,find(order~=0));
    pixelnum=numel(node(nn(1)).sequence)+1;
end
sequence=node(nn(1)).sequence;
mm=setdiff(find(order~=0),nn);

if ~isempty(mm)
sidelength=numel(node(mm(1)).sequence)+2;
else sidelength=NaN;
end


