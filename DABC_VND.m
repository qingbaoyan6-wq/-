function [X_NEW] = DABC_VND(XI,p,V,info,M,CT)

%两点插入
X_NEW1=transformation_insertion(XI,p,V);
X_NEW2=transformation_insertion(X_NEW1,p,V);
% 比较新旧解的适应度值
fit= comparison_fitness(XI,X_NEW2,info,V,M,CT);
% 如果新解的适应度值优于初始解，则更新
if fit==0
    XI = X_NEW2;
end
%单点插入
X_NEW3=transformation_insertion(XI,p,V);
fit= comparison_fitness(XI,X_NEW3,info,V,M,CT);
% 如果新解的适应度值优于初始解，则更新
if fit==0
    XI = X_NEW3;
end
X_NEW=XI;
end

    

