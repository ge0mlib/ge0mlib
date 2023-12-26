function Head=gJsf0426Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 0426 (File Timestamp Message; 0004824_REV_1.20 used). Warning: NOT TESTED.
%function Head=gJsf0426Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%File timestamp messages are often found at the beginning and end of a file.
%Example: Head=gJsf0426Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead0426: ' mes]);end;
LHead=(JsfHead.HMessageType==0426);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 0426
Head=struct('HMessageType',0426,'HMessageNum',zeros(1,LenHead),'TimeInSeconds',zeros(1,LenHead),'MillisecondsCurrentSecond',zeros(1,LenHead));
%===End Head Allocate for Message Type 0426
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 0426
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.MillisecondsCurrentSecond(m)=fread(fId,1,'int32'); %4-7// Milliseconds in the current second
    %===End Head Read for Message Type 0426
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 01/08/2016