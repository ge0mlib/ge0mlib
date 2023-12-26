function fi=gFieldsRowInsert(fi,dat,st_num,len)
%Insert dat to structure's Rows in position st_num; key for structure's field choice is field row length (len).
%Insert data “dat” into rows structure “fi”, if fields (rows) length is “len”; data insert in position “st_num”.
%function fi=gFieldsRowInsert(fi,dat,st_num,len), where
%fi - structure with rows-fields (one or a number of row);
%dat - data row for insert;
%st_num - structure's Rows position for insert;
%len - rows-fields length in fi will be active in appending (key for structure's fields choice).
%If fields are a number of rows, dat will apply to each row.
%Example: fi1=gFieldsRowInsert(fi,[1 2 3 4],10,3000);

names=fieldnames(fi);
for n=1:size(names,1),
    a=fi.(names{n});
    if size(a,2)==len, fi.(names{n})=[a(:,1:st_num-1) repmat(dat,size(a,1),1) a(:,st_num:len)];end;
end;

%mail@ge0mlib.ru 17/02/2017