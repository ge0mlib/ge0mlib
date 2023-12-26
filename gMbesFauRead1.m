function [FauHead,Head]=gFauRead(fName,Endian,BeamNum)
%Read FAU variables [FauHead,Head] from file.
%function function [FauHead,Head]=gFauRead(fName,Endian), where
%fName - the target file name;
%Endian - forced Endian; 'b'- big-endian; 'l'- Little-endian; if FauHead presented, than Endian autodetected;
%BeamNum - beam number (optional);
%FauHead - optional Header structure;
%Head - Header structure, included Datagram body.
%Remarks:
%1) The FauHead data-block in file is optional;
%2) There are following sub-formats: .fau-projected coordinates; .fas-stereographic coordinates; .fag/.fal-geographic coordinates; .fu2-roll multiplier is 0.2 and fields [BeamNumber, MeanError] instead of BeamAngle.
%3) Roll value, in 0.1 degrees, but can be 0.2 for some equipment types.
%Example: [FauHead,Head]=gFauRead('c:\temp\1.fau','b',[]);scatter3(Head.GpsE(1:10000),Head.GpsN(1:10000),Head.Depth(1:10000),[],Head.Depth(1:10000),'.');

%==Begin Endian and header detection
[fId, mes]=fopen(fName,'r',Endian);if ~isempty(mes), error(['gFauRead: ' mes]);end;
tmp=char(fread(fId,8,'uint8')); %Bytes used to detect the endianness adopted by the file: Little Endian: 'fau__uaf', Big Endian: '_uaffau_'
if strcmp(tmp,'fau__uaf'),Endian='l';FauHeadFl=1;elseif strcmp(tmp,'_uaffau_'),Endian='b';FauHeadFl=1;else,FauHeadFl=0;end;
fclose(fId);
%==End Endian and header detection
%==Begin File reading
[fId, mes]=fopen(fName,'r',Endian);if ~isempty(mes), error(['gFauRead: ' mes]);end;
FauHead.fName=fName;
FauHead.Endian=Endian;
FauHead.FauHeadFl=FauHeadFl;
FauHead.BeamNum=BeamNum;
finfo=dir(FauHead.fName);fSize=finfo.bytes;
%===Begin Read Binary Optional Header
if FauHeadFl,
    %U8 Unsigned Char; S8 Signed Char; U16 Unsigned Short; S16 Signed short; U32 Unsigned Integer; S32 Signed Integer; U64 Unsigned Long; S64 Signed Long; F32 Float; F64 Double
    FauHead.Identity=char(fread(fId,8,'uint8')); %1-8/8xS8/ Bytes used to detect the endianness adopted by the file: Little Endian: 'fau__uaf', Big Endian: '_uaffau_'
    FauHead.Minilab=char(fread(fId,20,'uint8')); %9-28/20xS8/ A 'minilabel' containing the geospatial reference system in use: #[Projection]N[Horizontal Datum]. The first character is always '#'. Despite the format name, it is also possible to store data in projection different from UTM. For example: mrc  Mercator npstg  Polar stereographic estg  Equatorial Stereographic itm  Gauss Krueger upsn  Universal Polar Stereographic North upss  Universal Polar Stereographic South dlmb  Lamberts Conical Two lmb  Lamberts Conical One sbf  System SBF (Denmark) dks  System DKS (Denmark/Sweden) The eighth character sets the adopted Z-convention. The 'N' indicates “normal heights” (depths) with positive down. Example of mini-label: '#utm22nNwgs84' identifies: utm22n  UTM projection, Zone 22 North. N  Depths (positive Z is down) wgs84  WGS84 datum.
    FauHead.Version=char(fread(fId,32,'uint8')); %29-60/32xS8/ The version of the program used for converting to FAU format.
    FauHead.ConversionTime=fread(fId,1,'int32'); %61-64/S32/ The UNIX time in seconds when the file was generated.
    FauHead.Length=fread(fId,1,'int32'); %65-68/S32/ The size of the header in bytes. The value is always 768 (3x 256 bytes, and 32x 24 bytes - the size of the Body Datagram).
    FauHead.PingNumber=fread(fId,1,'uint64'); %69-76/U64/ The ping number of the first ping converted into a FAU file. If not used/applicable, use 0.
    FauHead.Source=fread(fId,1,'int32'); %77-80/S32/ The source of the depth measurements: 1-Database; 2-SBD; 3-SEMI; 4-XYZ.
    FauHead.Kind=fread(fId,1,'int32'); %81-84/S32/ The type of depth measurements: 1-Multibeam, with DGPS navigation; 2-Multibeam, with RTK navigation; 4-Singlebeam; 8-Thinned; 16-Not the primary detection layer.
    FauHead.Tide=fread(fId,1,'uint32'); %85-88/S32/ A collection of bit fields for describing the approach adopted for vertical reduction: 1-Data is corrected for tide; 2-Delayed heave was applied; 4-Cross-section offset was applied.
    FauHead.RollOffset=fread(fId,1,'float32'); %89-92/F32/ Calibration value for static roll in decimal degrees. If not used/applicable, use 0.
    FauHead.PitchOffset=fread(fId,1,'float32'); %93-96/F32/ Calibration value for static pitch in decimal degrees. If not used/applicable, use 0.
    FauHead.HeadingOffset=fread(fId,1,'float32'); %97-100/F32/ Calibration value for static heading in decimal degrees. If not used/applicable, use 0.
    FauHead.TimeOffset=fread(fId,1,'int32'); %101-104/S32/ Calibration value for time in milliseconds. If not used/applicable, use 0.
    FauHead.EditedSensors=fread(fId,1,'uint32'); %105-108/S32/ A collection of bit fields for describing the sensors with edited values: 1-Roll; 2-Pitch; 4-Gyro; 8-Heave.
    FauHead.SvSensors=fread(fId,1,'uint32'); %109-112/S32/ A collection of bit fields for describing the type of sound speed sensor: 1-Transducer sensor; 2-Sound speed profiler; 4-Scanfish equipment; 8-Transducer sensor not working.
    FauHead.SvNname=char(fread(fId,512,'uint8')); %113-624/512xS8/ The sound speed filename used for the stored data, with extension. If not used/applicable, the field is left empty.
    FauHead.NrOfBeams=fread(fId,1,'int32'); %625-628/S32/ The number of beams for each ping/swath. It is mandatory for kind=1 and kind=2; otherwise, use 0.
    FauHead.NrOfPings=fread(fId,1,'int32'); %629-632/S32/ The total number of pings/swaths in the file. If not used/applicable (e.g., unstructured FAU), use 0.
    FauHead.BbMaxN=fread(fId,1,'int32'); %633-636/S32/ The maximum northing coordinate among the valid depth measurements, in centimeters.
    FauHead.BbMinN=fread(fId,1,'int32'); %637-640/S32/ The minimum northing coordinate among the valid depth measurements, in centimeters.
    FauHead.BbMaxE=fread(fId,1,'int32'); %641-644/S32/ The maximum easting coordinate among the valid depth measurements, in centimeters.
    FauHead.BbMinE=fread(fId,1,'int32'); %645-648/S32/ The minimum easting coordinate among the valid depth measurements, in centimeters.
    FauHead.BbMaxH=fread(fId,1,'int32'); %649-652/S32/ The maximum depth value among the valid depth measurements, in centimeters.
    FauHead.BbMinH=fread(fId,1,'int32'); %653-656/S32/ The minimum depth value among the valid depth measurements, in centimeters.
    FauHead.TrackHeading=fread(fId,1,'float32'); %657-660/F32/ The average heading of the trackline, in decimal degrees. If not used/applicable, use 0.0.
    FauHead.Speed=fread(fId,1,'float32'); %661-664/F32/ The average speed of the trackline, in meter per second. If not used/applicable, use 0.0.
    FauHead.Roll95=fread(fId,1,'float32'); %665-668/F32/ The interval in decimal degrees containing the 95% of the roll values. If not used/applicable, use 0.0.
    FauHead.Pitch95=fread(fId,1,'float32'); %669-672/F32/ The interval in decimal degrees containing the 95% of the pitch values. If not used/applicable, use 0.0.
    FauHead.Heave95=fread(fId,1,'int32'); %673-676/S32/ The interval in centimeters containing the 95% of the heave values. If not used/applicable, use 0.
    FauHead.MaxTimeGap=fread(fId,1,'int32'); %677-680/S32/ This value and ping_nr_max_time_gap provides information about the correct functioning of the multibeam system: does it deliver the requested number of pings per second? The maximum time gap in stored in centiseconds. If not used/applicable, use 0.
    FauHead.PingNrMaxTimeGap=fread(fId,1,'int32'); %681-684/S32/ This value and max_time_gap provides information about the correct functioning of the multibeam system: does it deliver the requested number of pings per second? If not used/applicable, use 0.
    FauHead.PingNrPosJump=fread(fId,1,'int32'); %685-688/S32/ Number of jumps between individual pings due to, for example, unstable positioning system. If not used/applicable, use 0.
    FauHead.MaxNonLinearity=fread(fId,1,'int32'); %689-692/S32/ The largest numerical difference (counted in number of swaths) between any swath in the file and the idealized swaths in the bounding box. If not used/applicable, use 0.
    FauHead.Major=fread(fId,1,'uint8'); %693/S8/ The major version number for Vise/MapSpikes.
    FauHead.Minor=fread(fId,1,'uint8'); %694/S8 The minor version number for Vise/MapSpikes.
    FauHead.AutoFlags=fread(fId,1,'uint8'); %695/S8/ Field indicating whether an automatic flagging was used. 0-No automatic flagging. 1-An automatic flagging was used.
    FauHead.RotRectValid=fread(fId,1,'uint8'); %696/S8/ A collection of bit fields for describing the validity of the rotated bounding box: 1-Valid rotated bounding box; 2-Maximum non-linearity valid; 4-Valid transducer depth.
    FauHead.BbTiltX=fread(fId,1,'float64'); %697-704/F64/ The x-coordinate of the rotated bounding box, in centimeters.
    FauHead.BbTiltY=fread(fId,1,'float64'); %705-712/F64/ The y-coordinate of the rotated bounding box, in centimeters.
    FauHead.BbTiltW=fread(fId,1,'float64'); %713-720/F64/ The width of the rotated bounding box, in centimeters.
    FauHead.BbTiltH=fread(fId,1,'float64'); %721-728/F64/ The height of the rotated bounding box, in centimeters.
    FauHead.BbTiltAng=fread(fId,1,'float64'); %729-736/F64/ The rotation angle of the rotated bounding box, in decimal degrees.
    FauHead.TransducerDepth=fread(fId,1,'int32'); %737-740/S32/ The depth of the transducer, in centimeters. If not used/applicable, use 0.
    FauHead.TransmitBeamWidth=fread(fId,1,'float32'); %741-744/F32/ Along-track TX beam width, in decimal degrees. If not used/applicable, use 0.0.
    FauHead.SwathAngle=fread(fId,1,'float32'); %745-748/F32/ The aperture of the swath, in decimal degrees. If not used/applicable, use 0.
    FauHead.Normalization=fread(fId,1,'int32'); %749-752/S32/ The UNIX time in seconds of the last performed channel normalization. A feature available with RESON systems for correcting the output of each analogue receiver channel for minor variations in amplitude and phase.
    FauHead.BitField=fread(fId,1,'uint32'); %753-756/S32/ A collection of bit fields for describing the data in the FAU file: 1-Roll stabilized; 2-Snippets; 4-Equiangle; 8-Equidistant; 16-Intermediate; 32-RESON Flex Mode; 64-Continuous Wave; 128-Frequency Modulated.
    FauHead.Frequency=fread(fId,1,'int16'); %757-758/S16/ The sonar frequency in KHz.
    FauHead.DatabaseId=fread(fId,1,'int64'); %759-766/S64/ An identifier for the source database. The Block Id in EIVA’s NaviEdit database.
    FauHead.Spare=fread(fId,10,'uint8'); %767-776/10xS8/ Currently unused.
end;
%===End Read Binary Optional Header
%===Begin NDtg Read
SeekDtgStart=ftell(fId);NDtg=(fSize-SeekDtgStart)./24;
switch FauHead.fName(end-2:end),
    case {'fau','FAU','fas','FAS'}, %.fas -- The 's' in the extension indicates that the location of the measurements is in stereographic coordinates.
        Head=struct('MessageNum',nan(1,NDtg),'UnixTime',nan(1,NDtg),'CentiSec',nan(1,NDtg),'GpsN',nan(1,NDtg),'GpsE',nan(1,NDtg),'BeamAngle',nan(1,NDtg),'Heave',nan(1,NDtg),'Roll',nan(1,NDtg),'Pitch',nan(1,NDtg),'Depth',nan(1,NDtg),'Amplitude',nan(1,NDtg),'Quality',nan(1,NDtg));
        for n=1:NDtg,
            Head.MessageNum(n)=n;
            Head.GpsN(n)=fread(fId,1,'int32'); %1-4/S32/ The northing coordinate, in centimeters.
            Head.GpsE(n)=fread(fId,1,'int32'); %5-8/S32/ The easting coordinate, in centimeters.
            Head.Depth(n)=fread(fId,1,'int32'); %9-12/S32/ The depth value, in centimeters
            Head.UnixTime(n)=fread(fId,1,'int32'); %13-16/S32/ The UNIX time, in seconds.
            Head.BeamAngle(n)=fread(fId,1,'int16'); %17-18/S16/ The beam angle, in 0.01 degrees. The angle is positive at starboard.
            Head.Heave(n)=fread(fId,1,'int8'); %19/S8/ The heave value, in 0.02 meters. The value is positive down.
            Head.Roll(n)=fread(fId,1,'int8'); %20/S8/ The roll value, in 0.1 degrees (0.2 for some equip). The angle is positive when the starboard side is down.
            Head.Quality(n)=fread(fId,1,'uint8'); %21/U8/ A value representing the quality of the depth measurement. Each bit in the value has a specific meaning: Bit0to3-quality indicators. Bit4to6-reserved for flagging. Bit7-Valid is 0, rejected is 1. // Bit0to3 for RESON echosounders EIVA: 00b-Not detected (neither amplitude nor phase); xx01b-amplitude detection; xx10b-phase detection; xx11b-combined amplitude and phase detection. x1xxb-passed Brightness Test; 1xxxb-passed Collinearity Test. // Bit4to6 Vise 14.3 implementation of the flagging/rejection: 1001b-rejected by angle (e.g., >60 degrees); 0010b-only flagged by MapSpikes; 1010b-rejected based on MapSpikes.
            Head.Amplitude(n)=fread(fId,1,'int8'); %22/S8/ The signal amplitude associated with the depth measurement. The unit of measure is unspecified.
            Head.Pitch(n)=fread(fId,1,'int8'); %23/S8/ The pitch value, in 0.1 degrees. The value is positive when the bow is up.
            Head.CentiSec(n)=fread(fId,1,'uint8'); %24/U8/ The number of centiseconds to be added to the sec field.
        end;
        Head.GpsN=Head.GpsN./100;Head.GpsE=Head.GpsE./100;Head.Depth=Head.Depth./100;Head.BeamAngle=Head.BeamAngle./0.01;Head.Heave=Head.Heave./0.02;Head.Roll=Head.Roll./0.1;Head.Pitch=Head.Pitch./0.1;
    case {'fag','FAQ','fal','FAL'}, %.fag /.fal  -- The 'g' in the extension indicates that the location of the measurements is in geographic coordinates. Similarly, the 'l' was for 'Latitude/Longitude'.
        Head=struct('MessageNum',nan(1,NDtg),'UnixTime',nan(1,NDtg),'CentiSec',nan(1,NDtg),'GpsLat',nan(1,NDtg),'GpsLon',nan(1,NDtg),'BeamAngle',nan(1,NDtg),'Heave',nan(1,NDtg),'Roll',nan(1,NDtg),'Pitch',nan(1,NDtg),'Depth',nan(1,NDtg),'Amplitude',nan(1,NDtg),'Quality',nan(1,NDtg));
        for n=1:NDtg,
            Head.MessageNum(n)=n;
            Head.GpsLat(n)=fread(fId,1,'int32'); %1-4/S32/ The latitude (dimention not described).
            Head.GpsLon(n)=fread(fId,1,'int32'); %5-8/S32/ The longitude (dimention not described).
            Head.Depth(n)=fread(fId,1,'int32'); %9-12/S32/ The depth value, in centimeters
            Head.UnixTime(n)=fread(fId,1,'int32'); %13-16/S32/ The UNIX time, in seconds.
            Head.BeamAngle(n)=fread(fId,1,'int16'); %17-18/S16/ The beam angle, in 0.01 degrees. The angle is positive at starboard.
            Head.Heave(n)=fread(fId,1,'int8'); %19/S8/ The heave value, in 0.02 meters. The value is positive down.
            Head.Roll(n)=fread(fId,1,'int8'); %20/S8/ The roll value, in 0.1 degrees (0.2 for some equip). The angle is positive when the starboard side is down.
            Head.Quality(n)=fread(fId,1,'uint8'); %21/U8/ A value representing the quality of the depth measurement. Each bit in the value has a specific meaning: Bit0to3-quality indicators. Bit4to6-reserved for flagging. Bit7-Valid is 0, rejected is 1. // Bit0to3 for RESON echosounders EIVA: 00b-Not detected (neither amplitude nor phase); xx01b-amplitude detection; xx10b-phase detection; xx11b-combined amplitude and phase detection. x1xxb-passed Brightness Test; 1xxxb-passed Collinearity Test. // Bit4to6 Vise 14.3 implementation of the flagging/rejection: 1001b-rejected by angle (e.g., >60 degrees); 0010b-only flagged by MapSpikes; 1010b-rejected based on MapSpikes.
            Head.Amplitude(n)=fread(fId,1,'int8'); %22/S8/ The signal amplitude associated with the depth measurement. The unit of measure is unspecified.
            Head.Pitch(n)=fread(fId,1,'int8'); %23/S8/ The pitch value, in 0.1 degrees. The value is positive when the bow is up.
            Head.CentiSec(n)=fread(fId,1,'uint8'); %24/U8/ The number of centiseconds to be added to the sec field.
        end;
        Head.GpsLat=Head.GpsLat./1e6;Head.GpsLon=Head.GpsLon./1e6;Head.Depth=Head.Depth./100;Head.BeamAngle=Head.BeamAngle./0.01;Head.Heave=Head.Heave./0.02;Head.Roll=Head.Roll./0.1;Head.Pitch=Head.Pitch./0.1;
    case {'fu2','FU2'}, %.fu2 -- (1) The implicit roll multiplier is 0.2 (rather than 0.1). (2) The 2-byte Beam Angle field is substituted by: 1-byte Beam Number (value stored as a char; thus its range is between -128 and 127); 1-byte Mean Error of the Depth Relative to its Neighborhood (value stored as an unsigned char; thus its range is  between 0 and 255).
        Head=struct('MessageNum',nan(1,NDtg),'UnixTime',nan(1,NDtg),'CentiSec',nan(1,NDtg),'GpsLat',nan(1,NDtg),'GpsLon',nan(1,NDtg),'BeamNumber',nan(1,NDtg),'Heave',nan(1,NDtg),'Roll',nan(1,NDtg),'Pitch',nan(1,NDtg),'Depth',nan(1,NDtg),'MeanError',nan(1,NDtg),'Amplitude',nan(1,NDtg),'Quality',nan(1,NDtg));
        for n=1:NDtg,
            Head.MessageNum(n)=n;
            Head.GpsN(n)=fread(fId,1,'int32'); %1-4/S32/ The northing coordinate, in centimeters.
            Head.GpsE(n)=fread(fId,1,'int32'); %5-8/S32/ The easting coordinate, in centimeters.
            Head.Depth(n)=fread(fId,1,'int32'); %9-12/S32/ The depth value, in centimeters
            Head.UnixTime(n)=fread(fId,1,'int32'); %13-16/S32/ The UNIX time, in seconds.
            Head.BeamNumber(n)=fread(fId,1,'int8'); %17/S8 Beam Number (value stored as a char; thus its range is between -128 and 127);
            Head.MeanError(n)=fread(fId,1,'uint8'); %18/U8 Mean Error of the Depth Relative to its doo Neighborhood (value stored as an unsigned char; thus its range is  between 0 and 255).
            Head.Heave(n)=fread(fId,1,'int8'); %19/S8/ The heave value, in 0.02 meters. The value is positive down.
            Head.Roll(n)=fread(fId,1,'int8'); %20/S8/ The roll value, in 0.1 degrees (0.2 for some equip). The angle is positive when the starboard side is down.
            Head.Quality(n)=fread(fId,1,'uint8'); %21/U8/ A value representing the quality of the depth measurement. Each bit in the value has a specific meaning: Bit0to3-quality indicators. Bit4to6-reserved for flagging. Bit7-Valid is 0, rejected is 1. // Bit0to3 for RESON echosounders EIVA: 00b-Not detected (neither amplitude nor phase); xx01b-amplitude detection; xx10b-phase detection; xx11b-combined amplitude and phase detection. x1xxb-passed Brightness Test; 1xxxb-passed Collinearity Test. // Bit4to6 Vise 14.3 implementation of the flagging/rejection: 1001b-rejected by angle (e.g., >60 degrees); 0010b-only flagged by MapSpikes; 1010b-rejected based on MapSpikes.
            Head.Amplitude(n)=fread(fId,1,'int8'); %22/S8/ The signal amplitude associated with the depth measurement. The unit of measure is unspecified.
            Head.Pitch(n)=fread(fId,1,'int8'); %23/S8/ The pitch value, in 0.1 degrees. The value is positive when the bow is up.
            Head.CentiSec(n)=fread(fId,1,'uint8'); %24/U8/ The number of centiseconds to be added to the sec field.
        end;
        Head.GpsN=Head.GpsN./100;Head.GpsE=Head.GpsE./100;Head.Depth=Head.Depth./100;Head.MeanError=Head.MeanError./100;Head.Heave=Head.Heave./0.02;Head.Roll=Head.Roll./0.2;Head.Pitch=Head.Pitch./0.1;
end;
fclose(fId);
%===End NDtg Read
if ~isempty(FauHead.BeamNum),
    tmp=NDtg./FauHead.BeamNum;
    if isfield(Head,'GpsN'), Head.GpsN=reshape(Head.GpsN,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'GpsE'), Head.GpsE=reshape(Head.GpsE,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'GpsLat'), Head.GpsLat=reshape(Head.GpsLat,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'GpsLon'), Head.GpsLon=reshape(Head.GpsLon,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'Depth'), Head.Depth=reshape(Head.Depth,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'UnixTime'), Head.UnixTime=reshape(Head.UnixTime,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'BeamAngle'), Head.BeamAngle=reshape(Head.BeamAngle,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'BeamNumber'), Head.BeamNumber=reshape(Head.BeamNumber,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'MeanError'), Head.MeanError=reshape(Head.MeanError,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'Heave'), Head.Heave=reshape(Head.Heave,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'Roll'), Head.Roll=reshape(Head.Roll,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'Quality'), Head.Quality=reshape(Head.Quality,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'Amplitude'), Head.Amplitude=reshape(Head.Amplitude,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'Pitch'), Head.Pitch=reshape(Head.Pitch,[FauHead.BeamNum,tmp]);end;
    if isfield(Head,'CentiSec'), Head.CentiSec=reshape(Head.CentiSec,[FauHead.BeamNum,tmp]);end;
end;
%tmp=diff(Head.BeamAngle);[N,Edges]=histcounts(tmp,50);
%==End File reading

%mail@ge0mlib.com 17/08/2023