function varargout=gDataToPL(Data,frL,toL)
%Shifted data-matrix (traces) from polyline1 to polyline2 (like to "rotation" in circle, where trace's start and end are connected).
%function Data=gDataToPL(Data,frL,toL), where
%Data- input matrix with traces; Data(trace_length,trace_num);
%frL- from polyline: 1)polyline struct; 2)two rows polyline [trace_number; current_trace's_point_number]; 3)scalar; 4)one rows polyline current_trace's_point_number for all traces;
%toL- to polyline: 1)polyline struct; 2)two rows polyline [trace_number; current_trace's_point_number]; 3)scalar; 4)one rows polyline current_trace's_point_number for all traces;
%The traces will be shift from frL_current_trace's_point_number to toL_current_trace's_point_number; frL or toL can be scalar, with trace's_point_number for all traces.
%varargout{1}=Data- output matrix with shifred (rotated) traces;
%varargout{2}=dL- shift value fromLine-toLine.
%Example: Data=rand(9,5);Data1=gDataToPL(Data,[1 2 3 4 5; 4 7 1 2 2],[1 2 3 4 5; 7 7 7 8 8]);Data1=gDataToPL(Data,4,2);

sData2=size(Data,2);
if isscalar(frL)&&all(isnumeric(frL)), frL=[1:sData2;repmat(frL,1,sData2)];
elseif all(isnumeric(frL))&&(numel(frL)==sData2), frL=[1:sData2;frL(:)'];
elseif all(isnumeric(frL))&&(size(frL,2))==sData2,
elseif isstruct(frL), frL=frL.PickL;
else error('Error gDataToPL: frL parameter error.');
end;
if isscalar(toL)&&all(isnumeric(toL)), toL=[1:sData2;repmat(toL,1,sData2)];
elseif all(isnumeric(toL))&&(numel(toL)==sData2), toL=[1:sData2;toL(:)'];
elseif all(isnumeric(toL))&&(size(toL,2))==sData2,    
elseif isstruct(toL), toL=toL.PickL;
else error('Error gDataToPL: toL parameter error.');
end;

if sData2~=size(frL,2), warning('Warning gDataToPL: length fromLine and Data trace number is not equal');end;
if sData2~=size(toL,2), warning('Warning gDataToPL: length toLine and Data trace number is not equal');end;
if any(frL(1,:)~=toL(1,:)), error('Error gDataToPL: fromLineX~=toLineX');end;
if any(isnan([toL(:);frL(:)])), warning('Warning gDataToPL: NaN in frL or toL detected');end;

sz=size(Data,1);
for nz=1:size(toL,2),
    if all(~isnan([toL(:,nz);frL(:,nz)])),
        n=toL(1,nz);
        if frL(2,nz)<toL(2,nz), Data(:,n)=[Data(frL(2,nz)+sz-toL(2,nz)+1:end,n);Data(1:frL(2,nz)+sz-toL(2,nz),n)];end;        
        if frL(2,nz)>toL(2,nz), Data(:,n)=[Data(frL(2,nz)-toL(2,nz)+1:end,n);Data(1:frL(2,nz)-toL(2,nz),n)];end;
    end;
end;
varargout{1}=Data;
varargout{2}=toL(2,:)-frL(2,:);

%mail@ge0mlib.com 18/10/2016