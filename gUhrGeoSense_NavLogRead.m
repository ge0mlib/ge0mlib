function out=gUhrGeoSense_NavLogRead(fName,key,varargin)
%Read Navigation log was created Multi-Trace Data Acquisition software (GEO Marine Survey Systems) for MultiTrace station. The station's input message from navigation is $CUSTOM
%function out=gUhrGeoSense_NavLogRead(fName,key), where
%fName- name of file with Navigation log data from MultiTrace station software (RAW_LOG-Input 0.log);
%key- the key for navigation message format;
%varargin - divider for GpsTime;
%out- output structure, depends from key;
%========= if key==1, then:
%1) out fields are: fName,GpsDay,GpsTime,FIX,GpsE,GpsN,Heading,Depth.
%2) Input file format example:
%$CUSTOM,20170906,221035.94,453,513681.21,8006048.81,50.16
%$CUSTOM,20170906,221037.65,454,513684.02,8006051.09,49.86
%where 20170906- date by Gps; 221037.65- time by Gps; 454- fix number; 513684.02- easting; 8006051.09- nording; 50.16- heading.
%=========
%Example: out=gUhrGeoSense_NavLogRead('c:\temp\Day1\RAW_LOG-Input 0.log',1);

switch key,
    case 1,
        [fId, mes]=fopen(fName,'r');if ~isempty(mes), error(mes);end;
        C=textscan(fId,'$CUSTOM,%f,%f,%f,%f,%f\r\n','Delimiter','', 'MultipleDelimsAsOne',1);fclose(fId);
        if ~isempty(varargin), C{2}=C{2}./varargin{1};end;
        GpsDay=gNavTime2Time('YMD2Dx',C{1});GpsTime=gNavTime2Time('HMS2Sd',C{2});
        out=struct('fName',fName,'GpsDay',GpsDay','GpsTime',GpsTime','FIX',C{3}','GpsE',C{4}','GpsN',C{5}','Heading',C{6}');
    otherwise, error('Unexpected format key');
end;

%mail@ge0mlib.com 23/10/2017