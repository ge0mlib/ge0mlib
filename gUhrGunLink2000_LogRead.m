function out=gUhrGunLink2000_LogRead(fName,key)
%Read Gun-log from GunLink2000 station software.
%function out=gUhrGunLink2000_LogRead(fName,key), where
%fName- name of file with GunLink2000 log data;
%key- the key for guns cluster format;
%out- output structure, depends from key;
%========= if key==1,then:
%1) The guns cluster includes: 4_guns + AtmReff + DepthSensor + LinePressureSensor
%2) out fields are: fName,LineName,Title,GpsDay,GpsTime,FIX,G1Err,G2Err,G3Err,G4Err,AtmReff,GunDepth,GunPress,GunVol
%3) Input file format example:
%Line: 0005_C_L_HR_18
%SHOTPOINT AIM_POINT_TIME String_1-Cluster_1-Gun_1 String_1-Cluster_1-Gun_2 String_1-Cluster_1-Gun_3 String_1-Cluster_1-Gun_4  _Atmospheric_Ref_ String_1_DT_1_ _Main_Manifold_ VOLUME
%000001001 2019-06-09_19:02:04.182081 7.0   0.0   0.0   2.0    1010.00   3.59   2180    160
%000001002 2019-06-09_19:02:06.996750 1.0   0.0   1.0   1.0    1009.50   3.51   2156    160
%=========
%Example: out=gUhrGunLink2000_LogRead('d:\001_RawData\0005_C_L_HR_18_GunLog.txt',1);

switch key,
    case 1,
        [fId, mes]=fopen(fName,'r');if ~isempty(mes), error(['Error gFGeoEelNavLogRead: ' mes]);end;
        LineName=textscan(fId,'Line: %s\n',1);
        Title=textscan(fId,'%s\n',1,'Delimiter','');
        C=textscan(fId,'%f %f-%f-%f_%f:%f:%f %f %f %f %f %f %f %f %f\n','Delimiter',' ','MultipleDelimsAsOne',1);
        fclose(fId);
        GpsTime=gNavTime2Time('HMS32Sd',C{5},C{6},C{7});
        GpsDay=datenum(C{2},C{3},C{4})';
        out=struct('fName',fName,'LineName',LineName{1},'Title',Title{1},'GpsDay',GpsDay','GpsTime',GpsTime,'FIX',C{1}',...
            'G1Err',C{8}'./10,'G2Err',C{9}'./10,'G3Err',C{10}'./10,'G4Err',C{11}'./10,'AtmReff',C{12}','GunDepth',C{13}','GunPress',C{14}','GunVol',C{15}');
    otherwise, error('gUhrGeoEel_NavLogRea unexpected format key');
end;

%mail@ge0mlib.com 15/07/2019