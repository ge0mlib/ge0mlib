function fi=gFields2RowGet(fi,len,mask)
%Get data from structure fi, using mask; key for structure fields choice is fields row length (len).
%The output structure “fi” will create; it contained fields with length “len”, and applied “mask”.
%function fi=gFieldsRowGet(fi,len,mask), where
%fi - structure with fields (one or a number of row);
%len - target fields row length (key for structure fields choice);
%mask - mask for data get along row.
%Mathematics: fi.zzz=fi.zzz(mask), where zzz - all fields with size(2)==len.
%Example: a=gFieldsRowGet(b,30000,10:100);

names=fieldnames(fi);
for n=1:size(names,1),
    a=fi.(names{n});if size(a,2)==len,fi.(names{n})=a(:,mask);end;
end;

%mail@ge0mlib.ru 02/08/2016