unit ProgUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, vcl.Graphics, vcl.Controls, vcl.Forms,
  vcl.Dialogs, vcl.StdCtrls, vcl.ExtCtrls, ComObj, StrUtils, Menus, ComCtrls, SynEdit,
  SynEditHighlighter, SynHighlighterFortran, SynHighlighterPas;

type
  TfrmSysDyf = class(TForm)
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Panel1: TPanel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    r1: TMenuItem;
    miRun: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    Open1: TMenuItem;
    Open2: TMenuItem;
    Save1: TMenuItem;
    SynEdit: TSynEdit;
    SynEdit2: TSynEdit;
    Memo1: TMemo;
    miViewGraph: TMenuItem;
    Save2: TMenuItem;
    Panel2: TPanel;
    Panel3: TPanel;
    procedure miRunClick(Sender: TObject);
    procedure Open2Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure miViewGraphClick(Sender: TObject);
    procedure Save2Click(Sender: TObject);
    procedure SynEditChange(Sender: TObject);
    procedure DelAllinFolder(const dir: string);

  private
    { Private declarations }
  public
   procedure Ode45;
   procedure euler;
   procedure Sys;

  end;

var
  frmSysDyf: TfrmSysDyf;
  FName:string;
implementation

uses Output, SynHighlighterSample;

{$R *.dfm}

procedure TfrmSysDyf.DelAllinFolder(const dir: string);
Var SR:TSearchRec;
    FindRes:Integer;
begin
FindRes:=FindFirst(dir+'*.*',faAnyFile,SR);
While FindRes=0 do
   begin
    if ((SR.Attr and faDirectory)=faDirectory)and(SR.Name<>'.')and(SR.Name<>'..') then
      begin
        DelAllinFolder(dir+SR.Name+'\');
        RemoveDir(dir+SR.Name);
      end;
    if ((SR.Attr and faDirectory)<>faDirectory)and(SR.Name<>'.')and(SR.Name<>'..') then
        DeleteFile(dir+SR.Name);
 
      FindRes:=FindNext(SR);
   end;
FindClose(SR); 
end;


function  LastSimvDel(stroka:string):string;
//удалить последний символ
begin
result:=Copy(stroka, 1, Length(stroka)-1);
end;

function  Oshibka1(slovo:string;proverka:string;otvet:string;synedit2:tsynedit):Boolean;
begin
if (slovo=proverka) then begin
result:=false;
synedit2.Lines.Add(otvet) end else result:=true;
end;

function  Oshibka2(slovo:string;proverka1:string;proverka2:string;proverka3:string;proverka4:string;otvet:string;synedit2:tsynedit):Boolean;
begin
if ((slovo=proverka1) or (slovo=proverka2) or (slovo=proverka3)or (slovo=proverka4))then result:=true else
begin
result:=false;
synedit2.Lines.Add(otvet);
end;
end;

function  Oshibka3(slovo:string;otvet:string;synedit2:tsynedit):Boolean;
begin
try strtofloat(slovo);
result:=true;
except
result:=false;
synedit2.Lines.Add(otvet);
end;;
end;

function  Oshibka4(slovo:string;proverka:string;otvet:string;synedit2:tsynedit):Boolean;
begin
if (slovo=proverka) then begin
result:=false;
synedit2.Lines.Add(otvet) end else result:=true;
end;

function  Oshibka5(slovo:string;proverka:string;otvet:string;synedit2:tsynedit):Boolean;
begin
if (slovo=proverka) then result:=true else
begin
result:=false;
synedit2.Lines.Add(otvet);
end;
end;


function Trans( Str1, Str2 ,StrSrc, SimvDel: String):string;
//первый идентификатор, второй идентификатор, область, возможный! разделитель
var
 StrTmp:string;
 Len1, Len2: Integer;
 Pos1, Pos2: Integer;
begin
  Len1 := Length(Str1);
  Len2 := Length(Str2);
    Pos1 := PosEx(Str1, StrSrc, 1);
    if pos1=0 then result:='L';     //новое
  while Pos1 > 0 do begin
    Pos2 := PosEx(Str2, StrSrc, Pos1 + Len1);
    if Pos2 = 0 then result:='R';
    if Pos2 = 0 then Break;      //новое
    //Текст между шаблонами.
    StrTmp := Copy(StrSrc, Pos1 + Len1, Pos2 - Pos1 - Len1);
    //Если требуется убрать ведущие и ведомые пробелы.
    StrTmp := Trim(StrTmp);
    //Обрабатываем записанный в StrTmp текст - возможно записываем его в базу и пр.
 result:=result+StrTmp+SimvDel;//добавляем разделитель
    //Продолжаем поиск.
    Pos1 := Pos2 + Len2;
   Pos1 := PosEx(Str1, StrSrc, Pos1);
  end;
  end;

procedure TfrmSysDyf.Sys;
var
StrSrc: String;
k:integer;
sysdyf,name,koef,koef_term,cauchy,cauchy_term,dUdU,Chisl,Znam,method,get,get_term:string;
begin
 memo1.Clear;
  StrSrc := SynEdit.Text; //область
  k:=0;   //количество диффуров
  name:=Trans('program ',';',StrSrc,'');   //[название_проги]
  dUdU:=Trans('given ','>',StrSrc,''); //[dxdt..dydt...]
  Chisl:=Trans('d','d',dUdU,'');    //[числитель диффура]
  Znam:=Trans((Chisl+'d'),'<',dUdU+'<','');  //[знаменатель диффура]
  koef:=Trans('koef','cauchy',StrSrc,'');   //[коэфициенты]
  koef_term:=LastSimvDel(Trans('>','=',koef,',')); //[идентефикаторы коэфициентов] //удалить последний разделитель
  SysDyf:=Trans('given '+dUdU,'koef',StrSrc,'');///[система_дифф_уравнений]
  cauchy:=Trans('cauchy','method',StrSrc,''); //[задача Коши(н.у.)]
  cauchy_term:=LastSimvDel(Trans('>','=',cauchy,','));    //[идентефикаторы н.у.]
  method:=Trans('method','get',StrSrc,''); //[метод интегрирования]
  get:=Trans('get','end.',StrSrc,'');  //[что сделать в итоге(plot - график)]
  get_term:=LastSimvDel(Trans('x(',')',get,',')); //[какие функции выводить а график]  //удалить последний разделитель

  //скинуть систему диффуров на отдельную форму
   memo1.text:=sysdyf;
  k:=memo1.Lines.Count;    //количество дифуров в системе

   // первая строка - имя функции, индетефикаторы - [function имя_функции=[название_проги]_funsys(t,x)]
   memo2.Lines.Add('function '+dUdU+'='+
                    name+'_funsys'+
                    '('+Znam+','+Chisl+')');

   //вторая строка - коэфициенты
   memo2.Lines.Add(LastSimvDel(Trans('>',';',koef,';'+#13#10)));

   //третья строка - количество диф уравнений в системе - [zeros(k,1)]
   memo2.Lines.Add(dUdU+'=zeros('+inttostr(k)+', 1);');

   //вторая строка - [система дифф уравнений]
   memo2.Lines.Add(LastSimvDel(Trans('>',';',SysDyf,';'+#13#10)));   //удалить последний разделитель
end;

procedure TfrmSysDyf.Ode45;
var
StrSrc: String;
SysDyf,name,koef,koef_term,cauchy,cauchy_term,t0,dt,tn,x0,dUdU,Chisl,Znam,method,get,get_term:string;
begin
  StrSrc := SynEdit.Text; //область
  name:=Trans('program',';',StrSrc,'');   //[название_проги]
  dUdU:=Trans('given ','>',StrSrc,''); //[dxdt..dydt...]
  Chisl:=Trans('d','d',dUdU,'');    //[числитель диффура]
  Znam:=Trans((Chisl+'d'),'<',dUdU+'<','');  //[знаменатель диффура]
  koef:=Trans('koef','cauchy',StrSrc,'');   //[коэфициенты]
  koef_term:=LastSimvDel(Trans('>','=',koef,',')); //[идентефикаторы коэфициентов] //удалить последний разделитель
  SysDyf:=Trans('given '+dUdU,'koef',StrSrc,'');///[система_дифф_уравнений]
  cauchy:=Trans('cauchy','method',StrSrc,''); //[задача Коши(н.у.)]
  t0:=Trans('tspan=[',',',cauchy,'');
  dt:=Trans('h=',';',cauchy,'');
  tn:=Trans(',',';',cauchy,'');
  x0:=Trans('x0=','];',cauchy,'');
  //cauchy_term:=LastSimvDel(Trans('>','=',cauchy,','));    //[идентефикаторы н.у.]
  method:=Trans('method','get',StrSrc,''); //[метод интегрирования]
  get:=Trans('get','end.',StrSrc,'');  //[что сделать в итоге(plot - график)]
  get_term:=LastSimvDel(Trans('x(',')',get,',')); //[какие функции выводить а график]  //удалить последний разделитель


  // первая строка - имя функции, индетефикаторы - [function [название_проги]_def()]
   memo3.Lines.Add('function '+name+'_ode()');

   //вторая строка - задача Коши(н.у.)
   memo3.Lines.Add('tspan=['+t0+':'+dt+':'+tn+';');   //
   memo3.Lines.Add('x0='+x0+'];');

   //третья строка - интегрирование - [[t,x]=метод_интегрирования(@4_fun,итервал_интегрирования,Коши(н.у.));]
      memo3.Lines.Add('['+znam+','+chisl+']=ode45(@'+name+'_funsys,tspan,x0);');//интегрирование по методу Рунге Кута

   //четвертая строка - матлабовская функцияя - не отображать график при вызове plot
  memo3.Lines.Add('f = figure('+'''Visible'''+','+'''off'''+');');

   //пятая строка - строить график тех диффуров системы, которые нада отобразить
  memo3.Lines.Add(Trans('>','[',get,'')+' ('+znam+','+chisl+'(:,['+get_term+']),'+
                        '''lineWidth'''+',3);');

   //шестая строка - строит на графике сетку
  memo3.Lines.Add('grid on;');

   //седьмая строка - легенда графиков
  memo3.Lines.Add('legend('+'''x`1'''+','+'''x`2'''+','+'''x`3'''+');');

   //восьмая строка - сохранить матлабовский график
  memo3.Lines.Add('print('+'''-dbmp'''+','+'''-r80'''+','+'''graf.bmp'''+');');
end;

procedure TfrmSysDyf.Euler;
var
StrSrc: String;
SysDyf,name,koef,koef_term,cauchy,cauchy_term,t0,dt,tn,dUdU,Chisl,Znam,method,get,get_term:string;
begin
  StrSrc := SynEdit.Text; //область
  name:=Trans('program',';',StrSrc,'');   //[название_проги]
  dUdU:=Trans('given ','>',StrSrc,''); //[dxdt..dydt...]
  Chisl:=Trans('d','d',dUdU,'');    //[числитель диффура]
  Znam:=Trans((Chisl+'d'),'<',dUdU+'<','');  //[знаменатель диффура]
  koef:=Trans('koef','cauchy',StrSrc,'');   //[коэфициенты]
  koef_term:=LastSimvDel(Trans('>','=',koef,',')); //[идентефикаторы коэфициентов] //удалить последний разделитель
  SysDyf:=Trans('given '+dUdU,'koef',StrSrc,'');///[система_дифф_уравнений]
  cauchy:=Trans('cauchy','method',StrSrc,''); //[задача Коши(н.у.)]
  cauchy_term:=LastSimvDel(Trans('>','=',cauchy,','));    //[идентефикаторы н.у.]
  t0:=Trans('tspan=[',',',cauchy,'');

  dt:=Trans('h=',';',cauchy,'');

  tn:=Trans(',','];',cauchy,'');
  method:=Trans('method','get',StrSrc,''); //[метод интегрирования]
  get:=Trans('get','end.',StrSrc,'');  //[что сделать в итоге(plot - график)]
  get_term:=LastSimvDel(Trans('x(',')',get,',')); //[какие функции выводить а график]  //удалить последний разделитель


  // первая строка - имя функции, индетефикаторы - [function [название_проги]_def()]
   memo4.Lines.Add('function [ts,data]='+name+'_euler()');

   //вторая строка - задача Коши(н.у.)
   memo4.Lines.Add('x0'+(Trans('>x0','];',cauchy,'];')));   //удалить последний разделитель

   memo4.Lines.Add('t0='+t0+';dt='+dt+';tn='+tn+';');

   memo4.Lines.Add('Nsteps = round(tn/dt);');
   memo4.Lines.Add('ts = zeros(Nsteps,1);');
   memo4.Lines.Add('data = zeros(Nsteps,length(x0));');
   memo4.Lines.Add('ts(1) = t0; ');
   memo4.Lines.Add('data(1,:) = x0'+''''+';');
   memo4.Lines.Add('for i =1:Nsteps');
   memo4.Lines.Add(dUdU+'= feval(@'+name+'_funsys'+',t0,x0);');
   memo4.Lines.Add('x0=x0+'+dudu+'*dt;');
   memo4.Lines.Add('t0 = t0+dt;');
   memo4.Lines.Add('ts(i+1) = t0;');
   memo4.Lines.Add('data(i+1,:) = x0'+''''+';');
   memo4.Lines.Add('end');
   memo4.Lines.Add('f = figure('+'''Visible'''+','+'''off'''+');');
   memo4.Lines.Add(Trans('>','[',get,'')+' ('+'ts'+ ','+'data'+'(:,['+get_term+']),'+
                        '''lineWidth'''+',3);');
   memo4.Lines.Add('grid on;');
   memo4.Lines.Add('legend('+'''x`1'''+','+'''x`2'''+','+'''x`3'''+');');
   memo4.Lines.Add('print('+'''-dbmp'''+','+'''-r80'''+','+'''graf1.bmp'''+');');
   memo4.Lines.Add('end');
end;

procedure TfrmSysDyf.miRunClick(Sender: TObject);
var
StrSrc: String;
k:integer;
dt:real;
SysDyf,name,koef,koef_term,cauchy,cauchy_term,dUdU,Chisl,Znam,method,get,get_term:string;
f:tstrings;
matlab:variant;
error:boolean;
begin
  StrSrc := SynEdit.Text; //область
  memo4.Clear;
  Memo2.Clear;
  Memo3.Clear;
  memo1.Clear;
  synedit2.Clear;
  name:=Trans('program ',';',StrSrc,'');   //[название_проги]
  dUdU:=Trans('given ','>',StrSrc,''); //[dxdt..dydt...]
  Chisl:=Trans('d','d',dUdU,'');    //[числитель диффура]
  Znam:=Trans((Chisl+'d'),'<',dUdU+'<','');  //[знаменатель диффура]
  koef:=Trans('koef','cauchy',StrSrc,'');   //[коэфициенты]
  koef_term:=LastSimvDel(Trans('>','=',koef,',')); //[идентефикаторы коэфициентов] //удалить последний разделитель
  SysDyf:=Trans('given '+dUdU,'koef',StrSrc,'');///[система_дифф_уравнений]
  cauchy:=Trans('cauchy','method',StrSrc,''); //[задача Коши(н.у.)]

  cauchy_term:=LastSimvDel(Trans('>','=',cauchy,','));    //[идентефикаторы н.у.]
  method:=Trans('method','get',StrSrc,''); //[метод интегрирования]
  get:=Trans('get','end.',StrSrc,'');  //[что сделать в итоге(plot - график)]
  get_term:=LastSimvDel(Trans('x(',')',get,',')); //[какие функции выводить а график]  //удалить последний разделитель


 //____________________________________________

  //первый файл - [название проги_fun.m]

   Sys;

  //_________________________________________

  //второй файл - [название проги_def.m]

   if Trans('>',';',method,'')='ode45' then    //поиск ключевого слова метода
begin
   Ode45;
end;
   if Trans('>',';',method,'')='euler' then    //поиск ключевого слова метода
begin
    euler;
end;
   if (Trans('>',';',method,'')='ode45euler') or (Trans('>',';',method,'')='eulerode45')then    //поиск ключевого слова метода
begin
    Ode45;
    euler;
end;

       //отлов ошибок построчно
     if (
         ((oshibka4(Trans('program','end.',strsrc,''),'L','ошибка: нету слова "program"',synedit2)=true) and
          (oshibka4(Trans('program','end.',strsrc,''),'R','ошибка: нету слова "end."',synedit2)=true))and

         ((oshibka4(name,'L','ошибка: нет пробела между "program" и "name_program"',synedit2)=true) and
          (oshibka1(name,'','ошибка: отсутсвует "name_program"',synedit2)=true)) and

       ((oshibka4(Trans('given','koef',strsrc,''),'L','ошибка: нету слова "given"',synedit2)=true)  and
          (oshibka1(Trans('given','>',strsrc,''),'','ошибка: отсутствует name_sys_diff',synedit2)=true) and
          (oshibka4(dudu,'L','ошибка: нету пробела между "given" и "name_sys_diff"',synedit2)=true)) and

         ((oshibka4(znam,'L','ошибка: некоректное "name_sys_diff". только "dxdt"',synedit2)=true)  and
          (oshibka4(Chisl,'R','ошибка: некоректоное "name_sys_diff". только "dxdt"',synedit2)=true)) and

         ((oshibka1(Chisl,'','ошибка: нет числителя в "name_sys_diff"',synedit2)=true) and
          (oshibka1(znam,'','ошибка: нет знаменателя "name_sys_diff"',synedit2)=true) and
          (Oshibka5(chisl,'x','ошибка: некоректный числитель. только "x"',synedit2)=true)and
          (Oshibka5(znam,'t','ошибка: некоректный знаментаель. только "t"',synedit2)=true)) and

         ((oshibka1(Trans('given '+dudu,'koef',strsrc,''),'','error:  System diff - emperty',synedit2)=true) and
          (oshibka1(Trans('>',';',sysdyf,''),'','error: ">name_diff(i)=[equation];..." not found',synedit2)=true))and

         ((oshibka4(koef,'L','ошибка: нету слова koef',synedit2)=true)and
        (oshibka1(koef,'','koef -emprty',synedit2)=true)and
        (oshibka1(Trans('>',';',koef,''),'','error: not found Koef',synedit2)=true))

             {

         ((oshibka1(sysdyf,'','error: "koef" not found. or System diff - emperty',synedit2)=true) and
          (oshibka1(Trans('>',';',sysdyf,''),'','error: ">name_diff(i)=[equation];..." not found',synedit2)=true)) and

         ((oshibka1(koef,'','error: "cauchy" not found.  or koef -emprty',synedit2)=true) and
          (oshibka1(Trans('>',';',koef,''),'','error: not found Koef',synedit2)=true)) and

         ((oshibka1(cauchy,'','error: "method" not found.  or cauchy -emprty',synedit2)=true) and
         (oshibka1(Trans('>',';',cauchy,''),'','error: not found Cauchy',synedit2)=true) and
         (oshibka1(Trans('h=',';',cauchy,''),'','ошибка: пустой шаг',synedit2)<>false) and
         (oshibka3(Trans('h=',';',cauchyё,''),'ошибка: шаг не число',synedit2)=true)) and

         ((oshibka1(method,'','error: "get" not found.  or method -emprty',synedit2)=true) and
           (oshibka1(Trans('>',';',method,''),'','error: ">method;" not found ',synedit2)=true) and
           (oshibka2(Trans('>',';',method,''),'ode45','euler','ode45euler','eulerode45','error: method "'+(Trans('>',';',method,''))+'" not found',synedit2)=true)) and

         ((oshibka1(get,'','error: "end."not found.  or get -emprty',synedit2)=true)and
          (oshibka1(Trans('>',';',get,''),'','error: ">plot [x(1),...x(i)];" not found',synedit2)=true))  }
         ) then


     //сохраняем файлики
     begin

     //но перед эти подчищаем в ней все
    DelAllinFolder(ExtractFilePath(Application.ExeName)+'data\');
     try

  f:=TStringList.Create();
  f.Add(memo2.text);
  f.SaveToFile(ExtractFilePath(Application.ExeName)+'data\'+name+'_funsys.m');
  f.Free;
  if Trans('>',';',method,'')='ode45' then
   begin
  f:=TStringList.Create();
  f.Add(memo3.text);
  f.SaveToFile(ExtractFilePath(Application.ExeName)+'data\'+name+'_ode.m');
  f.Free;
   end;
  if Trans('>',';',method,'')='euler' then
   begin
  f:=TStringList.Create();
  f.Add(memo4.text);
  f.SaveToFile(ExtractFilePath(Application.ExeName)+'data\'+name+'_euler.m');
  f.Free;
   end;
  if (Trans('>',';',method,'')='ode45euler') or (Trans('>',';',method,'')='eulerode45')then
   begin
  f:=TStringList.Create();
  f.Add(memo3.text);
  f.SaveToFile(ExtractFilePath(Application.ExeName)+'data\'+name+'_ode.m');
  f.Free;
  f:=TStringList.Create();
  f.Add(memo4.text);
  f.SaveToFile(ExtractFilePath(Application.ExeName)+'data\'+name+'_euler.m');
  f.Free;
   end;
  error:=true;
  except
  error:=false;
  synedit2.Lines.Add('error: ";" after "program NAME" not found');

  end;
   if error=true then
      begin
        SynEdit.Enabled:=false;
  SynEdit.Color:=clSilver;
  //запускаем ComObj малаб

  try
matlab:=CreateOleObject('Matlab.Application');
except
    ShowMessage('Could not start MatLab .');
         end;

matlab.execute('cd '+''''+ExtractFilePath(Application.ExeName)+'data''');   //перехожим в директори наших файлов

if Trans('>',';',method,'')='ode45' then
matlab.execute(name+'_ode');

if Trans('>',';',method,'')='euler' then
matlab.execute(name+'_euler');

if (Trans('>',';',method,'')='ode45euler') or (Trans('>',';',method,'')='eulerode45')then
begin
matlab.execute(name+'_ode');
matlab.execute(name+'_euler');
end;

try
frmOutput.image1.Picture.LoadFromFile(ExtractFilePath(Application.ExeName)+'data\graf.bmp');
frmOutput.image2.Picture.LoadFromFile(ExtractFilePath(Application.ExeName)+'data\graf1.bmp');
frmOutput.show;
except
frmOutput.show;
SynEdit.Lines.add('Graph not not received');
SynEdit.Enabled:=true;
SynEdit.Color:=clCream;
end;

  end;
end
else

end;

procedure TfrmSysDyf.Open2Click(Sender: TObject);
var
FName:string;
begin
SynEdit.Clear;
OpenDialog.InitialDir:=ExtractFilePath(Application.ExeName)+'program';
if OpenDialog.Execute then
 begin
  FName := OpenDialog.FileName;
  SynEdit.Lines.LoadFromFile(FName);
 end;
frmSysDyf.Caption:=FName;

end;

procedure TfrmSysDyf.Save1Click(Sender: TObject);
var
FName:string;
begin
SaveDialog.InitialDir:=ExtractFilePath(Application.ExeName)+'program';
SaveDialog.FileName := FName;
if SaveDialog.Execute then
 begin
  FName := SaveDialog.FileName;
  SynEdit.Lines.SaveToFile(FName+'.txt');
 end;
 end;

procedure TfrmSysDyf.Open1Click(Sender: TObject);
var
f:tstrings;
i:integer;
fname:string;
begin
fname:='NEW';
SynEdit.Clear;
f:=TStringList.Create();
f.LoadFromFile(ExtractFilePath(Application.ExeName)+'план.txt');
for i:=0 to f.Count-1 do
SynEdit.Lines.Add(f.Strings[i]);
f.Free;
frmSysDyf.Caption:=(ExtractFilePath(Application.ExeName)+'program\'+fname+'.txt');
end;


procedure TfrmSysDyf.FormCreate(Sender: TObject);
var
  HL: TSynSampleSyn;
begin
DecimalSeparator := '.';
memo1.clear;
SynEdit.Color:=clCream;
HL := TSynSampleSyn.Create(Self);
SynEdit.Highlighter := HL;
//SynEdit.Gutter.Width:=20;
//SynEdit.ClearAll;
//SynEdit1.Text := HL.SampleSource;
end;

procedure TfrmSysDyf.miViewGraphClick(Sender: TObject);
begin
frmOutput.Show;
end;

procedure TfrmSysDyf.Save2Click(Sender: TObject);
var
f:tstrings;
fname:string;
i:integer;
begin
fname:=Trans(ExtractFilePath(Application.ExeName)+'program\','.txt', frmSysDyf.Caption,'');
f:=TStringList.Create();
for i:=0 to SynEdit.Lines.Count do
f.Add(SynEdit.Lines[i]);
f.SaveToFile(ExtractFilePath(Application.ExeName)+'program\'+fname+'.txt');
f.free;
frmSysDyf.Caption:=(ExtractFilePath(Application.ExeName)+'program\'+fname+'.txt');
save2.Enabled:=false;
panel2.Caption:='';
end;

procedure TfrmSysDyf.SynEditChange(Sender: TObject);
var
fname,change:string;
begin
change:='changes to the file are not saved';
fname:=Trans(ExtractFilePath(Application.ExeName)+'program\','.txt', frmSysDyf.Caption,'');
frmSysDyf.Caption:=(ExtractFilePath(Application.ExeName)+'program\'+fname+'.txt***');
save2.Enabled:=true;
frmSysDyf.color:=clred;
panel2.Caption:=change;
end;


end.

