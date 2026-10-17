function random_time=Generation_uncertainty_time(V,time_file)

%% 输入各零件拆卸时间的平均值和标准差
% unsure_time=table2array(time_file);
unsure_time=time_file;
random_time=zeros(V,1);
%% 生成符合正态分布的随机时间
for i=1:V
    mean_time = unsure_time(i,1); % 平均拆卸时间
    std_dev_time = unsure_time(i,2); % 拆卸时间的标准差
    random_time(i,1) = normrnd(mean_time, std_dev_time);  % 保存并输出结果
end


end