function gSgyWrite_sio(SgyHead,Head,Data,fNameNew)
%Write Sgy variables [SgyHead,Head,Data] to file.
%function gSgyWrite(SgyHead,Head,Data,fNameNew), where
%SgyHead - Header structure, included Textual File Header, Binary File Header, Extended Textual File Header;
%Head - Header structure, included Trace Headers;
%Data - matrix with Traces Data.
%fNameNew - string, the target file for writing.
%Example: gSgyWrite_sio(SgyHead,Head,Data,'c:\temp\1new.sgy');

if ischar(Data),Data=gDataLoad(Data);end;
%==Begin File writing
[fId, mes]=fopen(fNameNew,'w',SgyHead.Endian);if ~isempty(mes), error(['gSgyWrite: ' mes]);end;
LenHead=size(Head.MessageNum,2); %trace number
cForm=SgyHead.Descript.DataSampleFormat.C{SgyHead.Descript.DataSampleFormat.Code==SgyHead.FDataSampleFormat}; %data format
FL=SgyHead.FixedLengthTraceFlag; %Flag -- FixedLengthTraceFlag
LTrace=SgyHead.ns; %trace length if FixedLengthTrace
errIbmFl=1; %Flag -- There is bitN7 set in IBM formated number.
errObsFl=1; %Flag -- There are bits from byteN1 set in Obsolete formated number.
%===Begin Write Textual File Header
fwrite(fId,SgyHead.TextualFileHeader,'uint8');
%===End Write Textual File Header
%===Begin Write Binary File Header
fwrite(fId,SgyHead.Job,'int32'); %Job identification number.
fwrite(fId,SgyHead.Line,'int32'); %Line number.  For 3-D poststack data, this will typically contain the in-line number.
fwrite(fId,SgyHead.Reel,'int32'); %Reel number.
fwrite(fId,SgyHead.DataTracePerEnsemble,'int16'); %Number of data traces per ensemble.  Mandatory for prestack data.
fwrite(fId,SgyHead.AuxiliaryTracePerEnsemble,'int16'); %Number of auxiliary traces per ensemble.  Mandatory for prestack data.
fwrite(fId,SgyHead.dt,'int16'); %Sample interval in microseconds (µs).  Mandatory for all data types.
fwrite(fId,SgyHead.dtOrig,'int16'); %Sample interval in microseconds  (µs) of original field recording.
fwrite(fId,SgyHead.ns,'int16'); %Number of samples per data trace.  Mandatory for all types of data. Note: The sample interval and number of samples in the Binary File Header should be for the primary set of seismic data traces in the file.
fwrite(fId,SgyHead.nsOrig,'int16'); %Number of samples per data trace for original field recording.
fwrite(fId,SgyHead.DataSampleFormat,'int16'); %Data sample format code.  Mandatory for all data. 1=4-byte IBM floating-point; 2=4-byte, two's complement integer; 3=2-byte, two's complement integer; 4=4-byte fixed-point with gain (obsolete); 5=4-byte IEEE floating-point; 6=Not currently used; 7=Not currently used; 8=1-byte, two's complement integer.
fwrite(fId,SgyHead.EnsembleFold,'int16'); %Ensemble fold - The expected number of data traces per trace ensemble (e.g. the CMP fold). Highly recommended for all types of data.
fwrite(fId,SgyHead.TraceSorting,'int16'); %Trace sorting code (i.e. type of ensemble) : -1=Other (should be explained in user Extended Textual File Header stanza; 0=Unknown; 1=As recorded (no sorting); 2=CDP ensemble; 3=Single fold continuous profile; 4=Horizontally stacked; 5=Common source point; 6=Common receiver point; 7=Common offset point; 8=Common mid-point; 9=Common conversion point. Highly recommended for all types of data.
fwrite(fId,SgyHead.VerticalSumCode,'int16'); %Vertical sum code: 1 = no sum, 2 = two sum, …, N = M-1 sum  (M = 2 to 32,767).
fwrite(fId,SgyHead.SweepFrequencyStart,'int16'); %Sweep frequency at start (Hz).
fwrite(fId,SgyHead.SweepFrequencyEnd,'int16'); %Sweep frequency at end (Hz).
fwrite(fId,SgyHead.SweepLength,'int16'); %Sweep length (ms).
fwrite(fId,SgyHead.SweepType,'int16'); %Sweep type code: 1=linear; 2=parabolic; 3=exponential; 4=other.
fwrite(fId,SgyHead.SweepChannel,'int16'); %Trace number of sweep channel.
fwrite(fId,SgyHead.SweepTaperlengthStart,'int16'); %Sweep trace taper length in milliseconds at start if tapered (the taper starts at zero time and is effective for this length).
fwrite(fId,SgyHead.SweepTaperLengthEnd,'int16'); %Sweep trace taper length in milliseconds at end (the ending taper starts at sweep length minus the taper length at end).
fwrite(fId,SgyHead.TaperType,'int16'); %Taper type: 1=linear; 2=cos^2; 3=other.
fwrite(fId,SgyHead.CorrelatedDataTraces,'int16'); %Correlated data traces: 1=no; 2=yes.
fwrite(fId,SgyHead.BinaryGain,'int16'); %Binary gain recovered: 1=yes; 2=no.
fwrite(fId,SgyHead.AmplitudeRecoveryMethod,'int16'); %Amplitude recovery method: 1=none; 2=spherical divergence; 3=AGC; 4=other.
fwrite(fId,SgyHead.MeasurementSystem,'int16'); %Measurement system: Highly recommended for all types of data.  If Location Data stanzas are included in the file, this entry must agree with the Location Data stanza.  If there is a disagreement, the last Location Data stanza is the controlling authority. 1=Meters; 2=Feet.
fwrite(fId,SgyHead.ImpulseSignalPolarity,'int16'); %Impulse signal polarity: 1=Increase in pressure or upward geophone case movement gives negative number on tape. 2=Increase in pressure or upward geophone case movement gives positive number on tape.
fwrite(fId,SgyHead.VibratoryPolarityCode,'int16'); %Vibratory polarity code: Seismic signal lags pilot signal by: 1=337.5 to 22.5; 2=22.5 to 67.5; 3=67.5 to 112.5; 4=112.5 to 157.5; 5=157.5 to 202.5; 6=202.5 to 247.5; 7=247.5 to 292.5;8=292.5 to 337.5.
fwrite(fId,SgyHead.Unassigned1,'int16'); %Unassigned1
fwrite(fId,SgyHead.SegyFormatRevisionNumber,'int16'); %SEG Y Format Revision Number. This is a 16-bit unsigned value with a Q-point between the first and second bytes. Thus for SEG Y Revision 1.0, as defined in this document, this will be recorded as 0100. This field is mandatory for all versions of SEG Y, although a value of zero indicates "traditional" SEG Y conforming to the 1975 standard.
fwrite(fId,SgyHead.FixedLengthTraceFlag,'int16'); %Fixed length trace flag. A value of one indicates that all traces in this SEG Y file are guaranteed to have the same sample interval and number of samples, as specified in Textual File Header bytes 3217-3218 and 3221-3222. A value of zero indicates that the length of the traces in the file may vary and the number of samples in bytes 115-116 of the Trace Header must be examined to determine the actual length of each trace. This field is mandatory for all versions of SEG Y, although a value of zero indicates "traditional" SEG Y conforming to the 1975 standard.
if ~isempty(SgyHead.ExtTextualHeaders), SgyHead.NumberOfExtTextualHeaders=ceil(numel(SgyHead.ExtTextualHeaders)./3200);else SgyHead.NumberOfExtTextualHeaders=0;end;
fwrite(fId,SgyHead.NumberOfExtTextualHeaders,'int16'); %Number of 3200-byte, Extended Textual File Header records following the Binary Header. A value of zero indicates there are no Extended Textual File Header records (i.e. this file has no Extended Textual File Header(s)).  A value of -1 indicates that there are a variable number of Extended Textual File Header records and the end of the Extended Textual File Header is denoted by an ((SEG: EndText)) stanza in the final record.
% A positive value indicates that there are exactly that many Extended Textual File Header records.  Note that, although the exact number of Extended Textual File Header records may be a useful piece of information, it will not always be known at the time the Binary Header is written and it is not mandatory that a positive value be recorded here.  This field is mandatory for all versions of SEG Y, although a value of zero indicates “traditional” SEG Y conforming to the 1975 standard.
fwrite(fId,SgyHead.Unassigned2,'int16'); %Unassigned2
%===End Write Binary File Header
%===Begin Write Extended Textual File Header
if ~isempty(SgyHead.ExtTextualHeaders), fwrite(fId,[SgyHead.ExtTextualHeaders (zeros(1,SgyHead.NumberOfExtTextualHeaders.*3200-numel(SgyHead.ExtTextualHeaders)))],'uint8');end; %create and write ExtTextualHeaders
%===End Write Extended Textual File Header
for n=1:LenHead,
    %===Begin Trase Header Write
    fwrite(fId,Head.TraceSequenceLine(n),'int32'); %Trace sequence number within line — Numbers continue to increase if the same line continues across multiple SEG Y files. Highly recommended for all types of data.
    fwrite(fId,Head.TraceSequenceFile(n),'int32'); %Trace sequence number within SEG Y file — Each file starts with trace sequence one.
    fwrite(fId,Head.FieldRecord(n),'int32'); %Original field record number. Highly recommended for all types of data.
    fwrite(fId,Head.TraceNumber(n),'int32'); %Trace number within the original field record. Highly recommended for all types of data.
    fwrite(fId,Head.EnergySourcePoint(n),'int32'); %Energy source point number — Used when more than one record occurs at the same effective surface location.  It is recommended that the new entry defined in Trace Header bytes 197-202 be used for shotpoint number.
    fwrite(fId,Head.cdp(n),'int32'); %Ensemble number (i.e. CDP, CMP, CRP, etc)
    fwrite(fId,Head.cdpTrace(n),'int32'); %Trace number within the ensemble — Each ensemble starts with trace number one.
    fwrite(fId,Head.TraceIdenitifactionCode(n),'int16'); %Trace identification code: -1=Other; 0=Unknown; 1=Seismic data; 2=Dead; 3=Dummy; 4=Time break; 5=Uphole; 6=Sweep; 7=Timing; 8=Waterbreak; 9=Near-field gun signature; 10=Far-field gun signature; 11=Seismic pressure sensor; 12=Multicomponent seismic sensor - Vertical component; 13=Multicomponent seismic sensor - Cross-line component; 14=Multicomponent seismic sensor - In-line component; 15=Rotated multicomponent seismic sensor - Vertical component; 16=Rotated multicomponent seismic sensor - Transverse component; 17=Rotated multicomponent seismic sensor - Radial component; 18=Vibrator reaction mass; 19=Vibrator baseplate; 20=Vibrator estimated ground force; 21=Vibrator reference; 22=Time-velocity pairs; 23 … N=optional use,  (maximum N = 32,767). Highly recommended for all types of data.
    fwrite(fId,Head.NSummedTraces(n),'int16'); %Number of vertically summed traces yielding this trace.  (1 is one trace, 2 is two summed traces, etc.)
    fwrite(fId,Head.NStackedTraces(n),'int16'); %Number of horizontally stacked traces yielding this trace.  (1 is one trace, 2 is two stacked traces, etc.)
    fwrite(fId,Head.DataUse(n),'int16'); %Data use: 1=Production; 2=Test.
    fwrite(fId,Head.offset(n),'int32'); %Distance from center of the source point to the center of the receiver group (negative if opposite to direction in which line is shot).
    %////The scalar in Trace Header bytes 69-70 applies to these values. The units are feet or meters as specified in Binary File Header bytes 3255-3256). The Vertical Datum should be defined through a Location Data stanza (see section D-1).
    fwrite(fId,Head.ReceiverGroupElevation(n),'int32'); %////Receiver group elevation (all elevations above the Vertical datum are positive and below are negative).
    fwrite(fId,Head.SourceSurfaceElevation(n),'int32'); %////Surface elevation at source.
    fwrite(fId,Head.SourceDepth(n),'int32'); %////Source depth below surface (a positive number).
    fwrite(fId,Head.ReceiverDatumElevation(n),'int32'); %////Datum elevation at receiver group.
    fwrite(fId,Head.SourceDatumElevation(n),'int32'); %////Datum elevation at source.
    fwrite(fId,Head.SourceWaterDepth(n),'int32'); %////Water depth at source.
    fwrite(fId,Head.GroupWaterDepth(n),'int32'); %////Water depth at group.
    fwrite(fId,Head.ElevationScalar(n),'int16'); %Scalar to be applied to all elevations and depths specified in Trace Header bytes 41-68 to give the real value.  Scalar = 1, +10, +100, +1000, or +10,000.  If positive, scalar is used as a multiplier; if negative, scalar is used as a divisor.
    fwrite(fId,Head.SourceGroupScalar(n),'int16'); %Scalar to be applied to all coordinates specified in Trace Header bytes 73-88 and to bytes Trace Header 181-188 to give the real value.  Scalar = 1, +10, +100, +1000, or +10,000.  If positive, scalar is used as a multiplier; if negative, scalar is used as divisor.
    %//The coordinate reference system should be identified through an extended header Location Data stanza (see section D-1). If the coordinate units are in seconds of arc, decimal degrees or DMS, the X values represent longitude and the Y values latitude. A positive value designates east of Greenwich Meridian or north of the equator and a negative value designates south or west.
    fwrite(fId,Head.SourceX(n),'int32'); %//Source coordinate - X.
    fwrite(fId,Head.SourceY(n),'int32'); %//Source coordinate - Y.
    fwrite(fId,Head.GroupX(n),'int32'); %//Group coordinate - X.
    fwrite(fId,Head.GroupY(n),'int32'); %//Group coordinate - Y.
    fwrite(fId,Head.CoordinateUnits(n),'int16'); %Coordinate units: 1=Length (meters or feet); 2=Seconds of arc; 3=Decimal degrees; 4=Degrees, minutes, seconds (DMS). Note: To encode +-DDDMMSS bytes 89-90 equal= +-DDD*10^4 + MM*10^2 + SS with bytes 71-72 set to 1; To encode +-DDDMMSS.ss bytes 89-90 equal= +-DDD*10^6 + MM*10^4 + SS*10^2 with bytes 71-72 set to -100.
    fwrite(fId,Head.WeatheringVelocity(n),'int16'); %Weathering velocity. (ft/s or m/s as specified in Binary File Header bytes 3255-3256).
    fwrite(fId,Head.SubWeatheringVelocity(n),'int16'); %Subweathering velocity. (ft/s or m/s as specified in Binary File Header bytes 3255-3256)
    %////Time in milliseconds as scaled by the scaled by the scalar specified in Trace Header bytes 215-216.
    fwrite(fId,Head.SourceUpholeTime(n),'int16'); %////Uphole time at source in milliseconds.
    fwrite(fId,Head.GroupUpholeTime(n),'int16'); %////Uphole time at group in milliseconds.
    fwrite(fId,Head.SourceStaticCorrection(n),'int16'); %////Source static correction in milliseconds.
    fwrite(fId,Head.GroupStaticCorrection(n),'int16'); %////Group static correction in milliseconds.
    fwrite(fId,Head.TotalStaticApplied(n),'int16'); %////Total static applied in milliseconds. (Zero if no static has been applied).
    fwrite(fId,Head.LagTimeA(n),'int16'); %////Lag time A — Time in milliseconds between end of 240-byte trace identification header and time break.  The value is positive if time break occurs after the end of header; negative if time break occurs before the end of header.  Time break is defined as the initiation pulse that may be recorded on an auxiliary trace or as otherwise specified by the recording system.
    fwrite(fId,Head.LagTimeB(n),'int16'); %////Lag Time B — Time in milliseconds between time break and the initiation time of the energy source.  May be positive or negative.
    fwrite(fId,Head.DelayRecordingTime(n),'int16'); %////Delay recording time — Time in milliseconds between initiation time of energy source and the time when recording of data samples begins.  In SEG Y rev 0 this entry was intended for deep-water work if data recording does not start at zero time.  The entry can be negative to accommodate negative start times (i.e. data recorded before time zero, presumably as a result of static application to the data trace).  If a non-zero value (negative or positive) is recorded in this entry, a comment to that effect should appear in the Textual File Header.
    fwrite(fId,Head.MuteTimeStart(n),'int16'); %////Mute time — Start time in milliseconds.
    fwrite(fId,Head.MuteTimeEnd(n),'int16'); %////Mute time — End time in milliseconds.
    fwrite(fId,Head.ns(n),'int16'); %Number of samples in this trace. Highly recommended for all types of data.
    fwrite(fId,Head.dt(n),'int16'); %Sample interval in microseconds (µs) for this trace. The number of bytes in a trace record must be consistent with the number of samples written in the trace header.  This is important for all recording media; but it is particularly crucial for the correct processing of SEG Y data in disk files (see Appendix C). If the fixed length trace flag in bytes 3503-3504 of the Binary File Header is set, the sample interval and number of samples in every trace in the SEG Y file must be the same as the values recorded in the Binary File Header.  If the fixed length trace flag is not set, the sample interval and number of samples may vary from trace to trace. Highly recommended for all types of data.
    fwrite(fId,Head.GainType(n),'int16'); %Gain type of field instruments: 1=fixed; 2=binary; 3=floating point; 4 … N=optional use.
    fwrite(fId,Head.InstrumentGainConstant(n),'int16'); %Instrument gain constant (dB).
    fwrite(fId,Head.InstrumentInitialGain(n),'int16'); %Instrument early or initial gain (dB).
    fwrite(fId,Head.Correlated(n),'int16'); %Correlated: 1=no; 2=yes.
    fwrite(fId,Head.SweepFrequenceStart(n),'int16'); %Sweep frequency at start (Hz).
    fwrite(fId,Head.SweepFrequenceEnd(n),'int16'); %Sweep frequency at end (Hz).
    fwrite(fId,Head.SweepLength(n),'int16'); %Sweep length in milliseconds.
    fwrite(fId,Head.SweepType(n),'int16'); %Sweep type: 1=linear; 2=parabolic; 3=exponential; 4=other.
    fwrite(fId,Head.SweepTraceTaperLengthStart(n),'int16'); %Sweep trace taper length at start in milliseconds.
    fwrite(fId,Head.SweepTraceTaperLengthEnd(n),'int16'); %Sweep trace taper length at end in milliseconds.
    fwrite(fId,Head.TaperType(n),'int16'); %Taper type: 1=linear; 2=cos^2; 3=other.
    fwrite(fId,Head.AliasFilterFrequency(n),'int16'); %Alias filter frequency (Hz), if used.
    fwrite(fId,Head.AliasFilterSlope(n),'int16'); %Alias filter slope (dB/octave).
    fwrite(fId,Head.NotchFilterFrequency(n),'int16'); %Notch filter frequency (Hz), if used.
    fwrite(fId,Head.NotchFilterSlope(n),'int16'); %Notch filter slope (dB/octave).
    fwrite(fId,Head.LowCutFrequency(n),'int16'); %Low-cut frequency (Hz), if used.
    fwrite(fId,Head.HighCutFrequency(n),'int16'); %High-cut frequency (Hz), if used.
    fwrite(fId,Head.LowCutSlope(n),'int16'); %Low-cut slope (dB/octave).
    fwrite(fId,Head.HighCutSlope(n),'int16'); %High-cut slope (dB/octave).
    fwrite(fId,Head.YearDataRecorded(n),'int16'); %Year data recorded — The 1975 standard is unclear as to whether this should be recorded as a 2-digit or a 4-digit year and both have been used.  For SEG Y revisions beyond rev 0, the year should be recorded as the complete 4-digit Gregorian calendar year (i.e. the year 2001 should be recorded as 2001 (7D1)).
    fwrite(fId,Head.DayOfYear(n),'int16'); %Day of year (Julian day for GMT and UTC time basis).
    fwrite(fId,Head.HourOfDay(n),'int16'); %Hour of day (24 hour clock).
    fwrite(fId,Head.MinuteOfHour(n),'int16'); %Minute of hour.
    fwrite(fId,Head.SecondOfMinute(n),'int16'); %Second of minute.
    fwrite(fId,Head.TimeBaseCode(n),'int16'); %Time basis code: 1=Local; 2=GMT (Greenwich Mean Time); 3=Other, should be explained in a user defined stanza in the Extended Textual File Header; 4=UTC (Coordinated Universal Time).
    fwrite(fId,Head.TraceWeightningFactor(n),'int16'); %Trace weighting factor — Defined as 2^-N volts for the least significant bit.  (N = 0, 1, ..., 32767)
    fwrite(fId,Head.GeophoneGroupNumberRoll(n),'int16'); %Geophone group number of roll switch position one.
    fwrite(fId,Head.GeophoneGroupNumberFirstTraceOrigField(n),'int16'); %Geophone group number of trace number one within original field record.
    fwrite(fId,Head.GeophoneGroupNumberLastTraceOrigField(n),'int16'); %Geophone group number of last trace within original field record.
    fwrite(fId,Head.GapSize(n),'int16'); %Gap size (total number of groups dropped).
    fwrite(fId,Head.OverTravel(n),'int16'); %Over travel associated with taper at beginning or end of line: 1=down (or behind); 2=up (or ahead).
    %fwrite(fId,Head.cdpX(n),'int32'); %X coordinate of ensemble (CDP) position of this trace (scalar in Trace Header bytes 71-72 applies). The coordinate reference system should be identified through an extended header Location Data stanza (see section D-1).
    fwrite(fId,Head.KelSpmCode(n),'uint16'); %Frequency channel code
    fwrite(fId,Head.KelPingStartTimeHr(n),'uint16'); %Time @ start of ping: Hours
    %fwrite(fId,Head.cdpY(n),'int32'); %Y coordinate of ensemble (CDP) position of this trace (scalar in bytes Trace Header 71-72 applies). The coordinate reference system should be identified through an extended header Location Data stanza (see section D-1).
    fwrite(fId,Head.KelPingStartTimeMin(n),'uint16'); %Time @ start of ping: Minutes
    fwrite(fId,Head.KelPingStartTimeSec(n),'uint16'); %Time @ start of ping: Seconds
    %fwrite(fId,Head.Inline3D(n),'int32'); %For 3-D poststack data, this field should be used for the in-line number. If one in-line per SEG Y file is being recorded, this value should be the same for all traces in the file and the same value will be recorded in bytes 3205-3208 of the Binary File Header.
    fwrite(fId,Head.KelPingStartTimeMs(n),'uint16'); %Time @ start of ping: Milliseconds
    fwrite(fId,Head.KelTxPower(n),'uint16'); %Transmit power parameter setting (1 to 8)
    %fwrite(fId,Head.Crossline3D(n),'int32'); %For 3-D poststack data, this field should be used for the cross-line number. This will typically be the same value as the ensemble (CDP) number in Trace Header bytes 21-24, but this does not have to be the case.
    fwrite(fId,Head.KelRxGain(n),'uint16'); %Receive gain parameter setting (0 to 255)
    fwrite(fId,Head.KelProcessingGain(n),'uint16'); %Processing gain parameter setting (0 to 8)
    %fwrite(fId,Head.ShotPoint(n),'int32'); %Shotpoint number — This is probably only applicable to 2-D poststack data. Note that it is assumed that the shotpoint number refers to the source location nearest to the ensemble (CDP) location for a particular trace.  If this is not the case, there should be a comment in the Textual File Header explaining what the shotpoint number actually refers to.
    fwrite(fId,Head.KelSensitivity(n),'uint16'); %Sensitivity parameter setting (1 to 100)
    fwrite(fId,Head.KelMuxChannel(n),'uint16'); %Multiplexer channel code (not currently used)
    %fwrite(fId,Head.ShotPointScalar(n),'int16'); %Scalar to be applied to the shotpoint number in Trace Header bytes 197-200 to give the real value.  If positive, scalar is used as a multiplier; if negative as a divisor; if zero the shotpoint number is not scaled (i.e. it is an integer.  A typical value will be -10, allowing shotpoint numbers with one decimal digit to the right of the decimal point).
    fwrite(fId,Head.KelEchoStrength(n),'uint16'); %Echo Strength expressed in dB
    %fwrite(fId,Head.TraceValueMeasurementUnit(n),'int16'); %Trace value measurement unit: -1=Other (should be described in Data Sample Measurement Units Stanza); 0=Unknown; 1=Pascal(Pa); 2=Volts(v); 3=Millivolts(mV); 4=Amperes(A); 5=Meters(m); 6=Meters per second(m/s); 7=Meters per second squared(m/s^2); 8=Newton(N); 9=Watt(W).
    fwrite(fId,Head.KelPrimaryChannel(n),'uint16'); %Primary channel parameter setting
    %fwrite(fId,Head.TransductionConstantMantissa(n),'int32'); %//Transduction Constant — The multiplicative constant used to convert the Data Trace samples to the Transduction Units (specified in Trace Header bytes 211-212).  The constant is encoded as a four-byte, two's complement integer (bytes 205-208) which is the mantissa and a two-byte, two's complement integer (bytes 209-210) which is the power of ten exponent (i.e. Bytes 205-208 * 10**Bytes 209-210).
    fwrite(fId,Head.KelPulseLength(n),'uint16'); %Pulse Length parameter selection code
    fwrite(fId,Head.KelTxBlank(n),'uint16'); %Transmit blanking paramter expressed in 1/10 system units
    %fwrite(fId,Head.TransductionConstantPower(n),'int16'); %//
    fwrite(fId,Head.KelSoundSpeed(n),'uint16'); %Sound Speed Parameter Setting
    %fwrite(fId,Head.TransductionUnit(n),'int16'); %Transduction Units — The unit of measurement of the Data Trace samples after they have been multiplied by the Transduction Constant specified in Trace Header bytes 205-210. -1=Other (should be described in Data Sample Measurement Unit stanza, page 36); 0=Unknown; 1=Pascal(Pa); 2=Volts(v); 3=Millivolts(mV); 4=Amperes(A); 5=Meters(m); 6=Meters per second(m/s); 7=Meters per second squared(m/s^2); 8=Newton(N); 9=Watt(W).
    fwrite(fId,Head.KelStartDepth(n),'uint16'); %Active window start depth
    %fwrite(fId,Head.TraceIdentifier(n),'int16'); %Device/Trace Identifier — The unit number or id number of the device associated with the Data Trace (i.e. 4368 for vibrator serial number 4368 or 20316 for gun 16 on string 3 on vessel 2).  This field allows traces to be associated across trace ensembles independently of the trace number (Trace Header bytes 25-28).
    fwrite(fId,Head.KelEndDepth(n),'uint16'); %Active window end depth
    %fwrite(fId,Head.ScalarTraceHeader(n),'int16'); %Scalar to be applied to times specified in Trace Header bytes 95-114 to give the true time value in milliseconds.  Scalar = 1, +10, +100, +1000, or +10,000. If positive, scalar is used as a multiplier; if negative, scalar is used as divisor. A value of zero is assumed to be a scalar value of 1.
    fwrite(fId,Head.KelUndefined(n),'uint16'); %No longer defined
    %fwrite(fId,Head.SourceType(n),'int16'); %Source Type/Orientation — Defines the type and the orientation of the energy source.  The terms vertical, cross-line and in-line refer to the three axes of an orthogonal coordinate system.  The absolute azimuthal orientation of the coordinate system axes can be defined in the Bin Grid Definition Stanza (page 27). -1 to -n = Other (should be described in Source Type/Orientation stanza, page 38). 0=Unknown; 1=Vibratory - Vertical orientation; 2=Vibratory - Cross-line orientation; 3=Vibratory - In-line orientation; 4=Impulsive - Vertical orientation; 5=Impulsive - Cross-line orientation; 6=Impulsive - In-line orientation; 7=Distributed Impulsive - Vertical orientation; 8=Distributed Impulsive - Cross-line orientation; 9=Distributed Impulsive - In-line orientation.
    fwrite(fId,Head.KelHeave(n),'uint16'); %Heave expressed in 1/100 of system units
    %fwrite(fId,Head.SourceEnergyDirectionMantissa(n),'int32'); %////Source Energy Direction with respect to the source orientation  — The positive orientation direction is defined in Bytes 217-218 of the Trace Header. The energy direction is encoded in tenths of degrees (i.e. 347.8 is encoded as 3478).
    fwrite(fId,Head.KelHeaveSensorLatency(n),'uint16'); %Latency since heave data received [sec]
    fwrite(fId,Head.KelGPSLatency(n),'uint16'); %Latency since GPS data received [sec]
    %fwrite(fId,Head.SourceEnergyDirectionExponent(n),'int16'); %////
    fwrite(fId,Head.KelEventMarkCode(n),'uint16'); %Event mark code: 0 = no event mark
    %fwrite(fId,Head.SourceMeasurementMantissa(n),'int32'); %//Source Measurement — Describes the source effort used to generate the trace. The measurement can be simple, qualitative measurements such as the total weight of explosive used or the peak air gun pressure or the number of vibrators times the sweep duration.  Although these simple measurements are acceptable, it is preferable to use true measurement units of energy or work. The constant is encoded as a four-byte, two's complement integer (bytes 225-228) which is the mantissa and a two-byte, two's complement integer (bytes 209-230) which is the power of ten exponent (i.e. Bytes 225-228 * 10**Bytes 229-230).
    fwrite(fId,Head.KelEventMarkNumber(n),'uint16'); %Event mark number if event present
    fwrite(fId,Head.KelScalar(n),'uint16'); %Scalar applied to digitized depth and sampling data rate
    %fwrite(fId,Head.SourceMeasurementExponent(n),'int16'); %//
    %fwrite(fId,Head.SourceMeasurementUnit(n),'int16'); %Source Measurement Unit — The unit used for the Source Measurement, Trace header bytes 225-230. -1 = Other (should be described in Source Measurement Unit stanza, page 39); 0=Unknown; 1=Joule(J); 2=Kilowatt(kW); 3=Pascal(Pa); 4=Bar(Bar); 4=Bar-meter(Bar-m); 5=Newton(N); 6=Kilograms(kg).
    fwrite(fId,Head.KelDataRate(n),'uint32');; %Sampling data rate
    fwrite(fId,Head.UnassignedInt1(n),'int32'); %Unassigned — For optional information.
    fwrite(fId,Head.UnassignedInt2(n),'int32'); %Unassigned — For optional information.
    %===End Trase Header Read
    %===Begin Trase Data Write
    if ~FL, LTrace=Head.ns(n); end;
    a=Data(1:LTrace,n);
    switch SgyHead.FDataSampleFormat, %format apply
        case 1, %1=4-byte IBM floating-point
            a(a>7.236998675585915e+75)=inf;a(a<-7.236998675585915e+75)=-inf; %//based on "function b=num2ibm(x)"; (C) Brian Farrelly, 22 October 2001; mailto:Brian.Farrelly@nho.hydro.com, Norsk Hydro Research Centre.
            [F,E]=log2(abs(a));e=E./4;ec=ceil(e);p=ec+64;
            f=round(pow2(F,-4.*(ec-e)).*16777216);
            L=(f==16777216);p(L)=p(L)+1;f(L)=1048576;
            b=bitor(bitshift(uint32(p),24),uint32(f));
            b(a<0)=bitset(b(a<0),32);
            b(a==0)=0;b(isnan(a))=2147483647;b(isinf(a)&a>0)=2147483632;b(isinf(a)&a<0)=4294967280;
            if errIbmFl,
                a1=(1-2.*double(bitget(b,32))).*pow2(double(bitand(b,16777215))./16777216,4.*(double(bitshift(bitand(b,2130706432),-24))-64));
                errIbmFl=~any((abs((a1-a)./a)<5e-7)&(a));
            end;
            fwrite(fId,b,cForm);
        case 4, %4=4-byte fixed-point with gain (obsolete)
            E=ceil(log2(abs(a)./32767));F=round(abs(a)./pow2(E));
            b=bitor(bitand(uint32(E),32767),bitshift(bitand(F,127),16));
            b(a<0)=bitset(b(a<0),16);
            if errIbmFl,
                errObsFl=~any(bitand(uint32(E),4294934528)||bitand(uint32(F),4294967040));
            end;
            fwrite(fId,b,cForm);
        otherwise,
            fwrite(fId,a,cForm);
    end;
    %===End Trase Data Write
    %if ~mod(n,5000), disp(['Trace: ',num2str(n)]);end;
end;
fclose(fId);
if ~errIbmFl, disp('Warning gSgyWrite: There was IEEE to IBM conversion error.');end;
if ~errObsFl, disp('Warning gSgyWrite: There was IEEE to Obsolete conversion overflow error.');end;
%==End File writing

%mail@ge0mlib.com 04/11/2020