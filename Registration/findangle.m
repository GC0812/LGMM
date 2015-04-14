function outdegs = findangle(boundvec)

%计算分叉点角度

npix = numel(boundvec);
if (sum(abs(boundvec))==0 || sum(abs(boundvec))== npix )
    outdegs =[];
    return;
end

%设置24个方向的角度
R  = npix/8; 
dy = [0:1:R, R*ones(1, 2*R-1), R:-1:-R, -R* ones(1,2*R-1), -R:1:-1];%得到7*7区域最外围的点的纵坐标（从3点钟方向开始）
dx = [R*ones(1, R+1), R-1:-1:-R+1, -R*ones(1, 2*R+1), -R+1:1:R-1, R*ones(1, R)];
degs = atan2(dy, dx)*180/pi;
degs(degs<0) = degs(degs<0) + 360;

%寻找连通区域
[labelmap, numlabel] = bwlabel(boundvec, 8);
if (boundvec(1)==1 && boundvec(end)==1)
    degs(labelmap == labelmap(end)) = degs(labelmap == labelmap(end))-360;
    labelmap(labelmap == labelmap(end)) = labelmap(1);
    numlabel= numlabel-1;
end

%%计算与中心点所成的角度
m=zeros(1,numlabel);
for k=1:numlabel
    seeds = sort(degs(labelmap==k)); 
    m(k) = (seeds(1)+seeds(end))/2;
end
m(m<0) = m(m<0)+360;

outdegs=zeros(1,numlabel-1);
for k = 1:numlabel-1
    outdegs(k)  = m(k+1)-m(k);
end
outdegs(numlabel)= m(1)-m(numlabel);
outdegs(outdegs<0) = outdegs(outdegs<0)+360;
