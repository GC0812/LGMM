function [points_bb,points_aa]=featurepoints_extraction(bw1,bw2,matchingpair1,matchingpair2,linktableoriginal1,linktableoriginal2,M)

%提取环-血管特征点%

[M1,N1]=size(bw1);
[M2,N2]=size(bw2);

if M==3
    bb=[1 2 3 4 5 6];
    bb1=[1 3 5];
elseif M==4
    bb=[1 2 3 4 5 6 7 8];
    bb1=[1 3 5 7];
else
    bb=[1 2 3 4 5 6 7 8 9 10];
    bb1=[1 3 5 7 9];
end
k=1;
A=matchingpair1;
B=matchingpair2;

%%%%%%%%环结构的分叉点特征点%%%%%%
pointsa1 = points_transform(A', [M1, N1]);     
pointsa2 = points_transform(B', [M2, N2]);

points_a(k).img=pointsa1';points_b(k).img=pointsa2';
k=k+1;

%%%%%%%%寻找环与之相连的血管上的点及末梢分叉点%%%%%%% 

%%判断两幅图像是否都有分叉点，并把都有分叉点的序号输出
R=3;externalbifu1=zeros(2,M);externalbifu2=zeros(2,M);cyclebifu1=zeros(5,M);cyclebifu2=zeros(5,M);
for i=1:M
    cyclebifu1(:,i)=linktableoriginal1(:,linktableoriginal1(1,:)==A(:,i));%环上每一个分叉点的相邻分叉点序列
    externalbifu1(:,i)=setdiff(cyclebifu1(:,i),A);%每个环上4个点的外接分叉点
    cyclebifu2(:,i)=linktableoriginal2(:,linktableoriginal2(1,:)==B(:,i));
    externalbifu2(:,i)=setdiff(cyclebifu2(:,i),B);
end
order1=find(externalbifu1~=0);
order2=find(externalbifu2~=0);
externalorder=intersect(order1,order2);%两幅图像都有的分叉点的序号

%%判断都有分叉点的图像的分叉点是否对应
n=1;order3=0;
for i=1:numel(externalorder)
    anglevec1=point_anglevec(bw1, externalbifu1(externalorder(i)), R);
    outangle1=findangle(anglevec1);%每个外接分叉点的角度
    anglevec2=point_anglevec(bw2, externalbifu2(externalorder(i)), R);
    outangle2=findangle(anglevec2);
    if numel(outangle1)==numel(outangle2)
        diffangle=outangle1-outangle2;
    else diffangle=100;
    end
    errorangle=sum(abs(diffangle))/numel(outangle1);%角度的平均误差    
    if any(diffangle==0) && numel(unique(abs(diffangle)))<=2 && errorangle<11.4%%好像有对应的分叉点会出现这种情况
        order3(n)=externalorder(i);n=n+1;%有对应的外接分叉点的序号
    end
end
allorder=setdiff(bb,order3);
vesselorder=setdiff(allorder,bb1(externalbifu1(1,:)==0));


%%对有对应的分叉点求特征点
invalidnum=[];
if order3~=0
    for i=1:numel(order3)
        [pixelnuma1(i), sequencea1(i).points, sidelengtha1(i)]=pixelcounting(bw1,cyclebifu1(:,ceil(order3(i)/2)),externalbifu1(order3(i)));
        [pixelnuma2(i), sequencea2(i).points, sidelengtha2(i)]=pixelcounting(bw2,cyclebifu2(:,ceil(order3(i)/2)),externalbifu2(order3(i)));
    end
    if ~isempty(find(~isnan(pixelnuma1(:))==0, 1)) || ~isempty(find(~isnan(pixelnuma2(:))==0, 1)) %如果计算环边长度有误，去掉此点
        invalidnum=[find(isnan(pixelnuma1(:))==1); find(isnan(pixelnuma2(:))==1)];
        pixelnuma1(invalidnum)=[];
        pixelnuma2(invalidnum)=[];
        sequencea1(invalidnum)=[];
        sequencea2(invalidnum)=[];
    end
    midpointsa1=zeros(1,numel(order3)-numel(invalidnum));midpointsa2=zeros(1,numel(order3)-numel(invalidnum));
    coordmidpointsa1=zeros(numel(order3)-numel(invalidnum),2);coordmidpointsa2=zeros(numel(order3)-numel(invalidnum),2);
    coordbifua1=zeros(numel(order3)-numel(invalidnum),2);coordbifua2=zeros(numel(order3)-numel(invalidnum),2);

    for i=1:numel(pixelnuma1)
        midpointsa1(i)=sequencea1(i).points(round(pixelnuma1(i)/2));%求出血管的中点的序号
        midpointsa2(i)=sequencea2(i).points(round(pixelnuma2(i)/2));
        coordmidpointsa1(i,:)=points_transform(midpointsa1(i)',[M1, N1]);%中点的坐标
        coordmidpointsa2(i,:)=points_transform(midpointsa2(i)',[M1, N1]);
        coordbifua1(i,:)=points_transform(externalbifu1(order3(i))',[M1, N1]);%血管外接分叉点的坐标
        coordbifua2(i,:)=points_transform(externalbifu2(order3(i))',[M1, N1]);
    end  
    pointsb1=[coordmidpointsa1;coordbifua1];
    pointsb2=[coordmidpointsa2;coordbifua2];
    points_a(k).img=pointsb1';points_b(k).img=pointsb2';
    k=k+1;
end

%血管求末梢处（包括分叉点）、1/2处的特征点（包含均有分叉点但不对应；只有一个有分叉点；两个均没分叉点的情况）
invalidnum=[];
if vesselorder~=0
    for i=1:numel(vesselorder)
        [pixelnumb1(i), sequenceb1(i).points, sidelengthb1(i)]=pixelcounting(bw1,cyclebifu1(:,ceil(vesselorder(i)/2)),externalbifu1(vesselorder(i)));
        [pixelnumb2(i), sequenceb2(i).points, sidelengthb2(i)]=pixelcounting(bw2,cyclebifu2(:,ceil(vesselorder(i)/2)),externalbifu2(vesselorder(i)));
        sideratioall(i)=sidelengthb1(i)/sidelengthb2(i);
    end
    %sideratio1=sum(sideratioall)/numel(vesselorder);
    sideratio1=1;
    if ~isempty(find(~isnan(pixelnumb1(:))==0, 1)) || ~isempty(find(~isnan(pixelnumb2(:))==0, 1)) %如果计算环边长度有误，去掉此点
        invalidnum=[find(isnan(pixelnumb1(:))==1); find(isnan(pixelnumb2(:))==1)];
        pixelnumb1(invalidnum)=[];
        pixelnumb2(invalidnum)=[];
        sequenceb1(invalidnum)=[];
        sequenceb2(invalidnum)=[];
    end  
    midpointsb1=zeros(1,numel(vesselorder)-numel(invalidnum));midpointsb2=zeros(1,numel(vesselorder)-numel(invalidnum));
    vesselendingb1=zeros(1,numel(vesselorder)-numel(invalidnum));vesselendingb2=zeros(1,numel(vesselorder)-numel(invalidnum));
    coordmidpointsb1=zeros(numel(vesselorder)-numel(invalidnum),2);coordmidpointsb2=zeros(numel(vesselorder)-numel(invalidnum),2);
    coordvesselendingb1=zeros(numel(vesselorder)-numel(invalidnum),2);coordvesselendingb2=zeros(numel(vesselorder)-numel(invalidnum),2);

    for i=1:numel(pixelnumb1)
        if pixelnumb1(i)<sideratio1*pixelnumb2(i)
            midpointsb1(i)=sequenceb1(i).points(round(pixelnumb1(i)/2));
            midpointsb2(i)=sequenceb2(i).points(round(pixelnumb1(i)/2/sideratio1));
            vesselendingb1(i)=sequenceb1(i).points(end);
            vesselendingb2(i)=sequenceb2(i).points(round((pixelnumb1(i)-1)/sideratio1));
        else
            midpointsb1(i)=sequenceb1(i).points(round(pixelnumb2(i)/2*sideratio1));
            midpointsb2(i)=sequenceb2(i).points(round(pixelnumb2(i)/2));
            vesselendingb1(i)=sequenceb1(i).points(round((pixelnumb2(i)-1)*sideratio1));
            vesselendingb2(i)=sequenceb2(i).points(end);
        end
        coordmidpointsb1(i,:)=points_transform(midpointsb1(i)',[M1, N1]);%中点的坐标
        coordmidpointsb2(i,:)=points_transform(midpointsb2(i)',[M1, N1]);
        coordvesselendingb1(i,:)=points_transform(vesselendingb1(i)',[M1, N1]);
        coordvesselendingb2(i,:)=points_transform(vesselendingb2(i)',[M1, N1]);
    end
    pointsc1=[coordmidpointsb1;coordvesselendingb1];
    pointsc2=[coordmidpointsb2;coordvesselendingb2];
    points_a(k).img=pointsc1';points_b(k).img=pointsc2';
    k=k+1;
end

%%%%%最终的特征点%%%%%%%%%%%
points_aa(:,1:numel(points_a(1).img(1,:)))=points_a(1).img;
points_bb(:,1:numel(points_b(1).img(1,:)))=points_b(1).img;
wa1=1+numel(points_a(1).img(1,:));wb1=1+numel(points_b(1).img(1,:));
for i=2:k-1
    points_aa(:,wa1:wa1+numel(points_a(i).img(1,:))-1)=points_a(i).img;
    wa1=wa1+numel(points_a(i).img(1,:));
    points_bb(:,wb1:wb1+numel(points_b(i).img(1,:))-1)=points_b(i).img;
    wb1=wb1+numel(points_b(i).img(1,:));
end
points_aa=points_aa';points_bb=points_bb';

