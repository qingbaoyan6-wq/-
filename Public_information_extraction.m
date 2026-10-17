function [information]=Public_information_extraction(origin_file)
% 该函数用于提取产品拆卸零件信息
% 输入excel应当符合规范各行数据应为：
% 1-序号  2-时间  3-工具  方向(暂无)  4-收益  5-危害  6-需求  7~N-紧前任务
information=cell(1,5); % 返回cell
origin_info = origin_file;
dis_info=table2array(origin_info); % table转换成矩阵
[V,y]=size(dis_info); % 读取产品零件数量和最大列数（紧前任务）
constrain_martix=zeros(V,V); % 约束矩阵

% 输入各零件拆卸时间的平均值和标准差
% time_file=readtable('Hanergy_inverter_time.xlsx');   % 时间数据源 
% time_file=readtable('Laptop_time.xlsx');   % 时间数据源 
% unsure_time=Generation_uncertainty_time(V,time_file);
unsure_time=Generation_uncertainty_time(V,dis_info(:,2:3));
% xlswrite('Laptop_unsure_time.xlsx',unsure_time,'sheet1','A1'); % 硬编码绝对路径已移除，DoE框架中只需读不需写

% 拆卸信息数据
dis_info(:,2)=unsure_time; % 输入不确定时间
time_dir_rev=dis_info(:,1:8)';

% 产品需要回收的零件集
hazard_parts=find(dis_info(:,8)==1)';
need_parts=find(dis_info(:,8)==1 | dis_info(:,9)==1)';

% 提取产品约束矩阵
for ii1 = 1:V
    current_parts=[];
    loc=10; % 零件信息中第10行开始为紧前任务
    while loc<=y % 限制范围
        current_parts=[current_parts,dis_info(ii1,loc)]; % 记录紧前任务
        loc=loc+1;
    end
    current_parts=current_parts(~isnan(current_parts)); % 删除NaN
    for ii2=1:length(current_parts)
        constrain_martix(current_parts(1,ii2),ii1)=1; % 保存到约束矩阵
    end
end

% 将所有信息保存至cell返回
information{1,1}=V;                  % 返回数据1：产品零件数
information{1,2}=time_dir_rev;       % 返回数据2：拆卸信息矩阵
information{1,3}=need_parts;         % 返回数据3：需求矩阵（包含危险零件必须）
information{1,4}=constrain_martix;   % 返回数据4：约束矩阵
information{1,5}=hazard_parts;       % 返回数据5：危害矩阵



end