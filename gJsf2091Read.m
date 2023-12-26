function Head=gJsf2091Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 2091 (Situation  Comprehensive  Message, version 2; 0004824_REV_1.20 used). Warning: NOT TESTED.
%function Head=gJsf2091Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%This message contains of a device header followed by a data area. The data area is a composite of several motion/position sensors.
%Example: Head=gJsf2091Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead2091: ' mes]);end;
LHead=(JsfHead.HMessageType==2091);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 2091
Head=struct('HMessageType',2091,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'MillisecondsCurrentSecond',zeros(1,LenHead),'Source',zeros(1,LenHead),'Reserved1',zeros(3,LenHead),...
    'ValidityFlags',zeros(1,LenHead),'Velocity12Directions',zeros(1,LenHead),'Reserved2',zeros(3,LenHead),'MicrosecondTimestamp',zeros(1,LenHead),'Latitude',zeros(1,LenHead),'Longitude',zeros(1,LenHead),...
    'Depth',zeros(1,LenHead),'Altitude',zeros(1,LenHead),'Heave',zeros(1,LenHead),'Velocity1',zeros(1,LenHead),'Velocity2',zeros(1,LenHead),'VelocityDown',zeros(1,LenHead),...
    'Pitch',zeros(1,LenHead),'Roll',zeros(1,LenHead),'Heading',zeros(1,LenHead),'SoundSpeed',zeros(1,LenHead),'WaterTemperature',zeros(1,LenHead),'Reserved3',zeros(3,LenHead));
%===End Head Allocate for Message Type 2091
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 2091
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.MillisecondsCurrentSecond(m)=fread(fId,1,'int32'); %4-7// Milliseconds in the current second
    Head.Source(m)=fread(fId,1,'uint8'); %8// Source, 1 = Sonar, 2 = DISCOVER, 3 = ETS (Reserved for v.1.20).
    Head.Reserved1(:,m)=fread(fId,3,'uint8'); %9-11// Reserved – Do not use
    Head.ValidityFlags(m)=fread(fId,1,'uint32'); %12-15// Validity Flags indicate which of the following fields are valid. Bit0: Timestamp Provided by the Source Valid; Bit1: Longitude Valid; Bit2: Latitude Valid; Bit3: Depth Valid; Bit4: Altitude Valid; Bit5: Heave Valid; Bit6: Velocity 1&2 Valid; Bit7: Velocity down Valid; Bit8: Pitch Valid; Bit9: Roll Valid; Bit10: Heading Valid; Bit11: Sound Speed Valid; Bit12: Water Temperature Valid; Others: Reserved, Presently 0.
    Head.Velocity12Directions(m)=fread(fId,1,'uint8'); %16// Velocity12 Directions: Velocity1 and 2 type. 0= North and East; 1= Forward and Starboard; 2= +45 Degrees Rotated from Forward.
    Head.Reserved2(:,m)=fread(fId,3,'uint8'); %17-19// Reserved – Do not use
    Head.Timestamp(m)=fread(fId,1,'uint64'); %20-27// Microsecond timestamp (0.01 of a microsecond), us since 12:00:00 am GMT, January 1, 1970
    Head.Latitude(m)=fread(fId,1,'float64'); %28-35// Double float: Latitude in degrees, north is positive
    Head.Longitude(m)=fread(fId,1,'float64'); %36-43// Double float: Longitude in degrees, east is positive
    Head.Depth(m)=fread(fId,1,'float32'); %44-47// Float: Depth in meters
    Head.Altitude(m)=fread(fId,1,'float32'); %48-51// Float: Altitude (in meters)
    Head.Heave(m)=fread(fId,1,'float32'); %52-55// Float: Heave (in meters, positive is down)
    Head.Velocity1(m)=fread(fId,1,'float32'); %56-59// Float: Velocity1 (North velocity (or forward) in meters per second)
    Head.Velocity2(m)=fread(fId,1,'float32'); %60-63// Float: Velocity2 (East velocity or stbd in meters per second)
    Head.VelocityDown(m)=fread(fId,1,'float32'); %64-67// Float: Velocity Down (Down velocity in meters per second)
    Head.Pitch(m)=fread(fId,1,'float32'); %68-71// Float: Pitch (in degrees, bow up is positive) 
    Head.Roll(m)=fread(fId,1,'float32'); %72-75// Float: Roll (in degrees, port is positive)
    Head.Heading(m)=fread(fId,1,'float32'); %76-79// Float: Heading (in degrees)
    Head.SoundSpeed(m)=fread(fId,1,'float32'); %80-83// Float: Sound Speed (in meters per second)
    Head.WaterTemperature(m)=fread(fId,1,'float32'); %84-87// Float: Water Temperature (in degrees Celsius)
    Head.Reserved3(:,m)=fread(fId,3,'float32'); %88-99// Float: Reserved – Do not use
    %===End Head Read for Message Type 2091
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018