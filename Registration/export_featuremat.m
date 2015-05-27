function [ featuremat3,featuremat4,featuremat5,loop3,loop4,loop5,linktableoriginal,bw,ptbifu] = export_featuremat( bw )

%求得图像的分叉点，连接关系，构造3种环结构并输出特征向量

featuremat3=[];featuremat4=[];featuremat5=[];loop3=[];loop4=[];loop5=[];

[ptbifu] = points_init(bw); %找分叉点
bw(ptbifu)=1;
radius=3;
% 
% label = points_show(bw,ptbifu,3);  %标记分叉点
% label_bifu = 1-cat(3, bw, bw+label , bw);
% figure,imshow(label_bifu)

[linktableoriginal] = points_link(bw, ptbifu); %找到每个分叉点的相邻分叉点构成连接关系

[linktable] = select_linktable(linktableoriginal);%挑选得到能构成环的连接关系

if isempty(linktable)
    return
end

[M,N]=size(bw);

no1=numel(linktable(1,:));
node1=linktable(1,:); %得到所有节点号
[xy1]=points_transform(node1',[M,N]);
nodexy=[node1' xy1]; %得到所有节点及坐标值

link1=linktable';

fid=fopen('./Registration/sdfs_temp/node.txt','w+');
fprintf(fid,'%d\n',no1);

for k=1:no1
    fprintf(fid,'%d %d %d\n',nodexy(k,:));
end
for m=1:no1
    fprintf(fid,'%d %d %d %d %d\n',link1(m,:));
end
fclose('all');

command='./Registration/sdfs_temp/sdfs';
[~]=system(command);

fidin=fopen('./Registration/sdfs_temp/result.txt','r');
j1=1;j2=1;j3=1;
while ~feof(fidin) % 判断是否为文件末尾
    tline=fgetl(fidin); % 从文件读行
    temp=str2num(tline);
    if numel(temp)==3
        loop3(j1,:)=temp;
        j1=j1+1;
    elseif numel(temp)==4
        loop4(j2,:)=temp;
        j2=j2+1;
    elseif numel(temp)==5
        loop5(j3,:)=temp;
        j3=j3+1;
    end
end
fclose(fidin);
fclose('all');

Len = size(loop3,1);
num_featuremat3=1;
for count=1:Len
    bifu_loop = loop3(count,:);
    featuremat3(num_featuremat3,:)= points_featuremat(bw, bifu_loop, radius);
    num_featuremat3=num_featuremat3+1;
end
Len = size(loop4,1);
num_featuremat4=1;
for count=1:Len
    bifu_loop = loop4(count,:);
    featuremat4(num_featuremat4,:)= points_featuremat(bw, bifu_loop, radius);
    num_featuremat4=num_featuremat4+1;
end
Len = size(loop5,1);
num_featuremat5=1;
for count=1:Len
    bifu_loop = loop5(count,:);
    featuremat5(num_featuremat5,:)= points_featuremat(bw, bifu_loop, radius);
    num_featuremat5=num_featuremat5+1;
end



