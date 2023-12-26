function status=gKmlClose(fId)
%Write to kml-file "close lines" and close file.
%function status=gKmlClose(fId), where
%fId- file identifier;
%status- returns a status of 0 when the close operation is successful. Otherwise, it returns -1.
%Function Example:
%gKmlClose(fId);

fprintf(fId,'</Document>\n');
fprintf(fId,'</kml>\n');
status=fclose(fId);

%mail@ge0mlib.com 22/04/2021