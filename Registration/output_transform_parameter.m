function [ mytform,points_in_bw1,points_in_bw2 ] = output_transform_parameter( P1,P2,P3,P4,P5,P6,loop1_3,loop2_3,loop1_4,loop2_4,loop1_5,loop2_5,M,N )

cycle_num=ones(1,3);

if isempty(P1)
    cycle_num(1)=0;
end
if isempty(P3)
    cycle_num(2)=0;
end
if isempty(P5)
    cycle_num(3)=0;
end

mytform.parameter=[];points_in_bw1=[];points_in_bw2=[];
if isempty(find(cycle_num==1, 1))
    return
end

if(cycle_num(1)==1)
        points1 = points_transform(loop1_3(P1(1),:)', [M, N]);
        points2 = points_transform(loop2_3(P2(1),:)', [M, N]);
        points_in_bw1(1).points=points1;
        points_in_bw2(1).points=points2;
        mytform(1).parameter = cp2tform(points2,points1,'similarity');
end
if(cycle_num(2)==1)
        points1 = points_transform(loop1_4(P3(1),:)', [M, N]);
        points2 = points_transform(loop2_4(P4(1),:)', [M, N]);
        points_in_bw1(2).points=points1;
        points_in_bw2(2).points=points2;
        mytform(2).parameter = cp2tform(points2,points1,'similarity');
end
if(cycle_num(3)==1)
        points1 = points_transform(loop1_5(P5(1),:)', [M, N]);
        points2 = points_transform(loop2_5(P6(1),:)', [M, N]);
        points_in_bw1(3).points=points1;
        points_in_bw2(3).points=points2;
        mytform(3).parameter = cp2tform(points2,points1,'similarity');
end
if(cycle_num(1)==1&&cycle_num(2)==1)
        points1 = points_transform(loop1_3(P1(1),:)', [M, N]);
        points2 = points_transform(loop2_3(P2(1),:)', [M, N]);
        points3 = points_transform(loop1_4(P3(1),:)', [M, N]);
        points4 = points_transform(loop2_4(P4(1),:)', [M, N]);
        points_a=[points1' points3']'; points_b=[points2' points4']';
        points_in_bw1(4).points=points_a;
        points_in_bw2(4).points=points_b;
        mytform(4).parameter = cp2tform(points_b,points_a,'similarity');
end
if(cycle_num(1)==1&&cycle_num(3)==1)
        points1 = points_transform(loop1_3(P1(1),:)', [M, N]);
        points2 = points_transform(loop2_3(P2(1),:)', [M, N]);
        points3 = points_transform(loop1_5(P5(1),:)', [M, N]);
        points4 = points_transform(loop2_5(P6(1),:)', [M, N]);
        points_a=[points1' points3']'; points_b=[points2' points4']';
        points_in_bw1(5).points=points_a;
        points_in_bw2(5).points=points_b;       
        mytform(5).parameter = cp2tform(points_b,points_a,'similarity');
end
if(cycle_num(2)==1&&cycle_num(3)==1)
        points1 = points_transform(loop1_4(P3(1),:)', [M, N]);
        points2 = points_transform(loop2_4(P4(1),:)', [M, N]);
        points3 = points_transform(loop1_5(P5(1),:)', [M, N]);
        points4 = points_transform(loop2_5(P6(1),:)', [M, N]);
        points_a=[points1' points3']'; points_b=[points2' points4']';
        points_in_bw1(6).points=points_a;
        points_in_bw2(6).points=points_b;
        mytform(6).parameter = cp2tform(points_b,points_a,'similarity');
end
if(cycle_num(1)==1&&cycle_num(2)==1&&cycle_num(3)==1)
        points1 = points_transform(loop1_3(P1(1),:)', [M, N]);
        points2 = points_transform(loop2_3(P2(1),:)', [M, N]);
        points3 = points_transform(loop1_4(P3(1),:)', [M, N]);
        points4 = points_transform(loop2_4(P4(1),:)', [M, N]);
        points5 = points_transform(loop1_5(P5(1),:)', [M, N]);
        points6 = points_transform(loop2_5(P6(1),:)', [M, N]);
        points_a=[points1' points3' points5']'; points_b=[points2' points4' points6']';
        points_in_bw1(7).points=points_a;
        points_in_bw2(7).points=points_b;
        mytform(7).parameter = cp2tform(points_b,points_a,'similarity');
        
end
                
if numel(mytform)<7 %%当mytform的field数不为7，需要补充位数，只需使第7个为空，其余自动补空
    mytform(7).parameter=[];
end
