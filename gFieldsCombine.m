function fi1=gFieldsCombine(fi1,fi2)
%Combine fields from two structures; if field name is equal, used fi2 structure's field.
%function fi1=gFieldsCombine(fi1,fi2), where
%fi1 - structure1 with fields;
%fi2 - structure2 with fields for appending.
%Example: Sens=gFieldsCombine(Sens,GpsOut); %add fields from GpsOut struct to Sens struct.

names2=fieldnames(fi2);
for n=1:size(names2,1),fi1.(names2{n})=fi2.(names2{n});end;

%mail@ge0mlib.ru 02/10/2019