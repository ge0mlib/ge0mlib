function [SgyHead,Head,Data1]=gSgySetDelayRecTime(SgyHead,Head,Data,DeT)
%Change Sgy DelayRecordingTime for each trace; add or delete trace's parts for Data.
%function [SgyHead,Head,Data1]=gSgySetDelayRecTime(SgyHead,Head,Data,DeT), where
%[SgyHead,Head,Data]- Sgy input variables;
%DeT- scalar (apply to all traces) or row (apply to each own trace) with new DelayRecordingTime in milliseconds;
%[SgyHead,Head,Data1]- Sgy output variables;
%Sgy Head fields changed: Head.DelayRecordingTime; Head.ns; Head.UnassignedInt1; Head.UnassignedInt2; SgyHead.FixedLengthTraceFlag; 
%if DelayRecordingTime bigger than trace length, than trace_data_samples number (Head.ns(n)) set to 1; Data sample set to 0.
%Example: [SgyHead,Head,Data]=gSgyRead(['c:\temp\1.sgy'],'',[]);[SgyHead1,Head1,Data1]=gSgySetDelayRecTime(SgyHead,Head,Data,0);

if ischar(Data),Data=gDataLoad(Data);end;

if ~all(Head.dt==Head.dt(1)), error('Head.dt not equal for all traces');end;
if SgyHead.dt~=Head.dt(1), error('Head.dt not equal SgyHead.dt');end;
if SgyHead.dt~=SgyHead.dtOrig, warning('Head.dt not equal SgyHead.dtOrig');end;
if DeT~=round(DeT), error('DeT must be integer-valued');end;

NTrace=size(Head.dt,2);%traces number
if isscalar(DeT), DeT=repmat(DeT,1,NTrace);end;%DelayTime for all traces from scalar
DeS=round((Head.DelayRecordingTime-DeT).*1000./Head.dt);%DelayTime shift in Samples for each trace
d=Head.ns+DeS;
Data1=nan(max(d),NTrace);%Trase Data Allocate // used max number samples in traces after Delay appying
for n=1:NTrace,
    if d(n)>0,
        if DeS(n)>=0, Data1(DeS(n)+1:d(n),n)=Data(1:Head.ns(n),n);end;
        if DeS(n)<0, Data1(1:d(n),n)=Data(-DeS(n)+1:Head.ns(n),n);end;
        Head.UnassignedInt1=Head.UnassignedInt1+DeS;Head.UnassignedInt2=Head.UnassignedInt2+DeS;
    end;
end;
L=d>0;Head.ns(L)=d(L);Head.ns(~L)=1;Data1(1,~L)=0;
if all(Head.ns==Head.ns(1)),SgyHead.FixedLengthTraceFlag=1;SgyHead.ns=Head.ns(1);SgyHead.nsOrig=Head.ns(1); else SgyHead.FixedLengthTraceFlag=0;end;
Head.DelayRecordingTime=DeT;

%mail@ge0mlib.com 15/08/2016
