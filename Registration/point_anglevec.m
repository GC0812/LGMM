function anglevec = point_anglevec(bw, seed, R) 

% This function generate the anglevector that surrounds the seed

[M, N]= size(bw);

% image(i,j) <==>(j-1)*M + i
idy = mod(seed, M); %找分叉点的行数
if (idy==0)
    idy=M;
end
idx = 1 + (seed - idy)/M; %分叉点的列数

if ( idy>R ) && ( idx>R ) && ( (idy+R)<=M ) && ( (idx+R)<=N )
    region = bw(idy-R:idy+R, idx-R:idx+R); %取出以分叉点为中心的一个7*7的区域
    [~, ~] = bwlabel(region,8); %给这个区域内的分叉点标号（有可能有多个）
    % counterclock starts from 3'oclock
    anglevec = [region(R+1:-1:1,end)', region(1, end-1:-1:2), region(1:end,1)', region(end,2:end-1), region(end:-1:R+2,end)']; %区域的边界值，从三点钟方向逆转一周
else
    Len = 8 * R;
    anglevec = zeros(1, Len);
end