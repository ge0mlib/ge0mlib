function DataFName=gFieldsTakeFData(Prof,FName)
%Take data from field-structure using string-name with sub-fields, without any numbers (example: 'info.data1.vels') or create cell with name’s parts.
%function DataFName=gFieldsTakeFData(Prof,FName), where
%Prof- structure with sub-fields;
%FName- string-name with sub-fields, without first point in name (example: 'info.data1.vels');
%DataFName- data extracted from sub-field
%DataFName- if Prof is empty, than DataFName is cells Nm for using with getfield(Prof,Nm{:}).
%Example: 
%a=gFieldsTakeFData(Prof{10},'Mag.DepthRaw');b=gFieldsTakeFData([],'Mag.DepthRaw');

L=find(FName=='.');
%cut string to field-names-in-cells
if numel(L)==0, Nm={FName};
else Nm=cell(numel(L)+1,1);
    Nm{1}=FName(1:L(1)-1);for n=1:numel(L)-1, Nm{n+1}=FName(L(n)+1:L(n+1)-1);end;Nm{end}=FName(L(numel(L))+1:end);
end; 
%create output
if isempty(Prof), DataFName=Nm; else DataFName=getfield(Prof,Nm{:});end; %getfield

%mail@ge0mlib.ru 12/08/2019