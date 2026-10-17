function [fitness] = comparison_fitness(old_set,new_set,info,V,M,CT)
%用以判断两个解的适应度优劣

mix_data=[old_set;new_set];
mix_data=[mix_data zeros(2,7)];
for i=1:2 % 为生成的新解集赋予目标函数值
%     mix_data(i,:)=Algorithm_Straight_Gift_Obj(mix_data(i,:),info,M,CT);
    mix_data(i,:)=U_objective_function(mix_data(i,:),info,M,CT);
end
mixbest=Public_Nondominated_Sorting(mix_data, M, V+1);  % paroto排序选出最优解mixbest
mixbest(:,V+2:V+M+3)=[]; %去除后面的目标函数和帕累托值
mix_data(:,V+2:V+M+3)=[]; %去除后面的目标函数值

fitness = isequal(mixbest, mix_data); %若一致则返回1

end