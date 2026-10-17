function [After_Optimize_Set] = Public_Algorithm_Select(Origin_set,alg_num,info,V,M,CT,It,It_Time,memeplex_num,elite_rate)
% Public_Algorithm_Select 此函数用于分配优化函数使用的具体算法
% 算法编号 1-CTFLA 2-IMOBFO 3-NSGA2 4-DABC 5-FLA
% 新增可选参数：memeplex_num-子种群数量, elite_rate-精英保留率（仅CTFLA使用）
if nargin < 10; elite_rate = 0.5; end   % 向后兼容默认精英保留率
if nargin < 9;  memeplex_num = 5; end  % 向后兼容默认子种群数量
switch alg_num
    case 1 % 1-CTFLA
        After_Optimize_Set=Algorithm_Ushaped_CTFLA(Origin_set,info,V,M,CT,It,It_Time,memeplex_num,elite_rate);
    case 2 % 2-IMOBFO
        After_Optimize_Set=Algorithm_Ushaped_IMOBFO(Origin_set,info,V,M,CT); 
    case 3 % 3-NSGA2
        After_Optimize_Set=Algorithm_Ushaped_NSGA2(Origin_set,info,V,M,CT);   
    case 4 % 4-DABC
        After_Optimize_Set=Algorithm_Ushaped_DABC(Origin_set,info,V,M,CT,It,It_Time);      
    case 5 % 5-FLA
        After_Optimize_Set=Algorithm_Ushaped_FLA(Origin_set,info,V,M,CT);    
end
end