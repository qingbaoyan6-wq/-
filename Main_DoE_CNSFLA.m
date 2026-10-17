
%% ========================================================================
% Main_DoE_CNSFLA.m  ——  CN-SFLA (CTFLA) 三因素三水平全因子 DoE 参数标定实验
% 对应论文 4.2 节：种群规模 N、子种群数量 M、精英保留率 E 的参数组合遍历
% 输出：27 组参数配置 × 30 次独立运行的 HV/耗时统计，筛选最优参数组合
% 硬件环境：Matlab R2020b / CPU i5-12490F / RAM 16G / Windows 11
% 作者说明：本脚本属于外层实验框架，仅循环调用已有 CN-SFLA 函数，不修改算法内部算子
% ========================================================================
clc; clear; close all;

%% ------------------------ 1. 实验输入配置定义 ------------------------
fprintf('==========================================\n');
fprintf(' CN-SFLA  DoE 参数标定实验  启动\n');
fprintf('==========================================\n\n');

% --- 1.1 实验因素与水平定义（三因素三水平全因子） ---
N_levels    = [30, 50, 70];           % 因素1：种群规模 N
M_levels    = [2,  5,  10];            % 因素2：子种群数量 memeplex_num（用 M 易与目标数混淆，后文统一用 memeplex_num）
E_levels    = [0.40, 0.60, 0.80];      % 因素3：精英保留率 elite_rate

% --- 1.2 公共全局实验固定参数 ---
M_Obj       = 5;                       % 优化目标数
CT          = 70;                      % 节拍时间 CT (s)
Alg_Num     = 1;                       % 算法编号 1=CTFLA (CN-SFLA)
max_iter    = 8;                      % 算法最大迭代次数
run_num     = 8;                      % 每组参数配置独立重复运行次数
Rref        = [15, 3, 150, 50, 500];   % HV 参考点（5 个目标上界）

% --- 1.3 算例数据读取（笔记本 32 零件拆卸实例） ---
origin_file = readtable('Laptop.xlsx');

% --- 1.4 循环外只提取一次零件信息 core_info（避免每次调用重复 xlswrite I/O） ---
fprintf('正在提取笔记本拆卸实例零件信息 ...\n');
core_info   = Public_information_extraction(origin_file);
V           = core_info{1,1};          % 零件数量 V=32
fprintf('零件数量 V = %d，读取完成\n\n', V);

% --- 1.5 全因子参数组合生成与约束校验 ---
% 遍历 3×3×3 = 27 组
config_list = [];                      % 存储合法参数组合的列表 [N, memeplex_num, elite_rate]
for ii_n = 1:length(N_levels)
    for ii_m = 1:length(M_levels)
        for ii_e = 1:length(E_levels)
            cur_N = N_levels(ii_n);
            cur_M = M_levels(ii_m);
            cur_E = E_levels(ii_e);
            % 约束校验：N % M == 0，保证每个子种群个体数量为整数
            if mod(cur_N, cur_M) ~= 0
                error('参数约束违反：N=%d 不能被子种群数 M=%d 整除，请检查配置！', cur_N, cur_M);
            end
            config_list = [config_list; cur_N, cur_M, cur_E];
        end
    end
end
num_config = size(config_list, 1);
fprintf('共生成 %d 组合法参数配置（N%%M==0 约束校验通过）\n\n', num_config);

%% ------------------------ 2. 循环执行全因子实验 ------------------------
% 初始化结果存储
doe_result_table = zeros(num_config, 7); % 列：[N, memeplex_num, elite_rate, mean_HV, std_HV, max_HV, mean_runtime]
all_hv_list      = zeros(num_config, run_num); % 每组 30 次运行的 HV 原始值
all_time_list    = zeros(num_config, run_num); % 每组 30 次运行的耗时原始值

% 为公平对比，不同参数组使用相同的随机种子序列（每次运行对应同一 seed）
rng_seed_base = 42;                    % 基准随机种子，保证可复现
seed_list     = rng_seed_base : rng_seed_base + run_num - 1;

fprintf('开始执行 DoE 循环（共 %d 组 × %d 次 = %d 次求解）...\n\n', num_config, run_num, num_config*run_num);

% --- 外层循环：遍历全部 27 组参数配置 ---
for ii_cfg = 1:num_config
    cur_N           = config_list(ii_cfg, 1);
    cur_memeplex    = config_list(ii_cfg, 2);
    cur_elite       = config_list(ii_cfg, 3);
    cur_hv_list     = zeros(1, run_num);
    cur_time_list   = zeros(1, run_num);

    fprintf('--- 配置 %2d/%d : N=%d, memeplex=%d, elite_rate=%.2f ---\n', ...
            ii_cfg, num_config, cur_N, cur_memeplex, cur_elite);

    % --- 内层循环：run_num=30 次独立重复运行 ---
    for ii_run = 1:run_num
        try
            % a. 设置本次运行随机种子（不同参数组匹配相同种子，公平对比）
            rng(seed_list(ii_run));

            % b. 记录开始计时
            tic_start = tic;

            % c. 调用 CN-SFLA (CTFLA) 主求解函数，传入可变参数
            pareto_set = Public_DLBP_Solution( ...
                M_Obj, max_iter, cur_N, CT, Alg_Num, ...
                origin_file, core_info, ii_run, ...
                cur_memeplex, cur_elite);

            % d. toc 获取本次运行耗时
            cur_time = toc(tic_start);

            % e. 计算本次 HV 值（pareto_set 可能为空，Public_Calc_HV 内部已做防护）
            cur_hv = Public_Calc_HV(pareto_set, Rref, V, M_Obj);

        catch ME
            % 异常捕获：记录日志，不中断全部 DoE 循环
            warning('【异常捕获】配置 %d (N=%d,M=%d,E=%.2f) 第 %d 次运行报错：%s', ...
                ii_cfg, cur_N, cur_memeplex, cur_elite, ii_run, ME.message);
            cur_time = NaN;
            cur_hv   = 0;
        end

        % 追加到当前组的存储容器
        cur_hv_list(ii_run)   = cur_hv;
        cur_time_list(ii_run) = cur_time;

        % 进度提示（每 5 次打印一次）
        if mod(ii_run, 5) == 0
            fprintf('  运行 %2d/%d : HV=%.4e, time=%.2fs\n', ...
                ii_run, run_num, cur_hv, cur_time);
        end
    end

    % --- 2.2 统计本组指标（忽略 NaN 异常数据） ---
    valid_mask            = ~isnan(cur_time_list);
    valid_hv              = cur_hv_list(valid_mask);
    valid_time            = cur_time_list(valid_mask);

    mean_HV   = mean(valid_hv);
    std_HV    = std(valid_hv);
    max_HV    = max(valid_hv);
    mean_time = mean(valid_time);

    % --- 2.3 存入结果表 ---
    doe_result_table(ii_cfg, :) = [cur_N, cur_memeplex, cur_elite, mean_HV, std_HV, max_HV, mean_time];
    all_hv_list(ii_cfg, :)      = cur_hv_list;
    all_time_list(ii_cfg, :)    = cur_time_list;

    fprintf('  => mean_HV=%.4e, std_HV=%.4e, max_HV=%.4e, mean_time=%.1fs\n\n', ...
        mean_HV, std_HV, max_HV, mean_time);
end

%% ------------------------ 3. 结果后处理与最优参数筛选 ------------------------
fprintf('\n==================== DoE 实验完成 ====================\n\n');

% --- 3.1 打印全因子 DoE 汇总表（对应论文表 4） ---
fprintf('表 4  Synthetic illustrative DoE summary for CN-SFLA\n');
fprintf('%-6s %-10s %-14s %-16s %-16s %-16s %-14s\n', ...
    'No.', 'N', 'memeplex(M)', 'mean_HV(×10^7)', 'std_HV(×10^7)', 'max_HV(×10^7)', 'mean_time(s)');
fprintf('%s\n', repmat('-', 1, 100));

for ii = 1:num_config
    row = doe_result_table(ii, :);
    fprintf('%-6d %-10d %-14d %-16.4f %-16.4f %-16.4f %-14.1f\n', ...
        ii, row(1), row(2), row(4)/1e7, row(5)/1e7, row(6)/1e7, row(7));
end

% --- 3.2 按筛选规则确定最优参数组合 ---
% 规则：优先 mean_HV 最大；接近时优先 std_HV 更小；再接近时优先 mean_runtime 更小
[~, sort_idx] = sortrows(doe_result_table(:, 4:7), [-1, 2, 4]);  % mean_HV降序→std升序→mean_runtime升序
best_idx      = sort_idx(1);
best_row      = doe_result_table(best_idx, :);

best_N     = best_row(1);
best_Mem   = best_row(2);
best_E     = best_row(3);
best_mean  = best_row(4);
best_std   = best_row(5);
best_max   = best_row(6);
best_time  = best_row(7);

fprintf('\n==================== 最优参数组合 ====================\n');
fprintf('种群规模 N = %d\n', best_N);
fprintf('子种群数量 M = %d\n', best_Mem);
fprintf('精英保留率 E = %.2f (%d%%)\n', best_E, round(best_E*100));
fprintf('对应指标：\n');
fprintf('  mean_HV  = %.4e  (%.4f × 10^7)\n', best_mean, best_mean/1e7);
fprintf('  std_HV   = %.4e  (%.4f × 10^7)\n', best_std,  best_std/1e7);
fprintf('  max_HV   = %.4e  (%.4f × 10^7)\n', best_max,  best_max/1e7);
fprintf('  mean_time = %.1f s\n', best_time);

% --- 3.3 保存最优参数到 workspace 变量，供后续对比实验 Main_U.m 直接调用 ---
assignin('base', 'best_DoE_params', struct( ...
    'N', best_N, 'memeplex_num', best_Mem, 'elite_rate', best_E, ...
    'mean_HV', best_mean, 'std_HV', best_std, 'max_HV', best_max, ...
    'mean_time', best_time));
fprintf('\n最优参数已写入 workspace 变量 best_DoE_params，后续对比实验可直接 load 使用。\n');

%% ------------------------ 4. 保存原始中间数据（备查/复现） ------------------------
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
save_file = sprintf('DoE_CNSFLA_result_%s.mat', timestamp);
save(save_file, 'doe_result_table', 'config_list', 'all_hv_list', 'all_time_list', ...
    'best_N', 'best_Mem', 'best_E', 'Rref', 'N_levels', 'M_levels', 'E_levels', ...
    'run_num', 'max_iter', 'CT', 'M_Obj', 'V', 'seed_list');
fprintf('\n全部原始数据已保存至：%s\n', save_file);

% 同时导出 Excel 表格方便查看
try
    T = table( (1:num_config)', doe_result_table(:,1), doe_result_table(:,2), ...
        doe_result_table(:,3), doe_result_table(:,4)/1e7, doe_result_table(:,5)/1e7, ...
        doe_result_table(:,6)/1e7, doe_result_table(:,7), ...
        'VariableNames', {'No','N','memeplex','elite_rate', ...
        'mean_HV_e7','std_HV_e7','max_HV_e7','mean_time_s'} );
    writetable(T, sprintf('DoE_CNSFLA_table_%s.xlsx', timestamp));
    fprintf('DoE 汇总表已导出为 Excel：DoE_CNSFLA_table_%s.xlsx\n', timestamp);
catch
    warning('Excel 导出失败（可能文件被占用），mat 文件已完整保存。');
end

fprintf('\n==================== 实验全部结束 ====================\n');
