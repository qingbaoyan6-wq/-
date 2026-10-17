function [initial_set] = Public_Initial_Solution(initial_set,info,CT,Group_Size,M)
% 本函数用于分配具体的拆卸线序列生成
for ii1=1:Group_Size
    initial_set(ii1,:)=Ushaped_line_uncomplete(info,CT,M); %生成拆卸序列
end
end