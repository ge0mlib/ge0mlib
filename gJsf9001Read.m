function Head=gJsf9001Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 9001 (DISCOVER II General Prefix Message; 0004824_REV_1.18 used). Warning: NOT TESTED.
%function Head=gJsf9001Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%The General Prefix Message proceeds most messages (such as NMEA strings, pitch/ roll, etc.) written by DISCOVER II and provides  the  supplementary  context  information for the message that follows it.
%Example: Head=gJsf9001Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead9001: ' mes]);end;
LHead=(JsfHead.HMessageType==9001);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 9001
Head=struct('HMessageType',9001,'HMessageNum',zeros(1,LenHead),'Timestamp',zeros(1,LenHead),'DataSourceSerialNumber',zeros(1,LenHead),'MessageVersionNumber',zeros(4,LenHead),'DataSourceDevice',zeros(1,LenHead));
%===End Head Allocate for Message Type 9001
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 9001
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.Timestamp(m)=fread(fId,1,'int64'); %0-7// Timestamp in the higher resolution DISCOVER II format. This is equivalent to the Microsoft Dot Net DateTime. Ticks property. The resolution is 10^-7 of a second (0.1 microsecond per increment), and is referenced to 12:00 midnight, Jan 1, 0001 C.E. in the Gregorian Calendar.
    Head.DataSourceSerialNumber(m)=fread(fId,1,'int32'); %8-11// Data Source Serial Number. A unique serial number, which could for example distinguish one tow fish from another, otherwise identically configured tow fish.
    Head.MessageVersionNumber(m)=fread(fId,1,'int16'); %12-13// Message Version Number. This is the version number of this message. This number may differ from the protocol version number in the main message header.
    Head.DataSourceDevice(m)=fread(fId,1,'int16'); %14-15// Data Source Device. For each Serial Number, there may be multiple devices.
    %===End Head Read for Message Type 9001
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018