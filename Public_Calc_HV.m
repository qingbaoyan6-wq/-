function hv = Public_Calc_HV(pareto_set, Rref, V, M)
% Public_Calc_HV 从 Pareto 解集矩阵中计算 Hypervolume 超体积指标
% 输入：pareto_set - Pareto 解集矩阵（每行一个解，列结构：[序列(1..V),零件数(V+1),目标(V+2..V+1+M),Pareto等级,拥挤度]）
%       Rref      - HV 参考点向量，长度=M（各目标上界）
%       V         - 零件数量（用于定位目标函数列）
%       M         - 优化目标数
% 输出：hv        - 超体积值；若解集为空返回 0 并打印警告
% 说明：目标 f5（拆卸利润）已在 U_objective_function 中取负转为最小化。
%       但 HV 参考点 Rref 的 f5 分量（如 500）是**原始正值空间的上界**，
%       因此此处必须将 f5 取负恢复到正值空间，保证 Pareto 前沿与参考点
%       处于同一符号空间，否则 f5 维度跨度会膨胀 ≈3 倍导致 HV 严重偏大。
%       其余目标 f1~f4 均为最小化且数值直接使用，无需额外变换。

    if isempty(pareto_set) || size(pareto_set,1) == 0
        warning('[Public_Calc_HV] Pareto 解集为空，HV 赋值为 0');
        hv = 0;
        return;
    end

    obj_matrix = pareto_set(:, V+2 : V+1+M);
    obj_matrix(:, M) = -obj_matrix(:, M);

    % 过滤被支配解，仅保留非支配解传入 HV 计算（保险机制）
    nondom_idx = filter_nondominated(obj_matrix);
    obj_matrix = obj_matrix(nondom_idx, :);

    if size(obj_matrix,1) == 0
        warning('[Public_Calc_HV] 过滤后无有效非支配解，HV 赋值为 0');
        hv = 0;
        return;
    end

    % Drawing_HI_approximate_hypervolume 要求 F 为 M×l（行=目标数，列=解数），故转置
    F = obj_matrix';
    ub = Rref(:);  % 确保为列向量

    % 调用近似 HV 计算（Monte Carlo 10万采样）
    hv = Drawing_HI_approximate_hypervolume(F, ub, 100000);
end

function nondom_idx = filter_nondominated(obj_matrix)
% 辅助函数：从目标矩阵中筛选非支配解的行索引
    [n, ~] = size(obj_matrix);
    dominated = false(n, 1);
    for i = 1:n
        if dominated(i), continue; end
        for j = 1:n
            if i == j, continue; end
            % 检查解 j 是否支配解 i：所有目标 j<=i 且至少一个 j<i
            if all(obj_matrix(j,:) <= obj_matrix(i,:)) && any(obj_matrix(j,:) < obj_matrix(i,:))
                dominated(i) = true;
                break;
            end
        end
    end
    nondom_idx = find(~dominated);
end
