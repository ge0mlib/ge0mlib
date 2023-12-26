%script gSgyHorizTime2DepthScript
%Convert folder with Sgy-files from time to depth as 2-thickness section (water and rock); used pre-picked bottom surface from Head-structure field ('UnassignedInt1' default).
%Start script with command >>> {'d:\002_Sgy\',1480,1640,'UnassignedInt1',5};gSgyHorizTime2DepthScript; <<< or the same.
%There are follow parameters: Root Folder, Speed of Water, Speed of Sediments, Pre-picked Bottom Head-field, DataSampleFormat.

gKey=ans;
try rootD=gKey{1};catch,rootD='d:\002_Proc_01(filtration)\';end;
try V_water=gKey{2};catch,V_water=1500;end;
try V_sediments=gKey{3};catch,V_sediments=1600;end;
try BottomField=gKey{4};catch,BottomField='UnassignedInt1';end;
try DataSampleFormat=gKey{5};catch,DataSampleFormat=5;end;
%read file names in root folder and create 'Convert' folder
dz=dir(rootD);lz=[dz(:).isdir];dz(lz)=[];fName=char(dz(:).name);fName=sortrows(fName);
[~,w]=dos(['dir ',rootD,'/b']);l=strfind(w,['Convert',char(10)]);
if isempty(l); dos(['mkdir ',rootD,'\Convert']);end; if ~isempty(l); dos(['del ',rootD,'\Convert\*.* /Q']);end; clear dz lz w l;
for n=1:size(fName,1), %=====cycle for file-by-file=====
    fNameN=deblank(fName(n,:));disp(fNameN);
    [SgyHead,Head,Data]=gSgyRead([rootD fNameN],'',[]);
    Hrz(1)=gSgyHorizCreate(1,size(Data),V_water,[],'zero','.-b');Hrz(2)=gSgyHorizCreate(Head.(BottomField),size(Data),V_sediments,'bottom',[],'.-b');VelMat=gSgyHoriz2VelMatrix(Hrz,size(Data),1);
    [SgyHeadD,HeadD,DataD,HrzD]=gSgyHorizTime2Depth(SgyHead,Head,Data,VelMat,Hrz,[]);
    HeadD.WeatheringVelocity(:)=V_water;HeadD.SubWeatheringVelocity(:)=V_sediments;
    SgyHeadD.FDataSampleFormat=DataSampleFormat;SgyHeadD.DataSampleFormat=DataSampleFormat;
    gSgyWrite(SgyHeadD,HeadD,DataD,[rootD 'Convert\' fNameN(1:end-4) '_dptIm.sgy']);
end;
clear gKey rootD V_water V_sediments BottomField DataSampleFormat fName n fNameN Hrz VelMat SgyHead Head Data SgyHeadD HeadD DataD     

%mail@ge0mlib.com 21/02/2020