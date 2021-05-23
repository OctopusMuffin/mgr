function merged

% dodaj ścieżkę skryptu z filterm DPAD - addpath
% dodaj ścieżkę VLFeat -- Vision Lab Features Library \vlfeat-0.9.21-bin\vlfeat-0.9.21\toolbox\vl_setup
addpath('E:\Pulpit\magisterium\dicomvol2\bus-segmentation-master\iciar2016\libs\pre\DPAD2006_OK')
run('E:\Pulpit\vlfeat-0.9.21-bin\vlfeat-0.9.21\toolbox\vl_setup');


javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.nimbus.NimbusLookAndFeel');
format long;

% User Interface
f = figure('Visible','on','Name','Dicom_USG',... 
    'units','normalized','outerposition',[0 0 1 1],...
    'Color',[.94 .97 1]);

uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized',...
    'Position',[.625 .95 .13 .04],...
    'String','Load next dicom file',...
    'Callback',@reset_callback);

    function reset_callback(~,~)
        guzik = questdlg(sprintf('Are you sure you want to load a next dicom file?\nYour previous calculations will disappear!'),...
            'Load next dicom file','Yes','No','No');
        drawnow; pause(0.05);
        if strcmp(guzik,'Yes')
            close(gcbf);
            dicomUSG2vol2
            return;
        else
            return;
        end
    end

uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized',...
    'Position',[.265 .95 .13 .04],...
    'String','Choose a dicom file',...
    'Callback',@sciezka1_callback);

uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized',...
    'Position',[.445 .95 .13 .04],...
    'String','Choose a raw data file',...
    'Callback',@sciezka2_callback);

sciezka2 = '';
skalaX = 0;
skalaY = 0;
sciezka3= '';

    function sciezka1_callback(~,~)
        [nazwa,sciezkaaa]=uigetfile('.dcm');
        sciezkaa=fullfile(sciezkaaa,nazwa);
        [sciezkaaa2,nazwa2,~]=fileparts(sciezkaa);
        sciezka2=fullfile(sciezkaaa2,nazwa2);
        if isempty(sciezka3)
        else
            uiresume(gcbf);
        end
    end

    function sciezka2_callback(~,~)
        [nazwa,sciezkaaa]=uigetfile('.xml');
        sciezkaa=fullfile(sciezkaaa,nazwa);
        [sciezkaaa2,nazwa2,~]=fileparts(sciezkaa);
        sciezka3=fullfile(sciezkaaa2,nazwa2);
        if isempty(sciezka2)
        else
            uiresume(gcbf);
        end
    end

uiwait(f);

% wczytaj plik dicom
sciezka = strcat(sciezka2,'.dcm');
stak = dicomread(sciezka);
parametry = dicominfo(sciezka);

skalaX = parametry.PixelSpacing(1);
skalaY = parametry.PixelSpacing(2);

sciezka3 = strcat(sciezka3,'.xml');
import javax.xml.xpath.*
file = xmlread(sciezka3);
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

expressionnn = xpath.compile('systemParameters/parameter[@name="Series-Name"]/@value');
nazwa = expressionnn.evaluate(file, XPathConstants.NODE);
nazwaa = char(nazwa.getTextContent);
set(f,'NumberTitle','off');
set(f,'Name',nazwaa);

expression = xpath.compile('systemParameters/parameter[@name="Color-Mode/Depth"]/@value');
W1Node = expression.evaluate(file, XPathConstants.NODE);
expressionn = xpath.compile('systemParameters/parameter[@name="Power-Mode/Depth"]/@value');
W11Node = expressionn.evaluate(file, XPathConstants.NODE);

if isempty(W1Node)
    W1= str2double(W11Node.getTextContent);
else
    W1 = str2double(W1Node.getTextContent);
end

expression1 = xpath.compile('systemParameters/parameter[@name="Color-Mode/Depth-Offset"]/@value');
W2Node = expression1.evaluate(file, XPathConstants.NODE);
expression11 = xpath.compile('systemParameters/parameter[@name="Power-Mode/Depth-Offset"]/@value');
W22Node = expression11.evaluate(file, XPathConstants.NODE);

if isempty(W2Node)
    W2= str2double(W22Node.getTextContent);
else
    W2 = str2double(W2Node.getTextContent);
end

W=(W1-W2)/skalaY;

expression7 = xpath.compile('systemParameters/parameter[@name="3D-Step-Size"]/@value');
StepSizeNode = expression7.evaluate(file, XPathConstants.NODE);
expression77 = xpath.compile('systemParameters/parameter[@name="3D-Step-Size"]/@value');
StepSize1Node = expression77.evaluate(file, XPathConstants.NODE);

if isempty(StepSizeNode)
    StepSize = str2double(StepSize1Node.getTextContent);
else
    StepSize = str2double(StepSizeNode.getTextContent);
end

X1 = parametry.SequenceOfUltrasoundRegions.Item_1.RegionLocationMinX0;
X2 = parametry.SequenceOfUltrasoundRegions.Item_1.RegionLocationMinY0;
X3 = parametry.SequenceOfUltrasoundRegions.Item_1.RegionLocationMaxX1;
X4 = parametry.SequenceOfUltrasoundRegions.Item_1.RegionLocationMaxY1;

Wbmode=X4-X2;
Dbmode=X3-X1;


I2 = imresize(stak,[160, 160],'bicubic');
I2=imcrop(I2(:,:,:,1), [14 26 125 100]); %przytnij przekrój do ramki detekcji
imsi = size(I2);
rozmiarx = imsi(1);
rozmiary = imsi(2);
rozmiarz = imsi(3);
rozmiars = size(stak,4);
stak2 = uint8(zeros(rozmiarx,rozmiary,rozmiarz,rozmiars));

for k=1:size(stak,4)
    I3 = imresize(stak,[160, 160],'bicubic'); % resize do 160x160
    I3=imcrop(I3(:,:,:,k), [14 26 125 100]);
    stak2(:,:,:,k)=I3;
end

imm = axes('Parent',f,'units','normalized',...
    'Position',[.345 .30 .33 .64]);

tabela = uitable('Parent',f,'units','normalized','Visible','off',...
    'BackgroundColor',[.79 .82 .95; .74 .82 .93],'RowStriping','on','Tag','myTable1',...
    'CellSelectionCallback',@cellSelect1);

roj1=uicontrol('Style','text',...
    'units','normalized','Visible','off',...
    'Position', [.17 .880 .1 .02],...
    'BackgroundColor',[.74 .82 .93],'String','Auto ROI');

tabela2 = uitable('Parent',f,'units','normalized','Visible','off',...
    'BackgroundColor',[.79 .82 .95; .74 .82 .93],'RowStriping','on','Tag','myTable2',...
    'CellSelectionCallback',@cellSelect2);

roj2=uicontrol('Style','text',...
    'units','normalized','Visible','off',...
    'Position', [.17 .650 .1 .02],...
    'BackgroundColor',[.74 .82 .93],'String','manual ROI');

%tabela wyników
function cellSelect1(src,evt)
index = evt.Indices;
if any(index)
    rows = index(:,1);
    set(src,'UserData',rows);
end
end

function cellSelect2(src,evt)
index = evt.Indices;
if any(index)
    rows = index(:,1);
    set(src,'UserData',rows);
end
end

%suwak przekrojów
slice_number1 = uicontrol('Style','edit',...
    'units','normalized','String','1',...
    'Position', [.495 .25 .03 .025],...
    'Callback',@slice1_number_callback);

slider1 = uicontrol('Style','slider','Parent',f,...
    'units','normalized',...
    'Position',[.345 .23 .33 .025],...
    'String','Slice number',...
    'Callback',{@slider1_callback,imm});

set(slider1,'value',1); 
set(slider1,'max',size(stak2,4)); 
set(slider1,'min',1);
set(slider1,'Sliderstep',[1/size(stak2,4), 10/size(stak2,4)] );

%przycisk do wywołania funkcji US_NcutImage
segmentation = uicontrol('Style','pushbutton','Parent',f,... 
    'units','normalized',...
    'Position',[.75 .89 .1 .04],...
    'String','Segmentation',...
    'Callback',{@US_NcutImage, sciezka});

guz = uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized',...
    'Position',[.75 .82 .1 .04],...
    'String','auto ROI',...
    'Callback',{@guz_callback,tabela});

guz2 = uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized',...
    'Position',[.75 .75 .1 .04],...
    'String','Choose ROI manually',...
    'Callback',{@guz2_callback,tabela,tabela2});

 uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized',...
    'Position',[.75 .68 .1 .04],...
    'String','Save image',...
    'Callback',@zapisz_callback);

 uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized',...
    'Position',[.7 .52 .095 .04],...
    'String','Delete row from auto ROI',...
    'Callback',@deleteRow1);

 uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized',...
    'Position',[.8 .52 .095 .04],...
    'String','Delete row from manual ROI',...
    'Callback',@deleteRow2);

uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized',...
    'Position',[.7 .59 .095 .06],...
    'String','<html><p style="text-align: center;">Copy data from table 1<br>to clipboard</p></html>',...
    'Callback',@export1_callback);

uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized',...
    'Position',[.8 .59 .095 .06],...
    'String','<html><p style="text-align: center;">Copy data from table 2<br>to clipboard</p></html>',...
    'Callback',@export2_callback);

volume = uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized','Visible','off',...
    'Position',[.70 .45 .14 .04],...
    'String','Measure total vessels volume [mm3]',...
    'Callback',{@volume_callback,tabela,tabela2});

volume_nc = uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized','Visible','off',...
    'Position',[.70 .40 .14 .04],...
    'String','Measure red vessels volume [mm3]',...
    'Callback',{@volume_nc_callback,tabela,tabela2});

volume_nb = uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized','Visible','off',...
    'Position',[.70 .27 .14 .04],...
    'String','Measure blue vessels volume [mm3]',...
    'Callback',{@volume_nb_callback,tabela,tabela2});

volume_guz = uicontrol('Style','pushbutton','Parent',f,...
    'units','normalized','Visible','off',...
    'Position',[.70 .35 .14 .06],...
    'String','Measure tumour volume [mm3]',...
    'Callback',{@volume_guz_callback,tabela,tabela2});
volume_text = uicontrol('Style','text',...
    'units','normalized','Visible','off',...
    'Position', [.70 .42 .14 .025],...
    'BackgroundColor',[.74 .82 .93]);

volume_guz_text = uicontrol('Style','text',...
    'units','normalized','Visible','off',...
    'Position', [.70 .32 .14 .025],...
    'BackgroundColor',[.74 .82 .93]);

volume_nc_text = uicontrol('Style','text',...
    'units','normalized','Visible','off',...
    'Position', [.55 .38 .14 .025],...
    'BackgroundColor',[.74 .82 .93]);

volume_nb_text = uicontrol('Style','text',...
    'units','normalized','Visible','off',...
    'Position', [.70 .245 .14 .025],...
    'BackgroundColor',[.74 .82 .93]);

imshow(stak2(:,:,:,1),'Parent',imm);

set(findobj(gcf,'type','axes'),'hittest','off');

number_errors = 0;
stak3 = zeros(size(stak2));

% usuń błędne zaznaczenia
    function deleteRow1(~,~)
        th = findobj('Tag','myTable1');
        data = get(th,'Data');
        rows = get(th,'UserData');
        mask = (1:size(data,1))';
        mask(rows) = [];
        data = data(mask,:);
        set(th,'Data',data);
    end

    function deleteRow2(~,~)
        th = findobj('Tag','myTable2');
        data = get(th,'Data');
        rows = get(th,'UserData');
        mask = (1:size(data,1))';
        mask(rows) = [];
        data = data(mask,:);
        set(th,'Data',data);
    end

    function zapisz_callback(~,~)
        klatka=getframe(imm);
        [iks,~] = frame2im(klatka);
        imshow(iks,'Parent',imm);
        imsave(imm);        
    end
    function guz_callback(~,~,tabela)
        slice = round(get(slider1,'Value'));
        im2=im2double(getimage(imm));
        [IBW2,~] = measureTumourAndVessels('','',sciezka);% //////////////////////////////////////////////
        guz = IBW2;
        guz2=bsxfun(@times,im2,guz);
        stak3(:,:,:,slice)=guz2;
        switch isempty(W1Node)
%             case 0
%                 set(tabela,'ColumnName',{'Slice number','Red vessels area [mm2]','Blue vessels area [mm2]','Total vessels area [mm2]','Tumour area [mm2]','Ratio'});
%                 set(tabela,'Position',[.071 .22 .381 .15]);
%                 set(tabela,'Visible','on');
%                 set(volume,'Visible','on');
%                 set(volume_text,'Visible','on');
%                 set(volume_guz,'Visible','on');
%                 set(volume_guz_text,'Visible','on');
%                 set(volume_nc,'Visible','on');
%                 set(volume_nc_text,'Visible','on');
%                 set(volume_nb,'Visible','on');
%                 set(volume_nb_text,'Visible','on');
%                 set(volume_guz_el_text,'Visible','on');
%                 set(volume_guz_el,'Visible','on');
%             powierzchnia_guza=length(find(guz==1));
%             im_red=stak3(:,:,1,slice);
%             im_blue=stak3(:,:,3,slice);
%             im_gray=rgb2gray(stak3(:,:,:,slice));
%             im_diff_red=imsubtract(im_red,im_gray);
%             im_diff_blue=imsubtract(im_blue,im_gray);
%             TH=graythresh(im_diff_red);
%             Ii=im2bw(im_diff_red,TH);
%             I = bwareaopen(Ii,20);
%             objectAreaInPixels_red=length(find(I==1));
%             TH2=graythresh(im_diff_blue);
%             Ii1=im2bw(im_diff_blue,TH2);
%             I1 = bwareaopen(Ii1,20);
%             objectAreaInPixels_blue=length(find(I1==1));
%             powierzchnia_guza2=powierzchnia_guza*skalaX*skalaY;
%             powierzchnia_naczyn_c = objectAreaInPixels_red*skalaX*skalaY;
%             powierzchnia_naczyn_n = objectAreaInPixels_blue*skalaX*skalaY;
%             powierzchnia_naczyn=(objectAreaInPixels_red+objectAreaInPixels_blue)*skalaX*skalaY;
%             ratio=powierzchnia_naczyn/powierzchnia_guza2;
%             dane={slice,powierzchnia_naczyn_c,powierzchnia_naczyn_n,powierzchnia_naczyn,powierzchnia_guza2,ratio};
%             olddata = get(tabela,'Data');
%             if isnan(dane{6})|| dane{6}==inf
%                 set(tabela,'Data',olddata);
%             else
%                 newdata = [olddata; dane];
%                 set(tabela,'Data',newdata);
%             end
            case 1
                %% Display
                set(tabela,'ColumnName',{'Slice number','Vessels area [mm2]','Tumour area [mm2]','Ratio'});
                set(tabela,'Position',[.10 .680 .231 .20]);
                set(tabela,'Visible','on');
                %% Variables
                set(roj1,'Visible','on');
                set(volume_nc,'Visible','off');
                set(volume_nb,'Visible','off');
                set(volume_nc_text,'Visible','off');
                set(volume_nb_text,'Visible','off');
                set(volume,'Visible','on');
                set(volume_text,'Visible','on');
                set(volume_guz,'Visible','on');
                set(volume_guz_text,'Visible','on');
                %% Calculations
            powierzchnia_guza=length(find(guz==1));
            im_red=stak3(:,:,1,slice);
            im_blue=stak3(:,:,2,slice);
            im_gray=rgb2gray(stak3(:,:,:,slice));
            im_diff_red=imsubtract(im_red,im_gray);
            im_diff_blue=imsubtract(im_blue,im_gray);
            TH=graythresh(im_diff_red);
            Ii=im2bw(im_diff_red,TH);
            I = bwareaopen(Ii,20);
            objectAreaInPixels_red=length(find(I==1));
            TH2=graythresh(im_diff_blue);
            Ii1=im2bw(im_diff_blue,TH2);
            I1 = bwareaopen(Ii1,20);
            objectAreaInPixels_blue=length(find(I1==1));
            powierzchnia_guza2=powierzchnia_guza*skalaX*skalaY;
            powierzchnia_naczyn=(objectAreaInPixels_red+objectAreaInPixels_blue)*skalaX*skalaY;
            ratio=powierzchnia_naczyn/powierzchnia_guza2;
            dane={slice,powierzchnia_naczyn,powierzchnia_guza2,ratio};
            olddata = get(tabela,'Data');
            if isnan(dane{4})|| dane{4}==inf
                set(tabela,'Data',olddata);
            else
                newdata = [olddata; dane];
                set(tabela,'Data',newdata);
            end
        end
    end

    function guz2_callback(~,~,tabela,tabela2)
        slice = round(get(slider1,'Value'));
        im2=im2double(getimage(imm));
        immmm = imfreehand(imm);
        wait(immmm);
        guz = createMask(immmm); % ręczne tworzenie maski guza
        guz3=bsxfun(@times,im2,guz);
        figure(1);imshow(guz3);
%       stak4(:,:,slice)=guz;
        stak3(:,:,:,slice)=guz3;
        
        switch isempty(W1Node)
%             case 0
%                 set(tabela2,'ColumnName',{'Slice number','Red vessels area [mm2]','Blue vessels area [mm2]','Total vessels area [mm2]','Tumour area [mm2]','Ratio'});
%                 set(tabela,'Position',[.071 .22 .381 .15]);
%                 set(tabela2,'Position',[.071 .05 .381 .15]);
%                 set(tabela,'Visible','on');
%                 set(tabela2,'Visible','on');
%                 set(roj1,'Visible','on');
%                 set(roj2,'Visible','on');
%                 set(volume,'Visible','on');
%                 set(volume_text,'Visible','on');
%                 set(volume_guz,'Visible','on');
%                 set(volume_guz_text,'Visible','on');
%                 set(volume_nc,'Visible','on');
%                 set(volume_nc_text,'Visible','on');
%                 set(volume_nb,'Visible','on');
%                 set(volume_nb_text,'Visible','on');
%                 set(volume_guz_el_text,'Visible','on');
%                 set(volume_guz_el,'Visible','on');
%             powierzchnia_guza=length(find(guz==1));
%             im_red=stak3(:,:,1,slice);
%             im_blue=stak3(:,:,3,slice);
%             im_gray=rgb2gray(stak3(:,:,:,slice));
%             im_diff_red=imsubtract(im_red,im_gray);
%             im_diff_blue=imsubtract(im_blue,im_gray);
%             TH=graythresh(im_diff_red);
%             Ii=im2bw(im_diff_red,TH);
%             I = bwareaopen(Ii,20);
%             objectAreaInPixels_red=length(find(I==1));
%             TH2=graythresh(im_diff_blue);
%             Ii1=im2bw(im_diff_blue,TH2);
%             I1 = bwareaopen(Ii1,20);
%             objectAreaInPixels_blue=length(find(I1==1));
%             powierzchnia_guza2=powierzchnia_guza*skalaX*skalaY;
%             powierzchnia_naczyn_c = objectAreaInPixels_red*skalaX*skalaY;
%             powierzchnia_naczyn_n = objectAreaInPixels_blue*skalaX*skalaY;
%             powierzchnia_naczyn=(objectAreaInPixels_red+objectAreaInPixels_blue)*skalaX*skalaY;
%             ratio=powierzchnia_naczyn/powierzchnia_guza2;
%             dane={slice,powierzchnia_naczyn_c,powierzchnia_naczyn_n,powierzchnia_naczyn,powierzchnia_guza2,ratio};
%             olddata = get(tabela2,'Data');
%             if isnan(dane{6})|| dane{6}==inf
%                 set(tabela2,'Data',olddata);
%             else
%                 newdata = [olddata; dane];
%                 set(tabela2,'Data',newdata);
%             end
            case 1
                set(tabela2,'ColumnName',{'Slice number','Vessels area [mm2]','Tumour area [mm2]','Ratio'});
                set(tabela2,'Position',[.10 .450 .231 .20]);
                set(tabela2,'Visible','on');
                set(roj2,'Visible','on');
                set(volume_nc,'Visible','off');
                set(volume_nb,'Visible','off');
                set(volume_nc_text,'Visible','off');
                set(volume_nb_text,'Visible','off');
                set(volume,'Visible','on');
                set(volume_text,'Visible','on');
                set(volume_guz,'Visible','on');
                set(volume_guz_text,'Visible','on');
            powierzchnia_guza=length(find(guz==1));
            im_red=stak3(:,:,1,slice);
            im_blue=stak3(:,:,2,slice);
            im_gray=rgb2gray(stak3(:,:,:,slice));
            im_diff_red=imsubtract(im_red,im_gray);
            im_diff_blue=imsubtract(im_blue,im_gray);
            TH=graythresh(im_diff_red);
            Ii=im2bw(im_diff_red,TH);
            I = bwareaopen(Ii,20);
            objectAreaInPixels_red=length(find(I==1));
            TH2=graythresh(im_diff_blue);
            Ii1=im2bw(im_diff_blue,TH2);
            I1 = bwareaopen(Ii1,20);
            objectAreaInPixels_blue=length(find(I1==1));
            powierzchnia_guza2=powierzchnia_guza*skalaX*skalaY;
            powierzchnia_naczyn=(objectAreaInPixels_red+objectAreaInPixels_blue)*skalaX*skalaY;
            ratio=powierzchnia_naczyn/powierzchnia_guza2;
            dane={slice,powierzchnia_naczyn,powierzchnia_guza2,ratio};
            olddata = get(tabela2,'Data');
            if isnan(dane{4})|| dane{4}==inf
                set(tabela2,'Data',olddata);
            else
                newdata = [olddata; dane];
                set(tabela2,'Data',newdata);
            end
        end
    end

    function slider1_callback(obj,~,imm)
        slice = round(get(obj,'Value'));
        imshow(stak2(:,:,:,slice),'Parent',imm);
        set(slice_number1,'String',num2str(slice));
        drawnow();
    end

    function slice1_number_callback(obj,~)
        val = str2double(get(obj,'String'));
        if isnumeric(val) && length(val) == 1 && ...
         val >= get(slider1,'Min') && ...
         val <= get(slider1,'Max')
         set(slider1,'Value',val);
         imshow(stak2(:,:,:,val),'Parent',imm);
        else
         number_errors = number_errors+1;
         set(obj,'String',...
             ['You have entered an invalid entry ',...
             num2str(number_errors),' times.']);
        end
    end
 
%skopiuj dane z tabeli w celu eksportu
    function export1_callback(~,~)
        d1 = get(tabela,'Data');
        d=cell2mat(d1);
        size_d = size(d); 
        str = ''; 
        for i=1:size_d(1) 
        for j=1:size_d(2) 
        str = sprintf ( '%s%f\t', str, d(i,j) ); 
        end 
        str = sprintf ( '%s\n', str ); 
        end 
        clipboard ( 'copy', str );
    end
 
    function export2_callback(~,~)
        d1 = get(tabela2,'Data');
        d=cell2mat(d1);
        size_d = size(d); 
        str = ''; 
        for i=1:size_d(1) 
        for j=1:size_d(2) 
        str = sprintf ( '%s%f\t', str, d(i,j) ); 
        end 
        str = sprintf ( '%s\n', str ); 
        end 
        clipboard ( 'copy', str );
    end
 
    function volume_callback(~,~,tabela,tabela2)
        danee = get(tabela,'Data');
        daneee = get(tabela2,'Data');
        checking = cell2mat(daneee);
        switch isempty(checking)
            case 1 
                switch isempty(W1Node)
                    case 1
                danee1=cell2mat(danee(:,2));
                vol1=danee1.*StepSize;
                vol=sum(vol1(:));
                set(volume_text,'String',num2str(vol));
                    case 0
                danee1=cell2mat(danee(:,4));
                vol1=danee1.*StepSize;
                vol=sum(vol1(:));
                set(volume_text,'String',num2str(vol));
                end
            case 0
                switch isempty(W1Node)
                    case 1
                danee1=cell2mat(danee(:,2));
                danee2=cell2mat(daneee(:,2));
                vol1=danee1.*StepSize;
                vol11=sum(vol1(:));
                vol12=danee2.*StepSize;
                vol2=sum(vol12(:));
                vol=vol11+vol2;
                set(volume_text,'String',num2str(vol));
                    case 0
                danee1=cell2mat(danee(:,4));
                danee2=cell2mat(daneee(:,4));
                vol1=danee1.*StepSize;
                vol11=sum(vol1(:));
                vol12=danee2.*StepSize;
                vol2=sum(vol12(:));
                vol=vol11+vol2;
                set(volume_text,'String',num2str(vol));
                end
        end
    end

    function volume_guz_callback(~,~,tabela,tabela2)
        danee = get(tabela,'Data');
        daneee = get(tabela2,'Data');
        checking = cell2mat(daneee);
        switch isempty(checking)
            case 1 
                switch isempty(W1Node)
                    case 1
                danee1=cell2mat(danee(:,3));
                vol1=danee1.*StepSize;
                vol=sum(vol1(:));
                set(volume_guz_text,'String',num2str(vol));
                    case 0
                danee1=cell2mat(danee(:,5));
                vol1=danee1.*StepSize;
                vol=sum(vol1(:));
                set(volume_guz_text,'String',num2str(vol));
                end
            case 0
                switch isempty(W1Node)
                    case 1
                danee1=cell2mat(danee(:,3));
                danee2=cell2mat(daneee(:,3));
                vol1=danee1.*StepSize;
                vol11=sum(vol1(:));
                vol12=danee2.*StepSize;
                vol2=sum(vol12(:));
                vol=vol11+vol2;
                set(volume_guz_text,'String',num2str(vol));
                    case 0
                danee1=cell2mat(danee(:,5));
                danee2=cell2mat(daneee(:,5));
                vol1=danee1.*StepSize;
                vol11=sum(vol1(:));
                vol12=danee2.*StepSize;
                vol2=sum(vol12(:));
                vol=vol11+vol2;
                set(volume_guz_text,'String',num2str(vol));
                end
        end
    end

    function volume_nc_callback(~,~,tabela,tabela2)
        danee = get(tabela,'Data');
        daneee = get(tabela2,'Data');
        checking = cell2mat(daneee);
        switch isempty(checking)
            case 1 
                danee1=cell2mat(danee(:,2));
                vol1=danee1.*StepSize;
                vol=sum(vol1(:));
                set(volume_nc_text,'String',num2str(vol));
            case 0
                danee1=cell2mat(danee(:,2));
                danee2=cell2mat(daneee(:,2));
                vol1=danee1.*StepSize;
                vol11=sum(vol1(:));
                vol12=danee2.*StepSize;
                vol2=sum(vol12(:));
                vol=vol11+vol2;
                set(volume_nc_text,'String',num2str(vol));
        end
    end

    function volume_nb_callback(~,~,tabela,tabela2)
        danee = get(tabela,'Data');
        daneee = get(tabela2,'Data');
        checking = cell2mat(daneee);
        switch isempty(checking)
            case 1 
                danee1=cell2mat(danee(:,3));
                vol1=danee1.*StepSize;
                vol=sum(vol1(:));
                set(volume_nb_text,'String',num2str(vol));
            case 0
                danee1=cell2mat(danee(:,3));
                danee2=cell2mat(daneee(:,3));
                vol1=danee1.*StepSize;
                vol11=sum(vol1(:));
                vol12=danee2.*StepSize;
                vol2=sum(vol12(:));
                vol=vol11+vol2;
                set(volume_nb_text,'String',num2str(vol));
        end        
    end

    function volume_guz_el_callback(~,~,tabela)
        switch isempty(W1Node)
            case 0
        danee = get(tabela,'Data');
        danee1=cell2mat(danee(:,5));
        [~,B] = max(danee1);
                danee2 = cell2mat(danee(:,1));
        slice = danee2(B);
        imshow(stak3(:,:,:,slice),'Parent',imm);
        set(slider1,'Value',slice);
        set(slice_number1,'String',num2str(slice));
        hh1 = imline(imm);
        wait(hh1);
        pozycja1 = getPosition(hh1);
        hh2 = imline(imm);
        wait(hh2);
        pozycja2 = getPosition(hh2);
        a = (pozycja1(2,1)-pozycja1(1,1))*skalaX;
        b = (pozycja2(2,2)-pozycja2(1,2))*skalaY;
        c = size(danee1,1);
        vol = (6/pi)*a*b*c;
        set(volume_guz_el_text,'String',num2str(vol));
            case 1
        danee = get(tabela,'Data');
        danee1=cell2mat(danee(:,3));
        [~,B] = max(danee1);
        danee2 = cell2mat(danee(:,1));
        slice = danee2(B);
        imshow(stak3(:,:,:,slice),'Parent',imm);
        set(slider1,'Value',slice);
        set(slice_number1,'String',num2str(slice));
        hh1 = imline(imm);
        wait(hh1);
        pozycja1 = getPosition(hh1);
        hh2 = imline(imm);
        wait(hh2);
        pozycja2 = getPosition(hh2);
        a = (pozycja1(2,1)-pozycja1(1,1))*skalaX;
        b = (pozycja2(2,2)-pozycja2(1,2))*skalaY;
        c = size(danee1,1)*StepSize;
        vol = (pi/6)*a*b*c;
        set(volume_guz_el_text,'String',num2str(vol));
        end
    end
    
    function US_NcutImage(~,~,sciezka)
%% Preprocesing
        sliceNumber = round(get(slider1,'Value'));
        img = dicomread(sciezka,'frames',sliceNumber);
        img = imresize(img,[160, 160],'bicubic');
        img = imcrop(img,[14 26 125 100]);
        img = im2gray(img);
        img = im2double(img);   
        [nr,nc,~] = size(img);
        
        img = imadjust(img);
        img = imcomplement(img);
        filteredImage = dpad(img,0.2,100,'cnoise',5,'big',5,'aja');
        filteredImage = filteredImage(5:end-4,5:end-4);
        filteredImage = imresize(filteredImage,[nr,nc]);
%% Segmentation
        nbSegments = 4;
        [SegLabel,~,NcutEigenvectors,~,~,~]= NcutImage(filteredImage,nbSegments);
        NC_Imgs = [];
        for j=1:nbSegments
            NC_Img = reshape(NcutEigenvectors(:,j),nr,nc);
            NC_Imgs = [NC_Imgs {NC_Img}];
        end
        bw = edge(SegLabel,0.01);
        figure(8);
        J1=showmask(filteredImage,imdilate(bw,ones(2,2))); imagesc(J1);axis off
    end
    
    function [IBW2,tumourArea] = measureTumourAndVessels(~,~,sciezka)      
%% Preprocesing
        sliceNumber = round(get(slider1,'Value'));
        img = dicomread(sciezka,'frames',sliceNumber);
        img = imresize(img,[160, 160],'bicubic');
        imgForMask = imcrop(img,[14 26 125 100]);
        imgForMask = im2double(imgForMask);
        
        img = imcrop(img,[14 26 125 100]);
        img = im2gray(img);
        img = im2double(img);   
        [nr,nc,~] = size(img);
        img = imadjust(img);
        img = imcomplement(img);
%% Segmentation
        filteredImage = dpad(img,0.2,100,'cnoise',5,'big',5,'aja');
        imgForMask = imresize(imgForMask,[nr,nc]);
        filteredImage = filteredImage(5:end-4,5:end-4);
        filteredImage = imresize(filteredImage,[nr,nc]);

        nbSegments = 4;
        [SegLabel,~,NcutEigenvectors,~,W,~]= NcutImage(filteredImage,nbSegments);
        NC_Imgs = [];
        for j=1:nbSegments
            NC_Img = reshape(NcutEigenvectors(:,j),nr,nc);
            NC_Imgs = [NC_Imgs {NC_Img}];
        end
%% Mask - uzyskaj maskę binarną guza z segmentacji
        ind = 1;
         for j=1:nbSegments
                [~, assignments] = vl_kmeans(NC_Imgs{j}(:)',2,'Initialization', 'plusplus','algorithm', 'elkan');
                for z=1:max(assignments)
                    IBW = reshape(assignments == z,nr,nc);
                    IBW = imclearborder(IBW);
                    if(max(IBW(:)) == 0)
                        ValMax(ind) = -1;
                        IBW2 = false(size(IBW));
                    else
                        stat = regionprops(IBW,'Area','PixelIdxList');
                        [ValMax(ind),indMax] = max([stat.Area]);
                        IBW2 = false(size(IBW));
                        if(~isempty(indMax))
                            IBW2(stat(indMax).PixelIdxList) = 1;
                        end
                    end
                    NC_BW{ind} = IBW2;
                    ind = ind +1;
                end
            end
        [~,indNCMax] = max(ValMax);
        IBW2 = NC_BW{indNCMax};
%% Wyświetl
        maskOverFilteredImage = imgForMask.* IBW2; %pomnóż: przekrój razy maska binarna guza
        figure(1); imshow(maskOverFilteredImage,[]);axis off
        tumourArea = bwarea(IBW2);
    end
end
