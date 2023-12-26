function Head=gJsf2002Read(JsfHead,ChN)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 2002 (NMEA String; 0004824_REV_1.20 used).
%function Head=gJsf2002Read(JsfHead,ChN), where
%JsfHead - Jsf Header structure;
%ChN - channel number;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HChannelMulti, HMessageNum.
%Each message contain the data folw piece from serial port.
%NMEA String consists of a time stamp followed by a NMEA string as read from a GPS, Gyro or other device.  Each message is a single NMEA string excluding the <CR>/<LF>.
%Example: Head=gJsf2002Read(JsfHead,0);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead2002: ' mes]);end;
LHead=(JsfHead.HMessageType==2002)&(JsfHead.HChannelMulti==ChN);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 2002
Head=struct('HMessageType',2002,'HChannelMulti',ChN,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'MillisecondsCurrentSecond',zeros(1,LenHead),'Source',zeros(1,LenHead),'Reserved1',zeros(3,LenHead),...
    'String',char(zeros(max(JsfHead.HSizeFollowingMessage(nHead))-12,LenHead)));
%===End Head Allocate for Message Type 2002
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 2002
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.MillisecondsCurrentSecond(m)=fread(fId,1,'int32'); %4-7// Milliseconds in the current second
    Head.Source(m)=fread(fId,1,'uint8'); %8// Source, 1 = Sonar, 2 = Discover, 3 = ETSI
    Head.Reserved1(:,m)=fread(fId,3,'uint8'); %9-11// Reserved – Do not use
    Head.String(1:JsfHead.HSizeFollowingMessage(nHead(m))-12,m)=char(fread(fId,JsfHead.HSizeFollowingMessage(nHead(m))-12,'uint8')); %12-end// NMEA string data
    %===End Head Read for Message Type 2002
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018