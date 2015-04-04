function [outmosaicbw_twice,sae_twice,mytform_twice,flag]=cycle_registration(bw1,bw2)

[featuremat1_3,featuremat1_4,featuremat1_5,loop1_3,loop1_4,loop1_5,linktableoriginal1,bw1] = export_featuremat( bw1 ); %获取环结构及其特征向量
[featuremat2_3,featuremat2_4,featuremat2_5,loop2_3,loop2_4,loop2_5,linktableoriginal2,bw2] = export_featuremat( bw2 );

if isempty(linktableoriginal1) || isempty(linktableoriginal2)
    outmosaicbw_twice(7).data=[];
    sae_twice=11:1:17;
    mytform_twice(7).data=[];
    flag=ones(1,7);%%表示该图没有存在连接关系的点
else
    linktableoriginal1(:,2)=[];linktableoriginal2(:,2)=[];
    linktableoriginal1=linktableoriginal1';linktableoriginal2=linktableoriginal2';%得到环上相邻分叉点的连接关系矩阵
    
    if(~isempty(loop1_3)&&~isempty(loop2_3))
        [P1,P2,Pidx1] = featurematchs(featuremat1_3,featuremat2_3,5);
        matchingpair1(1).points=loop1_3(P1(1),:);matchingpair2(1).points=loop2_3(P2(1),:);%得到最优的3点环匹配对
        if Pidx1(1)~=1
            matchingpair2(1).points=circshift(matchingpair2(1).points, [0, (Pidx1(1)-1)*(3+2)]);
        end
    else
        matchingpair1(1).points=[];matchingpair2(1).points=[];
    end
    if(~isempty(loop1_4)&&~isempty(loop2_4))
        [P3, P4,Pidx2] = featurematchs(featuremat1_4,featuremat2_4,5);
        matchingpair1(2).points=loop1_4(P3(1),:);matchingpair2(2).points=loop2_4(P4(1),:);%得到最优的4点环匹配对
        if Pidx2(1)~=1
            matchingpair2(2).points=circshift(matchingpair2(2).points, [0, (Pidx2(1)-1)*(3+2)]);
        end
    else
        matchingpair1(2).points=[];matchingpair2(2).points=[];
    end
    if(~isempty(loop1_5)&&~isempty(loop2_5))
        [P5, P6,Pidx3] = featurematchs(featuremat1_5,featuremat2_5,5);
        matchingpair1(3).points=loop1_5(P5(1),:);matchingpair2(3).points=loop2_5(P6(1),:);%得到最优的5点环匹配对
        if Pidx3(1)~=1
            matchingpair2(3).points=circshift(matchingpair2(3).points, [0, (Pidx3(1)-1)*(3+2)]);
        end
    else
        matchingpair1(3).points=[];matchingpair2(3).points=[];
    end
       
    %%%环-血管-分叉点配准%%%
    if ~isempty(matchingpair1(1).points) || ~isempty(matchingpair1(2).points) || ~isempty(matchingpair1(3).points)
        [points_bb,points_aa,outbw2,mytform]=cycle_vessel_registration(bw1,bw2,matchingpair1,matchingpair2,linktableoriginal1,linktableoriginal2);%环-血管配准
        [outmosaicbw_twice,sae_twice,mytform_twice,flag]=cycle_twice_registration(bw1,bw2,mytform,outbw2,points_bb,points_aa);%环-血管-分叉点配准
    else
        outmosaicbw_twice(7).data=[];sae_twice=11:1:17;mytform_twice(7).data=[];flag=2*ones(1,7);
    end
end

