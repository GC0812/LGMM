function [points_bb,points_aa,outbw2,mytform]= cycle_vessel_registration(bw1,bw2,matchingpair1,matchingpair2,linktableoriginal1,linktableoriginal2)

%%基于环-血管特征点的初次配准%%

M=[3 4 5];outbw1=bw1;

for i=1:3
    if ~isempty(matchingpair1(i).points) && ~isempty(matchingpair2(i).points)
        [points_bb(i).points,points_aa(i).points]=featurepoints_extraction(bw1,bw2,matchingpair1(i).points,matchingpair2(i).points,linktableoriginal1,linktableoriginal2,M(i));   
        mytform(i).cycle=cp2tform(points_bb(i).points,points_aa(i).points,'similarity');        
    end
end

if numel(points_bb)<3
    points_bb(3).points=[];
    points_aa(3).points=[];
end

if ~isempty(points_bb(1).points) && ~isempty(points_bb(2).points)
    points_bb(4).points=[points_bb(1).points;points_bb(2).points];
    points_aa(4).points=[points_aa(1).points;points_aa(2).points];
    mytform(4).cycle=cp2tform(points_bb(4).points,points_aa(4).points,'similarity');
else
    points_aa(4).points=[];points_bb(4).points=[];
    mytform(4).cycle=[];
end

if ~isempty(points_bb(1).points) && ~isempty(points_bb(3).points)
    points_bb(5).points=[points_bb(1).points;points_bb(3).points];
    points_aa(5).points=[points_aa(1).points;points_aa(3).points];
    mytform(5).cycle=cp2tform(points_bb(5).points,points_aa(5).points,'similarity');
else 
    points_aa(5).points=[];points_bb(5).points=[];
    mytform(5).cycle=[];
end

if ~isempty(points_bb(2).points) && ~isempty(points_bb(3).points)
    points_bb(6).points=[points_bb(2).points;points_bb(3).points];
    points_aa(6).points=[points_aa(2).points;points_aa(3).points];
    mytform(6).cycle=cp2tform(points_bb(6).points,points_aa(6).points,'similarity');
else 
    points_aa(6).points=[];points_bb(6).points=[];
    mytform(6).cycle=[];
end

if ~isempty(points_bb(1).points) && ~isempty(points_bb(2).points) && ~isempty(points_bb(3).points)
    points_bb(7).points=[points_bb(1).points;points_bb(2).points;points_bb(3).points];
    points_aa(7).points=[points_aa(1).points;points_aa(2).points;points_aa(3).points];
    mytform(7).cycle=cp2tform(points_bb(7).points,points_aa(7).points,'similarity');
else 
    points_aa(7).points=[];points_bb(7).points=[];
    mytform(7).cycle=[];
end
    
for j=1:7
    if ~isempty(mytform(j).cycle)
        outbw2(j).cycle=imtransform(bw2, mytform(j).cycle, 'XData', [1 size(outbw1,2)], 'YData', [1 size(outbw1,1)]);
    else
        outbw2(j).cycle=[];
    end
end

