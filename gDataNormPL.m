function Data=gDataNormPL(Data,frL,toL,param)
%Normalize traces/columns between polyline1 and polyline2.
%function Data=gDataNormPL(Data,frL,toL,param), where
%Data- input matrix with traces; Data(trace_length,trace_num);
%frL- from polyline: 1)polyline struct; 2)two rows polyline [trace_number; trace's_point_number]; 3)scalar; 4)if empty, than =1; 5)[trace's_point_number] for all traces;
%toL- to polyline: 1)polyline struct; 2)two rows polyline [trace_number; trace's_point_number]; 3)scalar; 4)if empty, than =end; 5)[trace's_point_number] for all traces;
%param(1)- normalization type: 0)Data-mean(Data); 1)Data/mean(abs(Data)); 2)Data/std(Data);
%param(2)- exception scalar (for example: Nan, 0, etc);
%Data- output matrix with normalized traces.
%Example: Data=rand(9,5);Data1=gDataNormPL(Data,[1 2 3 4 5; 4 7 1 2 2],[1 2 3 4 5; 7 7 7 8 8]);Data1=gDataNormPL(Data,4,2,[0 nan]);

sData2=size(Data,2);
if isempty(frL), frL=[1:sData2;ones(1,sData2)];
elseif isnumeric(frL)&&(numel(frL)==1), frL=[1:sData2;repmat(frL,1,sData2)];
elseif all(isnumeric(frL))&&(numel(frL)==sData2), frL=[1:sData2;frL(:)'];
elseif isstruct(frL), frL=frL.PickL;
else error('frL parameter error.');
end;
if isempty(toL), toL=[1:sData2;repmat(size(Data,1),1,sData2)];
elseif isnumeric(toL)&&(numel(toL)==1), toL=[1:sData2;repmat(toL,1,sData2)];
elseif all(isnumeric(toL))&&(numel(toL)==sData2), toL=[1:sData2;toL(:)'];
elseif isstruct(toL), toL=toL.PickL;
else error('toL parameter error.');
end;

if sData2~=size(frL,2), warning('Length fromLine and Data trace number is not equal');end;
if sData2~=size(toL,2), warning('Length toLine and Data trace number is not equal');end;
if any(frL(1,:)~=toL(1,:)), error('FromLineX~=toLineX');end;
if any(frL(2,:)>toL(2,:)), error('FromLineY>toLineY');end;
if any(isnan([toL(:);frL(:)])), warning('NaN in frL or toL detected');end;

for nz=1:size(toL,2),
    if all(~isnan([toL(:,nz);frL(:,nz)])),
        n=toL(1,nz);z=Data(frL(2,nz):toL(2,nz),n);L=(z==param(2));
        switch param(1),
            case 0, nm=mean(z(~L));Data(:,n)=Data(:,n)-nm;
            case 1, nm=mean(abs(z(~L)));Data(:,n)=Data(:,n)./nm;
            case 2, nm=std(z(~L));Data(:,n)=Data(:,n)./nm;
            otherwise, error('Param error');
        end;
    end;
end;

%mail@ge0mlib.com 17/10/2016