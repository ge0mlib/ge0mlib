function Data=gDataFillPL(Data,frL,toL,FillNum)
%Fill data-matrix (traces) from Line1 to Line2 using number FillNum.
%function Data=gDataFillPL(Data,frL,toL,FillNum), where
%Data- input matrix with traces; Data(trace_length,trace_num);
%frL- from polyline: 1)polyline struct; 2)two rows polyline [trace_number; current_trace's_point_number]; 3)scalar; 4)if empty, than =1; 5)one rows polyline current_trace's_point_number for all traces;
%toL- to polyline: 1)polyline struct; 2)two rows polyline [trace_number; current_trace's_point_number]; 3)scalar; 4)if empty, than =1; 5)one rows polyline current_trace's_point_number for all traces;
%FillNum- number for filling;
%Data- output matrix.
%Example: Data=rand(9,5);Data1=gDataFillPL(Data,[1 2 3 4 5; 4 7 1 2 2],[1 2 3 4 5; 7 7 7 8 8],99);

sData2=size(Data,2);
if isempty(frL), frL=[1:sData2;ones(1,sData2)];
elseif all(isnumeric(frL))&&(numel(frL)==1), frL=[1:sData2;repmat(frL,1,sData2)];
elseif all(isnumeric(frL))&&(numel(frL)==sData2), frL=[1:sData2;frL(:)'];
elseif isstruct(frL), frL=frL.PickL;
else error('Error gDataFillPL: frL parameter error.');
end;
if isempty(toL), toL=[1:sData2;ones(1,sData2)];
elseif all(isnumeric(toL))&&(numel(toL)==1), toL=[1:sData2;repmat(toL,1,sData2)];
elseif all(isnumeric(toL))&&(numel(toL)==sData2), toL=[1:sData2;toL(:)'];
elseif isstruct(toL), toL=toL.PickL;
else error('Error gDataFillPL: toL parameter error.');
end;

if sData2~=size(frL,2), warning('Warning gDataFillPL: length fromLine and Data trace not equal');end;
if sData2~=size(toL,2), warning('Warning gDataFillPL: length toLine and Data trace not equal');end;
if any(frL(1,:)~=toL(1,:)), error('Error gDataFillPL: fromLineX~=toLineX');end;
if any(frL(2,:)>toL(2,:)), error('Error gDataFillPL: fromLineY>toLineY');end;
if any(isnan([toL(:);frL(:)])), warning('Warning gDataFillPL: NaN in frL or toL detected');end;

for nz=1:size(toL,2),
    if all(~isnan([toL(:,nz);frL(:,nz)])),
        Data(frL(2,nz):toL(2,nz),toL(1,nz))=FillNum;
    end;
end;

%mail@ge0mlib.com 18/10/2016