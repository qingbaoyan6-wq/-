function [update_pop] = Algorithm_Ushaped_DABC(origin_pop,info,V,M,CT,It,It_Time)

[group_size,~]=size(origin_pop);
p=info{1,4};
dis=info{1,2};
update_pop=origin_pop; %存储初始解集
update_pop(:,V+2:V+M+3)=[];%去除后面的目标函数和帕累托值

%% 蜜源初始化
X_best=update_pop(1,:);
%% 雇佣蜂阶段
for i1=1:group_size
    XI=update_pop(i1,:);
    update_pop(i1,:)=DABC_VND(XI,p,V,info,M,CT);
end

%% 围观阶段+侦察阶段
for i2=1:group_size
    random_integers = randperm(50, 4);
    four_pop=zeros(4,V+1);
    for i3=1:4
        four_pop(i3,:)=update_pop(random_integers(1,i3),:);
    end
    four_pop=[four_pop zeros(4,M+2)]; %锦标赛选择
    for i4=1:4 % 为生成的新解集赋予目标函数值
        four_pop(i4,:)=U_objective_function(four_pop(i4,:),info,M,CT);
%         four_pop(i4,:)=Algorithm_Straight_Gift_Obj(four_pop(i4,:),info,M,CT);
    end
    four_pop = Public_Nondominated_Sorting(four_pop, M, V+1);
    Xi=four_pop(1,:);
    Xi(:,V+2:V+M+3)=[];%去除后面的目标函数和帕累托值
    update_pop(i2,:)=DABC_VND(Xi,p,V,info,M,CT);      
end

% 侦察蜂阶段
% if It>It_Time/2
    for i5=1:group_size
        Xi=update_pop(i5,:);
        r = randi([0, 2]);
        if r==1 %进行左重构
            Xi_new=transformation_left_reconstruction(Xi,p,V); %% 左重构
            fit= comparison_fitness(Xi,Xi_new,info,V,M,CT);
            % 如果新解的适应度值优于初始解，则更新
            if fit==0
                Xi = Xi_new;
            end
        else % 进行右重构
            Xi_new=transformation_right_reconstruction(Xi,p,V);%% 右重构
            fit= comparison_fitness(Xi,Xi_new,info,V,M,CT);
            % 如果新解的适应度值优于初始解，则更新
            if fit==0
               Xi = Xi_new;
            end
        end
       update_pop(i5,:)=Xi;                
    end
    
% end
%% 为生成的新解集赋予目标函数值
update_pop=[update_pop zeros(group_size,M+2)];
for i6=1:group_size 
     update_pop(i6,:)=U_objective_function( update_pop(i6,:),info,M,CT);
%     update_pop(i6,:)=Algorithm_Straight_Gift_Obj(update_pop(i6,:),info,M,CT);
end
update_pop=Public_Nondominated_Sorting(update_pop, M, V+1);  % paroto排序
end


