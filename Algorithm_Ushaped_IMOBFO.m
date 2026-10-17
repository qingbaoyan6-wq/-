function [update_pop] = Algorithm_Ushaped_IMOBFO(origin_pop,info,V,M,CT)
% 细菌觅食算法改进算法IMOBFO
[group_size,~]=size(origin_pop);
p=info{1,4};
dis=info{1,2};
update_pop=origin_pop; %存储初始解集
update_pop(:,V+2:V+M+3)=[];%去除后面的目标函数和帕累托值
fit=1;
%% 趋化
% 初始化变换方式表现计数
performance = ones(1, 4);
% 遍历每个解
for i1 = 1:group_size
    % 针对当前解使用轮盘赌选择序列变换方式
    for i2 = 1:4
        % 计算当前变换方式的被选中概率
        probability = performance(i2) / sum(performance);         
        % 生成0到1之间的随机数
        rand_num = rand();       
        % 如果随机数小于等于概率，则选中该变换方式
        if rand_num <= probability
            % 根据选中的变换方式对当前解进行变换
            new_solution = Algorithm_Ushaped_IMOBFO_Dispersion(update_pop(i1,:),p,V,i2);        
            % 比较新旧解的适应度值
            fit= comparison_fitness(update_pop(i1,:),new_solution,info,V,M,CT);
            % 如果新解的适应度值优于初始解，则更新表现计数
            if fit==0
                performance(i2) = performance(i2) + 1;
                update_pop(i1,:)=new_solution;
            end          
        end
    end
end
%% 繁殖
% 保留前50%个体
update_pop=[update_pop zeros(group_size,M+2)];
for i3=1:group_size % 为生成的新解集赋予目标函数值
    update_pop(i3,:)=U_objective_function(update_pop(i3,:),info,M,CT);
%     update_pop(i3,:)=Algorithm_Straight_Gift_Obj(update_pop(i3,:),info,M,CT);
end
update_pop=Public_Nondominated_Sorting(update_pop, M, V+1);  % paroto排序
pro_pop=update_pop(1:group_size/2,:);
pro_pop(:,V+2:V+M+3)=[];%去除后面的目标函数和帕累托值
% 产生新个体
new_set=zeros(group_size/2,V+M+3);
for n=1:group_size/2-1
    P=rand(1);
    if P<0.9 %PPX交叉产生新个体
        M1=pro_pop(n,:);
        M2=pro_pop(n+1,:);
        M3=Algorithm_Ushaped_merge(M1,M2,info);
        M4=Algorithm_Ushaped_merge(M2,M1,info);
        new_set(n,1:V+1)=M3(1,:);
        new_set(n+1,1:V+1)=M4(1,:);
    else %随机复制
        M1=pro_pop(n,:);
        M2=pro_pop(n+1,:);
        new_set(n,1:V+1)=M1(1,:);
        new_set(n+1,1:V+1)=M2(1,:);
    end
end
pro_pop=[pro_pop zeros(group_size/2,M+2)];
update_pop=[pro_pop;new_set];
%% 迁移
Pm=0.1;
for i=1:group_size
    PQ=rand(1); % 迁移算子
    if PQ<Pm
        update_pop(i,:)=Ushaped_line_uncomplete(info,CT,M); % 产生一个新解
    end
end
% 为生成的新解集赋予目标函数值
for i4=1:group_size 
    update_pop(i4,:)=U_objective_function(update_pop(i4,:),info,M,CT);
%     update_pop(i4,:)=Algorithm_Straight_Gift_Obj(update_pop(i4,:),info,M,CT);
end
update_pop=Public_Nondominated_Sorting(update_pop, M, V+1);  % paroto排序

end




