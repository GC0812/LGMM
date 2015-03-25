function [ptbifu] = points_init(bw)

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
[labelmap, numlabel] = bwlabel(bw1, 8); %得到numlabel个8连通区域
NUM=regionprops(labelmap,'Area'); %求得每个连通区域的像素数目

bifu_num=zeros(numlabel,1);
for i=1:numlabel
    bifu_num(i,1)=NUM(i,1).Area;
end
   sequence_no=find(bifu_num>=6); %寻找需要进一步分离的连通区域
      
   m=1;l=1;reserve_no=[];
   for k=1:numel(sequence_no)
       sequence(k).number=find(labelmap==sequence_no(k));%得到满足条件的区域序号
       no=numel(sequence(k).number);
       if ~isempty(find(countmap(sequence(k).number)>=5, 1))||(numel(find(countmap(sequence(k).number)==4))>=3 && NUM(sequence_no(k),1).Area==6)%多个点聚集在一起的情况,只选择一个作为分叉点；处理一种特殊情况
           reserve_no(l)=k; %不再划分连通区域，仅选择一个点作为分叉点
           l=l+1;
       else
           flag=1;
           if mod(no,2)==1
               part_sequence1(m).number=sequence(k).number(1:floor(no/2));%将该连通区域分离为两个区域
               part_sequence2(m).number=sequence(k).number(floor(no/2)+2:end);
               m=m+1;
           else
               if no==6
                   for h=1:no
                       coordcandidates(:,h)=points_transform(sequence(k).number(h)', [M, N]);
                   end
                   X = unique(coordcandidates(1,:));
                   [times,coord]=hist(coordcandidates(1,:),X);
                   maxcount = max(times);
                   if maxcount==4
                       target_no=coord(times==maxcount);
                       coordcandidates(:,coordcandidates(1,:)==target_no)=[];
                       part_sequence1(m).number=sequence(k).number([1 end-2 end-1]);
                       part_sequence2(m).number=sequence(k).number(setdiff([1:1:6],[1 end-1 end]));
                       m=m+1;flag=0;
                   end
               end
               if flag==1
                   part_sequence1(m).number=sequence(k).number(1:floor(no/2));
                   part_sequence2(m).number=sequence(k).number(floor(no/2)+1:end);
                   m=m+1;
               end
           end
       end
   end
   
   s1=setdiff(sequence_no,sequence_no(reserve_no));
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