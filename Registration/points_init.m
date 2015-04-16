function [ptbifu] = points_init(bw)

%求取图像的分叉点

[M, N]= size(bw);
imdim = M*N + 1;

Neighbor = [-M, 1, M, -1, -1-M, 1-M,  1+M, -1+M];
Len = numel(Neighbor);

seeds = find(bw == 1);
npix = numel(seeds);
countmap = zeros(size(bw));

for k =1:npix
    localidx = seeds(k);
    neighidx = localidx + Neighbor;%8邻域的点
    for i=1:Len
        idx = neighidx(i);
        if (idx>0) && (idx<imdim) && (bw(idx) ==1)
            countmap(localidx) = countmap(localidx)+1;%countmap记录每一个像素值为1的点的8邻域像素的个数
        end
    end
end

bw1 = (countmap>=3);
[labelmap, numlabel] = bwlabel(bw1, 8); %得到numlabel个8连通区域
NUM=regionprops(labelmap,'Area'); %求得每个连通区域的像素数目

bifu_num=zeros(numlabel,1);
for i=1:numlabel
    bifu_num(i,1)=NUM(i,1).Area;
end

%%处理连通区域像素数为6的情况
sequence1=find(bifu_num==6);reserve_no1=[];q=1;m=1;ptbifu1=[];
if ~isempty(sequence1)
    array1(numel(sequence1)).number=[];
end
if ~isempty(sequence1)
    for j=1:numel(sequence1)
        array1(j).number=find(labelmap==sequence1(j));%求得对应的序列号
        if numel(find(countmap(array1(j).number)==4))>=3 || ~isempty(find(countmap(array1(j).number)==5, 1))%判断出文档图2(a)\(d)第5个情况
            reserve_no1(q)=j;
            q=q+1;
        else
            [ptbifu11]=specialpoints_init(array1(j).number,M,N);%类似图2（c）情况
            if numel(ptbifu11)==2
                ptbifu1(m:m+1)=ptbifu11;
                m=m+2;
            else
                ptbifu1(m)=ptbifu11;
                m=m+1;
            end
        end
    end
end

%%处理连通区域像素数大于6的情况
sequence2=find(bifu_num>6);reserve_no2=[];l=1; %寻找需要进一步分离的连通区域
if ~isempty(sequence2)
    array2(numel(sequence2)).number=[];
end
for k=1:numel(sequence2)
    array2(k).number=find(labelmap==sequence2(k));%得到满足条件的区域序号
    if ~isempty(find(countmap(array2(k).number)>=5, 1)) && numel(array2(k).number)<11%多个点聚集在一起的情况,只选择一个作为分叉点
        reserve_no2(l)=k; %不再划分连通区域，仅选择一个点作为分叉点
        l=l+1;
    else
        [ptbifu22]=specialpoints_init(array2(k).number,M,N);
        if numel(ptbifu22)==2
            ptbifu1(m:m+1)=ptbifu22;
            m=m+2;
        else
            ptbifu1(m)=ptbifu22;
            m=m+1;
        end
    end
end

sequence=[sequence1; sequence2];
s1=setdiff(sequence,[sequence1(reserve_no1); sequence2(reserve_no2)]);
STATS1=regionprops(labelmap,'Centroid'); %求取各连通区域的中心点的坐标
STATS1(s1)=[];

bifu=zeros(numel(STATS1),2);ptbifu2=zeros(numel(STATS1),1);
for i=1:numel(STATS1)
    bifu(i,:)=round(STATS1(i,1).Centroid);
    ptbifu2(i,1)=(bifu(i,1)-1)*M+bifu(i,2);%得到所有分叉点坐标
end
ptbifu=[ptbifu1'; ptbifu2];
end

