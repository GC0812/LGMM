function [ptbifu] = points_init2(bw)

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
sequence1=find(bifu_num==6);q=1;m=1;reserve_no1=[];
if ~isempty(sequence1)
    for j=1:numel(sequence1)
        array1(j).number=find(labelmap==sequence1(j));%求得对应的序列号
        if numel(find(countmap(array1(j).number)==4))>=3 %判断出文档图2(a)情况
            reserve_no1(q)=j;
            q=q+1;
        else
            for k=1:numel(array1(j).number)
                coord(:,k)=points_transform(array1(j).number(k)', [M, N]);
            end
            X = unique(coord(1,:));
            [times,ordinate]=hist(coord(1,:),X);%得到所有纵坐标对应的重复次数
            maxcount = max(times);
            if maxcount==4                        %判断是否为图2(c)情况
                target_no=ordinate(times==maxcount);%得出重复次数最大的列号
                coord(:,coord(1,:)==target_no)=[];%得出位于连通区域两侧的点的坐标
                for s=1:2
                    seed2(s)=(coord(1,s)-1)*M+coord(2,s);
                    localidx = seed2(s);
                    neighidx = localidx + Neighbor;
                    d=1;
                    for i=1:Len
                        idx = neighidx(i);
                        if (idx>0) && (idx<imdim) && (bw1(idx) ==1)
                            region(s,d)=idx;%找到与连通区域两侧的点8邻域内相连的点
                            d=d+1;
                        end
                    end
                end
                part_sequence1(m).number=setdiff(region(1,:),0);
                part_sequence2(m).number=setdiff(region(2,:),0);
                m=m+1;
            else
                part_sequence1(m).number=array1(j).number(1:3);
                part_sequence2(m).number=array1(j).number(4:6);
                m=m+1;
            end
        end
    end
end

%%处理连通区域像素数大于6的情况
l=1;reserve_no2=[];sequence2=find(bifu_num>6); %寻找需要进一步分离的连通区域
for k=1:numel(sequence2)
    array2(k).number=find(labelmap==sequence2(k));%得到满足条件的区域序号
    no=numel(array2(k).number);
    if ~isempty(find(countmap(array2(k).number)>=5, 1))%多个点聚集在一起的情况,只选择一个作为分叉点
        reserve_no2(l)=k; %不再划分连通区域，仅选择一个点作为分叉点
        l=l+1;
    else
        if mod(no,2)==1
            part_sequence1(m).number=array2(k).number(1:floor(no/2));%将该连通区域分离为两个区域
            part_sequence2(m).number=array2(k).number(floor(no/2)+2:end);
            m=m+1;
        else
            part_sequence1(m).number=array2(k).number(1:floor(no/2));
            part_sequence2(m).number=array2(k).number(floor(no/2)+1:end);
            m=m+1;
        end
    end
end

sequence=[sequence1; sequence2];
s1=setdiff(sequence,[sequence1(reserve_no1); sequence2(reserve_no2)]);
STATS1=regionprops(labelmap,'Centroid'); %求取各连通区域的中心点的坐标
STATS1(s1)=[];

n=1;labelmap2=zeros(M,N); %对分离的分叉点标记
for j=1:m-1
    labelmap2(part_sequence1(j).number)=n;
    labelmap2(part_sequence2(j).number)=n+1;
    n=n+2;
end
STATS2=regionprops(labelmap2,'Centroid'); %求取分离分叉点连通区域的中心点的坐标
STATS=[STATS1;STATS2];
bifu=zeros(numel(STATS),2);ptbifu=zeros(numel(STATS),1);
for i=1:numel(STATS)
    bifu(i,:)=round(STATS(i,1).Centroid);
    ptbifu(i,1)=(bifu(i,1)-1)*M+bifu(i,2);
end
end