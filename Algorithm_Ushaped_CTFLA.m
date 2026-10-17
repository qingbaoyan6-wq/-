function [update_pop] = Algorithm_Ushaped_CTFLA(origin_pop,info,V,M,CT,It,It_Time,memeplex_num,elite_rate)
% CTFLA 细胞策略 
% 新增参数：memeplex_num-子种群数量(默认5), elite_rate-精英保留率(默认0.5)
if nargin < 10; elite_rate = 0.5; end   % 向后兼容默认精英保留率50%
if nargin < 9;  memeplex_num = 5; end   % 向后兼容默认子种群数量5
update_pop=zeros(1,V+1);
[group_size,~]=size(origin_pop);
NS=floor(group_size/memeplex_num);  % 每个子种群内的个体数 = 种群规模/子种群数量
K=memeplex_num;                      % 模因组数量 = 子种群数量
if mod(group_size, memeplex_num) ~= 0
    error('种群规模 %d 必须能被子种群数量 %d 整除！', group_size, memeplex_num);
end
p=info{1,4};
dis=info{1,2};
origin_pop(:,V+2:V+M+3)=[];%去除后面的目标函数和帕累托值
%% 先对小种群的个体进行优化
for i3=12:39
    if i3==20||i3==21||i3==30||i3==31
        break;
    end
    selected_rows = [i3-11,i3-10,i3-9,i3-1,i3,i3+1,i3+9,i3+10,i3+11];%行索引
    F = origin_pop(selected_rows, :);   
    F=[F zeros(9,7)];
    for ii4=1:9
%         F(ii4,:)=Algorithm_Straight_Gift_Obj(F(ii4,:),info,M,CT);
        F(ii4,:)=U_objective_function(F(ii4,:),info,M,CT);
    end
    F = Public_Nondominated_Sorting(F, M, V+1);
    F(:,V+2:V+M+3)=[];%去除后面的目标函数和帕累托值
  %F_Best=F(1,:);
    %     F1=F(2,:); %左上
    %     F2=F(3,:); %正上
    %     F3=F(4,:); %右上
    %     F4=F(5,:); %左
    %     F6=F(6,:); %右
    %     F7=F(7,:); %左下
    %     F8=F(8,:); %正下
    %     F9=F(9,:); %右下
    %% 开始九宫格内个体交流与进化
    % 初始化变换方式表现计数
    performance = ones(1, 4);
    for i4=1:9
        rows = [i3,i3-11,i3-10,i3-9,i3-1,i3+1,i3+9,i3+10,i3+11];
        for ii2 = 1:4
            % 计算当前变换方式的被选中概率
            probability = performance(ii2) / sum(performance);
            % 生成0到1之间的随机数
            rand_num = rand();
            % 如果随机数小于等于概率，则选中该变换方式
            if rand_num <= probability
               % 根据选中的变换方式对当前解进行变换
               new_solution = Algorithm_Ushaped_IMOBFO_Dispersion(F(i4,:),p,V,ii2);
               % 比较新旧解的适应度值
               fit = comparison_fitness(F(i4,:),new_solution,info,V,M,CT);
               % 如果新解的适应度值优于初始解，则更新表现计数
               if fit==0
                  performance(ii2) = performance(ii2) + 1;
                  F(i4,:)=new_solution;
                  origin_pop(rows(1,i4),:)=new_solution;
               end
            end
        end
        if i4==1
            F=[F zeros(9,7)];
            for iii4=1:9
                F(iii4,:)=U_objective_function(F(iii4,:),info,M,CT);
%                 F(iii4,:)=Algorithm_Straight_Gift_Obj(F(iii4,:),info,M,CT);
            end
            F = Public_Nondominated_Sorting(F, M, V+1);
            F(:,V+2:V+M+3)=[];%去除后面的目标函数和帕累托值
            F_Best=F(1,:);
            F_data_1=F_Best; % PPX交叉产生新个体
            F_data_2=F_Best; % PPX交叉产生新个体
        else
            F_data_1=Algorithm_Ushaped_merge(F_Best,F(i4,:),info); % PPX交叉产生新个体
            F_data_2=Algorithm_Ushaped_merge(F(i4,:),F_Best,info); % PPX交叉产生新个体
        end              
        mix_data=[F_Best;F_data_1;F_data_2;F(i4,:)];
        mix_data=[mix_data zeros(4,7)];
        for i11=1:4
            mix_data(i11,:)=U_objective_function(mix_data(i11,:),info,M,CT);
%             mix_data(i11,:)=Algorithm_Straight_Gift_Obj(mix_data(i11,:),info,M,CT);
        end
        mix_data=Public_Nondominated_Sorting(mix_data, M, V+1);
        mix_data(:,V+2:V+M+3)=[];%去除后面的目标函数和帕累托值
        F_Best = mix_data(1,:);
        F(i4,:) = mix_data(2,:);
        origin_pop(rows(1,i4),:)= mix_data(2,:);
        origin_pop(i3,:) = mix_data(1,:);     
%         fit= comparison_fitness(F_Best,F_data,info,V,M,CT);
        % 如果新解的适应度值优于初始解，则更新表现计数
%         if fit==0
%             F_Best=F_data;
% %             F_data=[F_data zeros(1,7)];
% %             F_data=Algorithm_Straight_Gift_Obj(F_data,info,M,CT);
%             origin_pop(i3,:)=F_data;
%         end
    end
end
origin_pop=[origin_pop zeros(group_size,7)];
for iiii4=1:group_size
    origin_pop(iiii4,:)=U_objective_function(origin_pop(iiii4,:),info,M,CT);
%     origin_pop(iiii4,:)=Algorithm_Straight_Gift_Obj(origin_pop(iiii4,:),info,M,CT);
end
origin_pop=Public_Nondominated_Sorting(origin_pop, M, V+1);

%% 移除了旧版的 elite_rate 内部替换逻辑（已移至外层 Public_Elitist_Select）
origin_pop(:,V+2:V+M+3)=[]; % 去除后面的目标函数和帕累托值
%% FLA  —— 模因组划分 + 进化（已改为动态 cell 数组，支持任意 memeplex_num）
% --- 模因组划分阶段：从排序后的种群中等间隔抽取 K 个子种群，每个子种群 NS 个个体 ---
subpop = cell(1, K);                       % 用 cell 数组动态创建 K 个子种群
for i1 = 1:NS                              % 每个子种群内的 NS 个个体
    for k = 1:K                            % K 个子种群等间隔取样：间隔为 K
        subpop{k}(i1, :) = origin_pop(k + (i1-1)*K, :);
    end
end

% --- 模因组进化阶段 ---
for i6 = 1:K                               % 遍历每个子种群
    P_gbest = origin_pop(1, :);            % 全局最优解（origin_pop 已按非支配排序）
    current_subpop = subpop{i6};           % 取出当前子种群（替代原来的 eval(['subpop_',num2str(i6)])）
    P_best = current_subpop(1, :);          % 当前子种群内最优
    for i7 = 2:NS                          % 从第 2 个个体开始遍历子种群内所有个体
        P_worst = current_subpop(i7, :);
        current_worst = P_worst;           % 记录原始个体供后续比较
        P_worst = Algorithm_Ushaped_Pollination_FLA_1(P_best, P_worst, V, p); % FLA 第一阶段
        % 新旧解适应度比较
        mix_data = [P_worst; current_worst];
        mix_data = [mix_data zeros(2, 7)];
        for i8 = 1:2
            mix_data(i8, :) = U_objective_function(mix_data(i8, :), info, M, CT);
        end
        mix_data = Public_Nondominated_Sorting(mix_data, M, V+1);
        mix_data(:, V+2:V+M+3) = [];
        P_worst = mix_data(1, :);
        result_1 = isequal(P_worst, current_worst);
        if result_1
            P_worst = Algorithm_Ushaped_Pollination_FLA_2(P_gbest, P_worst, V, p); % FLA 第二阶段
            mix_data = [P_worst; current_worst];
            mix_data = [mix_data zeros(2, 7)];
            for i9 = 1:2
                mix_data(i9, :) = U_objective_function(mix_data(i9, :), info, M, CT);
            end
            mix_data = Public_Nondominated_Sorting(mix_data, M, V+1);
            mix_data(:, V+2:V+M+3) = [];
            P_worst = mix_data(1, :);
            result_2 = isequal(P_worst, current_worst);
            if result_2
                random_set = zeros(1, V+1);
                random_set = Ushaped_line_uncomplete(info, CT, M);
                random_set(:, V+2:V+M+3) = [];
                current_subpop(i7, :) = random_set;
            else
                current_subpop(i7, :) = P_worst;
            end
        else
            current_subpop(i7, :) = P_worst;
        end
    end
    update_pop = [update_pop; current_subpop];
end
%% 合并子集
update_pop(1,:)=[];
% update_pop=[ ;subpop_2;subpop_3;subpop_4;subpop_5];
[m,~]=size(update_pop); % 提取解的总数
update_pop=[update_pop zeros(m,7)];
for i10=1:m % 为生成的新解集赋予目标函数值
%     update_pop(i10,:)=Algorithm_Straight_Gift_Obj(update_pop(i10,:),info,M,CT);
    update_pop(i10,:)=U_objective_function(update_pop(i10,:),info,M,CT);
end

end