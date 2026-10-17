clc; clear; close all;
addpath(genpath(pwd));

%% ========================================================================
% Main_Statistics_Test.m  ——  五算法 HV 统计显著性检验
% 对应论文 4.3 节 + 表 7 / 表 8
% 流程：数据采集 → 描述性统计(Table7) → 正态性检验 → Wilcoxon 秩和检验(Table8)
% 不改动任何算法寻优主体，仅外层循环 + HV 计算 + 统计检验
% ========================================================================

fprintf('============================================================\n');
fprintf(' 五算法 HV 统计显著性检验实验  启动\n');
fprintf('============================================================\n\n');

%% ------------------------ 1. 实验输入配置 ------------------------
alg_info = { ...
    'CN-SFLA', 1, 50, 5, 0.60; ...
    'IMOBFO',  2, 50, [], []; ...
    'NSGA-II', 3, 50, [], []; ...
    'DABC',    4, 50, [], []; ...
    'SFLA',    5, 50, [], []; ...
};
alg_names = alg_info(:, 1);
alg_nums  = cell2mat(alg_info(:, 2));
alg_N     = cell2mat(alg_info(:, 3));
num_alg   = length(alg_names);

M_Obj     = 5;
CT        = 70;
max_iter  = 20;
run_num   = 20;
Rref      = [15, 3, 150, 50, 500];
alpha     = 0.05;

origin_file = readtable('Laptop.xlsx');
core_info   = Public_information_extraction(origin_file);
V           = core_info{1,1};
fprintf('笔记本拆卸实例：零件数 V=%d, 读取完成\n\n', V);

%% ------------------------ 2. HV 样本采集 ------------------------
fprintf('------------------------ 阶段 1：HV 样本采集 ------------------------\n');
fprintf('5 算法 × %d 次独立运行 = %d 次求解\n\n', run_num, num_alg*run_num);

hv_collection = zeros(num_alg, run_num);
time_collection = zeros(num_alg, run_num);
seed_base = 42;

for ii_alg = 1:num_alg
    cur_name = alg_names{ii_alg};
    cur_num  = alg_nums(ii_alg);
    cur_N    = alg_N(ii_alg);

    if cur_num == 1
        cur_mem = 5; cur_elite = 0.60;
    else
        cur_mem = 5; cur_elite = 0.50;
    end

    fprintf('--- 算法 %d/%d : %s (Alg_Num=%d, N=%d) ---\n', ...
        ii_alg, num_alg, cur_name, cur_num, cur_N);

    for ii_run = 1:run_num
        try
            rng(seed_base + ii_run + ii_alg*100);
            tic_s = tic;

            pareto_set = Public_DLBP_Solution( ...
                M_Obj, max_iter, cur_N, CT, cur_num, ...
                origin_file, core_info, ii_run, ...
                cur_mem, cur_elite);

            cur_time = toc(tic_s);
            cur_hv   = Public_Calc_HV(pareto_set, Rref, V, M_Obj);

            if isnan(cur_hv) || cur_hv < 0
                warning('[警告] %s 第 %d 次 HV=%.4e 异常，置 0', cur_name, ii_run, cur_hv);
                cur_hv = 0;
            end
        catch ME
            warning('[异常] %s 第 %d 次运行报错：%s', cur_name, ii_run, ME.message);
            cur_time = NaN;
            cur_hv   = 0;
        end
        hv_collection(ii_alg, ii_run)   = cur_hv;
        time_collection(ii_alg, ii_run) = cur_time;

        if mod(ii_run, 5) == 0 || ii_run == run_num
            fprintf('  运行 %2d/%d : HV=%.4e, time=%.2fs\n', ii_run, run_num, cur_hv, cur_time);
        end
    end
    fprintf('\n');
end

for ii_alg = 1:num_alg
    if all(hv_collection(ii_alg, :) == 0)
        warning('[严重] 算法 %s 的 %d 次 HV 全部为 0，请检查！', alg_names{ii_alg}, run_num);
    end
end

%% ------------------------ 3. Table 7：描述性统计 ------------------------
fprintf('\n------------------------ 阶段 2：描述性统计表 7 ------------------------\n\n');

fprintf('%-12s %-20s %-20s\n', 'Algorithm', 'Mean HV (×10^7)', 'Std (×10^7)');
fprintf('%s\n', repmat('-', 1, 52));

desc_mean = zeros(num_alg, 1);
desc_std  = zeros(num_alg, 1);

for ii_alg = 1:num_alg
    cur_hv = hv_collection(ii_alg, :);
    desc_mean(ii_alg) = mean(cur_hv);
    desc_std(ii_alg)  = std(cur_hv);
    fprintf('%-12s %-20.4f %-20.4f\n', alg_names{ii_alg}, ...
        desc_mean(ii_alg)/1e7, desc_std(ii_alg)/1e7);
end

%% ------------------------ 4. 正态性检验 ------------------------
fprintf('\n------------------------ 阶段 3：Lilliefors 正态性检验 ------------------------\n\n');

lillie_p  = zeros(num_alg, 1);
is_normal = cell(num_alg, 1);

fprintf('%-12s %-14s %-18s\n', 'Algorithm', 'Lillie_p', 'Normal(α=0.05)');
fprintf('%s\n', repmat('-', 1, 44));

for ii_alg = 1:num_alg
    try
        [h, p] = lillietest(hv_collection(ii_alg, :), 'Alpha', alpha);
        lillie_p(ii_alg) = p;
        if p > alpha
            is_normal{ii_alg} = 'Yes';
        else
            is_normal{ii_alg} = 'No';
        end
    catch ME
        warning('Lilliefors 检验失败 (%s)：%s', alg_names{ii_alg}, ME.message);
        lillie_p(ii_alg) = NaN;
        is_normal{ii_alg} = 'Error';
    end
    fprintf('%-12s %-14.4f %-18s\n', alg_names{ii_alg}, lillie_p(ii_alg), is_normal{ii_alg});
end

%% ------------------------ 5. Table 8：Wilcoxon 秩和检验 ------------------------
fprintf('\n------------------------ 阶段 4：Wilcoxon 秩和检验 (Table 8) ------------------------\n\n');

cn_idx      = 1;
compare_idx = [2, 3, 4, 5];

fprintf('显著性水平 α = %.2f\n', alpha);
fprintf('注：论文正文描述 α=0.05；如审稿人要求多重比较校正，\n');
fprintf('   可采用 Bonferroni 校正 α_bonf = %.4f / %d = %.4f\n\n', ...
    alpha, length(compare_idx), alpha/length(compare_idx));

fprintf('%-25s %-14s %-20s\n', 'Comparison', 'p-value', 'Significant (α=0.05)');
fprintf('%s\n', repmat('-', 1, 59));

mw_pvalues = zeros(length(compare_idx), 1);
mw_sig     = cell(length(compare_idx), 1);

for k = 1:length(compare_idx)
    g2 = compare_idx(k);
    cn_hv   = hv_collection(cn_idx, :);
    comp_hv = hv_collection(g2, :);

    try
        [p_val, h, stats] = ranksum(cn_hv, comp_hv, 'Alpha', alpha);
        mw_pvalues(k) = p_val;
        if p_val < alpha
            mw_sig{k} = 'Yes';
        else
            mw_sig{k} = 'No';
        end
        fprintf('CN-SFLA vs %-15s %-14.4f %-20s\n', alg_names{g2}, p_val, mw_sig{k});
    catch ME
        warning('Wilcoxon 检验 CN-SFLA vs %s 失败：%s', alg_names{g2}, ME.message);
        mw_pvalues(k) = NaN;
        mw_sig{k} = 'Error';
        fprintf('CN-SFLA vs %-15s ERROR: %s\n', alg_names{g2}, ME.message);
    end
end

%% ------------------------ 6. 结论汇总 ------------------------
fprintf('\n\n============================================================\n');
fprintf('                      实验结论汇总\n');
fprintf('============================================================\n\n');

sig_count = sum(strcmp(mw_sig, 'Yes'));
fprintf('  CN-SFLA vs 4 对比算法 Wilcoxon 秩和检验 (α=%.2f)：\n', alpha);
for k = 1:length(compare_idx)
    fprintf('    vs %-10s : p = %.4f  →  %s\n', ...
        alg_names{compare_idx(k)}, mw_pvalues(k), mw_sig{k});
end
fprintf('\n  显著优于 %d/%d 个对比算法\n', sig_count, length(compare_idx));

%% ------------------------ 7. 保存原始数据 ------------------------
timestamp = datestr(now, 'yyyymmdd_HHMMSS');

mat_file = sprintf('Statistics_Test_result_%s.mat', timestamp);
save(mat_file, 'hv_collection', 'time_collection', 'alg_names', 'alg_nums', 'alg_N', ...
    'run_num', 'max_iter', 'CT', 'M_Obj', 'V', 'Rref', ...
    'desc_mean', 'desc_std', 'lillie_p', 'is_normal', ...
    'mw_pvalues', 'mw_sig', 'alpha');
fprintf('\n原始 mat 数据已保存：%s\n', mat_file);

try
    col_alg = cell(num_alg, 1);
    col_mean = zeros(num_alg, 1);
    col_std = zeros(num_alg, 1);
    for i = 1:num_alg
        col_alg{i} = alg_names{i};
        col_mean(i) = desc_mean(i) / 1e7;
        col_std(i)  = desc_std(i) / 1e7;
    end
    T7 = table(col_alg, col_mean, col_std, ...
        'VariableNames', {'Algorithm','Mean_HV_e7','Std_e7'});
    writetable(T7, sprintf('Statistics_Test_Table7_%s.xlsx', timestamp));
    fprintf('  ✓ Table7 导出成功\n');
catch ME
    warning('  ✗ Table7 导出失败：%s', ME.message);
end

try
    n_cmp = length(compare_idx);
    col_comp = cell(n_cmp, 1);
    col_p    = zeros(n_cmp, 1);
    col_sig  = cell(n_cmp, 1);
    for k = 1:n_cmp
        col_comp{k} = sprintf('CN-SFLA vs %s', alg_names{compare_idx(k)});
        col_p(k)    = mw_pvalues(k);
        col_sig{k}  = mw_sig{k};
    end
    T8 = table(col_comp, col_p, col_sig, ...
        'VariableNames', {'Comparison','p_value','Significant'});
    writetable(T8, sprintf('Statistics_Test_Table8_%s.xlsx', timestamp));
    fprintf('  ✓ Table8 导出成功\n');
catch ME
    warning('  ✗ Table8 导出失败：%s', ME.message);
end

fprintf('\n============================================================\n');
fprintf('                  统计检验实验全部结束\n');
fprintf('============================================================\n');
