function fId=gKmlOpen(FileName)
%Open file and write to kml-file "open lines".
%function fId=gKmlOpen(FileName), where
%fId- file identifier;
%FileName- the Name of kml-file.
%Function Example:
%fId=gKmlOpen('c:\temp\112.kml');

fId=fopen(FileName,'w');
fprintf(fId,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fId,'<kml xmlns="http://www.opengis.net/kml/2.2"');
fprintf(fId,' xmlns:gx="http://www.google.com/kml/ext/2.2"');
fprintf(fId,' xmlns:kml="http://www.opengis.net/kml/2.2"');
fprintf(fId,' xmlns:atom="http://www.w3.org/2005/Atom">\n');
fprintf(fId, '<Document>\n');
L1=find(FileName=='\');if isempty(L1),L1=0;end;
L2=find(FileName=='.');if isempty(L2),L2=numel(FileName+1);end;
fprintf(fId,['	<name>',FileName((L1(end)+1):(L2(end)-1)),'.kml</name>\n']);

%mail@ge0mlib.com 22/04/2021