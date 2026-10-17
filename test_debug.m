%% test_debug.m  ——  CN-SFLA 参数化改造验证 + 调试数据存储
% 一键运行：自动加路径 → 跑单次测试 → 存所有中间数据
% 直接按 F5 即可
clc; clear; close all;

%% 0. 自动加路径（解决 HV 函数找不到的问题）
addpath(genpath(pwd));
fprintf('[1/5] 已添加所有子文件夹到 MATLAB 路径\n');

%% 1. 算例读取 + 信息提取
origin_file = readtable('Laptop.xlsx');
core_info   = Public_information_extraction(origin_file);
V = core_info{1,1};
fprintf('[2/5] 笔记本拆卸实例读取完成，零件数 V = %d\n', V);

%% 2. 参数配置（最小测试：N=30, M=2, E=0.4）
cfg_N     = 30;
cfg_Mem   = 2;
cfg_E     = 0.4;
cfg_Iter  = 30;
cfg_CT    = 70;
cfg_MObj  = 5;
cfg_Seed  = 42;
Rref      = [15, 3, 150, 50, 500];

fprintf('[3/5] 测试参数：N=%d, memeplex=%d, elite_rate=%.2f, max_iter=%d\n', ...
    cfg_N, cfg_Mem, cfg_E, cfg_Iter);

%% 3. 跑算法 + 计时
rng(cfg_Seed);
tic_start = tic;
pareto_set = Public_DLBP_Solution( ...
    cfg_MObj, cfg_Iter, cfg_N, cfg_CT, 1, ...
    origin_file, core_info, 1, ...
    cfg_Mem, cfg_E);
elapsed_time = toc(tic_start);

fprintf('[4/5] 算法运行完成：耗时 %.2fs, Pareto 解集 %d × %d\n', ...
    elapsed_time, size(pareto_set,1), size(pareto_set,2));

%% 4. 计算 HV
hv_value = Public_Calc_HV(pareto_set, Rref, V, cfg_MObj);
fprintf('      HV = %.6e\n', hv_value);

%% 5. 存储全部调试数据
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
save_name = sprintf('test_debug_%s.mat', timestamp);
save(save_name, ...
    'pareto_set', 'hv_value', 'elapsed_time', ...
    'cfg_N', 'cfg_Mem', 'cfg_E', 'cfg_Iter', 'cfg_CT', 'cfg_MObj', 'cfg_Seed', ...
    'Rref', 'V', 'core_info');
fprintf('[5/5] 调试数据已保存：%s\n', save_name);

%% 额外：导出 Pareto 目标值到 Excel（方便查看）
try
    obj_cols = pareto_set(:, V+2 : V+1+cfg_MObj);
    T = table( obj_cols(:,1), obj_cols(:,2), obj_cols(:,3), obj_cols(:,4), obj_cols(:,5), ...
        'VariableNames', {'f1_workstation','f2_balance','f3_hazard','f4_carbon','f5_profit(neg)'} );
    excel_name = sprintf('test_debug_Pareto_%s.xlsx', timestamp);
    writetable(T, excel_name);
    fprintf('      Pareto 目标值已导出：%s\n', excel_name);
catch ME
    warning('Excel 导出失败：%s', ME.message);
end

fprintf('\n===== 测试全部完成 =====\n');
