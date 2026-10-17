function [res]=Algorithm_Ushaped_revive_seq(seq,length,V) 
%revive_seq 该函数用于将U型拆卸线序列恢复成正常序列，便于判断合理性
res=zeros(1,V+1);
front=1;
back=length;
for ii1=1:length
    if seq(1,ii1)>0
        res(1,front)=seq(1,ii1);
        front=front+1;
    elseif seq(1,ii1)<0
        res(1,back)=-1*seq(1,ii1);
        back=back-1;
    end
end
res(1,V+1)=length;
end