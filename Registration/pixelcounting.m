function [pixelnum, pixelsequence]=pixelcounting(bw,seed1,externalbifu)

%计算两点之间的距离(即像素个数)，externalbifu=0表明环上的分叉点没有分支，
%externalbifu=1表明环上的分叉点有分支但末端没有分叉点

[M, N]= size(bw);
imdim = M*N + 1;

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
    pixelsequence=[];tail=zeros(1,2);
    for i=1:2
        pixelnum(i) = numel(node(nn(i)).sequence)+1;%加上最初的分叉点
        pixelsequence=[pixelsequence seed node(nn(i)).sequence];
        tail(i)=node(nn(i)).sequence(end);
    end
else
    nn=zeros(1,numel(externalbifu));
    for i=1:numel(externalbifu)
        if externalbifu(i)~=0 && externalbifu(i)~=1          
            nn1= find(targetbifu==externalbifu(i));%确定哪一部分才是要找的外接血管            
        else
            nn1= find(targetbifu==0); %若无外接分叉点，则选择没有求得分叉点的路径
        end
        if isempty(nn1)
            return;
        end
        nn(i)=nn1(1);
    end   
    pixelsequence=[];
    for i=1:numel(nn)
        pixelnum(i) = numel(node(nn(i)).sequence)+1;%加上最初的分叉点
        pixelsequence=[pixelsequence seed node(nn(i)).sequence];
    end   
end

if isequal(externalbifu,[1 1])
    targetcoord=zeros(2,2);tailcoord=zeros(2,2);
    temp=setdiff(targetbifu,0);
    for k=1:2
        targetcoord(k,:)=points_transform(temp(k)', [M, N]);%分叉点在环上的两个相邻分叉点        
    end
    tailcoord(1,:)=points_transform(pixelsequence(pixelnum(1))', [M, N]);
    tailcoord(2,:)=points_transform(pixelsequence(end)', [M, N]);
    bifucoord=points_transform(seed', [M, N]);
    vab=zeros(2,2);vac=zeros(2,2);c=zeros(1,2);angle=zeros(1,2);
    vab(1,:)=[bifucoord(1)-targetcoord(1,1),bifucoord(2)-targetcoord(1,2)];%求得分叉点与环上两个相邻分叉点的向量
    for i=1:2
        vac(i,:)=[bifucoord(1)-tailcoord(i,1),bifucoord(2)-tailcoord(i,2)];%求得分叉点与血管末梢点的现货量
        c(i)=dot(vac(i,:),vab(1,:))/norm(vac(i,:),2)/norm(vab(1,:),2);
        angle(i)=rad2deg(acos(c(i)));%计算向量间的角度
    end    
    if angle(1)>angle(2)
        pixelnum=pixelnum([2,1]);
        pixelsequence=pixelsequence([pixelnum(2)+1:end,1:pixelnum(2)]);%如果角度不对，则认为目前环外血管顺序不对，使之按与某一分叉点相邻顺序输出
    end
end
