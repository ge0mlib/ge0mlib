function gJsf0080Write(JsfHead,Head,Data,fNameNew,flTraceLenChanged)
%Write [JsfHead,Head,Data] to *.jsf file for Message Type 0080 (SBP or SSS Data Message; 0004824_REV_1.20 used). Warning: One sample in packet.
%All another messages (not 0080) are copied to new file from “parent’s” file without any changes, in accordance with JsfHead.ROnFlag’s value.
%function gJsf0080Write(JsfHead,Head,Data,fNameNew,flTraceLenChanged), where
%JsfHead - Jsf Header structure;
%Head - Header structure;
%Data - Data Body for sonar channels;
%fNameNew - string, the target file for writing;
%flTraceLenChanged - set to one, if Data-Trace Length (Head.NumberDataSamples) was changed and JsfHead.HSizeFollowingMessage field need to correct.
%gJsf0080Write used file JsfHead.fName as data source for JsfHead.RHeaderType~=0. The file XtfHead.fName must be presented; names XtfHead.fName and fNameNew must be different.
%If you change Data-Trace Length (Head.NumberDataSamples), the JsfHead.HSizeFollowingMessage field must be correct. Use flTraceLenChanged==1 for auto-correction.
%Example: gJsf0080Write(JsfHead,Head,Data,'c:\temp\1new.jsf',0);

[fId, mes]=fopen(JsfHead.fName,'r+');if ~isempty(mes), error(['gJsfWrite0080: ' mes]);end;
if strcmp(fNameNew,JsfHead.fName), error('gJsfWrite0080: XtfHead.fName and fNameNew must be different.');end;
[fId2, mes]=fopen(fNameNew,'w');if ~isempty(mes), error(['gJsfWrite0080: ' mes]);end;
df=0;mm=0;nHead=find((JsfHead.HMessageType==0080)&(JsfHead.HChannelMulti==Head.HChannelMulti)&(JsfHead.HSubsystem==Head.HSubsystem));
for m=1:size(JsfHead.HMessageType,2),
    if ~((JsfHead.HMessageType(m)==0080)&&(JsfHead.HChannelMulti(m)==Head.HChannelMulti)&&(JsfHead.HSubsystem(m)==Head.HSubsystem)),
        %===Begin JsfHeader Record  Write;
        fwrite(fId2,JsfHead.HMarkerForStart(m),'uint16'); %0-1// Marker for the Start of Header = 0x1601
        fwrite(fId2,JsfHead.HVersionOfProtocol(m),'uint8'); %2// Version of Protocol used
        fwrite(fId2,JsfHead.HSessionIdentifier(m),'uint8'); %3// Session Identifier
        fwrite(fId2,JsfHead.HMessageType(m),'uint16'); %4-5// Message Type
        fwrite(fId2,JsfHead.HCommandType(m),'uint8'); %6// Command Type
        fwrite(fId2,JsfHead.HSubsystem(m),'uint8'); %7// Subsystem for a Multi-System Device. Common  subsystem assignments are as follows: Sub-bottom data - 0; Single frequency side scan data - 20; Lower frequency data of a dual frequency side scan - 20; Higher frequency data of a dual frequency side scan - 21; Higher frequency data of a tri-frequency side scan - 22; Raw serial/UDP/TCP data - 100 (v.1.20); Parsed serial/UDP/TCP data - 101 (v1.20); Raw UDP data - 103 (v.1.18);Parsed UPD data  - 104 (v1.18).
        fwrite(fId2,JsfHead.HChannelMulti(m),'uint8'); %8// Channel for a Multi-Channel Subsystem For Side Scan Subsystems; 0 = Port; 1 = Starboard; For Serial Ports: Port #
        fwrite(fId2,JsfHead.HSequenceNumber(m),'uint8'); %9// Sequence Number
        fwrite(fId2,JsfHead.HReserved(m),'uint16'); %10-11// Reserved
        fwrite(fId2,JsfHead.HSizeFollowingMessage(m),'uint32'); %12-15// Size of following Message in Bytes
        %===End JsfHeader Record Write
        %===Begin DataBlock Write (DataBlock length from JsfHead.HSizeFollowingMessage, DataBlock begin from JsfHead.RSeek)
        fseek(fId,JsfHead.RSeek(m)-df,'cof');
        zz=fread(fId,JsfHead.HSizeFollowingMessage(m),'uint8')';
        df=ftell(fId);fwrite(fId2,zz,'uint8'); %Byte field
        %===End DataBlock Write
    elseif (JsfHead.HMessageType(m)==0080)&&(JsfHead.HChannelMulti(m)==Head.HChannelMulti)&&(JsfHead.HSubsystem(m)==Head.HSubsystem),
        %===Begin JsfHeader Record Write
        fwrite(fId2,JsfHead.HMarkerForStart(m),'uint16'); %0-1// Marker for the Start of Header = 0x1601
        fwrite(fId2,JsfHead.HVersionOfProtocol(m),'uint8'); %2// Version of Protocol used
        fwrite(fId2,JsfHead.HSessionIdentifier(m),'uint8'); %3// Session Identifier
        fwrite(fId2,JsfHead.HMessageType(m),'uint16'); %4-5// Message Type (e.g. 80 = Sonar Trace Data)
        fwrite(fId2,JsfHead.HCommandType(m),'uint8'); %6// Command Type (2=Normal data source)
        fwrite(fId2,JsfHead.HSubsystem(m),'uint8'); %7// Subsystem for a Multi-System Device 0=Sub-bottom; 20=Lower or Single Frequency Side Scan; 21=High Frequency Side Scan; 22=Higher Frequency Side Scan. Note: that standard side scan systems are often single or dual frequency. When more than two side-scan frequencies are present, the subsystem number for side scan frequencies begin at 20 and increase with increasing acoustic center frequencies.
        fwrite(fId2,JsfHead.HChannelMulti(m),'uint8'); %8// Channel for a Multi-Channel Subsystem For Side Scan Subsystems; 0=Port; 1=Starboard.
        fwrite(fId2,JsfHead.HSequenceNumber(m),'uint8'); %9// Sequence Number
        fwrite(fId2,JsfHead.HReserved(m),'uint16'); %10-11// Reserved
        fwrite(fId2,JsfHead.HSizeFollowingMessage(m),'uint32'); %12-15// Size of following Message in Bytes
        %===End JsfHeader Record Write
        mm=mm+1;
        if nHead(mm)~=Head.HMessageNum(mm), error(['Error: gJsfWrite0080, not correct Messages order for message num=' num2str(mm)]);end;        
        %===Begin Head Write for Message Type 0080 (Head length from JsfHead.HSizeFollowingMessage; Header data from Head; Data Body from Data)
        fwrite(fId2,Head.PingTime(mm),'int32'); %0-3// Ping Time in seconds [since the start of time based on time() function] (1/1/1970) (added in protocol version 8)
        fwrite(fId2,Head.StartingDepth(mm),'uint32'); %4-7// Starting Depth (window offset) in samples  - usually zero
        fwrite(fId2,Head.PingNumber(mm),'uint32'); %8-11/ Ping Number (increments with each ping)
        fwrite(fId2,Head.Reserved1(:,mm),'int16'); %12-15// Reserved – Do not use
        fwrite(fId2,Head.MSB(mm),'uint16'); %16-17// MSBs – Most Significant Bits – High order bits to extend 16 bit unsigned short values to 20 bits.  The 4 MSB bits become the most significant portion of the new 20 bit value. Bits   0 -   3   – start frequency Bits   4 -   7   – end frequency Bits   8 – 11  – samples in this packet Bits 12 – 15  – reserved (added in protocol version 10)(see description below)
        fwrite(fId2,Head.LSB(mm),'uint16'); %18-19// LSB – low order bits for fields requiring greater precision. Bits 0-7 – Sample Interval. Bits 8- 15 – Course (added in protocol version 11 and was previously 0)
        fwrite(fId2,Head.LSB2(mm),'uint16'); %20-21// LSB2 – low order bits for fields requiring greater precision. Bits 0–3 – Speed. Bits 4 – 15 – Reserved (added in protocol version 12 and was previously 0)
        fwrite(fId2,Head.Reserved2(:,mm),'int16'); %22-27// Reserved – Do not use
        fwrite(fId2,Head.IdCode(mm),'int16'); %28-29// ID Code (always 1) 1 = Seismic Data
        fwrite(fId2,Head.ValidityFlag(mm),'uint16'); %30-31// Validity Flag; Validity flags bitmap. Bit0: Lat Lon or XY valid; Bit1: Course valid; Bit2: Speed valid; Bit3: Heading valid; Bit4: Pressure valid; Bit5: Pitch roll valid; Bit6: Altitude valid; Bit7: Reserved; Bit8: Water temperature valid; Bit9: Depth valid; Bit10: Annotation valid; Bit11: Cable counter valid; Bit12: KP valid; Bit13: Position interpolated; Bit 14: Water sound speed valid.
        fwrite(fId2,Head.Reserved3(mm),'uint16'); %32-33// Reserved – Do not use
        fwrite(fId2,Head.DataFormat(mm),'int16'); %34-35// Data Format; 0 = 1 short per sample  - Envelope Data; 1 = 2 shorts per sample - Analytic Signal Data, (Real, Imaginary); 2 = 1 short per sample - Raw Data, Prior to Matched Filter; 3 = 1 short per sample - Real portion of Analytic Signal Data; 4 = 1 short per sample - Pixel Data / CEROS Data; 9 = 2 shorts per sample – Analytic Signal Data from before the Match Filter, (Real, Imaginary) Normally only used for diagnostic purposes.
        fwrite(fId2,Head.FishAft(mm),'int16'); %36-37// Distance from Antenna to Tow point in Centimeters, Aft + (Fish Aft = +)
        fwrite(fId2,Head.FishStb(mm),'int16'); %38-39// Distance from Antenna to Tow Point in Centimeters, Starboard + (Fish to Starboard = +)
        fwrite(fId2,Head.Reserved4(:,mm),'int16'); %40-43// Reserved – Do not use
        %Navigation data
        fwrite(fId2,Head.KilometerPipe(mm),'float32'); %44-47// Kilometer of pipe (see bytes 30-31)
        fwrite(fId2,Head.Reserved5(:,mm),'int16'); %48-79// Reserved – Do not use
        fwrite(fId2,Head.X(mm),'int32'); %80-83// X in millimeters or decimeters or Longitude in Minutes of Arc / 10000 (see bytes 30-31 and 88-89)
        fwrite(fId2,Head.Y(mm),'int32'); %84-87// Y in millimeters or decimeters or Latitude in 0.0001 Minutes of Arc (see bytes 30-31 and 88-89)
        fwrite(fId2,Head.CoordinateUnits(mm),'int16'); %88-89// Coordinate Units: 1 = X, Y in millimeters; 2 = Longitude, Latitude in minutes of arc times 10-4; 3 = X, Y in decimeters
        %Pulse Information
        fwrite(fId2,Head.AnnotationString(:,mm),'uint8'); %90-113// Annotation String (ASCII Data)
        MSB=uint32(Head.MSB(mm));MSB=bitand(MSB,3840);MSB=bitshift(MSB,8);NumberDataSamples=Head.NumberDataSamples(mm)-MSB;
        fwrite(fId2,NumberDataSamples,'uint16'); %114-115// Number of data samples in this packet. See bytes 16–17 for MSB information Note: Very large sample sizes require multiple packets
        fwrite(fId2,fix(Head.SamplingInterval(mm)),'uint32'); %116-119// Sampling Interval in Nanoseconds (bytes 18-19 for LSB information)
        fwrite(fId2,Head.GainFactorAdc(mm),'uint16'); %120-121// Gain Factor of ADC
        fwrite(fId2,Head.PulsePower(mm),'int16'); %122-123// User Transmit Level Setting (0 – 100) percent
        fwrite(fId2,Head.Reserved6(mm),'int16'); %124-125// Reserved – Do not use
        MSB=uint32(Head.MSB(mm));MSB=bitand(MSB,15);MSB=bitshift(MSB,16);ChirpStartingFrequency=Head.ChirpStartingFrequency(mm)-MSB;
        fwrite(fId2,ChirpStartingFrequency,'uint16'); %126-127// Transmit pulse starting frequency in decahertz (daHz) (units of 10Hz) See bytes 17–18 for MSB information
        MSB=uint32(Head.MSB(mm));MSB=bitand(MSB,240);MSB=bitshift(MSB,12);ChirpEndingFrequency=Head.ChirpEndingFrequency(mm)-MSB;
        fwrite(fId2,ChirpEndingFrequency,'uint16'); %128-129// Transmit pulse ending frequency in decahertz (daHz)(units of 10Hz) See bytes 16–17 for MSB information
        fwrite(fId2,fix(Head.SweepLength(mm)),'uint16'); %130-131// Sweep Length in milliseconds
        fwrite(fId2,Head.Pressure(mm),'int32'); %132-135// Pressure in milliPSI  (1 unit = 1/1000 PSI) (see bytes 30-31)
        fwrite(fId2,Head.Depth(mm),'int32'); %136-139// Depth in millimeters (if not = 0)  (see bytes 30-31)
        fwrite(fId2,Head.SampleFreq(mm),'uint16'); %140-141// For all data types EXCEPT RAW (Data Format=2) this is the Sampling  Frequency of the data. For RAW data, this is one-half the Sample Frequency of the data (Fs/2).  All values are modulo 65536. Use this in conjunction with the Sample interval (Bytes 114-115) to calculate correct sample rate
        fwrite(fId2,Head.OutgoingPulseId(mm),'uint16'); %142-143// Outgoing pulse identifier
        fwrite(fId2,Head.Altitude(mm),'int32'); %144-147// Altitude in millimeters (If bottom tracking valid) 0 implies not filled (see bytes 30-31)
        fwrite(fId2,Head.SoundSpeed(mm),'float32'); %148-151// Sound Speed in meters per second
        fwrite(fId2,Head.MixerFreq(mm),'float32'); %152-155// Mixer Frequency in Hertz. Note: for single pulses this should be close to the center frequency. However, for multi-pulses this is should be approximately the center frequency.
        %CPU Time
        fwrite(fId2,Head.Year(mm),'int16'); %156-157// Year (e.g. 2009) (see Bytes 0-3) (Should not be used)
        fwrite(fId2,Head.Day(mm),'int16'); %158-159// Day (1–366) (Should not be used)
        fwrite(fId2,Head.Hour(mm),'int16'); %160-161// Hour (see Bytes 200-203) (Should not be used)
        fwrite(fId2,Head.Minute(mm),'int16'); %162-163// Minute (Should not be used)
        fwrite(fId2,Head.Second(mm),'int16'); %164-165// Second (should not be used)
        fwrite(fId2,Head.TimeBasis(mm),'int16'); %166-167// Time Basis (always 3)
        %Weighting Factor
        fwrite(fId2,Head.WeightingFactor(mm),'int16'); %168-169// Weighting Factor N (Signed Value!) Defined as 2^-N
        fwrite(fId2,Head.NumberOfPulses(mm),'int16'); %170-171// Number of pulses in the water 
        %Orientation Sensor Data
        fwrite(fId2,Head.CompassHeading(mm),'uint16'); %172-173// Compass Heading (0 to 360) in units of 1/100 degree (see bytes 30-31)
        fwrite(fId2,Head.Pitch(mm),'int16'); %174/175// Pitch:  Scale by 180/32768 to get degrees, + = bow up (see bytes 30-31)
        fwrite(fId2,Head.Roll(mm),'int16'); %176-177// Roll:  Scale by 180 / 32768 to get degrees, + = port up (see bytes 30-31)
        fwrite(fId2,Head.TowElectronicsTemperature(mm),'int16'); %178-179// Tow fish electronics Temperature, in unit of 1/10th degree C
        %Miscellaneous Data
        fwrite(fId2,Head.Reserved8(mm),'int16'); %180-181// Reserved – Do not use
        fwrite(fId2,Head.TriggerSource(mm),'int16'); %182-183// Trigger Source: 0 = Internal; 1 = External; 2 = Coupled
        MSB=uint32(Head.MSB(mm));MSB=bitand(MSB,61440);MSB=bitshift(MSB,4);MarkNumber=Head.MarkNumber(mm)-MSB;
        fwrite(fId2,MarkNumber,'uint16'); %184-185// Mark Number 0=No Mark. See bytes 16 –17 for MSB information.
        %NMEA Navigation Data
        fwrite(fId2,Head.NmeaHour(mm),'int16'); %186-187// Hour (0–23)
        fwrite(fId2,Head.NmeaMinutes(mm),'int16'); %188-189// Minutes (0–59)
        fwrite(fId2,Head.NmeaSeconds(mm),'int16'); %190-191// Seconds (0–59)
        fwrite(fId2,fix(Head.NmeaCourse(mm)),'int16'); %192-193// Course in Degrees (0 to 360) Fractional portion in LSB See bytes 18-19 for LSB information.
        fwrite(fId2,fix(Head.NmeaSpeed(mm)),'int16'); %194-195// Speed – in tenths of a knot for an additional fractional digit See bytes 20-21 LSB2 information.
        fwrite(fId2,Head.NmeaDay(mm),'int16'); %196-197// Day (1–366)
        fwrite(fId2,Head.NmeaYear(mm),'int16'); %198-199// Year
        %Other Miscellaneous Data
        fwrite(fId2,Head.MillisecondsToday(mm),'uint32'); %200-203// Milliseconds today (since midnight) (use in conjunction with Year / Day to get time of Ping)
        fwrite(fId2,Head.MaximumAbsoluteValueADC(mm),'uint16'); %204-205// Maximum Absolute Value of ADC samples in this packet
        fwrite(fId2,Head.Reserved9(mm),'int16'); %206-207// Reserved – Do not use
        fwrite(fId2,Head.Reserved10(mm),'int16'); %208-209// Reserved – Do not use
        fwrite(fId2,Head.SoftwareVersionNumber(:,mm),'uint8'); %210-215// Sonar Software Version Number - ASCII
        fwrite(fId2,Head.InitialSphericalCorrectionFactor(mm),'int32'); %216-219// Initial Spherical Correction Factor (Useful for multi-ping / deep application) * 100 
        fwrite(fId2,Head.PacketNumber(mm),'uint16'); %220-221// Packet Number Each ping starts with packet 1
        fwrite(fId2,Head.DecimationFactor(mm),'int16'); %222-223// 100 times the A/D Decimation Factor. Data is normally sampled at a high Rate.  Digital filters are applied to precisely limit the signal bandwidth.
        fwrite(fId2,Head.DecimationFactorAfterFFT(mm),'int16'); %224-225// Decimation Factor after the FFT
        fwrite(fId2,Head.WaterTemperature(mm),'int16'); %226-227// Water Temperature in units of 1/10 degree C (see bytes 30-31)
        fwrite(fId2,Head.Layback(mm),'float32'); %228-231// Layback in meters
        fwrite(fId2,Head.Reserved11(mm),'int32'); %232-235// Reserved – Do not use
        fwrite(fId2,Head.CableOut(mm),'uint16'); %236-237// Cable Out in decimeters (see bytes 30-31) 
        fwrite(fId2,Head.Reserved12(mm),'uint16'); %238-239// Reserved – Do not use
        %===End Head Write for Message Type 0080
        if ~mod(mm,5000), disp(['Trace: ',num2str(mm)]);end;
        %===Begin Data Write for Message Type 0080
        switch Head.DataFormat(mm),
            case {0,2,3,4}
                tmp=Data(1:Head.NumberDataSamples(mm),mm)./2.^(-Head.WeightingFactor(mm));
                fwrite(fId2,round(tmp),'int16');
            case {1,9}
                tmp=[(real(Data(1:Head.NumberDataSamples(mm),mm))')./2.^(-Head.WeightingFactor(mm));(imag(Data(1:Head.NumberDataSamples(mm),mm))')./2.^(-Head.WeightingFactor(mm))];
                fwrite(fId2,round(tmp),'int16');
        end;
        %===End Data Write for Message Type 0080
        %===Begin correction for Number Bytes This Record
        HSizeFollowingMessageNew=ftell(fId2)-JsfHead.RSeek(m); %estimate
        if (HSizeFollowingMessageNew~=JsfHead.HSizeFollowingMessage(m))&&(~flTraceLenChanged),error(['Error: gJsfWrite0080, not correct JsfHead.HSizeFollowingMessage for message num=' num2str(m)]);end;
        if (HSizeFollowingMessageNew~=JsfHead.HSizeFollowingMessage(m))&&(flTraceLenChanged),
            fseek(fId2,-HSizeFollowingMessageNew-4,'cof');fwrite(fId2,HSizeFollowingMessageNew,'uint32');fseek(fId2,HSizeFollowingMessageNew,'cof');
        end;
        %===End correction for Number Bytes This Record
    end;
end;
fclose(fId2);
fclose(fId);

%mail@ge0mlib.com 19/03/2018