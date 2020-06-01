unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Ipfilebroker, FTPsend, FileUtil, LazFileUtils, Windows,
  IniFiles;
//synapse library
type
  { TForm1 }
  TForm1 = class(TForm)
    Button1: TButton; Button2: TButton; Button3: TButton; Button4: TButton;
    b_tra2serv: TButton; b_copyarh: TButton;
    Edit1: TEdit;Edit3: TEdit;    Edit4: TEdit;
    Image1: TImage;
    Image2: TImage;
    label1: TLabel;    Label2: TLabel;    Label3: TLabel;    Label4: TLabel;
    Label5: TLabel;    Label6: TLabel;    Label7: TLabel;
    copy_path: TLabel;
    Label8: TLabel;
    ListBox1: TListBox;
    PageControl1: TPageControl;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    setup_sheet: TTabSheet;    post_sheet: TTabSheet;    get_sheet: TTabSheet;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure b_tra2servClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure b_copyarhClick(Sender: TObject);
    procedure copy_pathDblClick(Sender: TObject);
    procedure Edit4Enter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
//
  private
  public
  end;

var
  Form1: TForm1;
  FTP: TFTPSend;
  LocalPath, RemotePath, base_dir, dir1, dir_arh_f, dir_temp, apas:string;
  pas, server,port, us_name, prefix:string;
  Ini: TIniFile;
     procedure ini_init;
implementation
uses lib_pro;
{$R *.lfm}

{ TForm1 }

procedure TForm1.b_tra2servClick(Sender: TObject);
begin
if not FileExists(dir_arh_f) then ShowMessage('BUT error finding archive');
 FTP := TFTPSend.Create;
 FTP.TargetHost := server;
 FTP.TargetPort := port;
 FTP.AutoTLS := true;
 FTP.Username := us_name;
 FTP.Password:= pas;
 LocalPath:=dir_arh_f;
 RemotePath:=prefix+FormatDateTime('dd.mm.yyyy', Now)+'.7z';
try ////
if (FTP.Login) then
begin
      FTP.DirectFileName := LocalPath;
      FTP.DirectFile     := True; // FTP.CreateDir('1234567890');
if FTP.StoreFile(RemotePath, True) then
   begin
        ShowMessage('successful copying the database archive');
        b_tra2serv.Visible:=False;
        Button1.Visible:=True
        end
end else ShowMessage('error connect or auth 2 server');
  finally
    FTP.Free;
  end;
// если НУЖНО и точно все скачалось....удаляем с локального компа...
//if DeleteDirectory(dir_arh_f,False)then;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    Form1.Close;
end;

procedure TForm1.Button3Click(Sender: TObject);
var loc_dir, pas1,pass:string;
begin
RemotePath:='';
pas1:='u123z1';
pass := InputBox('settings', 'password', 'password');
if (pass=pas1) then
begin
loc_dir:=base_dir+'in_box\';
if directoryExists(loc_dir) then else  CreateDir(loc_dir);
 FTP := TFTPSend.Create;
 FTP.TargetHost := server;
 FTP.TargetPort := port;
 FTP.AutoTLS := true;
 FTP.Username := us_name;
 FTP.Password:= pas;
if listbox1.ItemIndex<>-1 then //listbox1.ItemIndex индекс строки с именем файла
try
if (FTP.Login) then
begin
     RemotePath:=listbox1.Items[ListBox1.ItemIndex];
     LocalPath:=loc_dir+listbox1.Items[ListBox1.ItemIndex];
      FTP.DirectFileName := LocalPath;
      FTP.DirectFile     := True;
      FTP.RetrieveFile(RemotePath, True);
  end else ShowMessage('error connect or auth 2 server');
  finally
    ShowMessage(RemotePath+' file retrieval process is successful!');
    FTP.Logout;
    FTP.Free;
  end else ShowMessage('You must select a file name');
end else ShowMessage('wrong password');
end;

procedure TForm1.Button4Click(Sender: TObject);
var pass:string;
begin
pass := InputBox('settings', 'password', 'password');
if (pass='1113') then  DeleteFile(PChar(base_dir+'client_b.ini'));
ini_init;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ListBox1.Clear;  //считываем файлы с фтп сервера
  ftpGetDir(server,port,'',us_name,pas,Listbox1);
end;

procedure TForm1.b_copyarhClick(Sender: TObject);
var cmdline, dir2:string;
begin
///копирование
b_copyarh.Visible:=False;
dir2:=base_dir+'Archive';
if directoryExists(dir2) then CreateDir(dir2);
CreateDir(base_dir+'Temp\');
dir_temp:=base_dir+'Temp\'+FormatDateTime('dd.mm.yyyy', Now);
CreateDir(dir_temp);
//копируем необходимые файлы и создаем файл ОК
cmdline:='xcopy /Y /E /C '+dir1+' '+dir_temp + '\ && NULL>'+dir_temp +'\ok1.txt';
dir_arh_f:=dir2+'\'+prefix+FormatDateTime('dd.mm.yyyy', Now)+'.zip';
//пытаемся в одну строку скопировать и архивировать файлы
cmdline:=cmdline+' & '+base_dir+'7z a -tzip -mx5 -r0 -p'+apas+' '+dir_arh_f+' '+dir_temp+ '&& NULL>'+dir_temp +'\ok2.txt';
// "/k" - для того чтобы консоль не закрылась...контроль, менять потом на /c
//if ShellExecute(0,nil, PChar('cmd'),PChar('/c '+cmdline),nil,1) =0 then;
if ShellExecute(0,nil, PChar('cmd'),PChar('/c '+cmdline),nil,0) =0 then;
//удаляем папку с содержимым
//if DeleteDirectory(base_dir+'Temp',False)then;
Timer1.Enabled:=True;
Timer2.Enabled:=True;
Label6.Visible:=True;
Label7.Visible:=True;
end;

procedure TForm1.copy_pathDblClick(Sender: TObject);
begin      //клик по полю с путем папок для архивирования и пересылки
  if SelectDirectoryDialog1.Execute then
    begin
    dir1:=SelectDirectoryDialog1.FileName;
//    Ini.WriteString('set','path',dir1);
    copy_path.Caption:=dir1;
    end;
end;

procedure TForm1.Edit4Enter(Sender: TObject);
var i:string;
begin
i:=Edit4.Text;
Ini.WriteString('set','us_name',i);
end;

procedure TForm1.FormCreate(Sender: TObject);
var poss: integer;
begin
Form1.BorderStyle:=bsSizeToolWin; //BsSingle
PageControl1.ActivePageIndex:=0;
Form1.Left:=10;
Form1.Top:=10;
//папка в которой расположена программа
base_dir:=ExtractFileDir(Application.ExeName)+'\';
ini_init;
//  Ini:=TIniFile.Create(base_dir+'client_b.ini');
  apas:='dctcnhfyyj100+';
  pas:='[htyjdfzyfxbyrfeGtnhjdf';
  //планируется встраивать пароль с печеньками
  //pas:='3728'+us_name+'cookies_bububu';
  poss:=pos('#',us_name);
  port:= RightStr(us_name, Length(us_name)-poss);
  prefix:=prefix+'coo';
//папка для передачи
copy_path.Caption:=dir1;
Edit1.Text:=server;Label8.Caption:=base_dir;
Edit3.Text:=prefix;Edit4.Text:=us_name;
Label6.Visible:=false;Label7.Visible:=false;
Timer1.Enabled:=false;b_tra2serv.Visible:=false;
Button1.Visible:=false;
extract_rc('7Z',base_dir+'7z.exe');//распаковываем архиватор если его нет
end;

procedure TForm1.Image1Click(Sender: TObject);
var pass:string;
  ipn:longword;
begin  //настройка
pass := InputBox('settings', 'password', 'password');
if (pass='1112') then
begin
//проверяем на валидность поля....
server:=Edit1.Text;
us_name:=Edit4.Text;
if (StrToIP(server, ipn)=False) then
ShowMessage('Format IP server not valid'+server+'_'+inttostr(ipn))
else
if (pos('#',us_name)=0) then
ShowMessage('Format username no valid, is missing #')
else
begin
Ini.WriteString('set','path',copy_path.Caption);
Ini.WriteString('set','us_name',Edit4.Caption);
Ini.WriteString('set','prefix',Edit3.Caption);
Ini.WriteString('set','server',Edit1.Caption);
end;
end;
end;
procedure TForm1.Timer1Timer(Sender: TObject);
var d1,d2:string;
begin
d1:=dir_temp + '\ok1.txt';
d2:=dir_temp + '\ok2.txt';
if FileExists(d1) then
if FileExists(d2) then
if DeleteDirectory(base_dir+'Temp',False)then
begin
b_tra2serv.Visible:=True;
Timer1.Enabled:=false;
Timer2.Enabled:=false;
Label6.Visible:=False;
Label7.Visible:=False;
end else begin end
else ShowMessage('error create arhive')
else ShowMessage('error create copies files');
if not FileExists(dir_arh_f) then ShowMessage('BUT error finding archive');
end;
procedure TForm1.Timer2Timer(Sender: TObject);
begin //  / - \ |
if (Label6.Caption='|') then Label6.Caption:='/'
else if (Label6.Caption='/') then Label6.Caption:='-'
else if (Label6.Caption='-') then Label6.Caption:='\'
else if (Label6.Caption='\') then Label6.Caption:='|';
end;
procedure ini_init;
begin // настройки из ini-файла
Ini:=TIniFile.Create(base_dir+'client_b.ini');
  if (FileExists(base_dir+'client_b.ini')) then
  begin
  dir1:=Ini.ReadString('set','path',Form1.copy_path.Caption);
  us_name:=Ini.ReadString('set','us_name',Form1.Edit4.Caption);
  prefix:=Ini.ReadString('set','prefix',Form1.Edit3.Caption);
  server:=Ini.ReadString('set','server',Form1.Edit1.Caption);
  end else
  begin
    dir1:='Y:\!test_pro\test';
    us_name:='ftp_test#21';
    prefix:='ar1_';
    server:='172.16.12.26';
    end ;// инициализируем настройки
end;
end.

