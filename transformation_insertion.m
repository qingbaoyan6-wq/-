function [update_set] = transformation_insertion(current_set,p,V)
count_mark=0;
%% U型线转换
sequence=Algorithm_Ushaped_revive_seq(current_set,current_set(1,V+1),V);
copy_sequence=sequence;
%% 直到符合拆卸约束矩阵
% 获取序列长度
sequence_length=sequence(1,V+1); % 存储V+1的数值

while 1
    sequence=copy_sequence;
    sequence(:,V+1)=[];    
    % 从序列中随机选择1个索引
    index = randi(sequence_length);
    % 保存索引处的值
    temp = sequence(index);
    % 去除索引处的值
    sequence(index) = [];  
    % 从序列中随机选择一个插入位置
    insert_index = randi(sequence_length); 
    % 插入数字到选定位置      
    sequence = [sequence(1:insert_index-1), temp, sequence(insert_index:end)];   
    % 返回插入后的序列
    update_set = [sequence,sequence_length];
   %% 检验程序
   judge_point=Straight_matchprocess(update_set,update_set(1,V+1),p); % 检查是否符合约束矩阵
   if judge_point==1   % 符合约束矩阵则跳出循环
       break;
   end
   count_mark=count_mark+1; % 记录失败次数
   if count_mark==100 % 为了防止陷入死循环，失败100次则放弃优化
       update_set=copy_sequence;
       break
   end
    
end
update_set=Ushaped_reconstruct_seq(update_set,update_set(1,V+1));%转换为U型线序列
end