function [ptbifu] = points_init(bw)

% This function initializes the feature points from the binary image

[M, N]= size(bw);
imdim = M*N + 1;

Neighbor = [-M, 1, M, -1, -1-M, 1-M,  1+M, -1+M];
Len = numel(Neighbor);

seeds = find(bw == 1);
npix = numel(seeds);
countmap = zeros(size(bw));

for k =1:npix
    localidx = seeds(k);
    neighidx = localidx + Neighbor;
    for i=1:Len
        idx = neighidx(i);
        if (idx>0) && (idx<imdim) && (bw(idx) ==1)
            countmap(localidx) = countmap(localidx)+1;
        end
    end
end

bw1 = (countmap>=3);
[labelmap, numlabel] = bwlabel(bw1, 4);
STATS1=regionprops(labelmap,'Centroid'); %求取每个连通区域的中心点的坐标
NUM=regionprops(labelmap,'Area'); %求得每个连通区域的像素数目
bifu1=zeros(numlabel,2);ptbifu1=zeros(numlabel,1);bifu_num=zeros(numlabel,1);
for i=1:numlabel
    bifu1(i,:)=round(STATS1(i,1).Centroid); 
    ptbifu1(i,1)=(bifu1(i,1)-1)*M+bifu1(i,2);
    bifu_num(i,1)=NUM(i,1).Area;
end
   sequence_no=find(bifu_num>=7);%寻找需要进一步分离的分叉点
      
   m=1;l=1;
   for k=1:numel(sequence_no)
       sequence(k).number=find(labelmap==sequence_no(k));
       no=numel(sequence(k).number);
       if ~isempty(find(countmap(sequence(k).number)>=5, 1))%去除多个点聚集在一起的情况，只在多个点种选择一个作为分叉点
          reserve_no(l)=k;
          l=l+1;
       else
           if mod(no,2)==1
               part_sequence1(m).number=sequence(k).number(1:floor(no/2));%将该分叉点分离为两个分叉点
               part_sequence2(m).number=sequence(k).number(floor(no/2)+2:end);
               m=m+1;
           else
               part_sequence1(m).number=sequence(k).number(1:floor(no/2));
               part_sequence2(m).number=sequence(k).number(floor(no/2)+1:end);
               m=m+1;
           end
       end
   end
   ptbifu1(setdiff(sequence_no,sequence_no(reserve_no)))=[];
   
   n=1;labelmap2=zeros(M,N); %对分离的分叉点标记
   for j=1:m-1
       labelmap2(part_sequence1(j).number)=n;
       n=n+1;
       labelmap2(part_sequence2(j).number)=n;
       n=n+1;
   end
   STATS2=regionprops(labelmap2,'Centroid'); %求取分离分叉点连通区域的中心点的坐标
   bifu2=zeros(2*(m-1),2);ptbifu2=zeros(2*(m-1),1);
   for i=1:2*(m-1)
       bifu2(i,:)=round(STATS2(i,1).Centroid);
       ptbifu2(i,1)=(bifu2(i,1)-1)*M+bifu2(i,2);
   end
   
   ptbifu=[ptbifu1;ptbifu2];
end
