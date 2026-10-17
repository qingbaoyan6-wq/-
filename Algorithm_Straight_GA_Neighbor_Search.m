function [temp_seq]=Algorithm_Straight_GA_Neighbor_Search(origin_Set,V,info)
% 双重领域搜索(交换)

p=info{1,4};    % 读取约束矩阵
time=origin_Set(1,V+1);
sequence=zeros(1,V+8);
sequence(1,1:time)=origin_Set(1,1:time);
NO=0;
ct=1;
while NO==0
temp_seq=sequence;
    while 1
    rp1=ceil(time*rand(1));
    rp2=ceil(time*rand(1));
        if (rp1~=rp2)&&(rp1<time)&&(rp2<time)
         break;  
        end  
    end
    % 交换位置
    part1=temp_seq(1,rp1);
    temp_seq(1,rp1)=temp_seq(1,rp2);
    temp_seq(1,rp2)=part1;
    NO=Straight_matchprocess(temp_seq,time,p);
    if ct==1000
        temp_seq(1,1:V)=origin_Set(1,1:V);
        break;
    end
    ct=ct+1;
end
temp_seq(1,1+V)=time;
end

