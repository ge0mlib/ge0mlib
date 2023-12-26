function Head=gJsf3002Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 3002 (Pressure Message Type; 0014932_REV_D March 2016 used).
%function Head=gJsf3002Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%PressureMessageType  is  a  source  for  sound  velocity,  and  possibly  water  temperature,  salinity, conductivity, and depth.
%Example: Head=gJsf3002Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead3002: ' mes]);end;
LHead=(JsfHead.HMessageType==3002);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 3002
Head=struct('HMessageType',3002,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'NanosecondSupplementTime',zeros(1,LenHead),'DataValidFlag',zeros(1,LenHead),...
    'AbsolutePressure',zeros(1,LenHead),'WaterTemperature',zeros(1,LenHead),'Salinity',zeros(1,LenHead),'Conductivity',zeros(1,LenHead),'SoundVelocity',zeros(1,LenHead),'Depth',zeros(1,LenHead));
%===End Head Allocate for Message Type 3002
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 3002
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'uint32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.NanosecondSupplementTime(m)=fread(fId,1,'uint32'); %4-7// Nanosecond Supplement to Time; The time stamp accuracy is 20 milliseconds or better.
    Head.DataValidFlag(m)=fread(fId,1,'uint32'); %8-11// Data Valid Flag: Bit0-Pressure; Bit1-Water Temperature; Bit2-Salinity; Bit3-Conductivity; Bit4-Sound Velocity; Bit5-Depth. 0 is clear, 1 is set. The validity of each field is indicated in the Data Valid Flag (bytes 8-11) and it is imperative that this is used to correctly parse the fields.
    Head.AbsolutePressure(m)=fread(fId,1,'float32'); %12-15// Absolute Pressure, PSI.
    Head.WaterTemperature(m)=fread(fId,1,'float32'); %16-19// Water Temperature, Degrees.
    Head.Salinity(m)=fread(fId,1,'float32'); %20-23// Salinity (PPM), Parts/Million.
    Head.Conductivity(m)=fread(fId,1,'float32'); %24-27// Conductivity, Degrees.
    Head.SoundVelocity(m)=fread(fId,1,'float32'); %28-31// Sound Velocity, Meters/Second. The Sound Velocity (bytes 28-31) is the sound velocity measured at the sonar head and must be used when calculating Slant Range in Message ID 3000, or BathymetricDataMessageType.
    Head.Depth(m)=fread(fId,1,'float32'); %32-35// Depth, Meters. Only on those platforms that are deployed subsea will have a valid Depth field (bytes 32-35) as provided by the platform’s depth or pressure sensor (such as ROV, ROTV and AUV applications).
    %===End Head Read for Message Type 3002
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018