 function [res_jud]=Straight_matchprocess(judging_seq,length,p)
%matchprocess 用于检测交叉后的序列是否符合基本法

mirror_seq=judging_seq(1,1:length);

for ii1=1:length % 需要保证这里检查的次数和有效序列长度一致
         temp_part=abs(mirror_seq(1,ii1));
         if  p(:,temp_part)==0  % 说明当前零件可拆去！！
             p(temp_part,:)=0;  % 将之拆去，更新p
         else
               break;
         end  
end

if  ii1<length
    res_jud=0;  % 说明不成功
else
    res_jud=1;  % 说明序列符合逻辑
end

end