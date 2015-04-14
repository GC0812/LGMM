function [ featuremat,order] = points_featuremat(bw, seeds, R)

%求得特征向量：距离、分支角度、及分叉点的角度

idx = numel(seeds); 
n=1;
for count = 1:idx
    anglevec = point_anglevec(bw, seeds(1,count), R);
    angel=findangle(anglevec);%每个分叉点的分支间角度
    NeighborNum = numel(find(angel~=0));
    switch NeighborNum
        case 0 
            angs(n,:)=[0 0 0 0 0];
            n=n+1;
        case 2
            angs(n,:)=[angel 0 0 0];
            n=n+1;
        case 3
            angs(n,:) = [angel 0 0];
            n = n+1;
        case 4
            angs(n,:) = [angel 0];
            n = n+1;
        case 5
            angs(n,:) = angel;
            n = n+1;            
        otherwise
            angs(n,:) = angel(1:5);
            angs(n,:)= sort(angs(n,:),'descend');
            n=n+1;
    end
end

[P,Q]=size(angs);
angs = reshape(angs',1,P*Q);

%--------------------------------------------------------------------------

% image(i,j) <==>(j-1)*M + i
[M, ~]= size(bw);
posi = mod(seeds, M); %seeds的行数和列数
posi(posi==0)= M; 
posj = 1 + (seeds-posi)/M;%行数

bDist=zeros(1,idx);mAng=zeros(1,idx);
for k =1:idx %求seeds中相邻元素的距离和角度
    if k==idx
        dy = -(posi(1)-posi(idx));
        dx = posj(1)-posj(idx);
    else   
        dy = -(posi(k+1)-posi(k));
        dx =   posj(k+1)-posj(k);
    end    
    bDist(k) = sqrt( dy*dy + dx*dx );
    mAng(k)  = atan2(dy, dx)*180/pi;
end
mAng(mAng<0) = mAng(mAng<0) + 360;

%将角度按大小排列作为顺序
[mAng,order] = sort(mAng);
bDist = bDist(order);
    
for k=1:idx %将每个分叉点的分支间角度按顺序重新排列
    nAng(5*(k-1)+1: 5*k) = angs( 5*(order(k)-1)+1: 5*order(k));
end

%求解分支间的角度
bAng=zeros(1,idx);
bAng(1)= mAng(1)-mAng(idx);
for k=2:idx
    bAng(k)  = mAng(k)-mAng(k-1);
end
bAng(bAng<0) = bAng(bAng<0) + 360;

%正则化距离及角度
bDist = bDist/sum(bDist);
bAng  = bAng/360;
nAng  = nAng/360;

for k=1:idx
    featuremat(7*(k-1)+1:7*k) = [bDist(k),bAng(k), nAng(5*(k-1)+1: 5*k)];%每个分叉点对应的距离、分支角度、及分叉点的角度
end
