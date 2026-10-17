function [update_pop] = Algorithm_Ushaped_FLA(origin_pop,info,V,M,CT)
% % FLA 
% 模因组划分阶段
update_pop=zeros(1,V+1);
NS=10; % 模因组中解的数量 number of set
[group_size,~]=size(origin_pop);
K=group_size/NS; % 模因组数量
p=info{1,4};
dis=info{1,2};
origin_pop(:,V+2:V+M+3)=[];%去除后面的目标函数和帕累托值

for i1=1:NS
    subpop_1(i1,:)=origin_pop(1+(i1-1)*K,:);
    subpop_2(i1,:)=origin_pop(2+(i1-1)*K,:);
    subpop_3(i1,:)=origin_pop(3+(i1-1)*K,:);
    subpop_4(i1,:)=origin_pop(4+(i1-1)*K,:);
    subpop_5(i1,:)=origin_pop(5+(i1-1)*K,:);
end
% 模因组进化阶段

for i6=1:K
    P_gbest=origin_pop(1,:); % 全局最优解
    current_subpop=eval(['subpop_',num2str(i6)]);
    P_best=current_subpop(1,:);
    for i7=2:NS
        P_worst=current_subpop(i7,:);
        current_worst=P_worst; %存储P_worst
        P_worst=Algorithm_Ushaped_Pollination_FLA_1(P_best,P_worst,V,p); % FLA第一阶段
        % 判断新解与原解的适应度
        mix_data= [P_worst;current_worst];
        mix_data= [mix_data zeros(2,7)];
        for i8=1:2 % 为生成的新解集赋予目标函数值
             mix_data(i8,:)=U_objective_function(mix_data(i8,:),info,M,CT);
%             mix_data(i8,:)=Algorithm_Straight_Gift_Obj(mix_data(i8,:),info,M,CT);
        end
        mix_data=Public_Nondominated_Sorting(mix_data, M, V+1);  % paroto排序选出最优解
        mix_data(:,V+2:V+M+3)=[]; % 去除后面的目标函数和帕累托值
        P_worst=mix_data(1,:);
        result_1=isequal(P_worst, current_worst);
        if result_1 
             P_worst=Algorithm_Ushaped_Pollination_FLA_2(P_gbest,P_worst,V,p); % FLA第二阶段
             % 判断新解与原解的适应度
             mix_data= [P_worst;current_worst];
             mix_data=[mix_data zeros(2,7)];
             for i9=1:2 % 为生成的新解集赋予目标函数值
                   mix_data(i9,:)=U_objective_function(mix_data(i9,:),info,M,CT);
%                  mix_data(i9,:)=Algorithm_Straight_Gift_Obj(mix_data(i9,:),info,M,CT);
             end
             mix_data=Public_Nondominated_Sorting(mix_data, M, V+1);  % paroto排序选出最优解
             mix_data(:,V+2:V+M+3)=[]; % 去除后面的目标函数和帕累托值
             P_worst=mix_data(1,:);
             result_2=isequal(P_worst, current_worst);
             if result_2
                 random_set=zeros(1, 33);
                 random_set=Ushaped_line_uncomplete(info,CT,M); % 产生一个新解
                 random_set(:,V+2:V+M+3)=[]; % 去除后面的目标函数和帕累托值           
                 current_subpop(i7,:)=random_set;
             else
                 current_subpop(i7,:)=P_worst;
             end                          
        else
            current_subpop(i7,:)=P_worst;
        end                                             
    end
    
update_pop=[update_pop;current_subpop];
end
%% 合并子集
update_pop(1,:)=[];
% update_pop=[ ;subpop_2;subpop_3;subpop_4;subpop_5];
[m,~]=size(update_pop); % 提取解的总数
update_pop=[update_pop zeros(m,7)];
for i10=1:m % 为生成的新解集赋予目标函数值
%     update_pop(i10,:)=Algorithm_Straight_Gift_Obj(update_pop(i10,:),info,M,CT);
    update_pop(i10,:)=U_objective_function(update_pop(i10,:),info,M,CT);
end

end