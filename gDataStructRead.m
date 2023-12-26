function [Title,Data]=gDataStructRead(fName,sTitle,tForm,tDelim,tEOL)
%Read data from text file with first Title strings and several data columns to struct
%function [Title,Data]=gDataStructRead(fName,sTitle,tForm,tDelim,tEOL), where
%fName- reading file name;
%sTitle- string with struct-fields-names; if empty, then fields-names get from Title (first string of file);
%tForm- string described data format (not includes delimiters into the text);
%tDelim- data text Delimiters (for example: ' ' or ',' or '\t');
%tEOL- data text End of Line (commonly '\r\n' or '\r' or '\n');
%Title- first string of file;
%Data- output data structure.
%Example
%File >>
%Line,Date,DB_number,HEADING_Frame,Line_Name,MAG_BACKGROUND_TARGETS,MAG_RESIDUAL_TARGETS_FINAL,QUALITY_MAG,TF_MAG,Time,X_CALC_MAG,X_RAW_Frame,Y_CALC_MAG,Y_RAW_Frame,Z_CALC_MAG
%L53.1,2024/07/21,0053_N05 - 0001.db,46.95,N05_CL,,,1409,49843.76,10:09:37,676.024929637,679.24,634.87051101,632.69,4.18015053691459
%L53.1,2024/07/21,0053_N05 - 0001.db,46.98,N05_CL,49843.7431946261,-0.010435837910336,1409,49843.73,10:09:37,676.175793843,679.39,635.0025139,632.82,4.15143443231579
%Command >>
%[Title,Data]=gDataStructRead('d:\ex.txt','Line,YYYY,MM,DD,DB_number,HEADING_Frame,Line_Name,MAG_BACKGROUND_TARGETS,MAG_RESIDUAL_TARGETS_FINAL,QUALITY_MAG,TF_MAG,hh,mm,ss,X_CALC_MAG,X_RAW_Frame,Y_CALC_MAG,Y_RAW_Frame,Z_CALC_MAG','%s%f/%f/%f%s%f%s%f%f%f%f%f:%f:%f%f%f%f%f%f',',','\r\n');
%[Title,Data]=gDataStructRead('d:\ex.txt','LineInd,YYYY,MM,DD,DB_name,Head,LinePlanName,Tback,Tres,Tsig,T,hh,mm,ss,GpsE,GpsE_Frame,GpsN,GpsN_Frame,Alt','%s%f/%f/%f%s%f%s%f%f%f%f%f:%f:%f%f%f%f%f%f',',','\r\n');
%File volume: 1.041Gb; Elapsed time is 23.502049 seconds.

[fId, mes]=fopen(fName,'r');
if ~isempty(mes), error(['Error gDataStructRead:' mes]);end;
Title=fgetl(fId);if isempty(sTitle),sTitle=Title;end;C0=textscan(sTitle,'%s','Delimiter',',', 'MultipleDelimsAsOne',0);C0=C0{1}';
C=textscan(fId,tForm,'Delimiter',tDelim,'MultipleDelimsAsOne',0,'EndOfLine',tEOL);for n=1:numel(C);C{n}=C{n}';end;
Data=cell2struct(C,C0,2);
fclose(fId);

%mail@ge0mlib.com 12/10/2023