function [name] = Public_road_create(alg_num)
%保存文件夹选择
    name='D:\文献\金锐硕士文件\1.大论文\Algorithm_DLBP_U_New\';
    name=[name,'U\'];
    
    switch alg_num
        case 1
            name=[name,'1、CTFLA\'];
        case 2
            name=[name,'2、IMOBFO\'];
        case 3
            name=[name,'3、NSGA2\'];
        case 4
            name=[name,'4、DABC\'];
        case 5
            name=[name,'5、FLA\'];

    end

end