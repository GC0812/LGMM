function [ptbifu, ptroot] = points_init(bw)

% This function initializes the feature points from the binary image

[M, N]= size(bw);
imdim = M*N + 1;

Neighbor = [-M, 1, M, -1, -1-M, 1-M,  1+M, -1+M]; %一个点相邻的八个位置
Len = numel(Neighbor);

seeds = find(bw == 1); %按列找到bw中是1的元素，返回位置（按列排的像素的序号）
npix = numel(seeds); %像素是1的像素个数
countmap = zeros(size(bw)); 

for k =1:npix
    localidx = seeds(k); 
    neighidx = localidx + Neighbor; %每个灰度值为1的相邻的八个像素
    for i=1:Len
        idx = neighidx(i);
        if (idx>0) && (idx<imdim) && (bw(idx) ==1)
            countmap(localidx) = countmap(localidx)+1; %计算灰度值为1的相邻八个点有几个值为1
        end
    end
end

bw1 = (countmap>=3);
[labelmap, numlabel] = bwlabel(bw1, 8);
STATS = regionprops(labelmap,'Centroid'); %求取每个连通区域的中心点的坐标
bifu = zeros(numel(STATS),2);ptbifu=zeros(numel(STATS),1);
for i=1:numel(STATS)
    bifu(i,:) = round(STATS(i,1).Centroid); 
    ptbifu(i,1) = (bifu(i,1)-1)*M+bifu(i,2);
end