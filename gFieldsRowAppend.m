function fi1=gFieldsRowAppend(fi1,fi2,len)
%Append Rows contents for two structures; key for structure's field choice is field row length (len).
%Append “fi2” rows to the end of “fi1” rows, for “fi1” field with length “len”.
%function fi1=gFieldsRowAppend(fi1,fi2,len), where
%fi1 - structure1 with rows-fields;
%fi2 - structure2 for fields-rows-contents appending;
%len - rows-fields length in fi1 will be active in appending (key for structure's fields choice).
%Example: fi3=gFieldsRowAppend(fi1,fi2,3000);

names=fieldnames(fi1);
for n=1:size(names,1),
    a=fi1.(names{n});
    if size(a,2)==len, fi1.(names{n})=[a fi2.(names{n})];end;
end;

%mail@ge0mlib.ru 13/08/2022