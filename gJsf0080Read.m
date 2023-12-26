function [Head,Data]=gJsf0080Read(JsfHead,ChN,SubSys)
%Read [Head,Data] from JsfHead.fName (*.jsf) file for Message Type 0080 (SBP or SSS Data Message; 0004824_REV_1.20 used). Warning: One sample in packet.
%function [Head,Data]=gJsf0080Read(JsfHead,ChN,SubSys), where
%JsfHead - Xsf Header structure;
%Head - Header structure;
%ChN - channel number;
%SubSys - subsystem number;
%Data - Data Body for sonar channel number ChN, subsystem number SubSys.
%Head include the addition fields: HMessageType, HChannelMulti, HSubsystem, HMessageNum.
%Calculate Nav's fields: GpsDay,GpsTime; use gSgyDTEN_on to calculate: GpsE,GpsN,GpsH.
%The Sonar Data Message consists of a single ping (receiver sounding period) of data for a single channel (such as Port Side Low Frequency Side-Scan).
%Standard sidescan sub-systems have two channels of data, port and starboard.  Standard sub-bottom sub-systems have a single channel of data.
%Data files with higher channel counts exist.  Which fields have data present depends on the system used and data acquisition procedures.
%Example: [Head,Data]=gJsf0080Read(JsfHead,1,21);

[fId, mes]=fopen(JsfHead.fName,'r');if ~isempty(mes), error(['gJsfRead0080: ' mes]);end;
LHead=(JsfHead.HMessageType==0080)&(JsfHead.HChannelMulti==ChN)&(JsfHead.HSubsystem==SubSys);LenHead=sum(LHead);nHead=find(LHead);
%===Begin Head Allocate for Message Type 0080
Head=struct('HMessageType',0080,'HChannelMulti',ChN,'HSubsystem',SubSys,'HMessageNum',zeros(1,LenHead),...
    'PingTime',zeros(1,LenHead),'StartingDepth',zeros(1,LenHead),'PingNumber',zeros(1,LenHead),'Reserved1',zeros(2,LenHead),'MSB',zeros(1,LenHead),'LSB',zeros(1,LenHead),'LSB2',zeros(1,LenHead),'Reserved2',zeros(3,LenHead),...
    'IdCode',zeros(1,LenHead),'ValidityFlag',zeros(1,LenHead),'Reserved3',zeros(1,LenHead),'DataFormat',zeros(1,LenHead),'FishAft',zeros(1,LenHead),'FishStb',zeros(1,LenHead),...
    'Reserved4',zeros(2,LenHead),'KilometerPipe',zeros(1,LenHead),'Reserved5',zeros(16,LenHead),'X',zeros(1,LenHead),'Y',zeros(1,LenHead),...
    'CoordinateUnits',zeros(1,LenHead),'AnnotationString',char(zeros(24,LenHead)),'NumberDataSamples',zeros(1,LenHead),'SamplingInterval',zeros(1,LenHead),'GainFactorAdc',zeros(1,LenHead),...
    'PulsePower',zeros(1,LenHead),'Reserved6',zeros(1,LenHead),'ChirpStartingFrequency',zeros(1,LenHead),'ChirpEndingFrequency',zeros(1,LenHead),'SweepLength',zeros(1,LenHead),...
    'Pressure',zeros(1,LenHead),'Depth',zeros(1,LenHead),'SampleFreq',zeros(1,LenHead),'OutgoingPulseId',zeros(1,LenHead),'Altitude',zeros(1,LenHead),'SoundSpeed',zeros(1,LenHead),'MixerFreq',zeros(1,LenHead),...
    'Year',zeros(1,LenHead),'Day',zeros(1,LenHead),'Hour',zeros(1,LenHead),'Minute',zeros(1,LenHead),'Second',zeros(1,LenHead),'TimeBasis',zeros(1,LenHead),...
    'WeightingFactor',zeros(1,LenHead),'NumberOfPulses',zeros(1,LenHead),'CompassHeading',zeros(1,LenHead),'Pitch',zeros(1,LenHead),'Roll',zeros(1,LenHead),'TowElectronicsTemperature',zeros(1,LenHead),...
    'Reserved8',zeros(1,LenHead),'TriggerSource',zeros(1,LenHead),'MarkNumber',zeros(1,LenHead),...
    'NmeaHour',zeros(1,LenHead),'NmeaMinutes',zeros(1,LenHead),'NmeaSeconds',zeros(1,LenHead),'NmeaCourse',zeros(1,LenHead),'NmeaSpeed',zeros(1,LenHead),'NmeaDay',zeros(1,LenHead),'NmeaYear',zeros(1,LenHead),...
    'MillisecondsToday',zeros(1,LenHead),'MaximumAbsoluteValueADC',zeros(1,LenHead),'Reserved9',zeros(1,LenHead),'Reserved10',zeros(1,LenHead),'SoftwareVersionNumber',char(zeros(6,LenHead)),...
    'InitialSphericalCorrectionFactor',zeros(1,LenHead),'PacketNumber',zeros(1,LenHead),'DecimationFactor',zeros(1,LenHead),'DecimationFactorAfterFFT',zeros(1,LenHead),...
    'WaterTemperature',zeros(1,LenHead),'Layback',zeros(1,LenHead),'Reserved11',zeros(1,LenHead),'CableOut',zeros(1,LenHead),'Reserved12',zeros(1,LenHead));
%===End Head Allocate for Message Type 0080
df=0;
for m=1:LenHead,
    %===Begin Head Read for Message Type 0080
    fseek(fId,JsfHead.RSeek(nHead(m))-df,'cof');
    Head.HMessageNum(m)=nHead(m);
    Head.PingTime(m)=fread(fId,1,'int32'); %0-3// Ping Time in seconds [since the start of time based on time() function] (1/1/1970) (added in protocol version 8,  this  field  is  zero  in  prior  protocol versions)
    Head.StartingDepth(m)=fread(fId,1,'uint32'); %4-7// Starting Depth (window offset) in samples  - usually zero
    Head.PingNumber(m)=fread(fId,1,'uint32'); %8-11// Ping Number (increments with each ping)
    Head.Reserved1(:,m)=fread(fId,2,'int16'); %12-15// Reserved – Do not use
    Head.MSB(m)=fread(fId,1,'uint16'); %16-17// MSBs – Most Significant Bits – High order bits to extend 16 bit unsigned short values to 20 bits.  The 4 MSB bits become the most significant portion of the new 20 bit value. Bits 0-3 – start frequency Bits. 4-7 – end frequency Bits. 8–11 – samples in this packet. Bits 12–15 – mark number (added in protocol version 10)(see description below)
    Head.LSB(m)=fread(fId,1,'uint16'); %18-19// LSB – low order bits for fields requiring greater precision. Bits 0-7 – Sample Interval fractional component. Bits 8-15 – fractional portion of course (added in protocol version 11 and was previously 0)
    Head.LSB2(m)=fread(fId,1,'uint16'); %20-21// LSB2 – low order bits for fields requiring greater precision. Bits 0–3 – Speed. Bits 4–13 – sweep Length in Microsecond, from 0-999 (added in protocol version 13). Bits 14–15: Reserved.
    Head.Reserved2(:,m)=fread(fId,3,'int16'); %22-27// Reserved – Do not use
    Head.IdCode(m)=fread(fId,1,'int16'); %28-29// ID Code (always 1) 1 = Seismic Data
    Head.ValidityFlag(m)=fread(fId,1,'uint16'); %30-31// Validity Flag; Validity flags bitmap. Bit0: Lat Lon or XY valid; Bit1: Course valid; Bit2: Speed valid; Bit3: Heading valid; Bit4: Pressure valid; Bit5: Pitch roll valid; Bit6: Altitude valid; Bit7: Reserved; Bit8: Water temperature valid; Bit9: Depth valid; Bit10: Annotation valid; Bit11: Cable counter valid; Bit12: KP valid; Bit13: Position interpolated; Bit 14: Water sound speed valid.
    Head.Reserved3(m)=fread(fId,1,'uint16'); %32-33// Reserved – Do not use
    Head.DataFormat(m)=fread(fId,1,'int16'); %34-35// Data Format; 0 =1 short per sample - Envelope Data; 1 =2 shorts per sample - Analytic Signal Data, (Real, Imaginary); 2 =1 short per sample - Raw Data, Prior to Matched Filter; 3 =1 short per sample - Real portion of Analytic Signal Data; 4 =1 short per sample - Pixel Data/CEROS Data; 9 =2 shorts per sample – Analytic Signal Data from before the Match Filter, (Real, Imaginary) Normally only used for diagnostic purposes.
    %34-35// NOTE: Values greater than 255 indicate that the data to follow is compressed and must be decompressed prior to use. For more  detail  refer  to  the  JSF  Data  File  Decompression Application Note for more information.
    Head.FishAft(m)=fread(fId,1,'int16'); %36-37// Distance from Antenna to Tow point in Centimeters, Aft + (Fish Aft = +)
    Head.FishStb(m)=fread(fId,1,'int16'); %38-39// Distance from Antenna to Tow Point in Centimeters, Starboard + (Fish to Starboard = +)
    Head.Reserved4(:,m)=fread(fId,2,'int16'); %40-43// Reserved – Do not use
    %Navigation data
    Head.KilometerPipe(m)=fread(fId,1,'float32'); %44-47// Kilometer of pipe (see validity flags bytes 30–31 and coordinate units bytes 88–89)
    Head.Reserved5(:,m)=fread(fId,16,'int16'); %48-79// Reserved – Do not use
    Head.X(m)=fread(fId,1,'int32'); %80-83// X in millimeters or decimeters or Longitude in Minutes of Arc / 10000 (see bytes 30-31 and 88-89)
    Head.Y(m)=fread(fId,1,'int32'); %84-87// Y in millimeters or decimeters or Latitude in 0.0001 Minutes of Arc (see bytes 30-31 and 88-89)
    Head.CoordinateUnits(m)=fread(fId,1,'int16'); %88-89// Coordinate Units: 1 = X,Y in millimeters; 2 = Longitude, Latitude in minutes of arc times 10000; 3 = X,Y in decimeters
    %Pulse Information
    Head.AnnotationString(:,m)=char(fread(fId,24,'uint8')); %90-113// Annotation String (ASCII Data)
    Head.NumberDataSamples(m)=fread(fId,1,'uint16'); %114-115// Number of data samples in this packet. See bytes 16–17 for MSB information Note: Very large sample sizes require multiple packets
    MSB=uint32(Head.MSB(m));MSB=bitand(MSB,3840);MSB=bitshift(MSB,8);Head.NumberDataSamples(m)=Head.NumberDataSamples(m)+MSB;
    Head.SamplingInterval(m)=fread(fId,1,'uint32'); %116-119// Sampling Interval in Nanoseconds See bytes 18-19 for LSB information.
    LSB=uint32(Head.LSB(m));LSB=bitand(LSB,255);Head.SamplingInterval(m)=Head.SamplingInterval(m)+LSB./100;
    Head.GainFactorAdc(m)=fread(fId,1,'uint16'); %120-121// Gain Factor of ADC
    Head.PulsePower(m)=fread(fId,1,'int16'); %122-123// User Transmit Level Setting (0–100) percent
    Head.Reserved6(m)=fread(fId,1,'int16'); %124-125// Reserved – Do not use
    Head.ChirpStartingFrequency(m)=fread(fId,1,'uint16'); %126-127// Transmit pulse starting frequency in decahertz (daHz) (units of 10Hz) See bytes 17–18 for MSB information
    MSB=uint32(Head.MSB(m));MSB=bitand(MSB,15);MSB=bitshift(MSB,16);Head.ChirpStartingFrequency(m)=Head.ChirpStartingFrequency(m)+MSB;
    Head.ChirpEndingFrequency(m)=fread(fId,1,'uint16'); %128-129// Transmit pulse ending frequency in decahertz (daHz)(units of 10Hz) See bytes 16–17 for MSB information
    MSB=uint32(Head.MSB(m));MSB=bitand(MSB,240);MSB=bitshift(MSB,12);Head.ChirpEndingFrequency(m)=Head.ChirpEndingFrequency(m)+MSB;
    Head.SweepLength(m)=fread(fId,1,'uint16'); %130-131// Sweep Length in milliseconds. See bytes 18-19 for LSBs (Least Significant Bits), LSB2 bits 4-13 contain the microsecond portion (0 - 999). LSB2 part was added in protocol version 14, and was previously 0.
    LSB=uint32(Head.LSB2(m));LSB=bitand(LSB,16368);LSB=bitshift(LSB,-4);Head.SweepLength(m)=Head.SweepLength(m)+LSB./1000;
    Head.Pressure(m)=fread(fId,1,'int32'); %132-135// Pressure in milliPSI (1 unit=1/1000 PSI) (see bytes 30-31)
    Head.Depth(m)=fread(fId,1,'int32'); %136-139// Depth in millimeters (if not = 0) (see bytes 30-31)
    Head.SampleFreq(m)=fread(fId,1,'uint16'); %140-141// For all data types EXCEPT RAW (Data Format=2) this is the Sampling  Frequency of the data. For RAW data, this is one-half the Sample Frequency of the data (Fs/2).  All values are modulo 65536. Use this in conjunction with the Sample interval (Bytes 114-115) to calculate correct sample rate.
    Head.OutgoingPulseId(m)=fread(fId,1,'uint16'); %142-143// Outgoing pulse identifier
    Head.Altitude(m)=fread(fId,1,'int32'); %144-147// Altitude in millimeters (If bottom tracking valid) 0 implies not filled (see bytes 30-31)
    Head.SoundSpeed(m)=fread(fId,1,'float32'); %148-151// Sound Speed in meters per second
    Head.MixerFreq(m)=fread(fId,1,'float32'); %152-155// Mixer Frequency in Hertz. Note: for single pulses this should be close to the center frequency. However, for multi-pulses this is should be approximately the center frequency.
    %CPU Time
    Head.Year(m)=fread(fId,1,'int16'); %156-157// Year Data Recorded (e.g. 2009) (See Bytes 0-3 these 2 time stamps are equivalent and identical). For higher resolution (milliseconds) use the Year, and Day values of bytes 156 to 159, and then use the milliSecondsToday value of bytes 200-203 to complete the timestamp.
    Head.Day(m)=fread(fId,1,'int16'); %158-159// Day Data Recorded (1–366) (Should not be used)
    Head.Hour(m)=fread(fId,1,'int16'); %160-161// Hour Data Recorded (see Bytes 200-203) (Should not be used)
    Head.Minute(m)=fread(fId,1,'int16'); %162-163// Minute Data Recorded (Should not be used)
    Head.Second(m)=fread(fId,1,'int16'); %164-165// Second Data Recorded (should not be used)
    Head.TimeBasis(m)=fread(fId,1,'int16'); %166-167// Time Basis Data Recorded (always 3)
    %Weighting Factor
    Head.WeightingFactor(m)=fread(fId,1,'int16'); %168-169// Weighting Factor N (Signed Value!) Defined as 2^-N
    Head.NumberOfPulses(m)=fread(fId,1,'int16'); %170-171// Number of pulses in the water 
    %Orientation Sensor Data
    Head.CompassHeading(m)=fread(fId,1,'uint16'); %172-173// Compass Heading (0 to 359.9) in units of 1/100 degree (see bytes 30-31). Can be Gyro heading.
    Head.Pitch(m)=fread(fId,1,'int16'); %174-175// Pitch:  Scale by 180/32768 to get degrees, + = bow up (see bytes 30-31)
    Head.Roll(m)=fread(fId,1,'int16'); %176-177// Roll:  Scale by 180/32768 to get degrees, + = port up (see bytes 30-31)
    Head.TowElectronicsTemperature(m)=fread(fId,1,'int16'); %178-179// Tow fish electronics Temperature, in unit of 1/10th degree C (for v1.20 is Reserved).
    %Miscellaneous Data
    Head.Reserved8(m)=fread(fId,1,'int16'); %180-181// Reserved – Do not use
    Head.TriggerSource(m)=fread(fId,1,'int16'); %182-183// Trigger Source: 0 = Internal; 1 = External; 2 = Coupled
    Head.MarkNumber(m)=fread(fId,1,'uint16'); %184-185// Mark Number 0=No Mark. See bytes 16–17 for MSB information for large values (>655350).
    MSB=uint32(Head.MSB(m));MSB=bitand(MSB,61440);MSB=bitshift(MSB,4);Head.MarkNumber(m)=Head.MarkNumber(m)+MSB;
    %NMEA Navigation Data
    Head.NmeaHour(m)=fread(fId,1,'int16'); %186-187// Position Fix Hour (0–23). NOTE:  the NAV time is the time of the latitude and longitude fix
    Head.NmeaMinutes(m)=fread(fId,1,'int16'); %188-189// Position Fix Minutes (0–59). NOTE:  the NAV time is the time of the latitude and longitude fix
    Head.NmeaSeconds(m)=fread(fId,1,'int16'); %190-191// Position Fix Seconds (0–59). NOTE:  the NAV time is the time of the latitude and longitude fix.
    Head.NmeaCourse(m)=fread(fId,1,'int16'); %192-193// Course in Degrees (0 to 359.9) Fractional portion in LSB See bytes 18-19 for LSB information.
    LSB=uint32(Head.LSB(m));LSB=bitand(LSB,65280);LSB=bitshift(LSB,-8);Head.NmeaCourse(m)=Head.NmeaCourse(m)+LSB./1000;
    Head.NmeaSpeed(m)=fread(fId,1,'int16'); %194-195// Starting with protocol version 12 one additional digit of fractional knot (1/100) is stored in LSB2. For an additional fractional digit, see LSB2 (bytes 20-21).
    LSB=uint32(Head.LSB2(m));LSB=bitand(LSB,15);Head.NmeaSpeed(m)=Head.NmeaSpeed(m)+LSB./10;
    Head.NmeaDay(m)=fread(fId,1,'int16'); %196-197// Position Fix Day (1–366).
    Head.NmeaYear(m)=fread(fId,1,'int16'); %198-199// Position Fix Year
    %Other Miscellaneous Data
    Head.MillisecondsToday(m)=fread(fId,1,'uint32'); %200-203// Milliseconds today (since midnight) (use in conjunction with Year/Day to get time of Ping)
    Head.MaximumAbsoluteValueADC(m)=fread(fId,1,'uint16'); %204-205// Maximum Absolute Value of ADC samples in this packet
    Head.Reserved9(m)=fread(fId,1,'int16'); %206-207// Reserved – Do not use
    Head.Reserved10(m)=fread(fId,1,'int16'); %208-209// Reserved – Do not use
    Head.SoftwareVersionNumber(:,m)=char(fread(fId,6,'uint8')); %210-215// Sonar Software Version Number - ASCII
    Head.InitialSphericalCorrectionFactor(m)=fread(fId,1,'int32'); %216-219// Initial Spherical Correction Factor (Useful for multi-ping/deep application)*100 
    Head.PacketNumber(m)=fread(fId,1,'uint16'); %220-221// Packet Number Each ping starts with packet 1
    Head.DecimationFactor(m)=fread(fId,1,'int16'); %222-223// 100 times the A/D Decimation Factor. Data is normally sampled at a high Rate. Digital filters are applied to precisely limit the signal bandwidth.
    Head.DecimationFactorAfterFFT(m)=fread(fId,1,'int16'); %224-225// Decimation Factor after the FFT (Reserved for v.1.20)
    Head.WaterTemperature(m)=fread(fId,1,'int16'); %226-227// Water Temperature in units of 1/10 degree C (see bytes 30-31)
    Head.Layback(m)=fread(fId,1,'float32'); %228-231// Layback. Distance to the sonar in meters
    Head.Reserved11(m)=fread(fId,1,'int32'); %232-235// Reserved – Do not use
    Head.CableOut(m)=fread(fId,1,'uint16'); %236-237// Cable Out in decimeters (see bytes 30-31) 
    Head.Reserved12(m)=fread(fId,1,'uint16'); %238-239// Reserved – Do not use
    %===End Head Read for Message Type 0080
    df=ftell(fId);
end;
%===Begin Data Allocate for Message Type 0080
if all(Head.DataFormat==0)||all(Head.DataFormat==2)||all(Head.DataFormat==3)||all(Head.DataFormat==4), Data=zeros(max(Head.NumberDataSamples),LenHead);
elseif all(Head.DataFormat==1)||all(Head.DataFormat==9), Data=complex(zeros(max(Head.NumberDataSamples),LenHead));
else error('Error gJsf0080Read: unknown/bad Head.DataFormat');
end;
%===End Data Allocate for Message Type 0080
fseek(fId,0,'bof');df=0;
for m=1:LenHead,
    if ~mod(m,5000), disp(['Trace: ',num2str(m)]);end;
    %===Begin Data Read for Message Type 0080
    fseek(fId,JsfHead.RSeek(nHead(m))+240-df,'cof');
    switch Head.DataFormat(m),
        case {0,2,3,4}
            tmp=fread(fId,Head.NumberDataSamples(m),'int16');
            Data(1:Head.NumberDataSamples(m),m)=tmp.*2.^(-Head.WeightingFactor(m));
        case {1,9}
            tmp=fread(fId,Head.NumberDataSamples(m).*2,'int16');tmp=reshape(tmp,2,length(tmp)./2);
            Data(1:Head.NumberDataSamples(m),m)=complex(tmp(1,:),tmp(2,:)).*2.^(-Head.WeightingFactor(m));
    end;
    %===End Data Read for Message Type 0080
    df=ftell(fId);
end;
fclose(fId);

%mail@ge0mlib.com 20/11/2019