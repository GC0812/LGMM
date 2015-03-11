function [ linktable4 ] = select_linktable(linktable)

%%选择有效的连接关系，去除无效的特征点

linktable4=[];linktable1=[];

flag=1;
count=1;
for i=1:size(linktable,1)
    if(linktable(i, 2)>=2) %提取矩阵中有三个和四个相邻分叉点的行数
        linktable1(count,:)=linktable(i,:);
        count=count+1;
    end
end

if isempty(linktable1)
    return
end

linktable1(:,2)=[]; %把第二列连接分叉点的个数去掉

while flag==1
flag=0;
L = size(linktable1,1);

for i=1:4*L         %分别找linktable中的点,若一个点的重复个数小于3,则赋值为0
    if(numel(find(linktable1==linktable1(i)))<3)
        linktable1(i)=0;flag=1;
    end
end

if flag==0
    break;
end

n=1;
linktable2=[];linktable3=[];
for j = 1:L
    if(numel(find(linktable1(j,:)~=0))>2) %去掉一行中非零元素小于2个的行
        linktable2(n,:)=linktable1(j,:);
        n=n+1;
    end
end
m=1;
for k=1:size(linktable2,1)
    if(linktable2(k,1)~=0)
        linktable3(m,:)=linktable2(k,:);
        m=m+1;
    end
end
linktable1=linktable3;
end

linktable4=linktable3';


end

