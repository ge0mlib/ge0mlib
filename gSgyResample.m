function [SgyHead,Head,Data1]=gSgyResample(SgyHead,Head,Data,siNew)
%Interpolate Sgy-section form current SampleInterval to new SampleInterval (data repeat or delete).
%function [SgyHead,Head,Data1]=gSgyResample(SgyHead,Head,Data,siNew), where
%[SgyHead,Head,Data]- Sgy input variables;
%siNew- new SampleInterval in microseconds for all traces;
%[SgyHead,Head,Data1]- Sgy output variables.
%Example: [SgyHead,Head,Data]=gSgyRead(['c:\temp\1.sgy'],'',[]);[SgyHead1,Head1,Data1]=gSgyResample(SgyHead,Head,Data,6);

if ischar(Data),Data=gDataLoad(Data);end;
if ~all(Head.dt==Head.dt(1)), error('Different SampleInterval for traces');end;
if ~all(Head.DelayRecordingTime==Head.DelayRecordingTime(1)), error('Different DelayRecordingTime for traces');end;
no=0:(size(Data,1)-1);to=no.*Head.dt(1);tn=0:siNew:to(end);
nn=round(interp1(to,no,tn,'linear'))+1;
Data1=Data(nn,:);
Head.UnassignedInt1=round((Head.UnassignedInt1-1).*Head.dt(1)./siNew)+1;%change sbp-current-bottom
Head.UnassignedInt2=round((Head.UnassignedInt2-1).*Head.dt(1)./siNew)+1;%change sbp-primary-bottom
Head.ns(:)=fix((Head.ns-1).*Head.dt(1)./siNew)+1;SgyHead.ns=max(Head.ns);
Head.dt(:)=siNew;SgyHead.dt=siNew;

%mail@ge0mlib.com 16/10/2017