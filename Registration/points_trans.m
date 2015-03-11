function [points1,points2] = points_trans(bw1_refine,bw2_refine, loop1,loop2,matches)

K = size(matches, 2) ;
[M1,N1]=size(bw1_refine);
[M2,N2]=size(bw2_refine);

P1=matches(1,:);
P2=matches(2,:);
n=1;m=1;
for i=1:K
   points1(n,:)=loop1(P1(i),:);
   n=n+1;
end
for i=1:K
   points2(m,:)=loop2(P2(i),:);
   m=m+1;
end

x1 = mod(points1, M1);
x1(x1==0) = M1; 
y1 = 1 + (points1-x1)/M1;
x1=x1';
y1=y1';
points1=[reshape(x1,1,size(x1,1)*size(x1,2));reshape(y1,1,size(y1,1)*size(y1,2))];


x2 = mod(points2, M2); 
x2(x2==0) = M2; 
y2 = 1 + (points2-x2)/M2;

points1=[reshape(x1,1,size(x1,1)*size(x1,2));reshape(y1,1,size(y1,1)*size(y1,2))];

