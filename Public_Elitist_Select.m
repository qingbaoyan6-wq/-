function [Ans_set] = Public_Elitist_Select(Old_set,New_set,M,V_SEQ,Group_Size,core_info_mix,CT,elite_rate)
    % Public_Elitist_Select 精英选择函数，合并新旧解并筛选保留精英个体
    % 输入：Old_set-旧解集, New_set-新解集, M-目标数, V_SEQ-序列长度, Group_Size-种群规模, core_info_mix-零件信息, CT-节拍时间
    %       elite_rate-精英保留率(可选,默认1.0)：从 Old_set 中保留的比例，0=完全不用旧解, 1=全部保留旧解
    % 修改说明：新增 elite_rate 参数——这是 DoE 实验中 E 因素的真实控制点！
    %          旧版逻辑：合并(旧,新)→排序→硬取前N，完全忽略新旧来源差异
    %          新版逻辑：先用 elite_rate 决定保留多少旧解 + 从新解中补充到 N
    if nargin < 8; elite_rate = 1.0; end  % 向后兼容：不传 E 时默认1.0(全部保留旧解)
    if nargin < 7; CT = 70; end

    %% 先对 Old_set 做一次排序，选出其中的帕累托精英
    old_sorted = Old_set;
    old_sorted(:,V_SEQ+M+1:V_SEQ+M+2) = 0;
    old_sorted = unique(old_sorted, 'rows', 'stable');
    old_sorted = Public_Nondominated_Sorting(old_sorted, M, V_SEQ);

    %% 对 New_set 同样排序
    new_sorted = New_set;
    new_sorted(:,V_SEQ+M+1:V_SEQ+M+2) = 0;
    new_sorted = unique(new_sorted, 'rows', 'stable');
    new_sorted = Public_Nondominated_Sorting(new_sorted, M, V_SEQ);

    %% 关键：按 elite_rate 决定保留多少旧精英
    % elite_rate=0.6  -> 保留 floor(Group_Size*0.6) 个旧解，剩下 floor(Group_Size*0.4) 从新解中选
    old_keep = floor(Group_Size * elite_rate);
    new_keep = Group_Size - old_keep;

    %% 特殊情况处理
    if old_keep == 0
        % E=0 极端情况：完全不用旧解
        merged_for_sort = new_sorted;
    elseif new_keep == 0
        % E=1 极端情况：完全不用新解
        merged_for_sort = old_sorted;
    else
        % 正常：旧解 + 新解合并后做一次全局排序，再根据"来源权重"选
        % 策略：先从旧解中取前 old_keep 个，再从新解中补充 new_keep 个
        %      但旧解和新解里可能有重复个体，需要先合并去重后排序
        merged = [old_sorted; new_sorted];
        merged(:,V_SEQ+M+1:V_SEQ+M+2) = 0;
        merged = unique(merged, 'rows', 'stable');
        merged = Public_Nondominated_Sorting(merged, M, V_SEQ);

        % 标记每行来自旧解还是新解
        is_old = ismember(merged(:,1:V_SEQ), old_sorted(:,1:V_SEQ), 'rows');

        % 先选旧解中的精英（按排序先后）
        picked = [];
        old_pick_count = 0;
        new_pick_count = 0;
        for ii = 1:size(merged,1)
            if is_old(ii) && old_pick_count < old_keep
                picked = [picked; merged(ii,:)];
                old_pick_count = old_pick_count + 1;
            elseif ~is_old(ii) && new_pick_count < new_keep
                picked = [picked; merged(ii,:)];
                new_pick_count = new_pick_count + 1;
            end
            if old_pick_count >= old_keep && new_pick_count >= new_keep
                break;
            end
        end
        merged_for_sort = picked;
    end

    %% 如果 picked 不够 Group_Size，随机补充
    [num,~] = size(merged_for_sort);
    if num < Group_Size
        for ii3 = num+1 : Group_Size
            merged_for_sort(ii3,:) = Ushaped_line_uncomplete(core_info_mix, CT, M);
        end
    end

    Ans_set = Public_Nondominated_Sorting(merged_for_sort, M, V_SEQ);
end
