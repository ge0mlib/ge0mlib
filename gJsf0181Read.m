function Head=gJsf0181Read(JsfHead)
%Read Head from JsfHead.fName (*.jsf) file for Message Type 0181 (Navigation Offsets Message; 0023492_Rev_C used).
%function Head=gJsf0181Read(JsfHead), where
%JsfHead - Jsf Header structure;
%Head - Message Header structure.
%Head include the addition fields: HMessageType, HMessageNum.
%Example: Head=gJsf0181Read(JsfHead);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead0181: ' mes]);end;
LHead=(JsfHead.HMessageType==0181);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 0181
Head=struct('HMessageType',0181,'HMessageNum',zeros(1,LenHead),...
    'XOffset',zeros(1,LenHead),'YOffset',zeros(1,LenHead),'LatitudeOffset',zeros(1,LenHead),'LongitudeOffset',zeros(1,LenHead),'AftOffset',zeros(1,LenHead),'StarboardOffset',zeros(1,LenHead),'DepthOffset',zeros(1,LenHead),'AltitudeOffset',zeros(1,LenHead),...
    'HeadingOffset',zeros(1,LenHead),'PitchOffset',zeros(1,LenHead),'RollOffset',zeros(1,LenHead),'YawOffset',zeros(1,LenHead),'TowPointElevationOffset',zeros(1,LenHead),'Reserved',zeros(3,LenHead));
%===End Head Allocate for Message Type 0181
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 0181
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.XOffset(m)=fread(fId,1,'float32'); %0-3// X offset in meters
    Head.YOffset(m)=fread(fId,1,'float32'); %4-7// Y offset in meters
    Head.LatitudeOffset(m)=fread(fId,1,'float32'); %8-11// Latitude Offset in degrees
    Head.LongitudeOffset(m)=fread(fId,1,'float32'); %12-15// Longitude Offset in degrees
    Head.AftOffset(m)=fread(fId,1,'float32'); %16-19// Aft Offset in meters: Forward is negative
    Head.StarboardOffset(m)=fread(fId,1,'float32'); %20-23// Starboard Offset in meters: Port is negative
    Head.DepthOffset(m)=fread(fId,1,'float32'); %24-27// Depth Offset in meters: Up is negative
    Head.AltitudeOffset(m)=fread(fId,1,'float32'); %28-31// Altitude Offset in meters: Down is negative
    Head.HeadingOffset(m)=fread(fId,1,'float32'); %32-35// Heading Offset in degrees
    Head.PitchOffset(m)=fread(fId,1,'float32'); %36-39// Pitch Offset in degrees: Nose up is positive
    Head.RollOffset(m)=fread(fId,1,'float32'); %40-43// Roll Offset in degrees: Port side up is positive
    Head.YawOffset(m)=fread(fId,1,'float32'); %44-47// Yaw Offset in degrees: Toward Port is negative
    Head.TowPointElevationOffset(m)=fread(fId,1,'float32'); %48-51// Tow point elevation offset (Up is positive)
    Head.Reserved(3,m)=fread(fId,3,'float32'); %52-63// Reserved [3]
    %===End Head Read for Message Type 0181
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 08/04/2021