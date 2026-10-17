function [after_mutation]=Algorithm_Ushaped_NSGA2(origin_Set,info,V,M,CT) 
%% 这一步函数是用来达到交换的目的的
[group_size,~]=size(origin_Set);
tour_size=2;
origin_Set=Algorithm_Public_NSGA2_tournament_selection(origin_Set, group_size, tour_size);

origin_Set(:,M+V+2:M+V+3)=0;
new_set=zeros(group_size,V+M+3);
ans_set=zeros(group_size,V+M+3);
for n=1:group_size/2
     P=rand(1);
      if(P<0.9)   
         M1=origin_Set(2*n-1,1:V+1);
         M2=origin_Set(2*n,1:V+1);
         M1=Algorithm_Ushaped_revive_seq(M1,M1(1,V+1),V);
         M2=Algorithm_Ushaped_revive_seq(M2,M2(1,V+1),V);
         M3=Algorithm_Ushaped_GA_merge(M1,M2,info);
         M4=Algorithm_Ushaped_GA_merge(M2,M1,info);
         new_set(2*n-1,1:V+1)=M3(1,:);
         new_set(2*n,1:V+1)=M4(1,:);
      else
         M1=origin_Set(2*n-1,1:V+1);
         M2=origin_Set(2*n,1:V+1);
         M1=Algorithm_Ushaped_revive_seq(M1,M1(1,V+1),V);
         M2=Algorithm_Ushaped_revive_seq(M2,M2(1,V+1),V);
         new_set(2*n-1,1:V+1)=M1(1,:);
         new_set(2*n,1:V+1)=M2(1,:);
      end   
end   
%% 从这里开始变异
after_mutation=zeros(group_size,V+M+3);
mutation_possibility=zeros(1,group_size);
for ii1=1:group_size
    mutation_possibility(1,ii1)=rand(1); % 这样每个个体就有了变异概率
end

for ii1=1:group_size
    if  mutation_possibility(1,ii1)<=0.1
        temp_individual=new_set(ii1,:);
        after_mutation(ii1,:)=Algorithm_Straight_GA_Neighbor_Search(temp_individual,V,info); %变异
    else
        after_mutation(ii1,:)=new_set(ii1,:);  % 不动,目标函数的值也不要改了
    end
    after_mutation(ii1,1:V)=Ushaped_reconstruct_seq(after_mutation(ii1,1:V),after_mutation(ii1,V+1));
    after_mutation(ii1,:)=U_objective_function(after_mutation(ii1,:),info,M,CT);
%     after_mutation(ii1,:)=Algorithm_Straight_Gift_Obj(after_mutation(ii1,:),info,M,CT);
end

end

