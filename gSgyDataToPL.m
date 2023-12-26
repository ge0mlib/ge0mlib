function [Head,Data]=gSgyDataToPL(Head,Data,frL,toL)
%Shifted Sgy Data matrix from polyline1 to polyline2; apply shift mod(1ms) to DelayRecTime
%function [Head,Data]=gSgyDataToPL(Head,Data,frL,toL), where
%Head- segy structure;
%Data- input matrix with traces; Data(trace_length,trace_num);
%frL- from polyline: 1)polyline struct; 2)two rows polyline [trace_number; current_trace's_point_number]; 3)scalar; 4)one rows polyline current_trace's_point_number for all traces;
%toL- to polyline: 1)polyline struct; 2)two rows polyline [trace_number; current_trace's_point_number]; 3)scalar; 4)one rows polyline current_trace's_point_number for all traces;
%The traces will be shift from frL_current_trace's_point_number to toL_current_trace's_point_number; frL or toL can be scalar, with trace's_point_number for all traces.
%Segy Head field changed: Head.DelayRecordingTime.
%Example: [SgyHead,Head,Data]=gSgyRead(['c:\temp\1.sgy'],'',[]);[Head1,Data1]=gSgyDataToPL(Head,Data,1,84);

if ischar(Data),Data=gDataLoad(Data);end;
if ~all(Head.dt==Head.dt(1)), error('Head.dt not equal for all traces');end;

sData2=size(Data,2);
if isscalar(frL)&&all(isnumeric(frL)), frL=[1:sData2;repmat(frL,1,sData2)];
elseif all(isnumeric(frL))&&(numel(frL)==sData2), frL=[1:sData2;frL(:)'];
elseif isstruct(frL), frL=frL.PickL;
else error('frL parameter error');
end;
if isscalar(toL)&&all(isnumeric(toL)), toL=[1:sData2;repmat(toL,1,sData2)];
elseif all(isnumeric(toL))&&(numel(toL)==sData2), toL=[1:sData2;toL(:)'];
elseif isstruct(toL), toL=toL.PickL;
else error('toL parameter error');
end;

if sData2~=size(frL,2), warning('Length fromLine and Data trace number is not equal');end;
if sData2~=size(toL,2), warning('Length toLine and Data trace number is not equal');end;
if any(frL(1,:)~=toL(1,:)), error('fromLineX~=toLineX');end;
if any(isnan([toL(:);frL(:)])), warning('NaN in frL or toL detected');end;
if (size(frL,2)==size(toL,2))&&(size(frL,2)==sData2)&&~any(isnan([toL(:);frL(:)])),
    dL=toL(2,:)-frL(2,:);ms=round(mean(Head.dt./1000.*dL));
    Head.DelayRecordingTime=Head.DelayRecordingTime+ms;
    toL(2,:)=toL(2,:)-round(ms./Head.dt.*1000);
end;

sz=size(Data,1);
for nz=1:size(toL,2),
    if all(~isnan([toL(:,nz);frL(:,nz)])),
        n=toL(1,nz);
        if frL(2,nz)<toL(2,nz), Data(:,n)=[Data(frL(2,nz)+sz-toL(2,nz)+1:end,n);Data(1:frL(2,nz)+sz-toL(2,nz),n)];end;        
        if frL(2,nz)>toL(2,nz), Data(:,n)=[Data(frL(2,nz)-toL(2,nz)+1:end,n);Data(1:frL(2,nz)-toL(2,nz),n)];end;
        Head.UnassignedInt1(n)=Head.UnassignedInt1(n)+toL(2,nz)-frL(2,nz);%change sbp-current-bottom
        Head.UnassignedInt2(n)=Head.UnassignedInt2(n)+toL(2,nz)-frL(2,nz);
    end;
end;

%mail@ge0mlib.com 14/10/2017