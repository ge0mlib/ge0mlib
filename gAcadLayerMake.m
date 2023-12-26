function gAcadLayerMake(fId,layerName)
%Write to AutoCad script file: make layer (create and set active).
%function gAcadLayerMake(fId,layerName), where
%fId- file identifier;
%layerName- layer name; layer 1)will be create and set active; 2)if layer exist, it is set active and turned on.
%Function Example:
%fId=fopen('c:\temp\112.scr','w');gAcadLayerMake(fId,'layer1');fclose(fId);

fprintf(fId,'-layer m "%s"\r\n\r\n',layerName);

%mail@ge0mlib.com 02/11/2019