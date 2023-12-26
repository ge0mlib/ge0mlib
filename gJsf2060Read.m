function Head=gJsf2060Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 2060 (Pressure Sensor; 0004824_REV_1.20 used).
%function Head=gJsf2060Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%If a pressure sensor is present in the system these messages will be in the data stream.
%Example: Head=gJsf2060Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead2060: ' mes]);end;
LHead=(JsfHead.HMessageType==2060);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 2060
Head=struct('HMessageType',2060,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'MillisecondsCurrentSecond',zeros(1,LenHead),'Reserved1',zeros(4,LenHead),...
    'Pressure',zeros(1,LenHead),'TemperatureInUnits',zeros(1,LenHead),'Salinity',zeros(1,LenHead),'DataValidFlags',zeros(1,LenHead),'Conductivity',zeros(1,LenHead),...
    'VelocityOfSound',zeros(1,LenHead),'Depth',zeros(1,LenHead),'Reserved2',zeros(9,LenHead));
%===End Head Allocate for Message Type 2060
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 2060
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.MillisecondsCurrentSecond(m)=fread(fId,1,'int32'); %4-7// Milliseconds in the current second
    Head.Reserved1(:,m)=fread(fId,4,'uint8'); %8-11// Reserved – Do not use
    Head.Pressure(m)=fread(fId,1,'int32'); %12-15// Pressure in units of 1/1000th of a PSI
    Head.TemperatureInUnits(m)=fread(fId,1,'int32'); %16-19// Temperature in units of 1/1000th of a degree Celsius
    Head.Salinity(m)=fread(fId,1,'int32'); %20-23// Salinity in Parts Per Million
    Head.DataValidFlags(m)=fread(fId,1,'int32'); %24-27// Data valid flags. Bit0:pressure; Bit1:temp; Bit 2:salt PPM; Bit3:conductivity; Bit 4:sound velocity; Bit 5: Depth.
    Head.Conductivity(m)=fread(fId,1,'int32'); %28-31// Conductivity in micro-Siemens per cm
    Head.VelocityOfSound(m)=fread(fId,1,'int32'); %32-35// Velocity of Sound in mm per second
    Head.Depth(m)=fread(fId,1,'int32'); %36-39// Depth in Meters
    Head.Reserved2(:,m)=fread(fId,9,'int32'); %40-75// Reserved – Do not use
    %===End Head Read for Message Type 2060
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018