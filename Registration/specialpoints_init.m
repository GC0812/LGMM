function [ptbifu]=specialpoints_init(array,M,N)

labelmap2=zeros(M,N); %对分离的分叉点标记
no=numel(array);
arraycoord=zeros(2,no);
bifu=zeros(2,2);ptbifu=zeros(1,2);
for j=1:numel(array)
    arraycoord(:,j)=points_transform(array(j)', [M, N]);
end
ss1=union(arraycoord(1,:),[]);%使横坐标按顺序排好
[times1,ordinate1]=hist(arraycoord(1,:),ss1);%得到所有横坐标对应的重复次数
maxcount=max(times1);
if maxcount==4  
   repeatx=ordinate1(times1==maxcount);
   ss2=union(arraycoord(2,:),[]);%使纵坐标按顺序排好
   [times2,ordinate2]=hist(arraycoord(2,:),ss2);
   repeaty=ordinate2(times2>=2);
   ptbifu(1)=(repeatx-1)*M+repeaty(1);
   ptbifu(2)=(repeatx-1)*M+repeaty(2);
else
    if mod(no,2)==1
        part_sequence1=array(1:floor(no/2));%将该连通区域分离为两个区域
        part_sequence2=array(floor(no/2)+2:end);        
    else
        part_sequence1=array(1:floor(no/2));
        part_sequence2=array(floor(no/2)+1:end);
    end
    labelmap2(part_sequence1)=1;
    labelmap2(part_sequence2)=2;
    STATS=regionprops(labelmap2,'Centroid');
    for i=1:2
    bifu(i,:)=round(STATS(i,1).Centroid);
    ptbifu(1,i)=(bifu(i,1)-1)*M+bifu(i,2);%得到所有分叉点坐标
    end
end

