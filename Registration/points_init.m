function [ptbifu, ptroot] = points_init(bw)

% This function initializes the feature points from the binary image

ptbifu=[];
[M, N]= size(bw);
imdim = M*N + 1;

Neighbor = [-M, 1, M, -1, -1-M, 1-M,  1+M, -1+M]; %一个点相邻的八个位置
Len = numel(Neighbor);

seeds = find(bw == 1); %按列找到bw中是1的元素，返回位置（按列排的像素的序号）
npix = numel(seeds); %像素是1的像素个数
countmap = zeros(size(bw)); 

for k =1:npix
    localidx = seeds(k); 
    neighidx = localidx + Neighbor; %每个灰度值为1的相邻的八个像素
    for i=1:Len
        idx = neighidx(i);
        if (idx>0) && (idx<imdim) && (bw(idx) ==1)
            countmap(localidx) = countmap(localidx)+1; %计算灰度值为1的相邻八个点有几个值为1
        end
    end
end

%处理countmap为4、5、6的特殊的四、五分叉点
bwf=find(countmap==4|countmap==5|countmap==6);
m1=1;fbifu=[];
for k2=1:numel(bwf) %这里认为countmap值为4或5的点若其斜角处有两个2则认为是四或五分叉点（即5678处），否则为三分叉点
    localidx1 = bwf(k2);
    neighidx1 = localidx1 + Neighbor;
    if countmap(bwf(k2))==6
        fbifu(m1)=bwf(k2);
        m1=m1+1;
        countmap(bwf(k2))=0;
        %countmap(neighidx1)=0;
        for i=1:8
            idx1= neighidx1(i);
            if (idx1>0) && (idx1<imdim)
                countmap(idx1) = 0;
            end
        end
    end
    if isempty(neighidx1([5,6,7,8])==0) && numel(find(countmap(neighidx1([5,6,7,8]))==2))>=2 
        if countmap(localidx1)==5 && isempty(find(countmap(neighidx1([1,2,3,4])))==4)%五分叉点除了需去除周围八个像素，还需要防止出现countmap为4点的情况
            if countmap(localidx1+M)==4
                countmap(localidx1+M+1)=0;
            elseif countmap(localidx1-M)==4
                countmap(localidx1+M-1)=0;
            elseif countmap(localidx1+1)==4
                countmap(localidx1+2)=0;
            elseif countmap(localidx1-1)==4
                countmap(localidx1-2)=0;
            end
        elseif countmap(localidx1)==4 && ~isempty(find(countmap(neighidx1)==4, 1))
            localidx2=neighidx1(countmap(neighidx1)==4);
            neighidx2=localidx2+Neighbor;
            countmap(localidx2)=0;
            %countmap(neighidx2)=0;
            for i=1:8
                idx2= neighidx2(i);
                if (idx2>0) && (idx2<imdim)
                    countmap(idx2) = 0;
                end
            end
            fbifu(m1)=bwf(k2);
            m1=m1+1;
            countmap(bwf(k2))=0;
            %countmap(neighidx1)=0;
            for i=1:8
                idx1= neighidx1(i);
                if (idx1>0) && (idx1<imdim)
                    countmap(idx1) = 0;
                end
            end
        else
            fbifu(m1)=bwf(k2);
            m1=m1+1;
            countmap(bwf(k2))=0;
            %countmap(neighidx1)=0;
            for i=1:8
                idx1= neighidx1(i);
                if (idx1>0) && (idx1<imdim)
                    countmap(idx1) = 0;
                end
            end
        end
    end
    clear neighidx1 neighidx2;
end

%处理一般性的分叉点
bw1 = (countmap==3|countmap==4);
[labelmap, numlabel] = bwlabel(bw1, 8); %给连通区域进行标记，并返回连通区域的数目
m2=1;
% for i=36
for i=1:numlabel
    %k=i
    candidates = find(labelmap==i);
    nn=numel(candidates);
    if nn>2
        coordcandidates=zeros(2,nn);repeatx=[];repeaty=[];ptbifu1=[];ptbifu11=[];tempbifu=zeros(2,3);
        for j=1:nn
            coordcandidates(:,j)=points_transform(candidates(j)', [M, N]);
        end
        ss1=union(coordcandidates(1,:),[]);%使横坐标按顺序排好
        [N1,X1]=hist(coordcandidates(1,:),ss1);%求横坐标及其个数
        repeatx=X1(N1>=2);%找到重复次数大于2的横坐标
        ss2=union(coordcandidates(2,:),[]);%使纵坐标按顺序排好
        if numel(ss2)==1
            ptbifu(m2)=candidates(fix((end+1)/2));
            m2=m2+1;
            continue;
        end
        [N2,X2]=hist(coordcandidates(2,:),ss2);
        repeaty=X2(N2>=2);flag=0;
        for k=1:numel(repeatx)%分叉点的横纵坐标一定重复次数大于2
            ptbifu11=coordcandidates(:,coordcandidates(1,:)==repeatx(k));
            for m=1:numel(repeaty)
                ptbifu1=ptbifu11(:,ptbifu11(2,:)==repeaty(m));
                if ~isempty(ptbifu1)
                    ptbifu(m2)=(ptbifu1(1)-1)*M+ptbifu1(2);
                    m2=m2+1;
                    flag=flag+1;tempbifu(:,flag)=ptbifu1;
                end
            end
        end
        if flag==3 %解决出现有两个分叉点的情况下，两个分叉点有相同的行或列，出现了第三个错误的点
            d1=find(diff(tempbifu(1,:))==0);
            if ~isempty(d1)
                dd=setdiff([1 2 3],[d1 d1+1]);
                if isempty(dd)
                    %ptbifu()
                    continue;
                end
                order=find(tempbifu(2,d1:d1+1)==tempbifu(2,dd));        
                ptbifu(m2-1-(3-order))=[];
                m2=m2-1;
            end
        end
        tempbifu=[];
        else
            ptbifu(m2) = candidates(fix((end+1)/2)); %找到每个连通区域的中心位置
            m2=m2+1;
        end
end
if ~isempty(fbifu)
    ptbifu=[ptbifu fbifu];
end

ptroot = find(countmap == 1);

ptbifu = ptbifu(:); %返回连通区域的中心位置
ptroot = ptroot(:); %返回孤立点的位置