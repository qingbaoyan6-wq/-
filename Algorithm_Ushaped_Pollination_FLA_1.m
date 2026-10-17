function [FLA] = Algorithm_Ushaped_Pollination_FLA_1(best_in,worst_in,V,cons)
%FLA算法的代码实现
% 需要注意第一个为更优解（目的地）
% 总零件数/零件编号或索引部分最大长度/零件编号与索引部分的差值
count_mark=0;
r=rand(1);
% 由于导入的序列变成了不完全序列，因此需要先对输入的解进行处理
%% U型线转换
best_in=Algorithm_Ushaped_revive_seq(best_in,best_in(1,V+1),V);
worst_in=Algorithm_Ushaped_revive_seq(worst_in,worst_in(1,V+1),V);
%% 不完全序列处理 
if worst_in(1,V+1)~=V % 当待处理解零件数为V时，显然无需对最优解进行处理
    % 需要对最优解和随机解1,2做改变,确保worst解在优化时不会调换不存在解
    best_in=Algorithm_Straight_Correct(best_in,worst_in,V);
end
%% 进入循环，直至结果序列符合零件约束矩阵
while 1 % 序列合理性判断  

   %% 离散化的FLA算法
   best=best_in;
   worst=worst_in;
   best_seq_length=best(1,V+1); % 检查不同的次数不应该超过最优解或普通解的有效序列长度
   worst_seq_length=worst(1,V+1);
   t=1; % 次数统计
   for ii2=1: min(best_seq_length,worst_seq_length) % 记录所需更换次数
       if worst(1,ii2)~=best(1,ii2) % 两零件编号/零件索引不同
           ex(1,t)=ii2; % 记录下不同的位置，方便下一步处理
           [~,yg]=find(worst==best(1,ii2),1);%确定对应元素的位置
           worst=Algorithm_Straight_sequence_change(ii2,yg,worst);
           t=t+1;
       end
   end
   t=t-1; % 实际处理次数，由于赋值需求需要-1
   T=ceil(r*t); % 序列交换次数=交换系数*交换次数
   if T>t   % 防止交换次数超过需转换次数
       T=t; % 交换次数超过需交换次数时强制相等
   end
   % 开始序列优化
   worst=worst_in;%归还xf原值
   for ii3=1:T
       best_point_parts=best(1,ex(1,ii3));
       loc=worst(1:V)==best_point_parts;
       worst(1,loc)=worst(1,ex(1,ii3));
       worst(1,ex(1,ii3))=best_point_parts;
   end
   %% 检验程序
   judge_point=Straight_matchprocess(worst,worst(1,V+1),cons); % 检查是否符合约束矩阵
   if judge_point==1   % 符合约束矩阵则跳出循环
       break;
   end
   count_mark=count_mark+1; % 记录失败次数
   if count_mark==500 % 为了防止陷入死循环，失败100次则放弃优化
       worst=worst_in;
       break
   end
end
worst=Ushaped_reconstruct_seq(worst,worst(1,V+1));%转换为U型线序列

FLA=worst;
end