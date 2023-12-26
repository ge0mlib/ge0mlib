function Head=gJsf2090Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 2090 (Situation Message; 0004824_REV_1.20 used). Warning: NOT TESTED.
%function Head=gJsf2090Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%A situation message is a composite of several motion / position sensors.  This message is not commonly used.
%Example: Head=gJsf2090Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead2090: ' mes]);end;
LHead=(JsfHead.HMessageType==2090);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 2090
Head=struct('HMessageType',2090,'HMessageNum',zeros(1,LenHead),...
    'TimeInSeconds',zeros(1,LenHead),'MillisecondsCurrentSecond',zeros(1,LenHead),'Reserved1',zeros(4,LenHead),...
    'ValidityFlags',zeros(1,LenHead),'Reserved2',zeros(4,LenHead),'MicrosecondTimestamp',zeros(1,LenHead),'Latitude',zeros(1,LenHead),'Longitude',zeros(1,LenHead),...
    'Depth',zeros(1,LenHead),'Heading',zeros(1,LenHead),'Pitch',zeros(1,LenHead),'Roll',zeros(1,LenHead),'XRelativePosition',zeros(1,LenHead),'YRelativePosition',zeros(1,LenHead),'ZRelativePosition',zeros(1,LenHead),...
    'XVelocity',zeros(1,LenHead),'YVelocity',zeros(1,LenHead),'ZVelocity',zeros(1,LenHead),'NorthVelocity',zeros(1,LenHead),'EastVelocity',zeros(1,LenHead),'DownVelocity',zeros(1,LenHead),...
    'XRate',zeros(1,LenHead),'YRate',zeros(1,LenHead),'ZRate',zeros(1,LenHead),'XAcceleration',zeros(1,LenHead),'YAcceleration',zeros(1,LenHead),'ZAcceleration',zeros(1,LenHead),...
    'LatitudeDeviation',zeros(1,LenHead),'LongitudeDeviation',zeros(1,LenHead),'DepthDeviation',zeros(1,LenHead),'HeadingDeviation',zeros(1,LenHead),'PitchDeviation',zeros(1,LenHead),...
    'RollDeviation',zeros(1,LenHead),'Reserved3',zeros(16,LenHead));
%===End Head Allocate for Message Type 2090
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 2090
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.TimeInSeconds(m)=fread(fId,1,'int32'); %0-3// Time in seconds (since the start of time based on time() function) (1/1/1970)
    Head.MillisecondsCurrentSecond(m)=fread(fId,1,'int32'); %4-7// Milliseconds in the current second
    Head.Reserved1(:,m)=fread(fId,4,'int8'); %8-11// Reserved – Do not use
    Head.ValidityFlags(m)=fread(fId,1,'uint32'); %12-15// Validity Flags indicate which of the following fields are valid. If the corresponding bit is set the field is valid. Bit0:microsecondTimestamp; Bit1:latitude; Bit2:longitude; Bit3:depth; Bit4:heading; Bit5:pitch; Bit6:roll; Bit7:XRelativePosition; Bit8:YRelativePosition; Bit9:ZRelativePosition; Bit10:XVelocity; Bit11:YVelocity; Bit12:ZVelocity; Bit13:NorthVelocity; Bit14:EastVelocity; Bit15:downVelocity; Bit16:XAngularRate; Bit17:YAngularRate; Bit18:ZAngularRate; Bit19:XAcceleration; Bit20:YAcceleration; Bit21:ZAcceleration; Bit22:latitudeStandardDeviation; Bit23:longitudeStandardDeviation; Bit24:depthStandardDeviation; Bit25:headingStandardDeviation; Bit26:pitchStandardDeviation; Bit27:rollStandardDeviation
    Head.Reserved2(:,m)=fread(fId,4,'uint8'); %16-19// Reserved – Do not use
    Head.Timestamp(m)=fread(fId,1,'uint64'); %20-27// Microsecond timestamp (0.01 of a microsecond), us since 12:00:00 am GMT, January 1, 1970
    Head.Latitude(m)=fread(fId,1,'float64'); %28-35// Double float: Latitude in degrees, north is positive
    Head.Longitude(m)=fread(fId,1,'float64'); %36-43// Double float: Longitude in degrees, east is positive
    Head.Depth(m)=fread(fId,1,'float64'); %44-51// Double float: Depth in meters
    Head.Heading(m)=fread(fId,1,'float64'); %52-59// Double float: Heading in degrees
    Head.Pitch(m)=fread(fId,1,'float64'); %60-67// Double float: Pitch in degrees, bow up is positive
    Head.Roll(m)=fread(fId,1,'float64'); %68-75// Double float: Roll in degrees, port up is positive
    Head.XRelativePosition(m)=fread(fId,1,'float64'); %76-83// Double float: X, forward, relative position in meters, surge
    Head.YRelativePosition(m)=fread(fId,1,'float64'); %84-91// Double float: Y, starboard, relative position in meters, sway
    Head.ZRelativePosition(m)=fread(fId,1,'float64'); %92-99// Double float: Z, downward, relative position in meters, heave
    Head.XVelocity(m)=fread(fId,1,'float64'); %100-107// Double float: X, forward, velocity in meters per second
    Head.YVelocity(m)=fread(fId,1,'float64'); %108-115// Double float: Y, starboard, velocity in meters per second
    Head.ZVelocity(m)=fread(fId,1,'float64'); %116-123// Double float: Z, downward, velocity in meters per second
    Head.NorthVelocity(m)=fread(fId,1,'float64'); %124-131// Double float: North velocity in meters per second
    Head.EastVelocity(m)=fread(fId,1,'float64'); %132-139// Double float: East velocity in meters per second
    Head.DownVelocity(m)=fread(fId,1,'float64'); %140-147// Double float: Down velocity in meters per second
    Head.XRate(m)=fread(fId,1,'float64'); %148-155// Double float:  X angular rate in degrees per second, port up is positive 
    Head.YRate(m)=fread(fId,1,'float64'); %156-163// Double float:  Y angular rate in degrees per second, bow up is positive
    Head.ZRate(m)=fread(fId,1,'float64'); %164-171// Double float: Z angular rate in degrees per second, starboard is positive
    Head.XAcceleration(m)=fread(fId,1,'float64'); %172-179// Double float: X, forward, acceleration in meters per second per second
    Head.YAcceleration(m)=fread(fId,1,'float64'); %180-187// Double float: Y, starboard, acceleration in meters per second per second
    Head.ZAcceleration(m)=fread(fId,1,'float64'); %188-195// Double float: Z, downward, acceleration in meters per second per second
    Head.LatitudeDeviation(m)=fread(fId,1,'float64'); %196-203// Double float: Latitude standard deviation in meters
    Head.LongitudeDeviation(m)=fread(fId,1,'float64'); %204-211// Double float: Longitude standard deviation in meters
    Head.DepthDeviation(m)=fread(fId,1,'float64'); %212-219// Double float: Depth standard deviation in meters
    Head.HeadingDeviation(m)=fread(fId,1,'float64'); %220-227// Double float: Heading standard deviation in degrees
    Head.PitchDeviation(m)=fread(fId,1,'float64'); %228-235// Double float: Pitch standard deviation in degrees
    Head.RollDeviation(m)=fread(fId,1,'float64'); %236-243// Double float: Roll standard deviation in degrees
    Head.Reserved3(:,m)=fread(fId,16,'uint16'); %244-275// Reserved – Do not use
    %===End Head Read for Message Type 2090
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 19/03/2018