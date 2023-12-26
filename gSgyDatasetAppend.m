function [SgyHeadOut,HeadOut,DataOut]=gSgyDatasetAppend(SgyHead,Head,Data)
%Append Sgy-variables from Dataset.
%function [SgyHeadOut,HeadOut,DataOut]=gSgyDatasetAppend(SgyHead,Head,Data), where:
%SgyHead- input SgyHead(1..n) structure;
%Head-  input Head(1..n) structure;
%Data- input cells with Data-matrix or temporary file names;
%[SgyHeadOut,HeadOut,DataOut]- output data appended.
%The follow fields are checked as equal for both data sets: SgyHead.dt.
%Warning!!! SgyHeadOut.fNameTmp==SgyHead(1).fNameTmp
%Example:
%[SgyHead(10),Head(10),Data{10}]=gSgyDatasetAppend(SgyHead(1:4),Head(1:4),Data(1:4));

SgyHeadOut=SgyHead(1);HeadOut=Head(1);
if ischar(Data{1}),DataOut=gDataLoad(Data{1});else DataOut=Data{1};end;
for nn=2:length(SgyHead),
    if ischar(Data{nn}),Data0=gDataLoad(Data{nn});else Data0=Data{nn};end;
    if SgyHead(nn).dt~=SgyHeadOut.dt, error(['Can not Append: SgyHead0.dt~=SgyHead.dt; Dataset index: ' num2str(nn)]);end;
    if SgyHead(nn).dtOrig~=SgyHeadOut.dtOrig, warning(['SgyHead0.dtOrig~=SgyHead.dtOrig; Dataset index: ' num2str(nn)]);end;
    if SgyHead(nn).nsOrig~=SgyHeadOut.nsOrig, warning(['SgyHead0.nsOrig~=SgyHead.nsOrig; Dataset index: ' num2str(nn)]);end;
    if SgyHead(nn).ns~=SgyHeadOut.ns, warning(['SgyHead0.ns~=SgyHead.ns; Dataset index: ' num2str(nn)]);SgyHead.FixedLengthTraceFlag=0;end;
    if any(Head(nn).DelayRecordingTime~=HeadOut.DelayRecordingTime(1)), warning(['Head.DelayRecordingTime~=HeadOut.DelayRecordingTime; Dataset index: ' num2str(nn)]);end;
    HeadOut=gFieldsRowAppend(HeadOut,Head(nn),length(HeadOut.MessageNum));
    if size(DataOut,1)>size(Data0,1), DataOut=[DataOut [Data0;nan(size(DataOut,1)-size(Data0,1),size(Data0,2))]];SgyHead.FixedLengthTraceFlag=0;
    elseif size(DataOut,1)<size(Data0,1), DataOut=[[DataOut;nan(size(Data0,1)-size(DataOut,1),size(DataOut,2))] Data0];SgyHead.FixedLengthTraceFlag=0;
    else DataOut=[DataOut Data0];
    end;
end;
SgyHead.ns=max(Head.ns);

%mail@ge0mlib.com 30/10/2017