function [new_seq] = U_objective_function(seq,info_mix,M,CT)
% 读取零件数量
V=info_mix{1,1};
% 读取零件信息
dis=info_mix{1,2};
% 读取危害零件
hazard_parts=info_mix{1,5};
% 生成带时间的拆卸序列
U_seq=seq(1,1:V);
local_parts_num = sum(U_seq ~= 0);

sequence=zeros(8,V);%新增一列带危害性
sequence(1,:)=U_seq(1,:);
for ii1=1:local_parts_num
    location=abs(U_seq(1,ii1));
    sequence(2:8,ii1)=dis(2:8,location);
end

%objective_function_uncompllete 不完全拆卸版本的
sequence_U=sequence;


% 统计非零元素的长度

sequence=Algorithm_Ushaped_revive_seq_abjective(sequence,local_parts_num,V); %由于为U型目标函数，先将序列转换为直线,附加其他信息一起转换

%% 环境设置
new_seq=zeros(1,V+M+3);  % “3”=1(拆除的零件数)+2（pareto等级和拥挤度）
% 环境设置
tool_time=2; % 假设更换一次拆卸方向的惩罚时间
disassemble_time_ws=0;
tool_time_ws=0;
current_part_in_workstation=1;
disassemble_set=[];
tool_change_set=[];
ST_set=[];
tool_time_list=[];
disassemble_time_list=zeros(4,V); % 第一行：1:V，第二行：工作站序列 ，第三行：各零件起始时间，第四行：各零件的终止时间 
disassemble_time_list(1,1:V)=1:V;
workstation=0;
counter_tool_change=0;
%% 计算危害性
harmfulness = 0;
for i1 = 1:local_parts_num
    harmfulness = harmfulness + i1 * sequence(8, i1);
end
%% 分配工作站以及记录工作站内的任务
%function [stations, total_stations, hazard_count] = assign_stations(dis_matrix, CT, hazard_parts)
    % 提取有效拆卸步骤（Useq非零的列）
    valid_cols = find(sequence_U(1, :) ~= 0);
    num_tasks = length(valid_cols);
    
    % 初始化工作站及危害计数器
    stations = {};
    current_station_time = 0;
    current_station_tasks = [];
    previous_tool = NaN; % 初始无工具
    station_count = 0;
    hazard_count = 0;    % 新增危害工作站计数器
    
    % 遍历有效列
    for idx = 1:num_tasks
        col = valid_cols(idx);
        task_time = sequence_U(2, col);
        tool = sequence_U(6, col);
        
        % 计算工具更换时间
        if isempty(current_station_tasks)
            additional_time = 0;
        else
            if tool ~= previous_tool
                additional_time = 2;
            else
                additional_time = 0;
            end
        end
        
        % 检查时间约束
        if (current_station_time + additional_time + task_time) <= CT
            current_station_time = current_station_time + additional_time + task_time;
            current_station_tasks = [current_station_tasks, sequence_U(1, col)];
            previous_tool = tool;
        else
            % 保存当前工作站并检查是否包含危害零件
            station_count = station_count + 1;
            stations{station_count} = current_station_tasks;
            % 新增危害检查逻辑
            if any(ismember(abs(current_station_tasks), hazard_parts))
                hazard_count = hazard_count + 1;
            end
            % 创建新工作站
            current_station_time = task_time;
            current_station_tasks = sequence_U(1, col);
            previous_tool = tool;
        end
    end
    
    % 处理最后一个工作站
    if ~isempty(current_station_tasks)
        station_count = station_count + 1;
        stations{station_count} = current_station_tasks;
        % 检查最后一个工作站是否包含危害零件
        if any(ismember(abs(current_station_tasks), hazard_parts))
            hazard_count = hazard_count + 1;
        end
    end
    
    total_stations = station_count;


%%  目标函数赋值 1、workstation 2、SI 3、sum_carbon_emission 4、revenue
% % % 1、workstation 2、SI  3、harmfulness  4、sum_carbon_emission 5、revenue
% 由空闲时间计算的平滑度
%% 开始分配工作站，记录拆卸时间
for ii1=1:local_parts_num
    while 1
        current_part=abs(sequence_U(1,ii1));
        if  current_part_in_workstation==1 % 如果工作站是新开工作站（不考虑方向生产线变化）
            disassemble_time_ws=0;
            tool_time_ws=0;
            total_ST=0;
            workstation=workstation+1;
            disassemble_time_ws=disassemble_time_ws+sequence_U(2,ii1);
            disassemble_time_list(2,current_part)=workstation;    % 一般拆卸时间的甘特，这一行记录对应零件所属的工作站 
            disassemble_time_list(3,current_part)=total_ST;     % 当前零件开始时间点
            disassemble_time_list(4,current_part)=total_ST+sequence_U(2,ii1);   % 结束时间点
            total_ST=total_ST+sequence_U(2,ii1);   % 工作站的容量要更新
            current_part_in_workstation=current_part_in_workstation+1; %工作站处理零件数+1
            if ii1==V  %剩下最后一个零件时开启新工作站
                disassemble_set(1,workstation)=disassemble_time_ws;
                tool_change_set(1,workstation)=tool_time_ws; %没有考虑工具切换时间
                ST_set(1,workstation)=total_ST;
            end
            break
        else % 工作站已拆卸过零件（考虑方向和生产线改变）
            % 方向和生产线变化时间计算
            tool_change_operator=sequence_U(6,ii1)-sequence_U(6,ii1-1);
            if tool_change_operator~=0
               tool_change_time=tool_time;  % 改变方向计入时间
            else
               tool_change_time=0;
            end
            
            if  total_ST+tool_change_time+sequence_U(2,ii1)<=CT % 工作站可以放下该零件
                disassemble_time_ws=disassemble_time_ws+sequence_U(2,ii1);    % 当前工作站中用于拆卸的时间
                tool_time_ws=tool_time_ws+tool_change_time;   % 当前工作站中用于变方位的时间
                if tool_change_operator~=0   % 甘特块----方位变换
                    counter_tool_change=counter_tool_change+1;
                    tool_time_list(1,counter_tool_change)=workstation;
                    tool_time_list(2,counter_tool_change)=total_ST;  % 开始时间
                    tool_time_list(3,counter_tool_change)=total_ST+tool_change_time;
                end
                disassemble_time_list(2,current_part)=workstation;
                disassemble_time_list(3,current_part)=total_ST+tool_change_time; 
                disassemble_time_list(4,current_part)=total_ST+tool_change_time+sequence_U(2,ii1); 
                total_ST=total_ST+sequence_U(2,ii1)+tool_change_time;    % 当前站的累计总时间
                current_part_in_workstation=current_part_in_workstation+1;

                if ii1==V
                    disassemble_set(1,workstation)=disassemble_time_ws;
                    tool_change_set(1,workstation)=tool_time_ws;
                    ST_set(1,workstation)=total_ST;
                end
                break
            else %工作站放不下该零件
                disassemble_set(1,workstation)=disassemble_time_ws;
                tool_change_set(1,workstation)=tool_time_ws;
                ST_set(1,workstation)=total_ST;
                current_part_in_workstation=1;
            end 
        end     
    end
end
ST_set(1,workstation)=total_ST;

%%  目标函数赋值 1、workstation 2、SI 3、sum_carbon_emission 4、revenue
% % % 1、workstation 2、SI  3、harmfulness  4、sum_carbon_emission 5、revenue
% 由空闲时间计算的平滑度
idle_time_set=CT-ST_set;
count_idle_time=sum(idle_time_set);
idle_time_set_square=idle_time_set.^2;    
all_idle_time=sum(idle_time_set_square+0.1);
SI_basic_item1=(idle_time_set_square+0.1)./all_idle_time;
SI_basic_item2=log(SI_basic_item1);
SI_denomination=sum(SI_basic_item1.*SI_basic_item2);
SI=-1*log(workstation)/SI_denomination;

% 计算碳排放量
Cw=0.1*CT*total_stations*0.5617/3.6;
Ct=0;
sum_carbon_emission=0;
for ii2=1:local_parts_num
    Ct=Ct+sequence(5,ii2)*sequence(2,ii2)*0.5617/3.6;
end
Ch=CT*hazard_count*0.5617*0.02/3.6;
sum_carbon_emission=Cw+Ct+Ch;

% 计算收益
S=0;
for ii3=1:local_parts_num
    S=S+sequence(4,ii3)*sequence(2,ii3);
end
R=0;
for ii4=1:local_parts_num
    R=R+sequence(6,ii4);
end
part_revenue=R-0.05*CT*total_stations-S-0.01*CT*hazard_count;
% 将全部目标函数放入一个矩阵中
obj_vector=[workstation,SI,harmfulness,sum_carbon_emission,-1*part_revenue]; %比较最小值所以需要将收益变为负数

%% 现在需要将输入矩阵和计算得到的目标函数合并，先将输入序列的零件编号和来源 合并成一行矩阵
% 录入拆卸零件编号和来源信息
new_seq(1,1:V)=sequence_U(1,1:V);
% 在序列的最末端放入本次不完全拆卸的零件总数
new_seq(1,V+1)=local_parts_num;
% 在合并后的矩阵末端插入目标函数
new_seq(1,V+2:V+M+1)=obj_vector;


 end % 函数结束