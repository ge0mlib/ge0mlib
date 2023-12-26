function LLog=gNavLLogRead(fName)
%Read LineLog for survey lines with tab-delimiter.
%function LLog=gNavLLogRead(fName), where
%fName- reading file name;
%LLog- structure with log records.
%File row example: 2019/09/01	0085_CR_1_3(05)	11:47	12:32	29	1
%File Format: Date LineName TimeStart TimeEnd Bearing LineNumber
%Example: LLog=gNavLLogRead('c:\temp\log.txt');

[fId,mes]=fopen(fName,'r');if ~isempty(mes), error([mes '-- cannot open LineLog file']);end;
C=textscan(fId,'%f/%f/%f %s %f:%f %f:%f %f %f\r\n','Delimiter',char(9),'MultipleDelimsAsOne',0);
fclose(fId);
tmp1=(C{5}.*3600+C{6})>(C{7}.*3600+C{8});tmp2=datenum(C{1},C{2},C{3});tmp2(tmp1)=tmp2(tmp1)+1;tmp3=datevec(tmp2);
LLog=struct('YMDHM_Begin',[C{1} C{2} C{3} C{5} C{6}]','YMDHM_End',[tmp3(:,1:3) C{7} C{8}]','Bearing',C{9}','Number',C{10}');LLog.Name=C{4}';

%mail@ge0mlib.com 30/09/2019