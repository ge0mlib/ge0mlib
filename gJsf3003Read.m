function Head=gJsf3003Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 3003 (Altitude Message Type; 0014932_REV_D March 2016 used).
%function Head=gJsf3003Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%AltitudeMessageType is a source for altitude and possibly speed, and heading.
%Example: Head=gJsf3003Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead3003: ' mes]);end;
LHead=(JsfHead.HMessageType==3003);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 3003
Head=struct('HMessageType',3003,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'NanosecondSupplementTime',zeros(1,LenHead),'DataValidFlag',zeros(1,LenHead),...
    'Altitude',zeros(1,LenHead),'Speed',zeros(1,LenHead),'Heading',zeros(1,LenHead));
%===End Head Allocate for Message Type 3003
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 3003
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'uint32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.NanosecondSupplementTime(m)=fread(fId,1,'uint32'); %4-7// Nanosecond Supplement to Time; The time stamp accuracy is 20 (?) milliseconds or better.
    Head.DataValidFlag(m)=fread(fId,1,'uint32'); %8-11// Data Valid Flag: Bit0-Altitude; Bit1-Speed; Bit2-Heading. 0 is clear, 1 is set. The validity of each field is indicated in the Data Valid Flag (bytes 8-11) and it is imperative that this is used to correctly parse the fields.
    Head.Altitude(m)=fread(fId,1,'float32'); %12-15// Altitude, Meters. This  Altitude  parameter  (bytes 12-15)  is  reported  for  each  ping  and  is  the  value  computed  from  the Depth Below Sounder (2.3.1.10). This field will always be valid and should be added to the depth field (if available) from Message ID 3002, or PressureMessageType, in order to calculate the total water depth.
    Head.Speed(m)=fread(fId,1,'float32'); %16-19// For Speed (bytes 16-19) and Heading (bytes 20-23), the Data Valid Flag (bytes 8-11) should be tested to determine if these fields are usable (or set to 1).  The validity of these fields depends on what devices are  connected  to  the  sonar  system.  For  example,  if  there  is  a  device  connected  to  the  sonar  which supplies heading only (such as a gyroscope) this heading field would be valid.
    Head.Heading(m)=fread(fId,1,'float32'); %20-23// Heading (0 to 359.9), Degrees.
    %===End Head Read for Message Type 3003
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018