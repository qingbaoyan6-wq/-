function [sequence] = Ushaped_reconstruct_seq(sequence,parts)
%RECONSTRUCT_SEQ : 将一般的序列转化成U-type的专用序列，只在生成新序列的时候用

Utype_seq=zeros(1,parts);
head_point=0; 
rare_point=parts+1;
for ii1=1:parts
     start_point=unidrnd(2);
     if  start_point==1 % 从头部开始取
         temp_index=head_point+1;
         Utype_seq(1,ii1)=sequence(1,temp_index);
         head_point=head_point+1;         
     else % 从尾部取
         temp_index=rare_point-1;
         Utype_seq(1,ii1)=-sequence(1,temp_index);
         rare_point=rare_point-1;
     end    
end
sequence(1,1:parts)=Utype_seq;

end