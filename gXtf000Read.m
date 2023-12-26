function [Head,Data]=gXtf000Read(XtfHead,SubCh)
%Read [Head,Data] from XtfHead.fName (*.xtf) file for Message Type 000 (Sonar Data Message).
%function [Head,Data]=gXtf000Read(XtfHead,SubCh), where
%XtfHead- Xtf Header structure;
%SubCh- sub channel number;
%Head- Header structure;
%Data- Data for sonar channels.
%Head include the next addition fields: Head.HSubChannelNumber, Head.HMessageNum.
%Example: [Head,Data]=gXtf000Read(XtfHead,0);

[fId, mes]=fopen(XtfHead.fName,'r');if ~isempty(mes), error(['gFXtfRead000: ' mes]);end;
LHead=(XtfHead.RHeaderType==0)&(XtfHead.RSubChannelNumber==SubCh);LenHead=sum(LHead);nHead=find(LHead);
ChF=max(XtfHead.RNumChansToFollow(nHead));
%===Begin Header and ChanInfo Allocate
Head=struct('HMessageType',000,'HSubChannelNumber',SubCh,'HMessageNum',nan(1,LenHead),'HYear',nan(1,LenHead),'HMonth',nan(1,LenHead),'HDay',nan(1,LenHead),'HHour',nan(1,LenHead),'HMinute',nan(1,LenHead),...
    'HSecond',nan(1,LenHead),'HHSeconds',nan(1,LenHead),'HJulianDay',nan(1,LenHead),'HEventNumber',nan(1,LenHead),'HPingNumber',nan(1,LenHead),'HSoundVelocity',nan(1,LenHead),...
    'HOceanTide',nan(1,LenHead),'HReserved2',nan(1,LenHead),'HConductivityFreq',nan(1,LenHead),'HTemperatureFreq',nan(1,LenHead),'HPressureFreq',nan(1,LenHead),...
    'HPressureTemp',nan(1,LenHead),'HConductivity',nan(1,LenHead),'HWaterTemperature',nan(1,LenHead),'HPressure',nan(1,LenHead),'HComputedSoundVelocity',nan(1,LenHead),...
    'HMagX',nan(1,LenHead),'HMagY',nan(1,LenHead),'HMagZ',nan(1,LenHead),'HAuxVal1',nan(1,LenHead),'HAuxVal2',nan(1,LenHead),'HAuxVal3',nan(1,LenHead),...
    'HAuxVal4',nan(1,LenHead),'HAuxVal5',nan(1,LenHead),'HAuxVal6',nan(1,LenHead),'HSpeedLog',nan(1,LenHead),'HTurbidity',nan(1,LenHead),'HShipSpeed',nan(1,LenHead),...
    'HShipGyro',nan(1,LenHead),'HShipYcoordinate',nan(1,LenHead),'HShipXcoordinate',nan(1,LenHead),'HShipAltitude',nan(1,LenHead),'HShipDepth',nan(1,LenHead),...
    'HFixTimeHour',nan(1,LenHead),'HFixTimeMinute',nan(1,LenHead),'HFixTimeSecond',nan(1,LenHead),'HFixTimeHsecond',nan(1,LenHead),'HSensorSpeed',nan(1,LenHead),...
    'HKP',nan(1,LenHead),'HSensorYcoordinate',nan(1,LenHead),'HSensorXcoordinate',nan(1,LenHead),'HSonarStatus',nan(1,LenHead),'HRangeToFish',nan(1,LenHead),'HBearingToFish',nan(1,LenHead),...
    'HCableOut',nan(1,LenHead),'HLayback',nan(1,LenHead),'HCableTension',nan(1,LenHead),'HSensorDepth',nan(1,LenHead),'HSensorPrimaryAltitude',nan(1,LenHead),...
    'HSensorAuxAltitude',nan(1,LenHead),'HSensorPitch',nan(1,LenHead),'HSensorRoll',nan(1,LenHead),'HSensorHeading',nan(1,LenHead),'HHeave',nan(1,LenHead),'HYaw',nan(1,LenHead),...
    'HAttitudeTimeTag',nan(1,LenHead),'HDOT',nan(1,LenHead),'HNavFixMilliseconds',nan(1,LenHead),'HComputerClockHour',nan(1,LenHead),'HComputerClockMinute',nan(1,LenHead),...
    'HComputerClockSecond',nan(1,LenHead),'HComputerClockHsec',nan(1,LenHead),'HFishPositionDeltaX',nan(1,LenHead),'HFishPositionDeltaY',nan(1,LenHead),'HFishPositionErrorCode',char(nan(1,LenHead)),...
    'HOptionalOffsey',nan(1,LenHead),'HCableOutHundredths',nan(1,LenHead),'HReservedSpace2',nan(6,LenHead),...
    'CChannelNumber',nan(ChF,LenHead),'CDownsampleMethod',nan(ChF,LenHead),'CSlantRange',nan(ChF,LenHead),'CGroundRange',nan(ChF,LenHead),'CTimeDelay',nan(ChF,LenHead),'CTimeDuration',nan(ChF,LenHead),...
    'CSecondsPerPing',nan(ChF,LenHead),'CProcessingFlags',nan(ChF,LenHead),'CFrequency',nan(ChF,LenHead),'CInitialGainCode',nan(ChF,LenHead),'CGainCode',nan(ChF,LenHead),...
    'CBandWidth',nan(ChF,LenHead),'CContactNumber',nan(ChF,LenHead),'CContactClassification',nan(ChF,LenHead),'CContactSubNumber',nan(ChF,LenHead),'CContactType',nan(ChF,LenHead),...
    'CNumSamples',nan(ChF,LenHead),'CMillivoltScale',nan(ChF,LenHead),'CContactTimeOffTrack',nan(ChF,LenHead),'CContactCloseNumber',nan(ChF,LenHead),'CReserved2',nan(ChF,LenHead),...
    'CFixedVSOP',nan(ChF,LenHead),'CWeight',nan(ChF,LenHead),'CReservedSpace',nan(ChF,LenHead,4));
%===End Header and ChanInfo Allocate
df=0;fseek(fId,0,'bof');CDataSeek=nan(ChF,LenHead);
for n=1:LenHead,
    fseek(fId,XtfHead.RSeek(nHead(n))-df,'cof');
    %===Begin Header Read
    Head.HMessageNum(n)=nHead(n);
    %face=fread(fId,1,'uint16');if face~=64206, error('Error gFXtfRead000: MagicNumber~=FACE');end;Head.HHeaderType(n)=fread(fId,1,'uint8');Head.HSubChannelNumber(n)=fread(fId,1,'uint8');Head.HNumChansToFollow(n)=fread(fId,1,'uint16');Head.HReserved1(:,n)=fread(fId,2,'uint16')';Head.HNumBytesThisRecord(n)=fread(fId,1,'uint32');
    Head.HYear(n)=fread(fId,1,'uint16'); %Ping year
    Head.HMonth(n)=fread(fId,1,'uint8'); %Ping month
    Head.HDay(n)=fread(fId,1,'uint8'); %Ping day
    Head.HHour(n)=fread(fId,1,'uint8'); %Ping hour
    Head.HMinute(n)=fread(fId,1,'uint8'); %Ping minute
    Head.HSecond(n)=fread(fId,1,'uint8'); %Ping seconds
    Head.HHSeconds(n)=fread(fId,1,'uint8'); %Ping hundredths of seconds (0-99)
    Head.HJulianDay(n)=fread(fId,1,'uint16'); %Julian day of a ping’s occurrence.
    Head.HEventNumber(n)=fread(fId,1,'uint32'); %Last logged event number; nav interface template token=O. NOTE: In Isis v4.30 and earlier EventNumber field was located at byte 26-27 and was a two byte WORD.  At byte 24-25 there used to be a WORD CurrentLineID.  The CurrentLineID field no longer exists in the .XTF format.  Therefore, to read the event number correctly an application MUST check the Isis version string starting at byte 10 of the XTFFILEHEADER structure.
    Head.HPingNumber(n)=fread(fId,1,'uint32'); %Counts consecutively (usually from 0) and increments for each update.  Isis Note: The counters are different between sonar and bathymetry updates.
    Head.HSoundVelocity(n)=fread(fId,1,'float32'); %m/s,  Isis uses 750 (one way), some XTF files use 1500.  Note: Can be changed on Isis menu.  This value is never computed and can only be changed manually by the user. See ComputedSoundVelocity below.
    Head.HOceanTide(n)=fread(fId,1,'float32'); %Altitude above Geoide (from RTK), if present; ELSE Ocean tide in meters; nav interface template token = {t} Isis Note: Can be changed by the user on the Configure menu in Isis.
    Head.HReserved2(n)=fread(fId,1,'uint32'); %Unused. Set to 0.
    Head.HConductivityFreq(n)=fread(fId,1,'float32'); %Conductivity frequency in Hz. nav interface template token = Q Raw CTD information.  The Freq values are those sent up by the Seabird CTD. The Falmouth Scientific CTD sends up computed data.
    Head.HTemperatureFreq(n)=fread(fId,1,'float32'); %Temperature frequency in Hz. nav interface template token = b Raw CTD information.  The Freq values are those sent up by the Seabird CTD. The Falmouth Scientific CTD sends up computed data.
    Head.HPressureFreq(n)=fread(fId,1,'float32'); %Pressure frequency in Hz. nav interface template token = 0.  Raw CTD information.  The Freq values are those sent up by the Seabird CTD. The Falmouth Scientific CTD sends up computed data.
    Head.HPressureTemp(n)=fread(fId,1,'float32'); %Pressure temperature (Degrees C); nav interface template token = ; Raw CTD information.  The Freq values are those sent up by the Seabird CTD. The Falmouth Scientific CTD sends up computed data.
    Head.HConductivity(n)=fread(fId,1,'float32'); %Conductivity in Siemens/m; nav interface token = {c}; can be computed from Q Computed CTD information. When using a Seabird CTD, these values are computed from the raw Freq values (above).
    Head.HWaterTemperature(n)=fread(fId,1,'float32'); %Water temperature in Celsius. nav interface token = {w}; can be computed from b. Computed CTD information. When using a Seabird CTD, these values are computed from the raw Freq values (above)
    Head.HPressure(n)=fread(fId,1,'float32'); %Water pressure in psia; nav interface token = {p}; can be computed from 0. Computed CTD information. When using a Seabird CTD, these values are computed from the raw Freq values (above).
    Head.HComputedSoundVelocity(n)=fread(fId,1,'float32'); %Meters/second computed from Conductivity, WaterTemperature, and Pressure using the Chen Millero formula (1977), formula (JASA, 62, 1129-1135)
    Head.HMagX(n)=fread(fId,1,'float32'); %X-axis magnetometer data in mgauss. Nav interface template token = e. Sensors Information.
    Head.HMagY(n)=fread(fId,1,'float32'); %Y-axis magnetometer data in mgauss. Nav interface template token = w. Sensors Information.
    Head.HMagZ(n)=fread(fId,1,'float32'); %Z-axis magnetometer data in mgauss. Nav interface template token = z. Sensors Information.
    Head.HAuxVal1(n)=fread(fId,1,'float32'); %Sensors Information. Nav interface template token = 1. Auxiliary values can be used to store and display any value at the user's discretion. Not used in any calculation in Isis or Target. Isis Note: Displayed in the “Sensors” window by selecting “Window?Text?Sensors”
    Head.HAuxVal2(n)=fread(fId,1,'float32'); %Sensors Information. Nav interface template token = 2. Auxiliary values can be used to store and display any value at the user's discretion.   These are not used in any calculation in Isis or Target. Isis Note: Displayed in the “Sensors” window by selecting “Window?Text?Sensors”
    Head.HAuxVal3(n)=fread(fId,1,'float32'); %Sensors Information. Nav interface template token = 3. Auxiliary values can be used to store and display any value at the user's discretion.   These are not used in any calculation in Isis or Target. Isis Note: Displayed in the “Sensors” window by selecting “Window?Text?Sensors”
    Head.HAuxVal4(n)=fread(fId,1,'float32'); %Sensors Information. Nav interface template token = 4. Auxiliary values can be used to store and display any value at the user's discretion.   These are not used in any calculation in Isis or Target. Isis Note: Displayed in the “Sensors” window by selecting “Window?Text?Sensors”
    Head.HAuxVal5(n)=fread(fId,1,'float32'); %Sensors Information. Nav interface template token = 5. Auxiliary values can be used to store and display any value at the user's discretion.   These are not used in any calculation in Isis or Target. Isis Note: Displayed in the “Sensors” window by selecting “Window?Text?Sensors”
    Head.HAuxVal6(n)=fread(fId,1,'float32'); %Sensors Information. Nav interface template token = 6. Auxiliary values can be used to store and display any value at the user's discretion.   These are not used in any calculation in Isis or Target. Isis Note: Displayed in the “Sensors” window by selecting “Window?Text?Sensors”
    Head.HSpeedLog(n)=fread(fId,1,'float32'); %Sensors Information. Speed log sensor on towfish in knots; Note: This is not fish speed. Nav interface template token = s.
    Head.HTurbidity(n)=fread(fId,1,'float32'); %Sensors Information. Turbidity sensor (0 to +5 volts) multiplied by 10000. nav interface template token = | (the “pipe” symbol).
    Head.HShipSpeed(n)=fread(fId,1,'float32'); %Ship Navigation information. Ship speed in knots. nav interface template token = v. Isis Note: These values are stored only and are not part of any equation or computation in Isis.
    Head.HShipGyro(n)=fread(fId,1,'float32'); %Ship Navigation information. Ship gyro in degrees. nav interface template token = G. Isis Note: This is used as the directional sensor for Multibeam Bathymetry data.
    Head.HShipYcoordinate(n)=fread(fId,1,'float64'); %Ship Navigation information. Ship latitude or northing in degrees. nav interface template token = y. Isis Note: These values are stored only and are not part of any equation or computation in Isis.
    Head.HShipXcoordinate(n)=fread(fId,1,'float64'); %Ship Navigation information. Ship longitude or easting in degrees. nav interface template token = x. Isis Note: These values are stored only and are not part of any equation or computation in Isis.
    Head.HShipAltitude(n)=fread(fId,1,'uint16'); %Ship altitude in decimeters
    Head.HShipDepth(n)=fread(fId,1,'uint16'); %Ship depth in decimeters.
    Head.HFixTimeHour(n)=fread(fId,1,'uint8'); %Sensor Navigation information. Hour of most recent nav update. nav interface template token = H. Isis Note: The time of the nav is adjusted by the NavLatency stored in the XTF file header.
    Head.HFixTimeMinute(n)=fread(fId,1,'uint8'); %Sensor Navigation information. Minute of most recent nav update. nav interface template token = I. Isis Note: The time of the nav is adjusted by the NavLatency stored in the XTF file header.
    Head.HFixTimeSecond(n)=fread(fId,1,'uint8'); %Sensor Navigation information. Second of most recent nav update. nav interface template token = S. Isis Note: The time of the nav is adjusted by the NavLatency stored in the XTF file header.
    Head.HFixTimeHsecond(n)=fread(fId,1,'uint8'); %Sensor Navigation information. Hundredth of a Second of most recent nav update. Isis Note: The time of the nav is adjusted by the NavLatency stored in the XTF file header.
    Head.HSensorSpeed(n)=fread(fId,1,'float32'); %Sensor Navigation information. Speed of towfish in knots. Used for speed correction and position calculation; nav interface template token = V.
    Head.HKP(n)=fread(fId,1,'float32'); %Sensor Navigation information. Kilometers Pipe; nav interface template token = {K}.
    Head.HSensorYcoordinate(n)=fread(fId,1,'float64'); %Sensor Navigation information. Sensor latitude or northing; nav interface template token = E. Note: when NavUnits in the file header is 0, values are in meters (northings and eastings).  When NavUnits is 3, values are in Lat/Long.  Also see the Layback value, below.
    Head.HSensorXcoordinate(n)=fread(fId,1,'float64'); %Sensor Navigation information. Sensor longitude or easting; nav interface template token = N. Note: when NavUnits in the file header is 0, values are in meters (northings and eastings).  When NavUnits is 3, values are in Lat/Long.  Also see the Layback value, below.
    Head.HSonarStatus(n)=fread(fId,1,'uint16'); %Tow Cable information. System status value, sonar dependant (displayed in Status window).
    Head.HRangeToFish(n)=fread(fId,1,'uint16'); %Slant range to sensor in decimeters; nav interface template token = ? (question mark).  Stored only – not used in any computation.
    Head.HBearingToFish(n)=fread(fId,1,'uint16'); %Bearing to towfish from ship, stored in degrees multiplied by 100; nav interface template token = > (greater-than sign).  Stored only – not used in any computation in Isis.
    Head.HCableOut(n)=fread(fId,1,'uint16'); %Tow Cable information. Amount of cable payed out in meters; nav interface template token = o.
    Head.HLayback(n)=fread(fId,1,'float32'); %Tow Cable information. Distance over ground from ship to fish.; nav interface template token = l. Isis Note: When this value is non-zero, Isis assumes that SensorYcoordinate and SensorXcoordinate need to be adjusted with the Layback.  The sensor position is then computed using the current sensor heading and this layback value.  The result is displayed when a position is computed in Isis.
    Head.HCableTension(n)=fread(fId,1,'float32'); %Tow Cable information Cable tension from serial port. Stored only; nav interface template token = P
    Head.HSensorDepth(n)=fread(fId,1,'float32'); %Sensor Attitude information. Distance (m) from sea surface to sensor. The deeper the sensor goes, the bigger (positive) this value becomes. nav interface template token = 0 (zero)
    Head.HSensorPrimaryAltitude(n)=fread(fId,1,'float32'); %Sensor Attitude information. Distance from towfish to the sea floor; nav interface template token = 7. Isis Note: This is the primary altitude as tracked by the Isis bottom tracker or entered manually by the user. Although not recommended, the user can override the Isis bottom tracker by sending the primary altitude over the serial port.  The user should turn the Isis bottom tracker Off when this is done.
    Head.HSensorAuxAltitude(n)=fread(fId,1,'float32'); %Sensor Attitude information. Auxiliary altitude; nav interface template token = a. Isis Note: This is an auxiliary altitude as transmitted by an altimeter and received over a serial port. The user can switch between the Primary and  Aux altitudes via the "options" button in the Isis bottom track window.
    Head.HSensorPitch(n)=fread(fId,1,'float32'); %Sensor Attitude information. Pitch in degrees (positive=nose up); nav interface template token = 8.
    Head.HSensorRoll(n)=fread(fId,1,'float32'); %Sensor Attitude information. Roll in degrees (positive=roll to starboard); nav interface template token = 9.
    Head.HSensorHeading(n)=fread(fId,1,'float32'); %Sensor Attitude information. Sensor heading in degrees; nav interface template token = h.
    Head.HHeave(n)=fread(fId,1,'float32'); %Attitude information. Sensors heave at start of ping. Positive value means sensor moved up. Note: These Pitch, Roll, Heading, Heave and Yaw values are those received closest in time to this sonar or bathymetry update.  If a TSS or MRU is being used with a multibeam/bathymetry sensor, the user should  use the higher-resolution attitude data found in the XTFATTITUDEDATA structures.
    Head.HYaw(n)=fread(fId,1,'float32'); %Attitude information. Sensor yaw.  Positive means turn to right. Note: These Pitch, Roll, Heading, Heave and Yaw values are those received closest in time to this sonar or bathymetry update.  If a TSS or MRU is being used with a multibeam/bathymetry sensor, the user should use the higher-resolution attitude data found in the XTFATTITUDEDATA structures.  Since the heading information is updated in high resolution, it is not necessary to log or use Yaw in any processing.  Isis does not use Yaw
    Head.HAttitudeTimeTag(n)=fread(fId,1,'uint32'); %Attitude information. In milliseconds - used to coordinate with millisecond time value in Attitude packets.  (M)andatory when logging XTFATTITUDE packets.
    Head.HDOT(n)=fread(fId,1,'float32'); %Misc. Distance Off Track
    Head.HNavFixMilliseconds(n)=fread(fId,1,'uint32'); %Misc. millisecond clock value when nav received
    Head.HComputerClockHour(n)=fread(fId,1,'uint8'); %Isis Note: The Isis computer clock time when this ping was received. May be different from ping time at start of this record if the sonar time-stamped the data and the two systems aren't synched. This time should be ignored in most cases
    Head.HComputerClockMinute(n)=fread(fId,1,'uint8'); %Isis Note:  see above Isis Note
    Head.HComputerClockSecond(n)=fread(fId,1,'uint8'); %Isis Note:  see above Isis Note
    Head.HComputerClockHsec(n)=fread(fId,1,'uint8'); %Isis Note:  see above Isis Note
    Head.HFishPositionDeltaX(n)=fread(fId,1,'int16'); %Additional Tow Cable and Fish information from Trackpoint. Stored as meters multiplied by 3.0, supporting +/- 10000.0m (usually from trackpoint); nav interface template token = {DX}.
    Head.HFishPositionDeltaY(n)=fread(fId,1,'int16'); %Additional Tow Cable and Fish information from Trackpoint. X, Y offsets can be used instead of logged layback.; nav interface template token = {DY}.
    Head.HFishPositionErrorCode(n)=fread(fId,1,'*char'); %Additional Tow Cable and Fish information from Trackpoint. Error code for FishPosition delta x,y. (typically reported by Trackpoint).
    Head.HOptionalOffsey(n)=fread(fId,1,'uint32'); %OptionalOffsey (Triton 7125 only)
    Head.HCableOutHundredths(n)=fread(fId,1,'uint8'); %Hundredths of a meter of cable out, to be added  to the CableOut field.
    Head.HReservedSpace2(:,n)=fread(fId,6,'uint8'); %Unused. Set to 0.
    %===End Header Read
    for nn=1:XtfHead.RNumChansToFollow(nHead(n)),
        %===Begin ChanInfo Read
        Head.CChannelNumber(nn,n)=fread(fId,1,'uint16'); %Typically 0=port (low frequency) 1=stbd (low frequency) 2=port (high frequency) 3=stbd (high frequency)
        Head.CDownsampleMethod(nn,n)=fread(fId,1,'uint16'); %2 = MAX; 4 = RMS
        Head.CSlantRange(nn,n)=fread(fId,1,'float32'); %Slant range of the data in meters
        Head.CGroundRange(nn,n)=fread(fId,1,'float32'); %Ground range of the data; in meters (SlantRange^2 - Altitude^2)
        Head.CTimeDelay(nn,n)=fread(fId,1,'float32'); %Amount of time, in seconds, to the start of recorded data. (almost always 0.0).
        Head.CTimeDuration(nn,n)=fread(fId,1,'float32'); %Amount of time, in seconds, recorded (typically SlantRange/750)
        Head.CSecondsPerPing(nn,n)=fread(fId,1,'float32'); %Amount of time, in seconds, from ping to ping. (SlantRange/750)
        Head.CProcessingFlags(nn,n)=fread(fId,1,'uint16'); %4 = TVG; 8 = BAC&GAC; 16 = filter, etc. (almost always zero)
        Head.CFrequency(nn,n)=fread(fId,1,'uint16'); %Ccenter transmit frequency for this channel
        Head.CInitialGainCode(nn,n)=fread(fId,1,'uint16'); %Settings as transmitted by sonar
        Head.CGainCode(nn,n)=fread(fId,1,'uint16'); %Settings as transmitted by sonar
        Head.CBandWidth(nn,n)=fread(fId,1,'uint16'); %Settings as transmitted by sonar
        Head.CContactNumber(nn,n)=fread(fId,1,'uint32'); %Contact information . Upated when contacts are saved in Target utility.
        Head.CContactClassification(nn,n)=fread(fId,1,'uint16'); %Contact information . Updated when contacts are saved in Target utility.
        Head.CContactSubNumber(nn,n)=fread(fId,1,'uint8'); %Contact information . Udated when contacts are saved in Target utility
        Head.CContactType(nn,n)=fread(fId,1,'uint8'); %Contact information . Updated when contacts are saved in Target utility
        Head.CNumSamples(nn,n)=fread(fId,1,'uint32'); %Number of samples that will follow this structure. The number of bytes will be this value multiplied by the number of bytes per sample. BytesPerSample found in CHANINFO structure (given in the file header).
        Head.CMillivoltScale(nn,n)=fread(fId,1,'uint16'); %Maximum voltage, in mv, represented by a full-scale value in the data.If zero, then the value stored in the VoltScale should be used instead. VoltScale can be found in the XTF file header, ChanInfo structure. Note that VoltScale is specified in volts, while MillivoltScale is stored in millivolts. This provides for a range of –65,536 volts to 65,535 volts.
        Head.CContactTimeOffTrack(nn,n)=fread(fId,1,'float32'); %Time off track to this contact (stored in milliseconds)
        Head.CContactCloseNumber(nn,n)=fread(fId,1,'uint8'); %
        Head.CReserved2(nn,n)=fread(fId,1,'uint8'); %Unused. Set to 0.
        Head.CFixedVSOP(nn,n)=fread(fId,1,'float32'); %This is the fixed, along-track size of each ping, stored in centimeters. On multibeam systems with zero beam spread, this value needs to be filled in to prevent Isis from calculating along-track ground coverage based on beam spread and speed over ground.
        Head.CWeight(nn,n)=fread(fId,1,'int16'); %Weighting factor passed by some sonars, this value is mandatory for Edgetech digital sonars types 24, 35, 38, 48 and Kongsberg SA type 48
        Head.CReservedSpace(nn,n,:)=fread(fId,4,'uint8'); %Unused. Set to 0.
        %===End ChanInfo Read
        %===Begin Data pass
        CDataSeek(nn,n)=ftell(fId);
        fseek(fId,Head.CNumSamples(nn,n).*XtfHead.CBytesPerSample(nn),'cof');
        %===End Data pass
    end;
    %if ~mod(n,5000), disp(['Trace: ',num2str(n)]);end;
    df=ftell(fId);
end;
%===Begin Data Allocate
Data=nan(max(Head.CNumSamples(:)),LenHead,ChF);
%===End Data Allocate
%===Begin Data Read
df=0;fseek(fId,0,'bof');
for n=1:LenHead,
    for nn=1:XtfHead.RNumChansToFollow(nHead(n)),
        fseek(fId,CDataSeek(nn,n)-df,'cof');
        L=find(XtfHead.RSubChannelNumber(n)==XtfHead.CSubChannelNumber); %!!!
        DBit=XtfHead.Descript.BytesPerSample.C{XtfHead.Descript.UniPolar.Code==XtfHead.CUniPolar(L(1)),XtfHead.Descript.BytesPerSample.Code==XtfHead.CBytesPerSample(L(1))};
        Data(1:Head.CNumSamples(nn,n),n,nn)=fread(fId,Head.CNumSamples(nn,n),DBit);
        df=ftell(fId);
    end;
end;
%===End Data Read
fclose(fId);

%mail@ge0mlib.com 01/08/2016