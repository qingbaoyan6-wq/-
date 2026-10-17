function [child_sequence] = Algorithm_Ushaped_merge(M1_stable, M2_stable,info)
% MERGE_2007: 交叉用函数
% 读取零件数量
V=info{1,1};
% 读取约束矩阵
p=info{1,4};

M1_stable=Algorithm_Ushaped_revive_seq(M1_stable,M1_stable(1,V+1),V);
M2_stable=Algorithm_Ushaped_revive_seq(M2_stable,M2_stable(1,V+1),V);

M1=M1_stable(1,1:V);
M2=M2_stable(1,1:V);
V1=M1_stable(1,V+1);
V2=M2_stable(1,V+1);
child_mark=zeros(1,V);
% 子代序列初始化

count_mark=1;

while 1
    M1=M1_stable(1:V);
    M2=M2_stable(1:V);
    child_mark=zeros(1,V);
% 子代序列初始化
    for jj1=1:V
        random_sequence= ceil(2*rand(1));
        child_mark(1,jj1)=random_sequence;
    end
    child_sequence=zeros(1,V);
    time=min(V1,V2);
    for ii1=1:time
        if  child_mark(1,ii1)==1
            % 说明走M1
            temp_part=M1(1,ii1);
            % 要考察一下这个元素是不是已经装填了
            if temp_part~=0
               % 说明对应的父代序列的  对应位置 没有给装填过
                child_sequence(1,ii1)=temp_part;               
                M1(M1==temp_part)=0;
                M2(M2==temp_part)=0;
            elseif temp_part==0                
                % 找到对应的爹的非0元素的索引
                first_non_zero_index=find(M1~=0,1,'first');
                temp_part1=M1(1, first_non_zero_index);
                child_sequence(1,ii1)=temp_part1;
                M1(M1==temp_part1)=0;
                M2(M2==temp_part1)=0;
            end            
            
        elseif child_mark(1,ii1)==2
            temp_part=M2(1,ii1);
            if temp_part~=0
               % 说明对应的父代序列的  对应位置 没有给装填过
                child_sequence(1,ii1)=temp_part;               
                M1(M1==temp_part)=0;
                M2(M2==temp_part)=0;
            elseif temp_part==0
                % 找到对应爹的非0元素的索引
                first_non_zero_index=find(M2~=0,1,'first');
                temp_part1=M2(1, first_non_zero_index);
                child_sequence(1,ii1)=temp_part1;
                M1(M1==temp_part1)=0;
                M2(M2==temp_part1)=0;
            end
        end                
    end %每个位的录入    
    NO=Straight_matchprocess(child_sequence,time,p);
    if NO==1
        break;
    end
    count_mark=count_mark+1;
    if count_mark==1000
        child_sequence(1,1:V)=M1_stable(1,1:V);
        break
        % 如果不这样弄，可能会非常非常慢！！
    end
end
child_sequence(1,V+1)=time;
child_sequence=Ushaped_reconstruct_seq(child_sequence,child_sequence(1,V+1));%转换为U型线序列
end

