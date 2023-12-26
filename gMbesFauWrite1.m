function gFauWrite(fNameNew,FauHead,Head)
%Write FAU variables [FauHead,Head] to file.
%function function gFauWrite(fName,FauHead,Head), where
%fNameNew - the target file name;
%FauHead - Header structure;
%Head - Header structure, included Datagram body.
%Remarks:
%1) The FauHead data-block in file is optional;
%2) There are following sub-formats: .fau-projected coordinates; .fas-stereographic coordinates; .fag/.fal-geographic coordinates; .fu2-roll multiplier is 0.2 and fields [BeamNumber, MeanError] instead of BeamAngle.
%3) Roll value, in 0.1 degrees, but can be 0.2 for some equipment types.
%Example: gFauWrite('c:\temp\2.fau',FauHead,Head);

%==Begin File writing
if ~strcmp(FauHead.fName(end-2:end),fNameNew(end-2:end)),warning('gFauWrite: the file extension was changed to original file extension.');fNameNew(end-2:end)=FauHead.fName(end-2:end);end;
[fId, mes]=fopen(fNameNew,'w',FauHead.Endian);if ~isempty(mes), error(['gFauWrite: ' mes]);end;
%===Begin Write Binary Optional Header
if FauHead.FauHeadFl,
    %U8 Unsigned Char; S8 Signed Char; U16 Unsigned Short; S16 Signed short; U32 Unsigned Integer; S32 Signed Integer; U64 Unsigned Long; S64 Signed Long; F32 Float; F64 Double
    fwrite(fId,FauHead.Identity,'uint8'); %1-8/8xS8/ Bytes used to detect the endianness adopted by the file: Little Endian: 'fau__uaf', Big Endian: '_uaffau_'
    fwrite(fId,FauHead.Minilab,'uint8'); %9-28/20xS8/ A 'minilabel' containing the geospatial reference system in use: #[Projection]N[Horizontal Datum]. The first character is always '#'. Despite the format name, it is also possible to store data in projection different from UTM. For example: mrc  Mercator npstg  Polar stereographic estg  Equatorial Stereographic itm  Gauss Krueger upsn  Universal Polar Stereographic North upss  Universal Polar Stereographic South dlmb  Lamberts Conical Two lmb  Lamberts Conical One sbf  System SBF (Denmark) dks  System DKS (Denmark/Sweden) The eighth character sets the adopted Z-convention. The 'N' indicates “normal heights” (depths) with positive down. Example of mini-label: '#utm22nNwgs84' identifies: utm22n  UTM projection, Zone 22 North. N  Depths (positive Z is down) wgs84  WGS84 datum.
    fwrite(fId,FauHead.Version,'uint8'); %29-60/32xS8/ The version of the program used for converting to FAU format.
    fwrite(fId,FauHead.ConversionTime,'int32'); %61-64/S32/ The UNIX time in seconds when the file was generated.
    fwrite(fId,FauHead.Length,'int32'); %65-68/S32/ The size of the header in bytes. The value is always 768 (3x 256 bytes, and 32x 24 bytes - the size of the Body Datagram).
    fwrite(fId,FauHead.PingNumber,'uint64'); %69-76/U64/ The ping number of the first ping converted into a FAU file. If not used/applicable, use 0.
    fwrite(fId,FauHead.Source,'int32'); %77-80/S32/ The source of the depth measurements: 1-Database; 2-SBD; 3-SEMI; 4-XYZ.
    fwrite(fId,FauHead.Kind,'int32'); %81-84/S32/ The type of depth measurements: 1-Multibeam, with DGPS navigation; 2-Multibeam, with RTK navigation; 4-Singlebeam; 8-Thinned; 16-Not the primary detection layer.
    fwrite(fId,FauHead.Tide,'uint32'); %85-88/S32/ A collection of bit fields for describing the approach adopted for vertical reduction: 1-Data is corrected for tide; 2-Delayed heave was applied; 4-Cross-section offset was applied.
    fwrite(fId,FauHead.RollOffset,'float32'); %89-92/F32/ Calibration value for static roll in decimal degrees. If not used/applicable, use 0.
    fwrite(fId,FauHead.PitchOffset,'float32'); %93-96/F32/ Calibration value for static pitch in decimal degrees. If not used/applicable, use 0.
    fwrite(fId,FauHead.HeadingOffset,'float32'); %97-100/F32/ Calibration value for static heading in decimal degrees. If not used/applicable, use 0.
    fwrite(fId,FauHead.TimeOffset,'int32'); %101-104/S32/ Calibration value for time in milliseconds. If not used/applicable, use 0.
    fwrite(fId,FauHead.EditedSensors,'uint32'); %105-108/S32/ A collection of bit fields for describing the sensors with edited values: 1-Roll; 2-Pitch; 4-Gyro; 8-Heave.
    fwrite(fId,FauHead.SvSensors,'uint32'); %109-112/S32/ A collection of bit fields for describing the type of sound speed sensor: 1-Transducer sensor; 2-Sound speed profiler; 4-Scanfish equipment; 8-Transducer sensor not working.
    fwrite(fId,FauHead.SvNname,'uint8'); %113-624/512xS8/ The sound speed filename used for the stored data, with extension. If not used/applicable, the field is left empty.
    fwrite(fId,FauHead.NrOfBeams,'int32'); %625-628/S32/ The number of beams for each ping/swath. It is mandatory for kind=1 and kind=2; otherwise, use 0.
    fwrite(fId,FauHead.NrOfPings,'int32'); %629-632/S32/ The total number of pings/swaths in the file. If not used/applicable (e.g., unstructured FAU), use 0.
    fwrite(fId,FauHead.BbMaxN,'int32'); %633-636/S32/ The maximum northing coordinate among the valid depth measurements, in centimeters.
    fwrite(fId,FauHead.BbMinN,'int32'); %637-640/S32/ The minimum northing coordinate among the valid depth measurements, in centimeters.
    fwrite(fId,FauHead.BbMaxE,'int32'); %641-644/S32/ The maximum easting coordinate among the valid depth measurements, in centimeters.
    fwrite(fId,FauHead.BbMinE,'int32'); %645-648/S32/ The minimum easting coordinate among the valid depth measurements, in centimeters.
    fwrite(fId,FauHead.BbMaxH,'int32'); %649-652/S32/ The maximum depth value among the valid depth measurements, in centimeters.
    fwrite(fId,FauHead.BbMinH,'int32'); %653-656/S32/ The minimum depth value among the valid depth measurements, in centimeters.
    fwrite(fId,FauHead.TrackHeading,'float32'); %657-660/F32/ The average heading of the trackline, in decimal degrees. If not used/applicable, use 0.0.
    fwrite(fId,FauHead.Speed,'float32'); %661-664/F32/ The average speed of the trackline, in meter per second. If not used/applicable, use 0.0.
    fwrite(fId,FauHead.Roll95,'float32'); %665-668/F32/ The interval in decimal degrees containing the 95% of the roll values. If not used/applicable, use 0.0.
    fwrite(fId,FauHead.Pitch95,'float32'); %669-672/F32/ The interval in decimal degrees containing the 95% of the pitch values. If not used/applicable, use 0.0.
    fwrite(fId,FauHead.Heave95,'int32'); %673-676/S32/ The interval in centimeters containing the 95% of the heave values. If not used/applicable, use 0.
    fwrite(fId,FauHead.MaxTimeGap,'int32'); %677-680/S32/ This value and ping_nr_max_time_gap provides information about the correct functioning of the multibeam system: does it deliver the requested number of pings per second? The maximum time gap in stored in centiseconds. If not used/applicable, use 0.
    fwrite(fId,FauHead.PingNrMaxTimeGap,'int32'); %681-684/S32/ This value and max_time_gap provides information about the correct functioning of the multibeam system: does it deliver the requested number of pings per second? If not used/applicable, use 0.
    fwrite(fId,FauHead.PingNrPosJump,'int32'); %685-688/S32/ Number of jumps between individual pings due to, for example, unstable positioning system. If not used/applicable, use 0.
    fwrite(fId,FauHead.MaxNonLinearity,'int32'); %689-692/S32/ The largest numerical difference (counted in number of swaths) between any swath in the file and the idealized swaths in the bounding box. If not used/applicable, use 0.
    fwrite(fId,FauHead.Major,'uint8'); %693/S8/ The major version number for Vise/MapSpikes.
    fwrite(fId,FauHead.Minor,'uint8'); %694/S8 The minor version number for Vise/MapSpikes.
    fwrite(fId,FauHead.AutoFlags,'uint8'); %695/S8/ Field indicating whether an automatic flagging was used. 0-No automatic flagging. 1-An automatic flagging was used.
    fwrite(fId,FauHead.RotRectValid,'uint8'); %696/S8/ A collection of bit fields for describing the validity of the rotated bounding box: 1-Valid rotated bounding box; 2-Maximum non-linearity valid; 4-Valid transducer depth.
    fwrite(fId,FauHead.BbTiltX,'float64'); %697-704/F64/ The x-coordinate of the rotated bounding box, in centimeters.
    fwrite(fId,FauHead.BbTiltY,'float64'); %705-712/F64/ The y-coordinate of the rotated bounding box, in centimeters.
    fwrite(fId,FauHead.BbTiltW,'float64'); %713-720/F64/ The width of the rotated bounding box, in centimeters.
    fwrite(fId,FauHead.BbTiltH,'float64'); %721-728/F64/ The height of the rotated bounding box, in centimeters.
    fwrite(fId,FauHead.BbTiltAng,'float64'); %729-736/F64/ The rotation angle of the rotated bounding box, in decimal degrees.
    fwrite(fId,FauHead.TransducerDepth,'int32'); %737-740/S32/ The depth of the transducer, in centimeters. If not used/applicable, use 0.
    fwrite(fId,FauHead.TransmitBeamWidth,'float32'); %741-744/F32/ Along-track TX beam width, in decimal degrees. If not used/applicable, use 0.0.
    fwrite(fId,FauHead.SwathAngle,'float32'); %745-748/F32/ The aperture of the swath, in decimal degrees. If not used/applicable, use 0.
    fwrite(fId,FauHead.Normalization,'int32'); %749-752/S32/ The UNIX time in seconds of the last performed channel normalization. A feature available with RESON systems for correcting the output of each analogue receiver channel for minor variations in amplitude and phase.
    fwrite(fId,FauHead.BitField,'uint32'); %753-756/S32/ A collection of bit fields for describing the data in the FAU file: 1-Roll stabilized; 2-Snippets; 4-Equiangle; 8-Equidistant; 16-Intermediate; 32-RESON Flex Mode; 64-Continuous Wave; 128-Frequency Modulated.
    fwrite(fId,FauHead.Frequency,'int16'); %757-758/S16/ The sonar frequency in KHz.
    fwrite(fId,FauHead.DatabaseId,'int64'); %759-766/S64/ An identifier for the source database. The Block Id in EIVA’s NaviEdit database.
    fwrite(fId,FauHead.Spare,'uint8'); %767-776/10xS8/ Currently unused.
end;
%===End Write Binary Optional Header
%===Begin NDtg Read
NDtg=numel(Head.MessageNum);
switch fNameNew(end-2:end),
    case {'fau','FAU','fas','FAS'}, %.fas -- The 's' in the extension indicates that the location of the measurements is in stereographic coordinates.
        Head.GpsN=Head.GpsN.*100;Head.GpsE=Head.GpsE.*100;Head.Depth=Head.Depth.*100;Head.BeamAngle=Head.BeamAngle.*0.01;Head.Heave=Head.Heave.*0.02;Head.Roll=Head.Roll.*0.1;Head.Pitch=Head.Pitch.*0.1;
        for n=1:NDtg,
            fwrite(fId,Head.GpsN(n),'int32'); %1-4/S32/ The northing coordinate, in centimeters.
            fwrite(fId,Head.GpsE(n),'int32'); %5-8/S32/ The easting coordinate, in centimeters.
            fwrite(fId,Head.Depth(n),'int32'); %9-12/S32/ The depth value, in centimeters
            fwrite(fId,Head.UnixTime(n),'int32'); %13-16/S32/ The UNIX time, in seconds.
            fwrite(fId,Head.BeamAngle(n),'int16'); %17-18/S16/ The beam angle, in 0.01 degrees. The angle is positive at starboard.
            fwrite(fId,Head.Heave(n),'int8'); %19/S8/ The heave value, in 0.02 meters. The value is positive down.
            fwrite(fId,Head.Roll(n),'int8'); %20/S8/ The roll value, in 0.1 degrees (0.2 for some equip). The angle is positive when the starboard side is down.
            fwrite(fId,Head.Quality(n),'uint8'); %21/U8/ A value representing the quality of the depth measurement. Each bit in the value has a specific meaning: Bit0to3-quality indicators. Bit4to6-reserved for flagging. Bit7-Valid is 0, rejected is 1. // Bit0to3 for RESON echosounders EIVA: 00b-Not detected (neither amplitude nor phase); xx01b-amplitude detection; xx10b-phase detection; xx11b-combined amplitude and phase detection. x1xxb-passed Brightness Test; 1xxxb-passed Collinearity Test. // Bit4to6 Vise 14.3 implementation of the flagging/rejection: 1001b-rejected by angle (e.g., >60 degrees); 0010b-only flagged by MapSpikes; 1010b-rejected based on MapSpikes.
            fwrite(fId,Head.Amplitude(n),'int8'); %22/S8/ The signal amplitude associated with the depth measurement. The unit of measure is unspecified.
            fwrite(fId,Head.Pitch(n),'int8'); %23/S8/ The pitch value, in 0.1 degrees. The value is positive when the bow is up.
            fwrite(fId,Head.CentiSec(n),'uint8'); %24/U8/ The number of centiseconds to be added to the sec field.
        end;
    case {'fag','FAQ','fal','FAL'}, %.fag /.fal  -- The 'g' in the extension indicates that the location of the measurements is in geographic coordinates. Similarly, the 'l' was for 'Latitude/Longitude'.
        Head.GpsLat=Head.GpsLat.*1e6;Head.GpsLon=Head.GpsLon.*1e6;Head.Depth=Head.Depth.*100;Head.BeamAngle=Head.BeamAngle.*0.01;Head.Heave=Head.Heave.*0.02;Head.Roll=Head.Roll.*0.1;Head.Pitch=Head.Pitch.*0.1;
        for n=1:NDtg,
            fwrite(fId,Head.GpsLat(n),'int32'); %1-4/S32/ The latitude (dimention not described).
            fwrite(fId,Head.GpsLon(n),'int32'); %5-8/S32/ The longitude (dimention not described).
            fwrite(fId,Head.Depth(n),'int32'); %9-12/S32/ The depth value, in centimeters
            fwrite(fId,Head.UnixTime(n),'int32'); %13-16/S32/ The UNIX time, in seconds.
            fwrite(fId,Head.BeamAngle(n),'int16'); %17-18/S16/ The beam angle, in 0.01 degrees. The angle is positive at starboard.
            fwrite(fId,Head.Heave(n),'int8'); %19/S8/ The heave value, in 0.02 meters. The value is positive down.
            fwrite(fId,Head.Roll(n),'int8'); %20/S8/ The roll value, in 0.1 degrees (0.2 for some equip). The angle is positive when the starboard side is down.
            fwrite(fId,Head.Quality(n),'uint8'); %21/U8/ A value representing the quality of the depth measurement. Each bit in the value has a specific meaning: Bit0to3-quality indicators. Bit4to6-reserved for flagging. Bit7-Valid is 0, rejected is 1. // Bit0to3 for RESON echosounders EIVA: 00b-Not detected (neither amplitude nor phase); xx01b-amplitude detection; xx10b-phase detection; xx11b-combined amplitude and phase detection. x1xxb-passed Brightness Test; 1xxxb-passed Collinearity Test. // Bit4to6 Vise 14.3 implementation of the flagging/rejection: 1001b-rejected by angle (e.g., >60 degrees); 0010b-only flagged by MapSpikes; 1010b-rejected based on MapSpikes.
            fwrite(fId,Head.Amplitude(n),'int8'); %22/S8/ The signal amplitude associated with the depth measurement. The unit of measure is unspecified.
            fwrite(fId,Head.Pitch(n),'int8'); %23/S8/ The pitch value, in 0.1 degrees. The value is positive when the bow is up.
            fwrite(fId,Head.CentiSec(n),'uint8'); %24/U8/ The number of centiseconds to be added to the sec field.
        end;
    case {'fu2','FU2'}, %.fu2 -- (1) The implicit roll multiplier is 0.2 (rather than 0.1). (2) The 2-byte Beam Angle field is substituted by: 1-byte Beam Number (value stored as a char; thus its range is between -128 and 127); 1-byte Mean Error of the Depth Relative to its Neighborhood (value stored as an unsigned char; thus its range is  between 0 and 255).
        Head.GpsN=Head.GpsN.*100;Head.GpsE=Head.GpsE.*100;Head.Depth=Head.Depth.*100;Head.MeanError=Head.MeanError.*100;Head.Heave=Head.Heave.*0.02;Head.Roll=Head.Roll.*0.2;Head.Pitch=Head.Pitch.*0.1;
        for n=1:NDtg,
            fwrite(fId,Head.GpsN(n),'int32'); %1-4/S32/ The northing coordinate, in centimeters.
            fwrite(fId,Head.GpsE(n),'int32'); %5-8/S32/ The easting coordinate, in centimeters.
            fwrite(fId,Head.Depth(n),'int32'); %9-12/S32/ The depth value, in centimeters
            fwrite(fId,Head.UnixTime(n),'int32'); %13-16/S32/ The UNIX time, in seconds.
            fwrite(fId,Head.BeamNumber(n),'int8'); %17/S8 Beam Number (value stored as a char; thus its range is between -128 and 127);
            fwrite(fId,Head.MeanError(n),'uint8'); %18/U8 Mean Error of the Depth Relative to its doo Neighborhood (value stored as an unsigned char; thus its range is  between 0 and 255).
            fwrite(fId,Head.Heave(n),'int8'); %19/S8/ The heave value, in 0.02 meters. The value is positive down.
            fwrite(fId,Head.Roll(n),'int8'); %20/S8/ The roll value, in 0.1 degrees (0.2 for some equip). The angle is positive when the starboard side is down.
            fwrite(fId,Head.Quality(n),'uint8'); %21/U8/ A value representing the quality of the depth measurement. Each bit in the value has a specific meaning: Bit0to3-quality indicators. Bit4to6-reserved for flagging. Bit7-Valid is 0, rejected is 1. // Bit0to3 for RESON echosounders EIVA: 00b-Not detected (neither amplitude nor phase); xx01b-amplitude detection; xx10b-phase detection; xx11b-combined amplitude and phase detection. x1xxb-passed Brightness Test; 1xxxb-passed Collinearity Test. // Bit4to6 Vise 14.3 implementation of the flagging/rejection: 1001b-rejected by angle (e.g., >60 degrees); 0010b-only flagged by MapSpikes; 1010b-rejected based on MapSpikes.
            fwrite(fId,Head.Amplitude(n),'int8'); %22/S8/ The signal amplitude associated with the depth measurement. The unit of measure is unspecified.
            fwrite(fId,Head.Pitch(n),'int8'); %23/S8/ The pitch value, in 0.1 degrees. The value is positive when the bow is up.
            fwrite(fId,Head.CentiSec(n),'uint8'); %24/U8/ The number of centiseconds to be added to the sec field.
        end;
end;
fclose(fId);
%===End NDtg Write
%==End File writing

%mail@ge0mlib.com 17/08/2023