function Head=gJsf2080Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 2080 (Doppler Velocity Log Data; 0004824_REV_1.20 used). Warning: NOT TESTED.
%function Head=gJsf2080Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%This is data from a DVL (if fitted) and often includes velocity and altitude readings.
%Example: Head=gJsf2080Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead2080: ' mes]);end;
LHead=(JsfHead.HMessageType==2080);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 2080
Head=struct('HMessageType',2080,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'MillisecondsCurrentSecond',zeros(1,LenHead),'Reserved1',zeros(4,LenHead),...
    'Flag',zeros(1,LenHead),'DistanceToBottom',zeros(4,LenHead),'XVelocity',zeros(1,LenHead),'YVelocity',zeros(1,LenHead),'ZVelocity',zeros(1,LenHead),...
    'XVelocity2',zeros(1,LenHead),'YVelocity2',zeros(1,LenHead),'ZVelocity2',zeros(1,LenHead),'Depth',zeros(1,LenHead),'Pitch',zeros(1,LenHead),...
    'Roll',zeros(1,LenHead),'Heading',(zeros(1,LenHead)),'Salinity',zeros(1,LenHead),'TemperatureInUnits',zeros(1,LenHead),'SoundVelocity',zeros(1,LenHead),'Reserved2',zeros(7,LenHead));
%===End Head Allocate for Message Type 2080
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 2080
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.MillisecondsCurrentSecond(m)=fread(fId,1,'int32'); %4-7// Milliseconds in the current second
    Head.Reserved1(:,m)=fread(fId,4,'uint8'); %8-11// Reserved – Do not use
    Head.Flags(m)=fread(fId,1,'uint32'); %12-15// Flags.  Indicates which values are present. Bit0:X,Y Velocity present; Bit1:1=>Velocity in ship coordinates 0=>Earth coordinates; Bit2:Z(Vertical Velocity) present; Bit3:X,Y Water Velocity present; Bit4:Z (Vertical Water Velocity) present; Bit5:Distance to bottom present; Bit6:Heading present; Bit7:Pitch present; Bit8:Roll present; Bit9:Temperature present; Bit10:Depth present; Bit11:Salinity present; Bit12:Sound velocity present; Bit31:Error detected
    Head.DistanceToBottom(:,m)=fread(fId,4,'int32'); %16-31// 4 Integers:  Distance to bottom in cm for up to 4 beams. A 0 value indicates an invalid or non-existing reading.
    Head.XVelocity(m)=fread(fId,1,'int16'); %32-33// X Velocity with respect to the bottom in mm / second. Positive=> Starboard or East. -32768 indicates an invalid reading.
    Head.YVelocity(m)=fread(fId,1,'int16'); %34-35// Y Velocity: Positive => Forward or North (mm/second)
    Head.ZVelocity(m)=fread(fId,1,'int16'); %36-37// Z Vertical Velocity: Positive => Upward (mm/second)
    Head.XVelocity2(m)=fread(fId,1,'int16'); %38-39// X Velocity with respect to a water layer in mm / second. Positive => Starboard or East
    Head.YVelocity2(m)=fread(fId,1,'int16'); %40-41// Y Velocity: Positive => Forward or North
    Head.ZVelocity2(m)=fread(fId,1,'int16'); %42-43// Z Vertical Velocity: Positive => Upward
    Head.Depth(m)=fread(fId,1,'uint16'); %44-45// Depth from depth sensor in decimeters
    Head.Pitch(m)=fread(fId,1,'int16'); %46-47// Pitch -180 to +180 degree  (units = 0.01 of a degree) + Bow up
    Head.Roll(m)=fread(fId,1,'int16'); %48-49// Roll -180 to +180 degrees  (units = 0.01 of a degree) + Port up
    Head.Heading(m)=fread(fId,1,'uint16'); %50-51// Heading: 0 to 360 degrees  (in units of 0.01 of a degree)
    Head.Salinity(m)=fread(fId,1,'uint16'); %52-53// Salinity in 1 part per thousand
    Head.TemperatureInUnits(m)=fread(fId,1,'int16'); %54-55// Temperature in units of 1/100 of a degree Celsius
    Head.SoundVelocity(m)=fread(fId,1,'int16'); %56-57// Sound velocity in meters per second
    Head.Reserved2(:,m)=fread(fId,7,'int16'); %58-71// Reserved – Do not use
    %===End Head Read for Message Type 2080
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 08/04/2017