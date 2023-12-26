function [SgyHeadOut,HeadOut,DataOut]=gSgyAppendFiles(varargin)
%Append Sgy files to variables [SgyHead,Head,Data].
%function [SgyHeadOut,HeadOut,DataOut]=gSgyAppendFiles(varargin), where:
%varargin- one or several files, file's lists, folders;
%[SgyHeadOut,HeadOut,DataOut]- appended files data;
%The follow fields are checked as equal for both data sets: SgyHead.dt.
%Example:
%[SgyHead,Head,Data]=gSgyAppendFiles('c:\temp\1.sgy','c:\temp\2.sgy','c:\temp\3.sgy');
%[SgyHead,Head,Data]=gSgyAppendFiles(['c:\temp\1.sgy';'c:\temp\2.sgy';'c:\temp\3.sgy']);
%[SgyHead,Head,Data]=gSgyAppendFiles('c:\temp1\','c:\temp2\');

for n=1:length(varargin), fName=varargin{n};
    if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end;fName=sortrows(fName);
    for nn=1:size(fName,1),
        [SgyHead,Head,Data]=gSgyRead(deblank(fName(nn,:)),'',[]);
        if (n==1)&&(nn==1),
            if any(Head.DelayRecordingTime~=Head.DelayRecordingTime(1)), warning(['Warning! Head.DelayRecordingTime~=HeadOut.DelayRecordingTime; file -- ' fName(nn,:)]);end;
            SgyHeadOut=SgyHead;HeadOut=Head;DataOut=Data;
        else
            if SgyHead.dt~=SgyHeadOut.dt, error(['Can not Append: SgyHead0.dt~=SgyHead.dt; file -- ' fName(nn,:)]);end;
            if SgyHead.dtOrig~=SgyHeadOut.dtOrig, warning(['SgyHead0.dtOrig~=SgyHead.dtOrig; file -- ' fName(nn,:)]);end;
            if SgyHead.nsOrig~=SgyHeadOut.nsOrig, warning(['SgyHead0.nsOrig~=SgyHead.nsOrig; file -- ' fName(nn,:)]);end;
            if SgyHead.ns~=SgyHeadOut.ns, warning(['Warning! SgyHead0.ns~=SgyHead.ns; file -- ' fName(nn,:)]);SgyHead.FixedLengthTraceFlag=0;end;
            if any(Head.DelayRecordingTime~=HeadOut.DelayRecordingTime(1)), warning(['Head.DelayRecordingTime~=HeadOut.DelayRecordingTime; file -- ' fName(nn,:)]);end;
            HeadOut=gFieldsRowAppend(HeadOut,Head,length(HeadOut.MessageNum));
            if size(DataOut,1)>size(Data,1), DataOut=[DataOut [Data;nan(size(DataOut,1)-size(Data,1),size(Data,2))]];SgyHead.FixedLengthTraceFlag=0;
            elseif size(DataOut,1)<size(Data,1), DataOut=[[DataOut;nan(size(Data,1)-size(DataOut,1),size(DataOut,2))] Data];SgyHead.FixedLengthTraceFlag=0;
            else DataOut=[DataOut Data];
            end;
        end;
    end;
end;
SgyHead.ns=max(Head.ns);

%mail@ge0mlib.com 15/10/2017