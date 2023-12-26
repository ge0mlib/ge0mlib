function flZ2=gLogFileFormatFix(fName,Form,Delim,LenFl,varargin)
%Read strings from position-formatted files and check it in accordance with Form-mask; copy "bad" files content to new files with '_good' and '_bad' postfixes.
%function flZ2=gLogFileFormatFix(fName,Form,Delim,LenFl,varargin), where
%fName - reading file name or files name or folder name with files (last name's symbol must be '\');
%Form- position-formated file "mask", includes ascii code limits for each symbol, there can be:
%- vector with two rows of mask, contained ascii code limits for strings' symbols;
%- predefined mask name;
%- cells, includes "vectors with two rows"; it is the method "multiple mask" realized.
%The last rows Form element is StringTerminate symbol code.
%if LenFl==0, then string can include several "not described in mask" chars before StringTerminate symbol code.
%Delim- [first_delimiter second_delimiter] for data recorded by gLog;
%LenFl- flag==1 for condition "string length is equal Form length";
%varargin{1}- the equipment components serial numbers, it is used for Form-string choice as an additional equipment description (see 'gLogSeaSpyGrad' below);
%flZ2- "bad" files quantity;
%For "bad" files create two additional files with follow content: if string is "good", then it coped to [rootD fNameN '_good'], else it coped to [rootD fNameN '_bad'].
%Form Example, LenFl=0 (<45157748,$GPAVL,R2,556.... recorded by gLog)
%Form(1,:)=[60 48 48 48 48 48 48 48 48 44 36 71 80 65 86 76 44 82 48 44 48 48 48 10];
%Form(2,:)=[60 57 57 57 57 57 57 57 57 44 36 71 80 65 86 76 44 82 57 44 57 57 57 10];
%Function example:
%gLogFileFormatFix('c:\05_Prog\123.txt','MagLogG88',['~' ','],1);gLogFileFormatFix('c:\05_Prog\TSS\',Form,['~' ','],1);

%======FormSelect=======
if all(isnumeric(Form)), tmp=Form;Form=[];Form{1}=tmp;end;
if all(ischar(Form)), Delim=uint8(Delim);
    switch Form,
        case 'MagLogG88',LenFl=1;Form=[]; %Geometrics Magnitometer recorded by MagLog (includes depth sensor and altimeter): $ 88628.738,0020,0103,0112  07/12/20 02:28:50.724
            if ~isnan(varargin{1}(2))&&~isnan(varargin{1}(3)), %serial numbers [mag1_SN, alt1_SN, depth1_SN], Alt and Depth
                %         $     5  5  8  6  5  .  6  7  5  ,  0  8  5  4  ,  3  8  6  7  ,  0  8  0  8        0  9  /  0  7  /  1  4     2  2  :  2  1  :  0  4  .  0  3  1
                Form{1}=[36 32 48 48 48 48 48 46 48 48 48 44 48 48 48 48 44 48 48 48 48 44 48 48 48 48 32 32 48 48 47 48 48 47 48 48 32 48 48 58 48 48 58 48 48 46 48 48 48 13 10;...
                         36 32 57 57 57 57 57 46 57 57 57 44 57 57 57 57 44 57 57 57 57 44 57 57 57 57 32 32 57 57 47 57 57 47 57 57 32 57 57 58 57 57 58 57 57 46 57 57 57 13 10];
            elseif ~isnan(varargin{1}(2))&&isnan(varargin{1}(3)), %serial numbers [mag1_SN, alt1_SN, nan], Alt and no-Depth
                %         $     5  5  8  6  5  .  6  7  5  ,  0  8  5  4  ,  0  8  0  8        0  9  /  0  7  /  1  4     2  2  :  2  1  :  0  4  .  0  3  1
                Form{1}=[36 32 48 48 48 48 48 46 48 48 48 44 48 48 48 48 44 48 48 48 48 32 32 48 48 47 48 48 47 48 48 32 48 48 58 48 48 58 48 48 46 48 48 48 13 10;...
                         36 32 57 57 57 57 57 46 57 57 57 44 57 57 57 57 44 57 57 57 57 32 32 57 57 47 57 57 47 57 57 32 57 57 58 57 57 58 57 57 46 57 57 57 13 10];                
            elseif isnan(varargin{1}(2))&&~isnan(varargin{1}(3)), %serial numbers [mag1_SN, nan, depth1_SN], no-Alt and Depth
                %         $     5  5  8  6  5  .  6  7  5  ,  0  8  5  4  ,  3  8  6  7        0  9  /  0  7  /  1  4     2  2  :  2  1  :  0  4  .  0  3  1
                Form{1}=[36 32 48 48 48 48 48 46 48 48 48 44 48 48 48 48 44 48 48 48 48 32 32 48 48 47 48 48 47 48 48 32 48 48 58 48 48 58 48 48 46 48 48 48 13 10;...
                         36 32 57 57 57 57 57 46 57 57 57 44 57 57 57 57 44 57 57 57 57 32 32 57 57 47 57 57 47 57 57 32 57 57 58 57 57 58 57 57 46 57 57 57 13 10];
            elseif isnan(varargin{1}(2))&&isnan(varargin{1}(3)), %serial numbers [mag1_SN, nan, nan], no-Alt and no-Depth
                %         $     5  5  8  6  5  .  6  7  5  ,  0  8  5  4        0  9  /  0  7  /  1  4     2  2  :  2  1  :  0  4  .  0  3  1
                Form{1}=[36 32 48 48 48 48 48 46 48 48 48 44 48 48 48 48 32 32 48 48 47 48 48 47 48 48 32 48 48 58 48 48 58 48 48 46 48 48 48 13 10;...
                         36 32 57 57 57 57 57 46 57 57 57 44 57 57 57 57 32 32 57 57 47 57 57 47 57 57 32 57 57 58 57 57 58 57 57 46 57 57 57 13 10];
            end;
        case 'MagLogG88TVG',LenFl=1;Form=[]; %Geometrics TVG-gradiometer recorded by MagLog: $ 88628.738,0020,0103,0112, 95906.361,0010,0095,0122  07/12/20 02:28:50.724
            %         $     8  8  6  2  8  .  7  3  8  ,  0  0  2  0  ,  0  1  0  3  ,  0  1  1  2  ,     9  5  9  0  6  .  3  6  1  ,  0  0  1  0  ,  0  0  9  5  ,  0  1  2  2        0  7  /  1  2  /  2  0     0  2  :  2  8  :  5  0  .  7  2  4
            Form{1}=[36 32 48 48 48 48 48 46 48 48 48 44 48 48 48 48 44 48 48 48 48 44 48 48 48 48 44 32 48 48 48 48 48 46 48 48 48 44 48 48 48 48 44 48 48 48 48 44 48 48 48 48 32 32 48 48 47 48 48 47 48 48 32 48 48 58 48 48 58 48 48 46 48 48 48 13 10;...
                     36 32 57 57 57 57 57 46 57 57 57 44 57 57 57 57 44 57 57 57 57 44 57 57 57 57 44 32 57 57 57 57 57 46 57 57 57 44 57 57 57 57 44 57 57 57 57 44 57 57 57 57 32 32 57 57 47 57 57 47 57 57 32 57 57 58 57 57 58 57 57 46 57 57 57 13 10];
        case 'MagLogGPGGA',LenFl=0;Form=[]; %GPGGA data recorded by MagLog: $GPGGA,222853.00,4710.583677,N,14341.606926,E,2,12,1.0,00001.829,M,00000.000,M,0.00,*49  07/12/20 02:28:51.596
            %         $  G  P  G  G  A  ,  2  2  2  8  5  3  ,  0
            Form{1}=[36 71 80 71 71 65 44 48 48 48 48 48 48 44 48 10;...
                     36 71 80 71 71 65 44 57 57 57 57 57 57 46 57 10];
        case 'gLogTSS1',LenFl=1;Form=[]; %TSS1, recorded by gLog: :XXAAAA_MHHHHQMRRRR_MPPPPZZ
            %               <  2  1  6  0  0  4  4  4        ,  :  0  B  F  C  7  9        0  0  2  9   U  -  0  0  5  4        0  3  3  1
            Form{1}=[Delim(1) 48 48 48 48 48 48 48 48 Delim(2) 58 48 48 48 48 48 48 32 32 48 48 48 48  32 32 48 48 48 48 32 32 48 48 48 48 13 10;...
                     Delim(1) 57 57 57 57 57 57 57 57 Delim(2) 58 70 70 70 70 70 70 32 45 57 57 57 57 122 45 57 57 57 57 32 45 57 57 57 57 13 10];
        case 'gLogGPGGU',LenFl=1;Form=[]; %$GPGGU, recorded by gLog: $GPGGU, 296290.7,X, 1726669.8,Y,150041.00*72
            %               ~  8  2  8  1  0  2  5  9        ,  $  G  P  G  G  U  ,     2  9  6  2  9  0  .  7  ,  X  ,     1  7  2  6  6  6  9  .  8  ,  Y  ,  1  5  0  0  4  1  .  0  0  *  7  2
            Form{1}=[Delim(1) 48 48 48 48 48 48 48 48 Delim(2) 36 71 80 71 71 85 44 32 48 48 48 48 48 48 46 48 44 88 44 32 48 48 48 48 48 48 48 46 48 44 89 44 48 48 48 48 48 48 46 48 48 42 48 48 13 10;...
                     Delim(1) 57 57 57 57 57 57 57 57 Delim(2) 36 71 80 71 71 85 44 32 57 57 57 57 57 57 46 57 44 88 44 32 57 57 57 57 57 57 57 46 57 44 89 44 57 57 57 57 57 57 46 57 57 42 70 70 13 10];
        case 'HEHDT',LenFl=1;Form=[]; %HEHDT, recorded by gLog: $HEHDT,001.1,T
            %               <  6  4  8  0  0  3  8  9        ,  $  H  E  H  D  T  ,  0  0  1  .  1  ,  T
            Form{1}=[Delim(1) 48 48 48 48 48 48 48 48 Delim(2) 36 72 69 72 68 84 44 48 48 48 46 48 44 84 13 10;...
                     Delim(1) 57 57 57 57 57 57 57 57 Delim(2) 36 72 69 72 68 84 44 57 57 57 46 57 44 84 13 10];
        case 'gLogSeaSpyGrad',LenFl=1;Form=[]; %SeaSpy gradiometer, recorded by gLog: *19.212/04:12:40.0 F[017345.893 074 0013 +0001.7 000.00 G_P] R[021818.742 080 0015 -0027.0 000.00 G_P] -04472.849
            if ~isnan(varargin{1}(1,2))&&~isnan(varargin{1}(2,2)), %serial numbers [mag1_SN, alt1_SN, depth1_SN; mag2_SN, alt2_SN, depth2_SN], nan if altimeter is absent
                %               ~  4  3  2  0  0  1  1  7        ,  *  1  9  .  2  5  0  /  1  1  :  5  9  :  5  9  .  0     F  [  0  4  4  9  6  3  .  3  6  1     1  5  6     0  4  6  5     +  0  0  0  3  .  1     0  0  3  .  3  4     _  _  _  ]     R  [  0  4  5  0  8  9  .  8  9  4     1  2  9     0  4  6  5     +  0  0  0  2  .  6     0  0  3  .  2  6     _  _  _  ]     -  0  0  1  2  6  .  5  3  3
                Form{1}=[Delim(1) 48 48 48 48 48 48 48 48 Delim(2) 42 48 48 46 48 48 48 47 48 48 58 48 48 58 48 48 46 48 32 70 91 48 48 48 48 48 48 46 48 48 48 32 48 48 48 32 48 48 48 48 32 43 48 48 48 48 46 48 32 48 48 48 46 48 48 32 65 65 65 93 32 82 91 48 48 48 48 48 48 46 48 48 48 32 48 48 48 32 48 48 48 48 32 43 48 48 48 48 46 48 32 48 48 48 46 48 48 32 65 65 65 93 32 43 48 48 48 48 48 46 48 48 48 13 10;...
                         Delim(1) 57 57 57 57 57 57 57 57 Delim(2) 42 57 57 46 57 57 57 47 57 57 58 57 57 58 57 57 46 57 32 70 91 57 57 57 57 57 57 46 57 57 57 32 57 57 57 32 57 57 57 57 32 45 57 57 57 57 46 57 32 57 57 57 46 57 57 32 95 95 95 93 32 82 91 57 57 57 57 57 57 46 57 57 57 32 57 57 57 32 57 57 57 57 32 45 57 57 57 57 46 57 32 57 57 57 46 57 57 32 95 95 95 93 32 45 57 57 57 57 57 46 57 57 57 13 10];
            elseif isnan(varargin{1}(1,2))&&~isnan(varargin{1}(2,2)),
                %               ~  4  3  2  0  0  1  1  7        ,  *  1  9  .  2  5  0  /  1  1  :  5  9  :  5  9  .  0     F  [  0  4  4  9  6  3  .  3  6  1     1  5  6     0  4  6  5     +  0  0  0  3  .  1     _  _  _  ]     R  [  0  4  5  0  8  9  .  8  9  4     1  2  9     0  4  6  5     +  0  0  0  2  .  6     0  0  3  .  2  6     _  _  _  ]     -  0  0  1  2  6  .  5  3  3
                Form{1}=[Delim(1) 48 48 48 48 48 48 48 48 Delim(2) 42 48 48 46 48 48 48 47 48 48 58 48 48 58 48 48 46 48 32 70 91 48 48 48 48 48 48 46 48 48 48 32 48 48 48 32 48 48 48 48 32 43 48 48 48 48 46 48 32 65 65 65 93 32 82 91 48 48 48 48 48 48 46 48 48 48 32 48 48 48 32 48 48 48 48 32 43 48 48 48 48 46 48 32 48 48 48 46 48 48 32 65 65 65 93 32 43 48 48 48 48 48 46 48 48 48 13 10;...
                         Delim(1) 57 57 57 57 57 57 57 57 Delim(2) 42 57 57 46 57 57 57 47 57 57 58 57 57 58 57 57 46 57 32 70 91 57 57 57 57 57 57 46 57 57 57 32 57 57 57 32 57 57 57 57 32 45 57 57 57 57 46 57 32 95 95 95 93 32 82 91 57 57 57 57 57 57 46 57 57 57 32 57 57 57 32 57 57 57 57 32 45 57 57 57 57 46 57 32 57 57 57 46 57 57 32 95 95 95 93 32 45 57 57 57 57 57 46 57 57 57 13 10];
            elseif ~isnan(varargin{1}(1,2))&&isnan(varargin{1}(2,2)),
                %               ~  4  3  2  0  0  1  1  7        ,  *  1  9  .  2  5  0  /  1  1  :  5  9  :  5  9  .  0     F  [  0  4  4  9  6  3  .  3  6  1     1  5  6     0  4  6  5     +  0  0  0  3  .  1     0  0  3  .  3  4     _  _  _  ]     R  [  0  4  5  0  8  9  .  8  9  4     1  2  9     0  4  6  5     +  0  0  0  2  .  6     _  _  _  ]     -  0  0  1  2  6  .  5  3  3
                Form{1}=[Delim(1) 48 48 48 48 48 48 48 48 Delim(2) 42 48 48 46 48 48 48 47 48 48 58 48 48 58 48 48 46 48 32 70 91 48 48 48 48 48 48 46 48 48 48 32 48 48 48 32 48 48 48 48 32 43 48 48 48 48 46 48 32 48 48 48 46 48 48 32 65 65 65 93 32 82 91 48 48 48 48 48 48 46 48 48 48 32 48 48 48 32 48 48 48 48 32 43 48 48 48 48 46 48 32 65 65 65 93 32 43 48 48 48 48 48 46 48 48 48 13 10;...
                         Delim(1) 57 57 57 57 57 57 57 57 Delim(2) 42 57 57 46 57 57 57 47 57 57 58 57 57 58 57 57 46 57 32 70 91 57 57 57 57 57 57 46 57 57 57 32 57 57 57 32 57 57 57 57 32 45 57 57 57 57 46 57 32 57 57 57 46 57 57 32 95 95 95 93 32 82 91 57 57 57 57 57 57 46 57 57 57 32 57 57 57 32 57 57 57 57 32 45 57 57 57 57 46 57 32 95 95 95 93 32 45 57 57 57 57 57 46 57 57 57 13 10];
            elseif isnan(varargin{1}(1,2))&&isnan(varargin{1}(2,2)),
                %               ~  4  3  2  0  0  1  1  7        ,  *  1  9  .  2  5  0  /  1  1  :  5  9  :  5  9  .  0     F  [  0  4  4  9  6  3  .  3  6  1     1  5  6     0  4  6  5     +  0  0  0  3  .  1     _  _  _  ]     R  [  0  4  5  0  8  9  .  8  9  4     1  2  9     0  4  6  5     +  0  0  0  2  .  6     _  _  _  ]     -  0  0  1  2  6  .  5  3  3
                Form{1}=[Delim(1) 48 48 48 48 48 48 48 48 Delim(2) 42 48 48 46 48 48 48 47 48 48 58 48 48 58 48 48 46 48 32 70 91 48 48 48 48 48 48 46 48 48 48 32 48 48 48 32 48 48 48 48 32 43 48 48 48 48 46 48 32 65 65 65 93 32 82 91 48 48 48 48 48 48 46 48 48 48 32 48 48 48 32 48 48 48 48 32 43 48 48 48 48 46 48 32 65 65 65 93 32 43 48 48 48 48 48 46 48 48 48 13 10;...
                         Delim(1) 57 57 57 57 57 57 57 57 Delim(2) 42 57 57 46 57 57 57 47 57 57 58 57 57 58 57 57 46 57 32 70 91 57 57 57 57 57 57 46 57 57 57 32 57 57 57 32 57 57 57 57 32 45 57 57 57 57 46 57 32 95 95 95 93 32 82 91 57 57 57 57 57 57 46 57 57 57 32 57 57 57 32 57 57 57 57 32 45 57 57 57 57 46 57 32 95 95 95 93 32 45 57 57 57 57 57 46 57 57 57 13 10];
            end;
        case 'gLogGPGGA',LenFl=0;Form=[]; %GPGGA, recorded by gLog: ~07200332,$GPGGA,175952.01,2400.329413,N,12014.620366,E,1,00,1.0,-0023.366,M,-0000.000,M,0.0,*74 // <55658200,$GPGGA,050000.00,5422.1680603,N,16236.8459860,E,2,16,0.8,8.6876,M,9.9814,M,37.6,0268*4A
            %               ~  0  7  2  0  0  3  3  2        ,  $  G  P  G  G  A  ,  1  7  5  9  5  2  .  0  1  ,  2400.329413,N,12014.620366,E,1,00,1.0,-0023.366,M,-0000.000,M,0.0,*74
            Form{1}=[Delim(1) 48 48 48 48 48 48 48 48 Delim(2) 36 71 80 71 71 65 44 48 48 48 48 48 48 46 48 48 44 10;...
                     Delim(1) 57 57 57 57 57 57 57 57 Delim(2) 36 71 80 71 71 65 44 57 57 57 57 57 57 46 57 57 44 10];
        case 'gLogHYTek',LenFl=1;Form=[]; %HYTek Cable Counter, recorded by gLog: ~46800152,CL+0206m
            %               ~  4  6  8  0  0  1  5  2        ,  C  L  +  0  2  0  6   m
            Form{1}=[Delim(1) 48 48 48 48 48 48 48 48 Delim(2) 67 76 43 48 48 48 48 109 13;...
                     Delim(1) 57 57 57 57 57 57 57 57 Delim(2) 67 76 45 57 57 57 57 109 13];
        case 'gLogMKII',LenFl=1;Form=[]; %MKII Cable Counter, recorded by gLog (20chars+x0D): ~55245049,L=6.9m    <x0D>~55245564,S=0.0m/m  <x0D>
            %               <  5  5  2  4  4  5  5  0        ,  S  =  0   .   0   m   /   m      
            Form{1}=[Delim(1) 48 48 48 48 48 48 48 48 Delim(2) 76 61 48  32  32  32  32  32   32   32 13;...
                     Delim(1) 57 57 57 57 57 57 57 57 Delim(2) 83 61 57 109 109 109 109 109  109  109 13];
        case 'gLogGpAvl',LenFl=0;Form=[]; %<45157748,$GPAVL,R1,5561000.000,46.21880000,142.79169707,27.256,-1.657,0.539,0.809,351174.000,-3520921.763,2673329.360,4582128.127,0.866,1.423,0.957*3A
            %              <   4  5  1  5  7  7  4  8  ,  $  G  P  A  V  L  ,  R  2  ,  5  5  6
            Form{1}=[Delim(1) 48 48 48 48 48 48 48 48 44 36 71 80 65 86 76 44 82 48 44 48 48 48 10;...
                     Delim(1) 57 57 57 57 57 57 57 57 44 36 71 80 65 86 76 44 82 57 44 57 57 57 10];
        otherwise, warning(['Unexpected key value; files not cheked: ' fName]);flZ2=[];return;
    end;
end;
%======FilesFix=======
if (size(fName,1)==1)&&(fName(end)=='\'), dz=dir(fName);dz([dz.isdir])=[];fName=[repmat(fName,length(dz),1) char(dz.name)];end;
flZ2=0;
for nn=1:size(fName,1),
    fNameN=deblank(fName(nn,:));
    [fId, mes]=fopen(fNameN,'r');if ~isempty(mes), error(mes);end;a=fread(fId,inf,'uint8');fclose(fId);
    if a(end)~=Form{1}(1,end),a(end+1)=Form{1}(1,end);end;
    L=find(a==Form{1}(1,end));b=[[1;L(1:end-1)+1] L];
    flZ=0;
    for n=1:size(b,1),
        z=a(b(n,1):b(n,2))';lenz=size(z,2);
        flG=0;
        for nnn=1:numel(Form),
            len=size(Form{nnn},2);
            if ((len==lenz)||(LenFl~=1))&&(len<=lenz),flG=flG|all((z(1:(len-1))>=Form{nnn}(1,1:(len-1)))&(z(1:(len-1))<=Form{nnn}(2,1:(len-1))));end;
        end;
        if flG, %create files ang write good or bad strings
            if flZ, fwrite(fId2,z,'uint8');end;
        else
            if ~flZ, flZ=1;fId2=fopen([fNameN '_good'],'w');fId3=fopen([fNameN '_bad'],'w');fwrite(fId2,a(1:(b(n,1)-1)),'uint8');end;
            fwrite(fId3,z,'uint8');
        end;
    end;
    if flZ, fclose(fId2);fclose(fId3);end;
    flZ2=flZ2+flZ;
end;

%mail@ge0mlib.com 15/07/2020