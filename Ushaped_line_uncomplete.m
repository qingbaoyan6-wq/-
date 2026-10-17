function [seq]=Ushaped_line_uncomplete(info_mix,CT,M)
%% 参数设置

% 读取零件数量
V=info_mix{1,1};
% 读取零件信息
dis=info_mix{1,2};
% 读取需求零件
need_parts=info_mix{1,3};
% 读取约束矩阵
p=info_mix{1,4};
% 读取危害零件
hazard_parts=info_mix{1,5};
% 记录剩余零件
B=1:V; 
local_parts_num=1;      % 记录本次拆卸拆去的零件总数，可能需要记入拆卸序列中
seq=zeros(1,V);

%% 序列生成
while isempty(need_parts)==0 % 判断需要拆卸的零件是否已经全部拆卸完成
    %% 登记可拆卸零件
    A=[]; % 存当前产品1可拆的零件的
    remain_part=length(B);
    k=0; % 产品1可拆零件记数
    % 登记可拆卸零件
    for ii1=1:remain_part
        temp_part=B(1,ii1);
        if  p(:,temp_part)==0 % 此零件不被约束，说明可拆
            A(1,k+1)=temp_part; 
            k=k+1;
        end
    end
    %% 依次分配拆卸序列
    % 分配拆卸序列
    random_part_index=unidrnd(length(A));
    temp_part=A(1,random_part_index);% 从当前可拆的随机挑一个出来
    B(B==temp_part)=[]; % 从剩余零件组中消去
    if find(need_parts==temp_part)~=0
        need_parts(need_parts==temp_part)=[];
    end
    p(temp_part,:)=0; % 更新p矩阵
    seq(1,local_parts_num)=temp_part; % 归档零件编号
    local_parts_num=local_parts_num+1;
    % 不完全拆卸需要做到的：分别提取出来自产品1和产品2的零件编号，分别依次与需求矩阵进行对比，如果存在缺少情况则再拆卸一个零件
    % PS:到这里的seq是一个两行*零件数的矩阵，ii1往后的列数全部为0，应当将ii1传入下一步函数
end
local_parts_num=local_parts_num-1; % 去除最后一个零件拆出后ii1多增加的一位
%% 多目标优化准备
% 生成带时间和方向的拆卸序列
seq=Ushaped_reconstruct_seq(seq,local_parts_num);
% full_sequence=zeros(8,V);%新增一列带危害性
% full_sequence(1,:)=seq(1,:);
% for ii1=1:local_parts_num
%     location=abs(seq(1,ii1));
%     full_sequence(2:8,ii1)=dis(2:8,location);
% end
seq=U_objective_function(seq,info_mix,M,CT);  %U型目标函数赋值
% seq=Straight_objective_function(full_sequence,local_parts_num,V,M,CT);%目标函数赋值,与直线型共用
end