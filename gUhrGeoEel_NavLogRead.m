function out=gUhrGeoEel_NavLogRead(fName,key)
%Read Navigation log formed GeoEel (Geometrics) station software. The station's input message from navigation is a string similar $GPGGA (not in NMEA spec.)
%function out=gUhrGeoEel_NavLogRead(fName,key), where
%fName- name of file with Navigation log data from GeoEel;
%key- the key for navigation message format;
%out- output structure, depends from key;
%========= if key==1, then:
%1) out fields are: fName,CompTime,GpsTime,GpsLat,GpsLon,GpsFixQuality,GpsSatNum,GpsHorizDilution,EchoDepth,FIX,SHOTID.
%2) Input file format example:
%File: 101, $GPGGA,22243766,1540.2444444,N,10926.7777777,E,2,16,0.70,216.6,102, 22:24:56.15
%========= if key==2, then:
%1) out-fields are: fName,CompTime,GpsDay,GpsTime,GpsE,GpsN,Head,FIX,SHOTID.
%2) Input file format example:
%File: 1000, $GPGGA,20190307,120310.58,1000,666396.45,5803185.78,28.2, 23:03:22.49
%=========
%Example: out=gUhrGeoEel_NavLogRead('c:\temp\Day1\TEST.Nav.txt',2);

switch key,
    case 1,
        [fId, mes]=fopen(fName,'r');if ~isempty(mes), error(mes);end;
        C=textscan(fId,'File:%f, $GPGGA,%f,%f,%c,%f,%c,%f,%f,%f,%f,%f, %f:%f:%f\r\n','Delimiter','', 'MultipleDelimsAsOne',1);fclose(fId);
        GpsTime=gNavTime2Time('HMS2Sd',C{2}./100);CompTime=C{12}.*3600+C{13}.*60+C{14};
        GpsLat=(fix(C{3}'./100)+mod(C{3}',100)./60);GpsLat(C{4}'=='S')=-GpsLat(C{6}'=='S');
        GpsLon=(fix(C{5}'./100)+mod(C{5}',100)./60);GpsLon(C{6}'=='W')=-GpsLon(C{8}'=='W');
        out=struct('fName',fName,'CompTime',CompTime','GpsTime',GpsTime','GpsLat',GpsLat,'GpsLon',GpsLon,'GpsFixQuality',C{7}','GpsSatNum',C{8}','GpsHorizDilution',C{9}','EchoDepth',C{10}','Fix',C{11}','ShotID',C{1}');
    case 2,
        [fId, mes]=fopen(fName,'r');if ~isempty(mes), error(mes);end;
        C=textscan(fId,'File:%f, $GPGGA,%f,%f,%f,%f,%f,%f, %f:%f:%f\r\n','Delimiter','', 'MultipleDelimsAsOne',1);
        fclose(fId);
        GpsDay=gNavTime2Time('YMD2Dx',C{2});GpsTime=gNavTime2Time('HMS2Sd',C{3});CompTime=C{8}.*3600+C{9}.*60+C{10};
        out=struct('fName',fName,'CompTime',CompTime','GpsDay',GpsDay','GpsTime',GpsTime','GpsE',C{5}','GpsN',C{6}','Head',C{7}','Fix',C{4}','ShotID',C{1}');
    otherwise, error('Unexpected format key');
end;

%mail@ge0mlib.com 27/10/2020