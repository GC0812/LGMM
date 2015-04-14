function labelmap = points_show(bw, pt, R, TagBw)

%用矩形框显示待显示点

if (nargin == 3)
   TagBw = true; 
end

[M, N]= size(bw);
imdim = M*N + 1;

%定义一个5x5的矩形区域
Neighbor = [R*M+R:-1:R*M-R, (R-1)*M-R:-M:-(R-1)*M-R, -R*M-R:1:-R*M+R, -(R-1)*M+R:M:(R-1)*M+R];
Len = numel(Neighbor);

seeds = pt;
npix = numel(seeds);
labelmap = zeros(size(bw));

for k = 1:npix
    localidx = seeds(k);
    neighidx = localidx + Neighbor; %位置点的周围24个像素
    for i=1:Len
        idx = neighidx(i);
        if (idx>0) && (idx<imdim)
            labelmap(idx) = k; 
        end
    end
end

labelmap(seeds) = [1:npix]';

%如果TagBw,将labelmap转化为二值图
if (TagBw)
    lablemap = (labelmap>0);
end