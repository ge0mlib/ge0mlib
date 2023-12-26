function gXtf000Write(XtfHead,Head,Data,fNameNew,flTraceLenChanged)
%Write [XtfHead,Head,Data] to *.xtf file for Message Type 000 (Sonar Data Message).
%function gXtf000Write(XtfHead,Head,Data,fNameNew,flTraceLenChanged), where
%XtfHead- Xtf Header structure;
%Head- Header structure;
%Data- Data for sonar channels;
%fNameNew - string, the target file for writing;
%flTraceLenChanged - key for changes:
%flTraceLenChanged=0, if Data Trace Length (Head.CNumSamples) was not changed;
%flTraceLenChanged=1, if Data Trace Length (Head.CNumSamples) was changed (see gXtf000DeleteSlant) and RNumBytesThisRecord field need to correct;
%flTraceLenChanged=2, if file XtfHead.fName is absent;
%gXtf000Write used file XtfHead.fName as data source for XtfHead.RHeaderType~=0. The file XtfHead.fName must be presented (flTraceLenChanged=2 is exeption); names XtfHead.fName and fNameNew must be different.
%Example: gXtf000Write(XtfHead,Head,Data,'c:\temp\1new.xtf',0);

face=hex2dec('FACE');
if flTraceLenChanged~=2,
    [fId, mes]=fopen(XtfHead.fName,'r+');if ~isempty(mes), error(['gFXtfWrite000: ' mes]);end;%fseek(fId,0,'bof');
    if strcmp(fNameNew,XtfHead.fName), error('gFXtfWrite000: XtfHead.fName and fNameNew must be different.');end;
end;
[fId2, mes]=fopen(fNameNew,'w');if ~isempty(mes), error(['gFXtfWrite000: ' mes]);end;
LHead=(XtfHead.RHeaderType==0)&(XtfHead.RSubChannelNumber==Head.HSubChannelNumber);nHead=find(LHead);
%===Begin XTFFILEHEADER Structure Write
fwrite(fId2,XtfHead.HFileFormat,'uint8'); %Set to 123 (0x7B)
fwrite(fId2,XtfHead.HSystemType,'uint8');%Set to 1
fwrite(fId2,XtfHead.HRecordingProgramName,'char*1'); %Example: "Isis
fwrite(fId2,XtfHead.HRecordingProgramVersion,'char*1'); %Example: "556" for version 5.56
fwrite(fId2,XtfHead.HSonarName,'char*1'); %Name of server used to access sonar.  Example: "C31_SERV.EXE"
fwrite(fId2,XtfHead.HSonarType,'uint16'); %
fwrite(fId2,XtfHead.HNoteString,'char*1'); %Notes as entered in the Sonar Setup dialog box
fwrite(fId2,XtfHead.HThisFileName,'char*1'); %Name of this file. Example:"LINE12-B.XTF"
fwrite(fId2,XtfHead.HNavUnits,'uint16'); %0=Meters (i.e., UTM) or 3=Lat/Long
fwrite(fId2,XtfHead.HNumberOfSonarChannels,'uint16'); %if > 6, header grows to 2K in size
fwrite(fId2,XtfHead.HNumberOfBathymetryChannels,'uint16'); %
fwrite(fId2,XtfHead.HNumberOfSnippetChannels,'uint8'); %
fwrite(fId2,XtfHead.HNumberOfForwardLookArrays,'uint8'); %
fwrite(fId2,XtfHead.HNumberOfEchoStrengthChannels,'uint16'); %
fwrite(fId2,XtfHead.HNumberOfInterferometryChannels,'uint8'); %
fwrite(fId2,XtfHead.HReserved1,'uint8'); %Reserved. Set to 0.
fwrite(fId2,XtfHead.HReserved2,'uint16'); %Reserved. Set to 0.
fwrite(fId2,XtfHead.HReferencePointHeigh,'float32'); %Height of reference point above water line (m)
fwrite(fId2,XtfHead.HProjectionType,'char*1'); %Navigation System Parameters. Not currently used. Set to 0.
fwrite(fId2,XtfHead.HSpheriodType,'char*1'); %Navigation System Parameters. Not currently used. Set to 0.
fwrite(fId2,XtfHead.HNavigationLatency,'int32'); %Navigation System Parameters. Latency of nav system in milliseconds. (Usually GPS). ISIS Note: This value is entered on the Serial port setup dialog box.  When computing a position, Isis will take the time of the navigation and subtract this value.
fwrite(fId2,XtfHead.HOriginY,'float32'); %Navigation System Parameters. Not currently used. Set to 0
fwrite(fId2,XtfHead.HOriginX,'float32'); %Navigation System Parameters. Not currently used. Set to 0
fwrite(fId2,XtfHead.HNavOffsetY,'float32'); %Navigation System Parameters. Orientation of positive Y is forward. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HNavOffsetX,'float32'); %Navigation System Parameters. Orientation of positive X is to starboard. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HNavOffsetZ,'float32'); %Navigation System Parameters. Orientation of positive Z is down.  Just like depth. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HNavOffsetYaw,'float32'); %Navigation System Parameters. Orientation of positive yaw is turn to right. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HMRUOffsetY,'float32'); %Navigation System Parameters. Orientation of positive Y is forward. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HMRUOffsetX,'float32'); %Navigation System Parameters. Orientation of positive X is to starboard. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HMRUOffsetZ,'float32'); %Navigation System Parameters. Orientation of positive Z is down.  Just like depth. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HMRUOffsetYaw,'float32'); %Navigation System Parameters. Orientation of positive yaw is turn to right. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HMRUOffsetPitch,'float32'); %Navigation System Parameters. Orientation of positive pitch is nose up. ISIS Note: This offset is entered in the Multibeam setup dialog box. ISIS Note: This offset is entered in the Multibeam setup dialog box
fwrite(fId2,XtfHead.HMRUOffsetRoll,'float32'); %Navigation System Parameters. Orientation of positive roll is lean to starboard. ISIS Note: This offset is entered in the Multibeam setup dialog box
%===End XTFFILEHEADER Structure Write
nChanel=XtfHead.HNumberOfSonarChannels+XtfHead.HNumberOfBathymetryChannels+XtfHead.HNumberOfSnippetChannels+XtfHead.HNumberOfForwardLookArrays+XtfHead.HNumberOfEchoStrengthChannels+XtfHead.HNumberOfInterferometryChannels;
for n=1:nChanel,
    %===Begin CHANINFO Structure Write
    fwrite(fId2,XtfHead.CTypeOfChannel(n),'uint8'); %SUBBOTTOM=0, PORT=1, STBD=2, BATHYMETRY=3
    fwrite(fId2,XtfHead.CSubChannelNumber(n),'uint8'); %Index for which CHANINFO structure this is
    fwrite(fId2,XtfHead.CCorrectionFlags(n),'uint16'); %1=sonar imagery stored as slant-range, 2=sonar imagery stored as ground range (corrected)
    fwrite(fId2,XtfHead.CUniPolar(n),'uint16'); %0=data is polar, 1=data is unipolar
    fwrite(fId2,XtfHead.CBytesPerSample(n),'uint16'); %1 (8-bit data) or 2 (16-bit data) or 4 (32-bit)
    fwrite(fId2,XtfHead.CReserved(n),'uint32'); %Isis Note: Previously this was SamplesPerChannel.  Isis now supports the recording of every sample per ping, which means that number of samples per channel can vary from ping to ping if the range scale changes.  Because of this, the NumSamples value in the XTFPINGCHANHEADER structure (defined in Section 3.18) holds the number of samples to read for a given channel. For standard analog systems, this Reserved value is still filled in with 1024, 2048 or whatever the initial value is for SamplesPerChannel.
    fwrite(fId2,XtfHead.CChannelName(:,n),'char*1'); %Text describing channel.  i.e., "Port 500"
    fwrite(fId2,XtfHead.CVoltScale(n),'float32'); %This states how many volts are represented by a maximum sample value in the range  [-5.0 to +4.9998] volts. Default is 5.0.
    fwrite(fId2,XtfHead.CFrequency(n),'float32'); %Center transmit frequency
    fwrite(fId2,XtfHead.CHorizBeamAngle(n),'float32'); %Typically 1 degree or so
    fwrite(fId2,XtfHead.CTiltAngle(n),'float32'); %Typically 30 degrees
    fwrite(fId2,XtfHead.CBeamWidth(n),'float32'); %3dB beam width, Typically 50 degrees
    fwrite(fId2,XtfHead.COffsetX(n),'float32'); %Orientation of positive X is to starboard. Note: This offset is entered in the Multibeam setup dialog box
    fwrite(fId2,XtfHead.COffsetY(n),'float32'); %Orientation of positive Y is forward. Note: This offset is entered in the Multibeam setup dialog box
    fwrite(fId2,XtfHead.COffsetZ(n),'float32'); %Orientation of positive Z is down.  Just like depth. Note: This offset is entered in the Multibeam setup dialog box
    fwrite(fId2,XtfHead.COffsetYaw(n),'float32'); %Orientation of positive yaw is turn to right. If the multibeam sensor is reverse mounted (facing backwards), then OffsetYaw will be around 180 degrees. Note: This offset is entered in the Multibeam setup dialog box
    fwrite(fId2,XtfHead.COffsetPitch(n),'float32'); %Orientation of positive pitch is nose up. Note: This offset is entered in the Multibeam setup dialog box
    fwrite(fId2,XtfHead.COffsetRoll(n),'float32'); %Orientation of positive roll is lean to starboard. Note: This offset is entered in the Multibeam setup dialog box
    fwrite(fId2,XtfHead.CBeamsPerArray(n),'uint16'); %For forward look only (i.e., Sonatech DDS)
    fwrite(fId2,XtfHead.CReservedArea2(:,n),'char*1'); %Unused Set value to 0
    %===Begin CHANINFO Structure Write
end;
if mod(ftell(fId2),1024)~=0, z=zeros(1024-mod(ftell(fId2),1024),1);fwrite(fId2,z,'uint8');end; %0 to 1024*n
df=0;m=0;
for n=1:size(XtfHead.RHeaderType,2),
    if ~((XtfHead.RHeaderType(n)==0)&&(XtfHead.RSubChannelNumber(n)==Head.HSubChannelNumber))&&(flTraceLenChanged~=2),
        %===Begin ShortHeader structure Write
        fwrite(fId2,face,'uint16'); %FACE
        fwrite(fId2,XtfHead.RHeaderType(n),'uint8'); %HeaderType
        fwrite(fId2,XtfHead.RSubChannelNumber(n),'uint8'); %SubChannelNumber
        fwrite(fId2,XtfHead.RNumChansToFollow(n),'uint16'); %NumChansToFollow
        fwrite(fId2,XtfHead.RUnused(n),'uint32'); %Unused. Set to 0
        fwrite(fId2,XtfHead.RNumBytesThisRecord(n),'uint32'); %NumBytesThisRecord
        %===End ShortHeader structure Write
        %===Begin DataBlock Write
        fseek(fId,XtfHead.RSeek(n)-df,'cof');
        zz=fread(fId,XtfHead.RNumBytesThisRecord(n)-14,'uint8')';
        df=ftell(fId);fwrite(fId2,zz,'uint8'); %Byte field
        %===End DataBlock Write
    elseif (XtfHead.RHeaderType(n)==0)&&(XtfHead.RSubChannelNumber(n)==Head.HSubChannelNumber),
        m=m+1;
        if nHead(m)~=Head.HMessageNum(m), error(['Error: gFXtfWrite000, not correct Messages order for message num=' num2str(m)]);end;
        %===Begin ShortHeader structure Write
        fwrite(fId2,face,'uint16'); %FACE
        fwrite(fId2,XtfHead.RHeaderType(n),'uint8'); %HeaderType
        fwrite(fId2,XtfHead.RSubChannelNumber(n),'uint8'); %SubChannelNumber
        fwrite(fId2,XtfHead.RNumChansToFollow(n),'uint16'); %NumChansToFollow
        fwrite(fId2,XtfHead.RUnused(n),'uint32'); %Unused. Set to 0
        fwrite(fId2,XtfHead.RNumBytesThisRecord(n),'uint32'); %NumBytesThisRecord
        RSeekCurrent=ftell(fId2);
        %===End ShortHeader structure Write
        %===Begin Head Write
        %fwrite(fId2,face,'uint16');fwrite(fId2,Head.HHeaderType(m),'uint8');fwrite(fId2,Head.HSubChannelNumber(m),'uint8');fwrite(fId2,Head.HNumChansToFollow(m),'uint16');fwrite(fId2,Head.HReserved1(:,m),'uint16');fwrite(fId2,Head.HNumBytesThisRecord(m),'uint32');
        fwrite(fId2,Head.HYear(m),'uint16'); %Ping year
        fwrite(fId2,Head.HMonth(m),'uint8'); %Ping month
        fwrite(fId2,Head.HDay(m),'uint8'); %Ping day
        fwrite(fId2,Head.HHour(m),'uint8'); %Ping hour
        fwrite(fId2,Head.HMinute(m),'uint8'); %Ping minute
        fwrite(fId2,Head.HSecond(m),'uint8'); %Ping seconds
        fwrite(fId2,Head.HHSeconds(m),'uint8'); %Ping hundredths of seconds (0-99)
        fwrite(fId2,Head.HJulianDay(m),'uint16'); %Julian day of a ping’s occurrence.
        fwrite(fId2,Head.HEventNumber(m),'uint32'); %Last logged event number; nav interface template token=O. NOTE: In Isis v4.30 and earlier EventNumber field was located at byte 26-27 and was a two byte WORD.  At byte 24-25 there used to be a WORD CurrentLineID.  The CurrentLineID field no longer exists in the .XTF format.  Therefore, to read the event number correctly an application MUST check the Isis version string starting at byte 10 of the XTFFILEHEADER structure.
        fwrite(fId2,Head.HPingNumber(m),'uint32'); %Counts consecutively (usually from 0) and increments for each update.  Isis Note: The counters are different between sonar and bathymetry updates.
        fwrite(fId2,Head.HSoundVelocity(m),'float32'); %m/s,  Isis uses 750 (one way), some XTF files use 1500.  Note: Can be changed on Isis menu.  This value is never computed and can only be changed manually by the user. See ComputedSoundVelocity below.
        fwrite(fId2,Head.HOceanTide(m),'float32'); %Altitude above Geoide (from RTK), if present; ELSE Ocean tide in meters; nav interface template token = {t} Isis Note: Can be changed by the user on the Configure menu in Isis.
        fwrite(fId2,Head.HReserved2(m),'uint32'); %Unused. Set to 0.
        fwrite(fId2,Head.HConductivityFreq(m),'float32'); %Conductivity frequency in Hz. nav interface template token = Q Raw CTD information.  The Freq values are those sent up by the Seabird CTD. The Falmouth Scientific CTD sends up computed data.
        fwrite(fId2,Head.HTemperatureFreq(m),'float32'); %Temperature frequency in Hz. nav interface template token = b Raw CTD information.  The Freq values are those sent up by the Seabird CTD. The Falmouth Scientific CTD sends up computed data.
        fwrite(fId2,Head.HPressureFreq(m),'float32'); %Pressure frequency in Hz. nav interface template token = 0.  Raw CTD information.  The Freq values are those sent up by the Seabird CTD. The Falmouth Scientific CTD sends up computed data.
        fwrite(fId2,Head.HPressureTemp(m),'float32'); %Pressure temperature (Degrees C); nav interface template token = ; Raw CTD information.  The Freq values are those sent up by the Seabird CTD. The Falmouth Scientific CTD sends up computed data.
        fwrite(fId2,Head.HConductivity(m),'float32'); %Conductivity in Siemens/m; nav interface token = {c}; can be computed from Q Computed CTD information. When using a Seabird CTD, these values are computed from the raw Freq values (above).
        fwrite(fId2,Head.HWaterTemperature(m),'float32'); %Water temperature in Celsius. nav interface token = {w}; can be computed from b. Computed CTD information. When using a Seabird CTD, these values are computed from the raw Freq values (above)
        fwrite(fId2,Head.HPressure(m),'float32'); %Water pressure in psia; nav interface token = {p}; can be computed from 0. Computed CTD information. When using a Seabird CTD, these values are computed from the raw Freq values (above).
        fwrite(fId2,Head.HComputedSoundVelocity(m),'float32'); %Meters/second computed from Conductivity, WaterTemperature, and Pressure using the Chen Millero formula (1977), formula (JASA, 62, 1129-1135)
        fwrite(fId2,Head.HMagX(m),'float32'); %X-axis magnetometer data in mgauss. Nav interface template token = e. Sensors Information.
        fwrite(fId2,Head.HMagY(m),'float32'); %Y-axis magnetometer data in mgauss. Nav interface template token = w. Sensors Information.
        fwrite(fId2,Head.HMagZ(m),'float32'); %Z-axis magnetometer data in mgauss. Nav interface template token = z. Sensors Information.
        fwrite(fId2,Head.HAuxVal1(m),'float32'); %Sensors Information. Nav interface template token = 1. Auxiliary values can be used to store and display any value at the user's discretion. Not used in any calculation in Isis or Target. Isis Note: Displayed in the “Sensors” window by selecting “Window?Text?Sensors”
        fwrite(fId2,Head.HAuxVal2(m),'float32'); %Sensors Information. Nav interface template token = 2. Auxiliary values can be used to store and display any value at the user's discretion.   These are not used in any calculation in Isis or Target. Isis Note: Displayed in the “Sensors” window by selecting “Window?Text?Sensors”
        fwrite(fId2,Head.HAuxVal3(m),'float32'); %Sensors Information. Nav interface template token = 3. Auxiliary values can be used to store and display any value at the user's discretion.   These are not used in any calculation in Isis or Target. Isis Note: Displayed in the “Sensors” window by selecting “Window?Text?Sensors”
        fwrite(fId2,Head.HAuxVal4(m),'float32'); %Sensors Information. Nav interface template token = 4. Auxiliary values can be used to store and display any value at the user's discretion.   These are not used in any calculation in Isis or Target. Isis Note: Displayed in the “Sensors” window by selecting “Window?Text?Sensors”
        fwrite(fId2,Head.HAuxVal5(m),'float32'); %Sensors Information. Nav interface template token = 5. Auxiliary values can be used to store and display any value at the user's discretion.   These are not used in any calculation in Isis or Target. Isis Note: Displayed in the “Sensors” window by selecting “Window?Text?Sensors”
        fwrite(fId2,Head.HAuxVal6(m),'float32'); %Sensors Information. Nav interface template token = 6. Auxiliary values can be used to store and display any value at the user's discretion.   These are not used in any calculation in Isis or Target. Isis Note: Displayed in the “Sensors” window by selecting “Window?Text?Sensors”
        fwrite(fId2,Head.HSpeedLog(m),'float32'); %Sensors Information. Speed log sensor on towfish in knots; Note: This is not fish speed. Nav interface template token = s.
        fwrite(fId2,Head.HTurbidity(m),'float32'); %Sensors Information. Turbidity sensor (0 to +5 volts) multiplied by 10000. nav interface template token = | (the “pipe” symbol).
        fwrite(fId2,Head.HShipSpeed(m),'float32'); %Ship Navigation information. Ship speed in knots. nav interface template token = v. Isis Note: These values are stored only and are not part of any equation or computation in Isis.
        fwrite(fId2,Head.HShipGyro(m),'float32'); %Ship Navigation information. Ship gyro in degrees. nav interface template token = G. Isis Note: This is used as the directional sensor for Multibeam Bathymetry data.
        fwrite(fId2,Head.HShipYcoordinate(m),'float64'); %Ship Navigation information. Ship latitude or northing in degrees. nav interface template token = y. Isis Note: These values are stored only and are not part of any equation or computation in Isis.
        fwrite(fId2,Head.HShipXcoordinate(m),'float64'); %Ship Navigation information. Ship longitude or easting in degrees. nav interface template token = x. Isis Note: These values are stored only and are not part of any equation or computation in Isis.
        fwrite(fId2,Head.HShipAltitude(m),'uint16'); %Ship altitude in decimeters
        fwrite(fId2,Head.HShipDepth(m),'uint16'); %Ship depth in decimeters.
        fwrite(fId2,Head.HFixTimeHour(m),'uint8'); %Sensor Navigation information. Hour of most recent nav update. nav interface template token = H. Isis Note: The time of the nav is adjusted by the NavLatency stored in the XTF file header.
        fwrite(fId2,Head.HFixTimeMinute(m),'uint8'); %Sensor Navigation information. Minute of most recent nav update. nav interface template token = I. Isis Note: The time of the nav is adjusted by the NavLatency stored in the XTF file header.
        fwrite(fId2,Head.HFixTimeSecond(m),'uint8'); %Sensor Navigation information. Second of most recent nav update. nav interface template token = S. Isis Note: The time of the nav is adjusted by the NavLatency stored in the XTF file header.
        fwrite(fId2,Head.HFixTimeHsecond(m),'uint8'); %Sensor Navigation information. Hundredth of a Second of most recent nav update. Isis Note: The time of the nav is adjusted by the NavLatency stored in the XTF file header.
        fwrite(fId2,Head.HSensorSpeed(m),'float32'); %Sensor Navigation information. Speed of towfish in knots. Used for speed correction and position calculation; nav interface template token = V.
        fwrite(fId2,Head.HKP(m),'float32'); %Sensor Navigation information. Kilometers Pipe; nav interface template token = {K}.
        fwrite(fId2,Head.HSensorYcoordinate(m),'float64'); %Sensor Navigation information. Sensor latitude or northing; nav interface template token = E. Note: when NavUnits in the file header is 0, values are in meters (northings and eastings).  When NavUnits is 3, values are in Lat/Long.  Also see the Layback value, below.
        fwrite(fId2,Head.HSensorXcoordinate(m),'float64'); %Sensor Navigation information. Sensor longitude or easting; nav interface template token = N. Note: when NavUnits in the file header is 0, values are in meters (northings and eastings).  When NavUnits is 3, values are in Lat/Long.  Also see the Layback value, below.
        fwrite(fId2,Head.HSonarStatus(m),'uint16'); %Tow Cable information. System status value, sonar dependant (displayed in Status window).
        fwrite(fId2,Head.HRangeToFish(m),'uint16'); %Slant range to sensor in decimeters; nav interface template token = ? (question mark).  Stored only – not used in any computation.
        fwrite(fId2,Head.HBearingToFish(m),'uint16'); %Bearing to towfish from ship, stored in degrees multiplied by 100; nav interface template token = > (greater-than sign).  Stored only – not used in any computation in Isis.
        fwrite(fId2,Head.HCableOut(m),'uint16'); %Tow Cable information. Amount of cable payed out in meters; nav interface template token = o.
        fwrite(fId2,Head.HLayback(m),'float32'); %Tow Cable information. Distance over ground from ship to fish.; nav interface template token = l. Isis Note: When this value is non-zero, Isis assumes that SensorYcoordinate and SensorXcoordinate need to be adjusted with the Layback.  The sensor position is then computed using the current sensor heading and this layback value.  The result is displayed when a position is computed in Isis.
        fwrite(fId2,Head.HCableTension(m),'float32'); %Tow Cable information Cable tension from serial port. Stored only; nav interface template token = P
        fwrite(fId2,Head.HSensorDepth(m),'float32'); %Sensor Attitude information. Distance (m) from sea surface to sensor. The deeper the sensor goes, the bigger (positive) this value becomes. nav interface template token = 0 (zero)
        fwrite(fId2,Head.HSensorPrimaryAltitude(m),'float32'); %Sensor Attitude information. Distance from towfish to the sea floor; nav interface template token = 7. Isis Note: This is the primary altitude as tracked by the Isis bottom tracker or entered manually by the user. Although not recommended, the user can override the Isis bottom tracker by sending the primary altitude over the serial port.  The user should turn the Isis bottom tracker Off when this is done.
        fwrite(fId2,Head.HSensorAuxAltitude(m),'float32'); %Sensor Attitude information. Auxiliary altitude; nav interface template token = a. Isis Note: This is an auxiliary altitude as transmitted by an altimeter and received over a serial port. The user can switch between the Primary and  Aux altitudes via the "options" button in the Isis bottom track window.
        fwrite(fId2,Head.HSensorPitch(m),'float32'); %Sensor Attitude information. Pitch in degrees (positive=nose up); nav interface template token = 8.
        fwrite(fId2,Head.HSensorRoll(m),'float32'); %Sensor Attitude information. Roll in degrees (positive=roll to starboard); nav interface template token = 9.
        fwrite(fId2,Head.HSensorHeading(m),'float32'); %Sensor Attitude information. Sensor heading in degrees; nav interface template token = h.
        fwrite(fId2,Head.HHeave(m),'float32'); %Attitude information. Sensors heave at start of ping. Positive value means sensor moved up. Note: These Pitch, Roll, Heading, Heave and Yaw values are those received closest in time to this sonar or bathymetry update.  If a TSS or MRU is being used with a multibeam/bathymetry sensor, the user should  use the higher-resolution attitude data found in the XTFATTITUDEDATA structures.
        fwrite(fId2,Head.HYaw(m),'float32'); %Attitude information. Sensor yaw.  Positive means turn to right. Note: These Pitch, Roll, Heading, Heave and Yaw values are those received closest in time to this sonar or bathymetry update.  If a TSS or MRU is being used with a multibeam/bathymetry sensor, the user should use the higher-resolution attitude data found in the XTFATTITUDEDATA structures.  Since the heading information is updated in high resolution, it is not necessary to log or use Yaw in any processing.  Isis does not use Yaw
        fwrite(fId2,Head.HAttitudeTimeTag(m),'uint32'); %Attitude information. In milliseconds - used to coordinate with millisecond time value in Attitude packets.  (M)andatory when logging XTFATTITUDE packets.
        fwrite(fId2,Head.HDOT(m),'float32'); %Misc. Distance Off Track
        fwrite(fId2,Head.HNavFixMilliseconds(m),'uint32'); %Misc. millisecond clock value when nav received
        fwrite(fId2,Head.HComputerClockHour(m),'uint8'); %Isis Note: The Isis computer clock time when this ping was received. May be different from ping time at start of this record if the sonar time-stamped the data and the two systems aren't synched. This time should be ignored in most cases
        fwrite(fId2,Head.HComputerClockMinute(m),'uint8'); %Isis Note:  see above Isis Note
        fwrite(fId2,Head.HComputerClockSecond(m),'uint8'); %Isis Note:  see above Isis Note
        fwrite(fId2,Head.HComputerClockHsec(m),'uint8'); %Isis Note:  see above Isis Note
        fwrite(fId2,Head.HFishPositionDeltaX(m),'int16'); %Additional Tow Cable and Fish information from Trackpoint. Stored as meters multiplied by 3.0, supporting +/- 10000.0m (usually from trackpoint); nav interface template token = {DX}.
        fwrite(fId2,Head.HFishPositionDeltaY(m),'int16'); %Additional Tow Cable and Fish information from Trackpoint. X, Y offsets can be used instead of logged layback.; nav interface template token = {DY}.
        fwrite(fId2,Head.HFishPositionErrorCode(m),'*char'); %Additional Tow Cable and Fish information from Trackpoint. Error code for FishPosition delta x,y. (typically reported by Trackpoint).
        fwrite(fId2,Head.HOptionalOffsey(m),'uint32'); %OptionalOffsey (Triton 7125 only)
        fwrite(fId2,Head.HCableOutHundredths(m),'uint8'); %Hundredths of a meter of cable out, to be added  to the CableOut field.
        fwrite(fId2,Head.HReservedSpace2(:,m),'uint8'); %Unused. Set to 0.
        for mm=1:XtfHead.RNumChansToFollow(nHead(m)),
            %===Begin ChanInfo Write
            fwrite(fId2,Head.CChannelNumber(mm,m),'uint16'); %Typically 0=port (low frequency) 1=stbd (low frequency) 2=port (high frequency) 3=stbd (high frequency)
            fwrite(fId2,Head.CDownsampleMethod(mm,m),'uint16'); %2 = MAX; 4 = RMS
            fwrite(fId2,Head.CSlantRange(mm,m),'float32'); %Slant range of the data in meters
            fwrite(fId2,Head.CGroundRange(mm,m),'float32'); %Ground range of the data; in meters (SlantRange^2 - Altitude^2)
            fwrite(fId2,Head.CTimeDelay(mm,m),'float32'); %Amount of time, in seconds, to the start of recorded data. (almost always 0.0).
            fwrite(fId2,Head.CTimeDuration(mm,m),'float32'); %Amount of time, in seconds, recorded (typically SlantRange/750)
            fwrite(fId2,Head.CSecondsPerPing(mm,m),'float32'); %Amount of time, in seconds, from ping to ping. (SlantRange/750)
            fwrite(fId2,Head.CProcessingFlags(mm,m),'uint16'); %4 = TVG; 8 = BAC&GAC; 16 = filter, etc. (almost always zero)
            fwrite(fId2,Head.CFrequency(mm,m),'uint16'); %Ccenter transmit frequency for this channel
            fwrite(fId2,Head.CInitialGainCode(mm,m),'uint16'); %Settings as transmitted by sonar
            fwrite(fId2,Head.CGainCode(mm,m),'uint16'); %Settings as transmitted by sonar
            fwrite(fId2,Head.CBandWidth(mm,m),'uint16'); %Settings as transmitted by sonar
            fwrite(fId2,Head.CContactNumber(mm,m),'uint32'); %Contact information . Upated when contacts are saved in Target utility.
            fwrite(fId2,Head.CContactClassification(mm,m),'uint16'); %Contact information . Updated when contacts are saved in Target utility.
            fwrite(fId2,Head.CContactSubNumber(mm,m),'uint8'); %Contact information . Udated when contacts are saved in Target utility
            fwrite(fId2,Head.CContactType(mm,m),'uint8'); %Contact information . Updated when contacts are saved in Target utility
            fwrite(fId2,Head.CNumSamples(mm,m),'uint32'); %Number of samples that will follow this structure. The number of bytes will be this value multiplied by the number of bytes per sample. BytesPerSample found in CHANINFO structure (given in the file header).
            fwrite(fId2,Head.CMillivoltScale(mm,m),'uint16'); %Maximum voltage, in mv, represented by a full-scale value in the data.If zero, then the value stored in the VoltScale should be used instead. VoltScale can be found in the XTF file header, ChanInfo structure. Note that VoltScale is specified in volts, while MillivoltScale is stored in millivolts. This provides for a range of –65,536 volts to 65,535 volts.
            fwrite(fId2,Head.CContactTimeOffTrack(mm,m),'float32'); %Time off track to this contact (stored in milliseconds)
            fwrite(fId2,Head.CContactCloseNumber(mm,m),'uint8'); %
            fwrite(fId2,Head.CReserved2(mm,m),'uint8'); %Unused. Set to 0.
            fwrite(fId2,Head.CFixedVSOP(mm,m),'float32'); %This is the fixed, along-track size of each ping, stored in centimeters. On multibeam systems with zero beam spread, this value needs to be filled in to prevent Isis from calculating along-track ground coverage based on beam spread and speed over ground.
            fwrite(fId2,Head.CWeight(mm,m),'int16'); %Weighting factor passed by some sonars, this value is mandatory for Edgetech digital sonars types 24, 35, 38, 48 and Kongsberg SA type 48
            fwrite(fId2,Head.CReservedSpace(mm,m,:),'uint8'); %Unused. Set to 0.
            %===End ChanInfo Write
            %===Begin Data Write
            L=find(XtfHead.RSubChannelNumber(n)==XtfHead.CSubChannelNumber); %!!!
            DBit=XtfHead.Descript.BytesPerSample.C{XtfHead.Descript.UniPolar.Code==XtfHead.CUniPolar(L(1)),XtfHead.Descript.BytesPerSample.Code==XtfHead.CBytesPerSample(L(1))};
            fwrite(fId2,Data(1:Head.CNumSamples(mm,m),m,mm),DBit);
            %===End Data Write
        end;
        %zzz=mod(64-ftell(fId2),64);if zzz==0, zzz
        if mod(ftell(fId2),64)~=0, z=zeros(64-mod(ftell(fId2),64),1);fwrite(fId2,z,'uint8');
        %else,fwrite(fId2,zeros(64,1),'uint8');%!!!!!!!!! add for test
        end; %0 to 64*n
        %===Begin correction for Number Bytes This Record
        RNumBytesThisRecordNew=ftell(fId2)-RSeekCurrent+14; %estimate
        %disp([n RNumBytesThisRecordNew XtfHead.RNumBytesThisRecord(n)]);
        if (RNumBytesThisRecordNew~=XtfHead.RNumBytesThisRecord(n))&&(flTraceLenChanged==0),error(['Error: gFXtfWrite0000, not correct XtfHead.RNumBytesThisRecord for message num=' num2str(n)]);end;
        if (RNumBytesThisRecordNew~=XtfHead.RNumBytesThisRecord(n))&&(flTraceLenChanged>0),
            fseek(fId2,-RNumBytesThisRecordNew+10,'cof');fwrite(fId2,RNumBytesThisRecordNew,'uint32');fseek(fId2,RNumBytesThisRecordNew-14,'cof');
        end;
        %===End correction for Number Bytes This Record
        %if ~mod(m,5000), disp(['Trace: ',num2str(m)]);end;
    end;
end;
fclose(fId2);
if flTraceLenChanged~=2, fclose(fId);end;

%mail@ge0mlib.com 18/05/2017