function [res]=Algorithm_Ushaped_revive_seq_objective(seq,length,V) 
%revive_seq 该函数用于将U型拆卸线序列恢复成正常序列,附带其他信息
res=zeros(8,V);
front=1;
back=length;
for ii1=1:length
    if seq(1,ii1)>0
        res(1:8,front)=seq(1:8,ii1);
        front=front+1;
    elseif seq(1,ii1)<0
        res(1,back)=-1*seq(1,ii1);
        res(2:8,back)=seq(2:8,ii1);
        back=back-1;
    end
end
