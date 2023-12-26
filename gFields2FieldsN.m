function fi=gFields2FieldsN(fi,fiName,N,key1,key2)
%Tramsform structure fi(1..N).X with row for each X, to fi(1..N).X with matrix for each X, using row/column number N and number of elements for field fiName.
%The output structure fi will create; transformed only fields from fi, with original length equal fi.(fiName)
%function fi=gFields2FieldsN(fi,fiName,N,key1,key2), where
%fi - structure with fields;
%fiName - name of key-field to define number of elements for each fi(1..N); 
%N - number of raw for output matrix for each fi(1..N).X;
%key1 - the key of sequence for reshape row to matrix; key1=0 >> [1 2 1 2 1 2 1 2],reshape(a,2,4); key1=1 >> [1 1 1 1 2 2 2 2],reshape(a,4,2)';
%key2 - the key of rule "keep first raw only, if each raw equal first".
%Example: Data1=gFields2nFields(Data,'DB_number');

names=fieldnames(fi);
for nn=1:numel(fi),
    len=numel(fi(nn).(fiName));
    for n=1:size(names,1),
        a=fi(nn).(names{n});
        if size(a,2)==len,
            if key1==0, fi(nn).(names{n})=reshape(a,N,len./N);elseif key1==1, fi(nn).(names{n})=reshape(a,len./N,N)';end;
            if key2,
                if isnumeric(fi(nn).(names{n})(1)),fl=0;elseif ischar(fi(nn).(names{n}){1}),fl=1;else,error('Type of field is not detect');end;
                if fl,
                    if all(all(strcmp(repmat(fi(nn).(names{n})(1,:),[N 1]),fi(nn).(names{n})))),fi(nn).(names{n})=fi(nn).(names{n})(1,:);end;
                else
                    if all(all(repmat(fi(nn).(names{n})(1,:),[N 1])==fi(nn).(names{n}))),fi(nn).(names{n})=fi(nn).(names{n})(1,:);end;
                end;
            end;
        end;
    end;
end;

%mail@ge0mlib.ru 12/10/2023