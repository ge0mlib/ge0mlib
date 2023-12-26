function fi=gFieldsRowSet(fi,len,mask,dat)
%Set dat to structure fi, using mask; key for structure fields choice is fields row length (len).
%Write “dat” to fields with length “len”, using “mask” position. The function usually used to delete some row numbers for row-content.
%function fi=gFieldsRowSet(fi,len,mask,dat), where
%fi - structure with fields (one or a number of row);
%len - target fields row length (key for structure fields choice);
%mask - mask for data change along row;
%dat - new data for fi.zzz(mask).
%If fields are a number of rows, dat will apply to each row.
%Mathematics: Tfi.zzz(n,mask)=dat, where zzz - all fields with size(2)==len.
%Example: a=gFieldsRowSet(b,30000,[10 100 1000],1.25);a=gFieldsRowSet(b,30000,[10 100 1000],[]);a=gFieldsRowSet(b,30000,[10 100 1000],[1 2 3]);

names=fieldnames(fi);
for n=1:size(names,1),
    a=fi.(names{n});
    if size(a,2)==len, 
        if isempty(dat),a(:,mask)=[];
        elseif all(size(dat)==1), a(:,mask)=dat;
        else a(:,mask)=repmat(dat,size(a,1),1);
        end;
        fi.(names{n})=a;
    end;
end;

%mail@ge0mlib.ru 10/02/2017