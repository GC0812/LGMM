function [points_bb,points_aa]=featurepoints_extraction(bw1,bw2,matchingpair1,matchingpair2,linktableoriginal1,linktableoriginal2,M)

%提取环-血管特征点%

[M1,N1]=size(bw1);
[M2,N2]=size(bw2);

if M==3
    no=[1 2 3 4 5 6];
    no1=[1 3 5];
elseif M==4
    no=[1 2 3 4 5 6 7 8];
    no1=[1 3 5 7];
else
    no=[1 2 3 4 5 6 7 8 9 10];
    no1=[1 3 5 7 9];
end
count=1;
A=matchingpair1;
B=matchingpair2;

%%%%%%%%环结构的分叉点特征点%%%%%%
pointsa1 = points_transform(A', [M1, N1]);  %由序号转化为坐标   
pointsa2 = points_transform(B', [M2, N2]);

points_a(count).img=pointsa1';points_b(count).img=pointsa2';
count=count+1;

%%%%%%%%寻找与环相连的血管上的点及末梢分叉点%%%%%%% 

%%判断两幅图像与环相连的血管末梢是否都有分叉点，并把都有分叉点的序号输出
externalbifu1=zeros(2,M);externalbifu2=zeros(2,M);cyclebifu1=zeros(5,M);cyclebifu2=zeros(5,M);
for i=1:M
    cyclebifu1(:,i)=linktableoriginal1(:,linktableoriginal1(1,:)==A(:,i));%环上每一个分叉点的相邻分叉点序列
    cyclebifu2(:,i)=linktableoriginal2(:,linktableoriginal2(1,:)==B(:,i));
end

%%由连接关系将环上的点重新排序
cycle1=zeros(1,M);cycle1(1)=A(1);l=2;seq1=zeros(1,M);
cycle2=zeros(1,M);cycle2(1)=B(1);h=2;seq2=zeros(1,M);
for i=1:M-1
    for j=1:M
        if  cyclebifu1(1,j)==cycle1(i) || (i>1 && cyclebifu1(1,j)==cycle1(i-1))
            continue;
        end
        cycle_no1=find(cyclebifu1(:,j)==cycle1(i), 1);
        if ~isempty(cycle_no1)
            cycle1(l)=cyclebifu1(1,j);
            l=l+1;
            break;
        end
    end
    for k=1:M
        if  cyclebifu2(1,k)==cycle2(i) || (i>1 && cyclebifu2(1,k)==cycle2(i-1))
            continue;
        end
        cycle_no2=find(cyclebifu2(:,k)==cycle2(i), 1);
        if ~isempty(cycle_no2)
            cycle2(h)=cyclebifu2(1,k);
            h=h+1;
            break;
        end
    end
end
for i=1:M
    seq1(i)=find(A==cycle1(i)); %给出环的正确连接顺序
    seq2(i)=find(B==cycle2(i)); 
end

cyclebifu1=cyclebifu1(:,seq1);A=A(seq1);%将环分叉点按逐次相连的顺序重新排序
cyclebifu2=cyclebifu2(:,seq2);B=B(seq2);

points_a(count-1).img=points_a(count-1).img(:,seq1);
points_b(count-1).img=points_b(count-1).img(:,seq2);


for i=1:M
    externalbifu1(:,i)=setdiff(cyclebifu1(:,i),A);%每个环上4个点的外接分叉点
    externalbifu2(:,i)=setdiff(cyclebifu2(:,i),B);
end
order1=find(externalbifu1~=0);
order2=find(externalbifu2~=0);
externalorder=intersect(order1,order2);%两幅图像都有外接分叉点的序号

%%得到环上分叉点的正确连接顺序并求出环每条边的像素长度

% loop=[2:1:M 1];
% length1=zeros(1,M);length2=zeros(1,M);
% sequence1(M).cycle=[];sequence2(M).cycle=[];
% for i=1:M
%     [length1(i), sequence1(i).cycle]=pixelcounting2(bw1,cyclebifu1(:,i),A(loop(i)));
%     [length2(i), sequence2(i).cycle]=pixelcounting2(bw2,cyclebifu2(:,i),B(loop(i)));
% end
% edgeratio=(sum(length1)-M)/(sum(length2)-M);%计算对应环的缩放比例(计算环的四个分叉点时有重复)


%%判断都有分叉点的图像的分叉点是否对应
n=1;bifuorder=0;R=3;
for i=1:numel(externalorder)
    anglevec1=point_anglevec(bw1, externalbifu1(externalorder(i)), R);
    outangle1=findangle(anglevec1);%每个外接分叉点的角度
    anglevec2=point_anglevec(bw2, externalbifu2(externalorder(i)), R);
    outangle2=findangle(anglevec2);
    if numel(outangle1)==numel(outangle2)
        diffangle=outangle1-outangle2;
    else diffangle=100;
    end
    anglerror=sum(abs(diffangle))/numel(outangle1);%角度的平均误差    
    if any(diffangle==0) && numel(unique(abs(diffangle)))<=2 && anglerror<11.4%%好像有对应的分叉点会出现这种情况
        bifuorder(n)=externalorder(i);n=n+1;%有对应的外接分叉点的序号
    end
end
order3=setdiff(no,bifuorder);
order4=union(no1(externalbifu1(1,:)==0),no1(externalbifu2(1,:)==0));
vesselorder=setdiff(order3,order4);

%%对有对应分叉点的环求血管及外接分叉点作为特征点
invalidnum=[];
if bifuorder~=0
    for i=1:numel(bifuorder)
        [pixelnuma1(i), sequencea1(i).points]=pixelcounting2(bw1,cyclebifu1(:,ceil(bifuorder(i)/2)),externalbifu1(bifuorder(i)));
        [pixelnuma2(i), sequencea2(i).points]=pixelcounting2(bw2,cyclebifu2(:,ceil(bifuorder(i)/2)),externalbifu2(bifuorder(i)));
    end
    if ~isempty(find(~isnan(pixelnuma1(:))==0, 1)) || ~isempty(find(~isnan(pixelnuma2(:))==0, 1)) %如果计算环边长度有误，去掉此点
        invalidnum=[find(isnan(pixelnuma1(:))==1); find(isnan(pixelnuma2(:))==1)];
        pixelnuma1(invalidnum)=[];
        pixelnuma2(invalidnum)=[];
        sequencea1(invalidnum)=[];
        sequencea2(invalidnum)=[];
    end
    midpointsa1=zeros(1,numel(bifuorder)-numel(invalidnum));midpointsa2=zeros(1,numel(bifuorder)-numel(invalidnum));
    coordmidpointsa1=zeros(numel(bifuorder)-numel(invalidnum),2);coordmidpointsa2=zeros(numel(bifuorder)-numel(invalidnum),2);
    coordbifua1=zeros(numel(bifuorder)-numel(invalidnum),2);coordbifua2=zeros(numel(bifuorder)-numel(invalidnum),2);

    for i=1:numel(pixelnuma1)
        midpointsa1(i)=sequencea1(i).points(round(pixelnuma1(i)/2)+1);%求出血管的中点的序号
        midpointsa2(i)=sequencea2(i).points(round(pixelnuma2(i)/2)+1);
        coordmidpointsa1(i,:)=points_transform(midpointsa1(i)',[M1, N1]);%中点的坐标
        coordmidpointsa2(i,:)=points_transform(midpointsa2(i)',[M1, N1]);
        coordbifua1(i,:)=points_transform(externalbifu1(bifuorder(i))',[M1, N1]);%血管外接分叉点的坐标
        coordbifua2(i,:)=points_transform(externalbifu2(bifuorder(i))',[M1, N1]);
    end  
    pointsb1=[coordmidpointsa1;coordbifua1];
    pointsb2=[coordmidpointsa2;coordbifua2];
    points_a(count).img=pointsb1';points_b(count).img=pointsb2';
    count=count+1;
end

%血管求末梢处（包括分叉点）、1/2处的特征点（包含均有分叉点但不对应；只有一个有分叉点；两个均没分叉点的情况）
invalidnum=[];
if vesselorder~=0
    for i=1:numel(vesselorder)
        [pixelnumb1(i), sequenceb1(i).points]=pixelcounting2(bw1,cyclebifu1(:,ceil(vesselorder(i)/2)),externalbifu1(vesselorder(i)));
        [pixelnumb2(i), sequenceb2(i).points]=pixelcounting2(bw2,cyclebifu2(:,ceil(vesselorder(i)/2)),externalbifu2(vesselorder(i)));
    end
    edgeratio=1;
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
        if pixelnumb1(i)<edgeratio*pixelnumb2(i)
            midpointsb1(i)=sequenceb1(i).points(round(pixelnumb1(i)/2)+1);
            midpointsb2(i)=sequenceb2(i).points(round(pixelnumb1(i)/2/edgeratio)+1);
            vesselendingb1(i)=sequenceb1(i).points(end);
            vesselendingb2(i)=sequenceb2(i).points(round((pixelnumb1(i))/edgeratio));
        else
            midpointsb1(i)=sequenceb1(i).points(round(pixelnumb2(i)/2*edgeratio)+1);
            midpointsb2(i)=sequenceb2(i).points(round(pixelnumb2(i)/2)+1);
            vesselendingb1(i)=sequenceb1(i).points(round((pixelnumb2(i))*edgeratio));
            vesselendingb2(i)=sequenceb2(i).points(end);
        end
        coordmidpointsb1(i,:)=points_transform(midpointsb1(i)',[M1, N1]);%中点的坐标
        coordmidpointsb2(i,:)=points_transform(midpointsb2(i)',[M1, N1]);
        coordvesselendingb1(i,:)=points_transform(vesselendingb1(i)',[M1, N1]);
        coordvesselendingb2(i,:)=points_transform(vesselendingb2(i)',[M1, N1]);
    end
    pointsc1=[coordmidpointsb1;coordvesselendingb1];
    pointsc2=[coordmidpointsb2;coordvesselendingb2];
    points_a(count).img=pointsc1';points_b(count).img=pointsc2';
    count=count+1;
end

%%%%%最终的特征点%%%%%%%%%%%
points_aa(:,1:numel(points_a(1).img(1,:)))=points_a(1).img;
points_bb(:,1:numel(points_b(1).img(1,:)))=points_b(1).img;
wa1=1+numel(points_a(1).img(1,:));wb1=1+numel(points_b(1).img(1,:));
for i=2:count-1
    points_aa(:,wa1:wa1+numel(points_a(i).img(1,:))-1)=points_a(i).img;
    wa1=wa1+numel(points_a(i).img(1,:));
    points_bb(:,wb1:wb1+numel(points_b(i).img(1,:))-1)=points_b(i).img;
    wb1=wb1+numel(points_b(i).img(1,:));
end
points_aa=points_aa';points_bb=points_bb';

