function initial_set=Public_DLBP_Solution(M,It_Time,Group_Size,CT,Alg_Num,origin_file,core_info,Operate_time,memeplex_num,elite_rate)
    % Public_DLBP_Solution DLBP主求解入口
    % 输入：M-目标数, It_Time-迭代次数, Group_Size-种群规模, CT-节拍, Alg_Num-算法编号,
    %       origin_file-原始数据, core_info-零件信息, Operate_time-运行序号,
    %       memeplex_num-子种群数量(可选,默认5), elite_rate-精英保留率(可选,默认0.5)
    if nargin < 10; elite_rate = 0.5; end    % 向后兼容默认精英保留率
    if nargin < 9;  memeplex_num = 5; end   % 向后兼容默认子种群数量
    V=core_info{1,1};   % 零件数量
    V_SEQ=V+1;  % 序列长度

    %% 构建初始解
    initial_set=zeros(Group_Size, V_SEQ+M+2);
    initial_set=Public_Initial_Solution(initial_set,core_info,CT,Group_Size,M); %生成拆卸序列
    initial_set=Public_Nondominated_Sorting(initial_set,M,V_SEQ);
    %% 算法优化迭代
    for It=1:It_Time
        fprintf('正在进行第%d次求解,第%d次迭代,',Operate_time,It);
        tic;
        new_initial_set=Public_Algorithm_Select(initial_set,Alg_Num,core_info,V,M,CT,It,It_Time,memeplex_num,elite_rate);
        initial_set=Public_Elitist_Select(new_initial_set,initial_set,M,V_SEQ,Group_Size,core_info,CT,elite_rate);
        toc;
    end

    initial_set=Public_Nondominated_Sorting(initial_set,M,V_SEQ);
    %% 提取 Pareto 前沿（pareto等级=1）
    pareto_index=initial_set(:,V+M+2)==1;
    initial_set=initial_set(pareto_index,:);
end