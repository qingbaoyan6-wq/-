function [update_set] = Algorithm_Ushaped_IMOBFO_Dispersion(current_set,p,V,h)
switch h
    case 1
        update_set=transformation_exchanged(current_set,p,V);% 交换
    case 2
        update_set=transformation_insertion(current_set,p,V);%% 插入
    case 3
        update_set=transformation_left_reconstruction(current_set,p,V);%% 左重构
    case 4
        update_set=transformation_right_reconstruction(current_set,p,V);%% 右重构
end     
end