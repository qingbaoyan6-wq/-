%% diagnose_elite.m  ——  诊断 elite_rate 参数为何无效
% 固定随机种子，对比不同 elite_rate 下最终 Pareto 解集是否相同
clc; clear; close all;
addpath(genpath(pwd));

origin_file = readtable('Laptop.xlsx');
core_info   = Public_information_extraction(origin_file);
V = 32;
Rref = [15, 3, 150, 50, 500];

fprintf('=========== elite_rate 诊断测试 ===========\n\n');

% 测试 1：N=30, M=2, 固定 seed=42, 仅跑 5 次迭代（快速）
fprintf('【测试1】N=30, M=2, It=5, 固定 seed=42, 对比 E=0.4 vs E=0.6 vs E=0.8\n');
rng(42); p_04 = Public_DLBP_Solution(5, 5, 30, 70, 1, origin_file, core_info, 1, 2, 0.4);
rng(42); p_06 = Public_DLBP_Solution(5, 5, 30, 70, 1, origin_file, core_info, 1, 2, 0.6);
rng(42); p_08 = Public_DLBP_Solution(5, 5, 30, 70, 1, origin_file, core_info, 1, 2, 0.8);

hv_04 = Public_Calc_HV(p_04, Rref, V, 5);
hv_06 = Public_Calc_HV(p_06, Rref, V, 5);
hv_08 = Public_Calc_HV(p_08, Rref, V, 5);

fprintf('  E=0.4: HV = %.6e, 解集大小 %d\n', hv_04, size(p_04,1));
fprintf('  E=0.6: HV = %.6e, 解集大小 %d\n', hv_06, size(p_06,1));
fprintf('  E=0.8: HV = %.6e, 解集大小 %d\n', hv_08, size(p_08,1));
fprintf('  E=0.4 与 E=0.6 解集完全相同？ %d\n', isequal(p_04, p_06));
fprintf('  E=0.4 与 E=0.8 解集完全相同？ %d\n', isequal(p_04, p_08));
fprintf('  E=0.6 与 E=0.8 解集完全相同？ %d\n', isequal(p_06, p_08));

% 测试 2：CTFLA 函数内部 elite_rate 到底有没有用
fprintf('\n【测试2】直接调 CTFLA 单次，看 elite_count 是否真的不同\n');
group_size = 30;
for e = [0.4, 0.6, 0.8]
    ec = floor(group_size * e);
    fprintf('  elite_rate=%.2f  =>  elite_count=%d,  补充随机解数=%d\n', e, ec, group_size-ec);
end

% 测试 3：完整 30 次迭代，确认 HV 是否真的完全相同
fprintf('\n【测试3】N=30, M=2, It=30, 完整迭代, seed=42, 对比 E=0.4 vs E=0.8\n');
rng(42); tic;
p_full_04 = Public_DLBP_Solution(5, 30, 30, 70, 1, origin_file, core_info, 1, 2, 0.4);
t04 = toc;
rng(42); tic;
p_full_08 = Public_DLBP_Solution(5, 30, 30, 70, 1, origin_file, core_info, 1, 2, 0.8);
t08 = toc;

hv_full_04 = Public_Calc_HV(p_full_04, Rref, V, 5);
hv_full_08 = Public_Calc_HV(p_full_08, Rref, V, 5);
fprintf('  E=0.4: HV=%.6e, time=%.2fs, 解集大小=%d\n', hv_full_04, t04, size(p_full_04,1));
fprintf('  E=0.8: HV=%.6e, time=%.2fs, 解集大小=%d\n', hv_full_08, t08, size(p_full_08,1));
fprintf('  两个解集完全相同？ %d\n', isequal(p_full_04, p_full_08));

% 如果解集不同，找出第一个不同的位置
if ~isequal(p_full_04, p_full_08)
    fprintf('  解集确实不同！差异位置：');
    diff_rows = find(any(p_full_04 ~= p_full_08, 2));
    fprintf('第 %d 行\n', diff_rows(1));
    fprintf('  E=0.4 第%d行的前5个目标值: [%.4f %.4f %.4f %.4f %.4f]\n', diff_rows(1), ...
        p_full_04(diff_rows(1),V+2), p_full_04(diff_rows(1),V+3), p_full_04(diff_rows(1),V+4), ...
        p_full_04(diff_rows(1),V+5), p_full_04(diff_rows(1),V+6));
    fprintf('  E=0.8 第%d行的前5个目标值: [%.4f %.4f %.4f %.4f %.4f]\n', diff_rows(1), ...
        p_full_08(diff_rows(1),V+2), p_full_08(diff_rows(1),V+3), p_full_08(diff_rows(1),V+4), ...
        p_full_08(diff_rows(1),V+5), p_full_08(diff_rows(1),V+6));
end

% 保存诊断数据
save('diagnose_result.mat');
fprintf('\n诊断数据已保存至 diagnose_result.mat\n');
fprintf('=========== 诊断完成 ===========\n');
