function [outmosaicbw_twice,sae_twice,mytform_twice,flag]=cycle_twice_registration(bw1,bw2,mytform,outbw2,points_bb,points_aa,ptbifu1,ptbifu2)

%%基于环-血管-分叉点特征点的二次配准%%

flag=zeros(1,7);
bw2_num=numel(find(bw2==1));
outmosaicbw_twice(7).data=[];mytform_twice(7).data=[];sae_twice=10*ones(1,7);
for i=1:7
    if isempty(points_bb(i).points) || isempty(points_aa(i).points)
        flag(i)=3;
    else
        R=5;
        [reference_points,transformed_points]=find_local_regis_points(bw1,outbw2(i).cycle,ptbifu1,R);%得到局部未配准的特征点
        if(isempty(transformed_points))
            sae_twice(i)=saem(bw1,outbw2(i).cycle,bw2_num);
            outmosaicbw_twice(i).data=1-cat(3,bw1,outbw2(i).cycle,outbw2(i).cycle);
            mytform_twice(i).data=[];
            flag(i)=4;
            continue;
        else
            [new_corresponding_points]=find_original_corresponding(bw2,ptbifu2,mytform(i).cycle,transformed_points);%由outbw2得到bw2对应的局部特征点
            
            reference = [reference_points;points_aa(i).points]; %与初始特征点集集合在一起
            transform = [new_corresponding_points;points_bb(i).points];
            mytform_twice(i).data = cp2tform(transform,reference,'similarity');
            
            outbw2_twice = imtransform(bw2, mytform_twice(i).data, 'XData', [1 size(bw1,2)], 'YData', [1 size(bw1,1)]);
            outmosaicbw_twice(i).data = 1-cat(3,bw1,outbw2_twice,outbw2_twice);
            sae_twice(i)=saem(bw1,outbw2_twice,bw2_num);
        end
    end
end


