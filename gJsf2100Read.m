function Head=gJsf2100Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 2100 (Cable Counter Data Message; 0004824_REV_1.20 used). Warning: NOT TESTED.
%function Head=gJsf2100Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%Example: Head=gJsf2100Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead2100: ' mes]);end;
LHead=(JsfHead.HMessageType==2100);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 2100
Head=struct('HMessageType',2100,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'MillisecondsCurrentSecond',zeros(1,LenHead),'Reserved1',zeros(4,LenHead),...
    'CableLength',zeros(1,LenHead),'CableSpeed',zeros(1,LenHead),'CableLengthValidFlag',zeros(1,LenHead),'CableSpeedValidFlag',zeros(1,LenHead),'CableCounterError',zeros(1,LenHead),...
    'CableTensionValidFlag',zeros(1,LenHead),'CableTension',zeros(1,LenHead));
%===End Head Allocate for Message Type 2100
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 2100
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.MillisecondsCurrentSecond(m)=fread(fId,1,'int32'); %4-7// Milliseconds in the current second
    Head.Reserved1(:,m)=fread(fId,4,'uint8'); %8-11// Reserved – Do not use
    Head.CableLength(m)=fread(fId,1,'float32'); %12-15// Cable Length in meters
    Head.CableSpeed(m)=fread(fId,1,'float32'); %16-19// Cable Speed in meters/second
    Head.CableLengthValidFlag(m)=fread(fId,1,'int16'); %20-21// Cable Length valid flag, 0 – Invalid,
    Head.CableSpeedValidFlag(m)=fread(fId,1,'int16'); %22-23// Cable Speed valid flag, 0 – Invalid,
    Head.CableCounterError(m)=fread(fId,1,'int16'); %24-25// Cable Counter Error, 0 – No Error, 
    Head.CableTensionValidFlag(m)=fread(fId,1,'int16'); %26-27// Cable Tension valid flag, 0 – Invalid
    Head.CableTension(m)=fread(fId,1,'float32'); %28-31// Cable Tension in kilograms
    %===End Head Read for Message Type 2100
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 01/08/2016