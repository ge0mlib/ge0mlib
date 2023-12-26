function Head=gJsf3005Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 3005 (Status Message Type; 0014932_REV_D March 2016 used).
%function Head=gJsf3005Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%StatusMessageType is a source for GPS status and quality (i.e. fixed, float, DGPS, etc.). The status includes information such as Number of Satellites and Horizontal Dilution of Precision. The quality indicator is given by its numerical code in the incoming GPS message.
%EdgeTech reads these status codes and indicates which message structure provided the information. Currently, there are only two sources that can provide the necessary status information: GGA or GGK.
%The Talker ID for the incoming GPS messages does not matter (e.g. $GPGGA, $PTNL,GGK, $INGGK, $GPGGK, etc).
%Example: Head=gJsf3005Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead3005: ' mes]);end;
LHead=(JsfHead.HMessageType==3005);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 3005
Head=struct('HMessageType',3005,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'NanosecondSupplementTime',zeros(1,LenHead),'DataValidFlag',zeros(1,LenHead),...
    'Version',zeros(1,LenHead),'GgaStatus',zeros(1,LenHead),'GgkStatus',zeros(1,LenHead),'NumberSatellites',zeros(1,LenHead),'Reserved1',zeros(2,LenHead),...
    'DilutionPrecision',zeros(1,LenHead),'Reserved2',zeros(11,LenHead));
%===End Head Allocate for Message Type 3005
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 3005
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'uint32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.NanosecondSupplementTime(m)=fread(fId,1,'uint32'); %4-7// Nanosecond Supplement to Time; The time stamp accuracy is 20 (?) milliseconds or better.
    Head.DataValidFlag(m)=fread(fId,1,'uint16'); %8-9// Data Valid Flag: Bit0-GGA Status; Bit1-GGK Status; Bit2-Number of Satellites; Bit3-Dilution of Precision. 0 is clear, 1 is set. The validity of each field is indicated in the Data Valid Flag (bytes 8-11) and it is imperative that this is used to correctly parse the fields.
    Head.Version(m)=fread(fId,1,'uint8'); %10// Version.
    Head.GgaStatus(m)=fread(fId,1,'uint8'); %11// GGA Status.
    Head.GgkStatus(m)=fread(fId,1,'uint8'); %12// GGK Status.
    Head.NumberSatellites(m)=fread(fId,1,'uint8'); %13// Number of Satellites.
    Head.Reserved1(:,m)=fread(fId,2,'uint8'); %14-15// Reserved.
    Head.DilutionPrecision(m)=fread(fId,1,'float32'); %16-19// Dilution of Precision, Meters.
    Head.Reserved2(:,m)=fread(fId,11,'uint32'); %20-63// Reserved.
    %===End Head Read for Message Type 3005
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018