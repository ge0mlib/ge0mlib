function [Title,Data]=gDataTxtRead(fName,nTitle,nColumn,tForm,tDelim,tEOL)
%Read data from text file with several Title strings and several formatted numeric columns.
%function [Title,Data]=gDataTxtRead(fName,nTitle,nColon,tForm,tDelimiters,tEOL), where
%fName- reading file name;
%nTitle- number title strings (can be zero);
%nColumn- number data columns;
%tForm- data format (commonly '%f'); warning: not use '%s', only '%9c' or the same;
%tDelim- data text Delimiters (for example: ' ' or ',' or '\t');
%tEOL- data text End of Line (commonly '\r\n' or '\r' or '\n');
%Title- output cell array with Title strings;
%Data- output data matrix.
%Example:
%[Title,Data]=gDataTxtRead('c:\05_Prog\gSpi\Sample\PTS\123.txt','%f',9,3,'\t','\r\n');
%[Title,Data]=gDataTxtRead('c:\05_Prog\gSpi\Sample\PTS\NEWGRID1.pts','%f',0,3,' ','\r\n');

[fId, mes]=fopen(fName,'r');
if ~isempty(mes), error(['Error gDataTxtRead:' mes]);end;
if ~isempty(nTitle),
    Title=repmat({''},1,nTitle);for n=1:nTitle, Title{n}=fgetl(fId);end;
else
    Title={''};
end;
C=textscan(fId,tForm,'Delimiter',tDelim, 'MultipleDelimsAsOne',0,'EndOfLine',tEOL);
Data=reshape(C{1},nColumn,[])';
fclose(fId);

%mail@ge0mlib.com 25/01/2021