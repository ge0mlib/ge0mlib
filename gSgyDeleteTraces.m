function [Head,Data]=gSgyDeleteTraces(Head,Data,mask)
%Delete traces from Sgy variables.
%function [Head,Data]=gSgyDeleteTraces(Head,Data,mask), where
%[Head,Data]- Sgy input variables;
%mask- mask for traces delete (logical or trace_numbers);
%[Head,Data]- Sgy output variables.
%Example: [SgyHead,Head,Data]=gSgyRead(['c:\temp\1.sgy'],'',[]);[Head1,Data1]=gSgyDeleteTraces(Head,Data,1:100);

if ischar(Data),Data=gDataLoad(Data);end;
Head=gFieldsRowSet(Head,size(Head.dt,2),mask,[]);
Data(:,mask)=[];

%mail@ge0mlib.com 15/08/2016