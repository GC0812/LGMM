function [error]=saem(bw1,outbw2,bw2_num)

%%%计算配准结果的skeleton alignment error%%%

num1=find(bw1==1);
num2=find(outbw2==1);
m2=numel(num2);

[M1,~]=size(bw1);
[M2,N2]=size(outbw2);

mdirect1=mod(num1,M1);       %序号对应的纵坐标
mdirect1(mdirect1==0)=M1;
ndireb1=1+(num1-mdirect1)/M1;%序号对应的横坐标

mdirect2=mod(num2,M2);       %序号对应的纵坐标
mdirect2(mdirect2==0)=M2;
ndireb2=1+(num2-mdirect2)/M2;%序号对应的横坐标

bw1_coord=[mdirect1 ndireb1]; %bw1对应的横纵坐标
outbw2_coord=[mdirect2 ndireb2];

[bw1_no,distance]=knnsearch(bw1_coord,outbw2_coord,'k',1,'distance','euclidean');%计算离outbw2上每一个点最近的bw1上的点

averagerror=sum(distance)/m2;
N=fix(averagerror)+1;
if N>3
    N=3;
end
error_all=zeros(1,m2);
k2=0;k3=1;

num_matrix=zeros(M2,N2);
for i=1:M2*N2
    num_matrix(i)=i;
end
for i=1:m2
    if  mdirect2(i)>N && ndireb2(i)>N && (mdirect2(i)+N)<=M2 && (ndireb2(i)+N)<=N2
        squaregionb=num_matrix(mdirect2(i)-N:mdirect2(i)+N,ndireb2(i)-N:ndireb2(i)+N);
        squaregionb=squaregionb(:);
    else
        squaregionb=num2(i)-N-N*M2:1:num2(i)-N-N*M2+2*N;
        for k=2:2*N+1
            squaregionb=[squaregionb num2(i)-N-N*M2+M2*(k-1):1:num2(i)-N-N*M2+M2*(k-1)+2*N];%%最大7x7的矩形区域
        end
    end
    outelement=intersect(num1(bw1_no(i)),squaregionb(:));
    if isempty(outelement)
        k2=k2+1; %无效点数
    else
        error_all(k3)=distance(i);
        k3=k3+1;
    end
end

effective_rate=(m2-k2)/m2;
if effective_rate>0.5 && m2/bw2_num>0.38 %%正确的误差需要满足一定条件
    error=sum(error_all)/(m2-k2);
else
    error=13;
end

