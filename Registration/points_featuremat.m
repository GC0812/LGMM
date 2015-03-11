function [ featuremat,order] = points_featuremat(bw, seeds, R)
%POINTS_FEATUREMAT Summary of this function goes here
%   Detailed explanation goes here


idx = numel(seeds); %计算环中每个分叉点的角度，写成一个一维向量的形式
n=1;
for count = 1:idx
    anglevec = point_anglevec(bw, seeds(1,count), R);
    angel=findangle(anglevec);
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
posj = 1 + (seeds-posi)/M;

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

% counterclock start from 3 oclock, rearanage features
[mAng,order] = sort(mAng);
bDist = bDist(order);
    
for k=1:idx
    nAng(5*(k-1)+1: 5*k) = angs( 5*(order(k)-1)+1: 5*order(k));
end


% angle between each branch
bAng(1)= mAng(1)-mAng(idx);
for k=2:idx
    bAng(k)  = mAng(k)-mAng(k-1);
end
bAng(bAng<0) = bAng(bAng<0) + 360;

% normalize the Dist and Angle
bDist = bDist/sum(bDist);
bAng  = bAng/360;
nAng  = nAng/360;

for k=1:idx
    featuremat(7*(k-1)+1:7*k) = [bDist(k),bAng(k), nAng(5*(k-1)+1: 5*k)];
end
