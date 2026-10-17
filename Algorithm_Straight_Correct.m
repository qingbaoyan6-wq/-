function [best] =Algorithm_Straight_Correct(best_set,normal_set,V)
% correct 由于不完全拆卸特殊性，需要对最优解和可能成为最优解的最优解进行处理
% 需要注意，找到相同的零件编号不一定说明normal中存在此零件，必须要零件编号与零件索引都相同才可以
% 总零件数
different_point=0;
best=best_set;
for ii1=1:best_set(1,V+1)
    judge=find(normal_set(1:normal_set(1,V+1))==best_set(1,ii1), 1);
    if isempty(judge)==1  % 第一种情况——完全没有同零件编号
        for ii2=(ii1-different_point):V-1
            best(1,ii2)=best(1,ii2+1);
        end
          best(1,V)=0;
          different_point=different_point+1;
    end
end
best(1,V+1)=best_set(1,V+1)-different_point;
end
