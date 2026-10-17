function [seq] = Algorithm_Straight_sequence_change(index1,index2,seq)
%将变异重组后的序列索引改变
part=seq(1,index1);
seq(1,index1)=seq(1,index2);
seq(1,index2)=part;
end
