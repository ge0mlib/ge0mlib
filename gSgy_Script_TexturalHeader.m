%script gTraining02_SgyTexturalHeader;
%Create text-headers for Sgy-files and apply it to files in folder; there is EdgeTech 3200SX/512I equipment.
%The textural headers template is formed in accordance with the requirements of the State Bank of Digital Geological Information (Russia) for 2DHR.
%http://www.rfgf.ru/4.htm >>> http://www.rfgf.ru/instrukziy/seismika.pdf (page 11-13)
%The 16th mandatory records marked in comments as: +++
%C39 is defined as mandatory in SEGY standard >>> https://seg.org/Portals/0/SEG/News%20and%20Resources/Technical%20Standards/seg_y_rev1.pdf
%Used Ge0MLib functions: gSgyRead, gSgyWrite, gSgyTextAscii2Ebcdic, gSgyTexturalCorrect.
%   StHead is the data for change, there are a number of fields: StHead(n).Pos- text position; StHead(n).Rec- text for writing; StHead(n).Num- max number of symbols for text.
%   StHead(n).Rec need to change for own survey.
%   The folder rootD\conv will be clear and rewrite.
%Start script with command >>> {'d:\3200SX\'};gTraining02_SgyTexturalHeader; <<< or the same.
%There is parameter: Root Folder.


gKey=ans;
try rootD=gKey{1};catch,rootD='d:\3200SX\';end;
dz=dir(rootD);lz=[dz(:).isdir];dz(lz)=[];fName=char(dz(:).name);fName=sortrows(fName);
[~,w]=dos(['dir ',rootD,'/b']);l=strfind(w,['Convert',char(10)]);
if isempty(l); dos(['mkdir ',rootD,'\Convert']);end; if ~isempty(l); dos(['del ',rootD,'\Convert\*.* /Q']);end; clear dz lz w l;

THeader='C01 CLIENT                        COMPANY                       CREW NO         C02 LINE            AREA                        MAP ID                          C03 REEL NO           DAY-START OF REEL     YEAR      OBSERVER                  C04 INSTRUMENT: MFG            MODEL            SERIAL NO                       C05 DATA TRACES/RECORD        AUXILIARY TRACES/RECORD         CDF FOLD          C06 SAMPLE INTERVAL         SAMPLES/TRACE       BITS/IN      BYTES SAMPLE       C07 RECORDING FORMAT        FORMAT THIS REEL        MEASUREMENT SYSTEM          C08 SAMPLE CODE: FLOATING PT     FIXED PT     FIXED PT-GAIN     CORRELATED      C09 GAIN TYPE:  FIXED     BINARY     FLOATING POINT     OTHER                   C10 FILTERS: ALIAS     HZ  NOTCH     HZ  BAND     -     HZ  SLOPE    -   DB/OCT C11 SOURCE: TYPE            NUMBER/POINT        POINT/INTERVAL                  C12      PATTERN:                          LENGTH        WIDTH                  C13 SWEEP: START     HZ  END     HZ  LENGTH      MS  CHANNEL NO     TYPE        C14 TAPER: START LENGTH      MS   END LENGTH       MS  TYPE                     C15 SPREAD: OFFSET        MAX DISTANCE        GROUP INTERVAL                    C16 GEOPHONES: PER GROUP     SPACING     FREQUENCY     MFG          MODEL       C17      PATTERN:                          LENGTH        WIDTH                  C18 TRACES SORTED BY: RECORD     CDP     OTHER                                  C19 AMPLITUDE RECOVERY: NONE      SPHERICAL DIV       AGC    OTHER              C20 MAP PROJECTION                      ZONE ID       COORDINATE UNITS          C21 DEMULTIPLEXING SOFT                                                         C22                                                                             C23                                                                             C24                                                                             C25                                                                             C26                                                                             C27 GRID ORIG 0                                                                 C28                                                                             C29                                                                             C30                                                                             C31 I-LINE X-LINE BIN SIZE AND AZIMUTH                                          C32 I-LINE X-LINE INCREMENTS                                                    C33                                                                             C34                                                                             C35                                                                             C36                                                                             C37 SURVEY NAME                               LINE NAME                         C38                                                                             C39                                                                             C40                                                                             ';
%====C01====+++
n=01;StHead(n).Pos=012;StHead(n).Num=22;StHead(n).Rec='COMPANY1';         %+++ CLIENT \\ Заказчик
n=02;StHead(n).Pos=043;StHead(n).Num=21;StHead(n).Rec='COMPANY2';         %COMPANY/CONTRACTOR \\ Компания-исполнитель
n=03;StHead(n).Pos=073;StHead(n).Num=08;StHead(n).Rec='Vessel1';          %CREW NO/VESSEL NAME \\ Имя партии, судна
%====C02====+++
n=04;StHead(n).Pos=090;StHead(n).Num=10;StHead(n).Rec='NW';               %+++ LINE W/SURVEY PREFIX \\ Имя профиля или съемки
n=05;StHead(n).Pos=106;StHead(n).Num=25;StHead(n).Rec='Some Sea';         %+++ AREA \\ Площадь
n=06;StHead(n).Pos=136;StHead(n).Num=25;StHead(n).Rec='WGS84;6378137;298.2572236'; %+++ MAP ID/INT.DATUM \\ Проекция, эллипсоид
%====C03====
n=07;StHead(n).Pos=173;StHead(n).Num=09;StHead(n).Rec=' ';                %REEL NO \\ Номер ленты
n=08;StHead(n).Pos=201;StHead(n).Num=03;StHead(n).Rec='#';                %DAY-START OF REEL/LINE \\ Дата начала работ
n=09;StHead(n).Pos=210;StHead(n).Num=04;StHead(n).Rec='2017';             %YEAR \\ Год
n=10;StHead(n).Pos=224;StHead(n).Num=17;StHead(n).Rec='OP1,OP2';          %OBSERVER \\ Оператор
%====C04====
n=11;StHead(n).Pos=261;StHead(n).Num=10;StHead(n).Rec='EdgeTech';         %INSTRUMENT:MFG \\ Аппаратура (производитель?)
n=12;StHead(n).Pos=278;StHead(n).Num=10;StHead(n).Rec='3200SX512i';       %MODEL \\ Модель
n=13;StHead(n).Pos=299;StHead(n).Num=22;StHead(n).Rec='00000';            %SERIAL NO \\ Серийный номер
%====C05====+++
n=14;StHead(n).Pos=344;StHead(n).Num=06;StHead(n).Rec='1';                %+++ DATA TRACES/RECORD \\ Количество трасс на запись
n=15;StHead(n).Pos=375;StHead(n).Num=07;StHead(n).Rec='0';                %+++ AUXILIARY TRACES/RECORD \\ Вспомогательные трассы на запись
n=16;StHead(n).Pos=392;StHead(n).Num=09;StHead(n).Rec='1';                %CDP FOLD \\ Кратность
%====C06====+++
n=17;StHead(n).Pos=421;StHead(n).Num=06;StHead(n).Rec='46';               %+++ SAMPLE INTERVAL (mks) \\ Шаг дискретизации в мкс
n=18;StHead(n).Pos=443;StHead(n).Num=05;StHead(n).Rec='#';                %+++ SAMPLES/TRACE \\ Количество отсчетов на трассу
n=19;StHead(n).Pos=457;StHead(n).Num=04;StHead(n).Rec=' ';                %BITS/IN \\ Плотность записи Бит/дюйм
n=20;StHead(n).Pos=475;StHead(n).Num=06;StHead(n).Rec='4';                %BYTES/SAMPLE \\ Плотность записи Байт/отсчет
%====C07====+++
n=21;StHead(n).Pos=502;StHead(n).Num=06;StHead(n).Rec='SEGY1';            %+++ RECORDING FORMAT \\ Формат записи
n=22;StHead(n).Pos=526;StHead(n).Num=06;StHead(n).Rec='NTFS';             %+++ FORMAT THIS REEL \\ Формат магнитного носителя
n=23;StHead(n).Pos=552;StHead(n).Num=09;StHead(n).Rec='SI';               %MEASUREMENT SYSTEM \\ Система измерений
%====C08====
n=24;StHead(n).Pos=590;StHead(n).Num=03;StHead(n).Rec='yes';             %SAMLPE CODE: FLOATING PT \\ Формат числа: Плавающая точка
n=25;StHead(n).Pos=603;StHead(n).Num=03;StHead(n).Rec=' ';               %FIXED PT \\ Фиксированная точка
n=26;StHead(n).Pos=621;StHead(n).Num=03;StHead(n).Rec=' ';               %FIXED PT-GAIN \\ Фиксированная точка - усиление
n=27;StHead(n).Pos=636;StHead(n).Num=05;StHead(n).Rec=' ';               %CORRELATED \\ Корреляция
%====C09====
n=28;StHead(n).Pos=663;StHead(n).Num=03;StHead(n).Rec=' ';               %GAIN TYPE: FIXED \\ Тип усиления: фиксированный
n=29;StHead(n).Pos=674;StHead(n).Num=03;StHead(n).Rec=' ';               %BINARY \\ Двоичный
n=30;StHead(n).Pos=693;StHead(n).Num=03;StHead(n).Rec=' ';               %FLOATING POINT \\ Плавающая точка
n=31;StHead(n).Pos=703;StHead(n).Num=08;StHead(n).Rec=' ';               %OTHER \\ Другие
%====C10====
n=32;StHead(n).Pos=740;StHead(n).Num=03;StHead(n).Rec=' ';               %FILTER: ALIAS \\ Фильтры: альясинг (Гц)
n=33;StHead(n).Pos=754;StHead(n).Num=03;StHead(n).Rec=' ';               %NOTCH \\ Режекторный (Гц)
n=34;StHead(n).Pos=767;StHead(n).Num=03;StHead(n).Rec=' ';               %BAND \\ Полоса пропускания низкие частоты (Гц)
n=35;StHead(n).Pos=773;StHead(n).Num=03;StHead(n).Rec=' ';               %\\ Полоса пропускания высокие частоты (Гц)
n=36;StHead(n).Pos=787;StHead(n).Num=02;StHead(n).Rec=' ';               %SLOPE \\ Крутизна низкие частоты (Дб/Окт)
n=37;StHead(n).Pos=792;StHead(n).Num=02;StHead(n).Rec=' ';               %\\ Крутизна высокие частоты (Дб/Окт)
%====C11====
n=38;StHead(n).Pos=818;StHead(n).Num=10;StHead(n).Rec='Chirp';           %SOURCE: TYPE \\ Источник: тип
n=39;StHead(n).Pos=842;StHead(n).Num=06;StHead(n).Rec=' ';               %NUMBER/POINT \\ Номер/точка
n=40;StHead(n).Pos=864;StHead(n).Num=17;StHead(n).Rec=' ';               %POINT INTERVAL \\ Расстояние ПВ
%====C12====
n=41;StHead(n).Pos=898;StHead(n).Num=25;StHead(n).Rec=' ';               %PATTERN: \\ Параметры группирования источника
n=42;StHead(n).Pos=931;StHead(n).Num=06;StHead(n).Rec=' ';               %LENGTH \\ Длина
n=43;StHead(n).Pos=944;StHead(n).Num=17;StHead(n).Rec=' ';               %WIDTH \\ Ширина
%====C13====
n=44;StHead(n).Pos=978;StHead(n).Num=03;StHead(n).Rec=' ';               %SWEEP: START \\ Параметры свипа низкая частота (Гц)
n=45;StHead(n).Pos=990;StHead(n).Num=03;StHead(n).Rec=' ';               %END \\ Параметры свипа высокая частота (Гц)
n=46;StHead(n).Pos=1005;StHead(n).Num=04;StHead(n).Rec=' ';              %LENGTH \\ Длинна (мс)
n=47;StHead(n).Pos=1025;StHead(n).Num=03;StHead(n).Rec=' ';              %CHANNEL NO \\ Номер канала
n=48;StHead(n).Pos=1034;StHead(n).Num=07;StHead(n).Rec=' ';              %TYPE \\ Тип свипа
%====C14====
n=49;StHead(n).Pos=1065;StHead(n).Num=05;StHead(n).Rec=' ';              %TAPER: START LENGTH \\ Тайперинг начало (мс)
n=50;StHead(n).Pos=1086;StHead(n).Num=05;StHead(n).Rec=' ';              %END LENGTH \\ конец (мс)
n=51;StHead(n).Pos=1101;StHead(n).Num=20;StHead(n).Rec=' ';              %TYPE \\ Тип
%====C15====
n=52;StHead(n).Pos=1140;StHead(n).Num=06;StHead(n).Rec=' ';              %SPREAD: OFFSET \\ Параметры расстановки:
n=53;StHead(n).Pos=1160;StHead(n).Num=06;StHead(n).Rec=' ';              %MAX DISTANCE \\ Максимальное удаление
n=54;StHead(n).Pos=1182;StHead(n).Num=19;StHead(n).Rec=' ';              %GROUP INTERVAL \\ Расстояние между центрами групп
%====C16====
n=55;StHead(n).Pos=1226;StHead(n).Num=03;StHead(n).Rec=' ';              %GEOPHONES: PER GROUP \\ Сейсмоприемники: в группе
n=56;StHead(n).Pos=1238;StHead(n).Num=03;StHead(n).Rec=' ';              %SPACING \\ База
n=57;StHead(n).Pos=1252;StHead(n).Num=03;StHead(n).Rec=' ';              %FREQUENCY \\ Частота
n=58;StHead(n).Pos=1260;StHead(n).Num=03;StHead(n).Rec=' ';              %MGF \\ Идентификатор (производитель?)
n=59;StHead(n).Pos=1275;StHead(n).Num=06;StHead(n).Rec=' ';              %MODEL \\ Модель
%====C17====
n=60;StHead(n).Pos=1298;StHead(n).Num=25;StHead(n).Rec=' ';              %PATTERN \\ Параметры группирования
n=61;StHead(n).Pos=1331;StHead(n).Num=06;StHead(n).Rec=' ';              %LENGTH \\ Длина
n=62;StHead(n).Pos=1344;StHead(n).Num=17;StHead(n).Rec=' ';              %WIDTH \\ Ширина
%====C18====
n=63;StHead(n).Pos=1390;StHead(n).Num=03;StHead(n).Rec=' ';              %TRACES SORTED BY: RECORD \\ Тип сортировки трасс: рекорд(сейсмограмма ОТВ)
n=64;StHead(n).Pos=1398;StHead(n).Num=03;StHead(n).Rec=' ';              %CDP \\ ОГТ
n=65;StHead(n).Pos=1408;StHead(n).Num=33;StHead(n).Rec=' ';              %OTHER \\ Другой
%====C19====
n=66;StHead(n).Pos=1470;StHead(n).Num=04;StHead(n).Rec=' ';              %AMPLITUDE RECOVERY: NONE \\ Выравнивание амплитуд: отсутствует
n=67;StHead(n).Pos=1489;StHead(n).Num=05;StHead(n).Rec=' ';              %SPHERICAL DIV \\ Сферическое расхождение
n=68;StHead(n).Pos=1499;StHead(n).Num=02;StHead(n).Rec=' ';              %AGC \\ Параметры усиления (АРУ?)
n=69;StHead(n).Pos=1508;StHead(n).Num=13;StHead(n).Rec='yes';            %OTHER \\ Другое
%====C20====
n=70;StHead(n).Pos=1540;StHead(n).Num=20;StHead(n).Rec='UTM;177W;00N;0.9996'; %MAP PROJECTION \\ Проекция
n=71;StHead(n).Pos=1569;StHead(n).Num=05;StHead(n).Rec='01N';            %ZONE ID \\ Меридиан. Зона
n=72;StHead(n).Pos=1592;StHead(n).Num=09;StHead(n).Rec='Metre';          %COORDINATE UNITS \\ Единицы измерения координат
%====C21====+++
%====C22====
%====C23====
%====C24====
%====C25====
%====C26====
n=73;StHead(n).Pos=1627;StHead(n).Num=19;StHead(n).Rec='not applicable'; %+++ CONTRACTOR AND SOFTWARE VERSION USED TO PERFORM THE DEMULTIPLEXING \\ Наименование организации-обработчика и программного обеспечения, применявшегося для демультиплексации
%====C27====+++
n=74;StHead(n).Pos=2097;StHead(n).Num=64;StHead(n).Rec='500000.00E; 0.00N'; %+++ GRID ORIG 0 \\ Начало координатной сетки
%====C28====
%====C29====
%====C30====
%====C31====+++
n=75;StHead(n).Pos=2440;StHead(n).Num=41;StHead(n).Rec='not applicable'; %+++ I-LINE X-LINE BIN SIZE AND AZIMUTH \\ Размеры площадки Bin, инлайна и крослайна и азимут.
%====C32====+++
n=76;StHead(n).Pos=2510;StHead(n).Num=51;StHead(n).Rec='not applicable'; %+++ I-LINE X-LINE INCREMENTS \\ Инкремент инлайна и крослайна.
%====C33====
%====C34====
%====C35====
%====C36====
%====C37====
n=77;StHead(n).Pos=2897;StHead(n).Num=29;StHead(n).Rec='Area-1';         %SURVEY NAME \\ Имя площади работ (съемки, месторождения)
n=78;StHead(n).Pos=2937;StHead(n).Num=24;StHead(n).Rec='#';              %LINE NAME \\ Имя профиля
%====C38====
%====C39====+++
n=79;StHead(n).Pos=3045;StHead(n).Num=76;StHead(n).Rec='SEG Y REV1';     %+++ SEG-Y REV \\ Ревизия формата
%====C40====+++
n=80;StHead(n).Pos=3125;StHead(n).Num=76;StHead(n).Rec='END EBCDIC';     %+++ END EBCDIC \\ Конец заголовка EBCDIC
%====END====
for n=1:size(fName,1),
    fNameN=deblank(fName(n,:));disp(fNameN);
    [SgyHead,Head,Data]=gSgyRead([rootD fNameN],'',[]);
    StHead(08).Rec=num2str(Head.DayOfYear(1),'%3d'); %DAY-START OF REEL/LINE \\ Дата начала записи линии съемки
    StHead(18).Rec=num2str(SgyHead.ns,'%d'); %+++ SAMPLES/TRACE \\ Количество отсчетов на трассу
    StHead(78).Rec=fNameN;
    THeaderZ=gSgyTextCorrect(THeader,StHead);[SgyHead.TextualFileHeader,L]=gSgyTextAscii2Ebcdic(THeaderZ);
    if ~isempty(L), disp(['gSgyTexturalAscii2Ebcdic, incorrect symbols position (file - ' fNameN ':']);disp(L);end;
    gSgyWrite(SgyHead,Head,Data,[rootD 'Convert\' fNameN]);
end;

%mail@ge0mlib.com 23/02/2020