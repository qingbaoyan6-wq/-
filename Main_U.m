% A_Start_Oneness 进行多次的DLBP求解
clc;
clear;

%% 需要传入的参数
Operation_Times=10                              ; % 运算次数
M=5;             % 优化目标数 M
It_Time=30;      % 迭代次数 It_Time
Group_Size=50;  % 种群大小 Group_Size
CT=70;           % 节拍时间 CT
% Alg_Num=4;      % 算法编号 Alg_Num   (1-RTFPA )
% Line_Style=2;    % 拆卸线型 Line_Style 

% 确定输入文件
% U型需要一个文件

% origin_file=readtable('Hanergy_inverter.xlsx');   % 数据源  origin_file
 origin_file=readtable('Laptop.xlsx');   % 数据源  origin_file

core_info=Public_information_extraction(origin_file);  % 读取产品的零件信息
inf=core_info{1,2};   % 零件数量
% xlswrite(['Laptop_unsure_time.xlsx'],inf,'sheet1','A1'); % 导出不确定时间
%% 开始进行DLBP求解
for Alg_Num=1:5 % 算法编号，一次运行多个数据
    i=1;
%     tic; %计时器
    while i<=Operation_Times
        folder_name=Public_road_create(Alg_Num); % 保存到哪个文件夹
        prefix_name=Public_prefix_create(Alg_Num);
        prefix_name=[prefix_name,num2str(i),'.xlsx']; % 保存文件名称，将一个变量i转换为字符串，并与前缀字符串prefix_name和后缀字符串".xlsx"拼接在一起，生成一个新的字符串
        % 开始运算
        ans_set=Public_DLBP_Solution(M,It_Time,Group_Size,CT,Alg_Num,origin_file,core_info,i);%优化目标数，迭代次数，种群大小，节拍时间，算法编号，拆卸线型，原始数据，运算次数
        if isempty(ans_set)==1
           continue;
        else                                                               
            xlswrite([folder_name,prefix_name],ans_set,'sheet1','A1'); % 写入文件
            i=i+1;
        end
    end
%     toc;
end