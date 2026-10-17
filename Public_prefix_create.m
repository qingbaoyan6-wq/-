function [name] = Public_prefix_create(alg_num)
%算法选择
    name='';
    switch alg_num
        case 1
            name=[name,'CTFLA_'];
        case 2
            name=[name,'IMOBFO_'];
        case 3
            name=[name,'NSGA2_'];
        case 4
            name=[name,'DABC_'];
        case 5
            name=[name,'FLA_'];
    end
    name=[name,'U_'];
end