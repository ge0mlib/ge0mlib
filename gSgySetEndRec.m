function [SgyHead,Head,Data1]=gSgySetEndRec(SgyHead,Head,Data,EndT,fl)
%Change Sgy Traces Length.
%function [SgyHead,Head,Data1]=gSgySetEndRec(SgyHead,Head,Data,EndT), where
%[SgyHead,Head,Data]- Sgy input variables;
%EndT- new trace's EndTime in milliseconds scalar (apply to all traces) or row (apply to each own trace) or SamplesNumber (scalar only);
%fl- flag; if fl==0, then EndT is samples number; if fl==1, then EndT is milliseconds;
%[SgyHead,Head,Data1]- Sgy output variables;
%Sgy Head fields changed: Head.DelayRecordingTime; Head.ns; SgyHead.FixedLengthTraceFlag.
%if TraceLength less than one, than trace_data_samples number (Head.ns(n)) set to 1; Data sample set to 0.
%Example: [SgyHead,Head,Data]=gSgyRead(['c:\temp\1.sgy'],'',[]);[SgyHead1,Head1,Data1]=gSgySetEndRec(SgyHead,Head,Data,20,1);

if ischar(Data),Data=gDataLoad(Data);end;
if fl, %milliseconds
    if ~all(Head.dt==Head.dt(1)), error('Head.dt not equal for all traces');end;
    if SgyHead.dt~=Head.dt(1), error('Head.dt not equal SgyHead.dt');end;
    if SgyHead.dt~=SgyHead.dtOrig, warning('Head.dt not equal SgyHead.dtOrig');end;
    NTrace=size(Head.dt,2);%traces number
    if isscalar(EndT), EndT=repmat(EndT,1,NTrace);end;%DelayTime for all traces from scalar
    TrL=round((EndT-Head.DelayRecordingTime).*1000./Head.dt);%New TraceLength in samples for each trace
    Data1=nan(max(TrL),NTrace);%Trase Data Allocate //max number samples in traces after EndTime appying
    for n=1:NTrace,
        if TrL(n)>0,
            if TrL(n)<=Head.ns(n), Data1(1:TrL(n),n)=Data(1:TrL(n),n);end;
            if TrL(n)>Head.ns(n), Data1(1:Head.ns(n),n)=Data(1:Head.ns(n),n);Data1(Head.ns(n)+1:TrL(n),n)=0;end;
        end;
    end;
    L=TrL>0;Head.ns(L)=TrL(L);Head.ns(~L)=1;Data1(1,~L)=0;
    if all(Head.ns==Head.ns(1)),SgyHead.FixedLengthTraceFlag=1;SgyHead.ns=Head.ns(1);SgyHead.nsOrig=Head.ns(1); else SgyHead.FixedLengthTraceFlag=0;end;
    Head.DelayRecordingTime(~L)=round(EndT(~L));
else %samples number
    if EndT<=size(Data,1),
        Data1=Data(1:EndT,:);
    else
        Data1=[Data;zeros(EndT-size(Data,1),size(Data,2))];
    end;
    Head.ns(:)=EndT;SgyHead.ns=EndT;SgyHead.nsOrig=EndT;
end;

%mail@ge0mlib.com 20/02/2020