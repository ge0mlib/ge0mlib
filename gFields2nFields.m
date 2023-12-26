function fi1=gFields2nFields(fi,fiName)
%Tramsform structure fi, to fi(1..N) using equalency of data from field fiName as a key.
%The output structure fi1(1..N) will create; it includes only fields from fi, with original length equal fi.(fiName)
%function fi1=gFields2nFields(fi,fiName), where
%fi - structure with fields;
%fiName - name of key-field; the equalency of data from field fiName use for data choice/separating;
%fi1 - output structure fi1(1..N) with fields.
%Example: Data1=gFields2nFields(Data,'DB_number');

len=size(fi.(fiName),2);mask=true(1,len);names=fieldnames(fi);nn=0;
if isnumeric(fi.(fiName)(1)),fl=0;elseif ischar(fi.(fiName){1}),fl=1;else,error('Type of field is not detect');end;
while any(mask), nn=nn+1;
    L1=find(mask,1);
    if fl,L=strcmp(fi.(fiName),fi.(fiName){L1});else,L=fi.(fiName)==fi.(fiName)(L1);end;
    mask=mask&(~L);
    for n=1:size(names,1),
        a=fi.(names{n});if size(a,2)==len,fi1(nn).(names{n})=a(:,L);end;
    end;
end;

%mail@ge0mlib.ru 12/10/2023