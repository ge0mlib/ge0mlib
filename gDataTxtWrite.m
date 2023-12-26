function gDataTxtWrite(Title,Data,fName,tForm,tDelim,tEOL)
%Write data to text file with several Title strings and several formatted data columns.
%function gDataTxtWrite(Title,Data,fName,tForm,tDelimiters,tEOL)
%fName- writing file name;
%Title- cell array with Title strings;
%Data- data matrix.
%tForm- data format (commonly '%f'); warning: not use '%s', only '%9c' or the same;
%tDelim- data text Delimiters (for example: ' ' or ',' or '\t');
%tEOL - data text End of Line (commonly '\r\n' or '\r' or '\n');
%Example:
%gDataTxtWrite(Title,Data,'c:\05_Prog\gSpi\Sample\PTS\123z.txt','%d','\t','\r\n');
%gDataTxtWrite(Title,Data,'c:\05_Prog\gSpi\Sample\PTS\NEWGRID1z.pts','%1.3f',' ','\r\n');

[fId,mes]=fopen(fName,'w');
if ~isempty(mes), error(['Error gDataTxtWrite:' mes]);end;
if ~isempty(Title), for n=1:size(Title,2), fprintf(fId,['%s' tEOL],Title{n});end;end;
s=[repmat([tForm tDelim],1,size(Data,2)-1) tForm];
fprintf(fId,[s tEOL],Data');
fclose(fId);

%mail@ge0mlib.com 19/09/2016