function [update_set] = transformation_right_reconstruction(current_set,p,V)
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
    % 从序列中随机选择1个重构分割点
    index = randi(sequence_length - 3); %保证右侧至少要有三个序列重构
    % 后部分
    prefix = sequence(index:sequence_length);
    % 随机打乱后部分
    shuffled_prefix = prefix(randperm(length(prefix)));
    % 需要添加零矩阵
    zero_matrix = zeros(1,V-sequence_length);
    % 合并前部分和后部分
    shuffled_sequence = [sequence(1:index-1),shuffled_prefix,zero_matrix];
    % 返回插入后的序列
    update_set = [shuffled_sequence,sequence_length];

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