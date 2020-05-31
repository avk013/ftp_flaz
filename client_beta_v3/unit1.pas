unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Ipfilebroker, FTPsend, ShellApi, FileUtil, LazFileUtils, Windows,
  Types, IniFiles;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    b_tra2serv: TButton;
    b_copyarh: TButton;
    copy_path: TEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Image1: TImage;
    label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    ListBox1: TListBox;
    PageControl1: TPageControl;
    get_sheet: TTabSheet;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    setup_sheet: TTabSheet;
    post_sheet: TTabSheet;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure b_tra2servClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure b_copyarhClick(Sender: TObject);
    procedure copy_pathDblClick(Sender: TObject);
    procedure copy_pathKeyPress(Sender: TObject; var Key: char);
    procedure Edit4Enter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  FTP: TFTPSend;
  LocalPath, RemotePath, base_dir, dir1, dir_arh_f, dir_temp, apas:string;
  pas, server,port, us_name, prefix:string;
  Ini: TIniFile;
implementation
uses lib_pro;
{$R *.lfm}

{ TForm1 }
//synapse library
procedure config();
begin //папка для беккапа
//if FileExists(base_dir+'config.ini')
end;

procedure extract_();
var // распаковка консольной версии 7-zip из файла ресурсов
  S: TResourceStream;
  F: TFileStream;
begin //распаковка архиватора если его нет
if not FileExists(base_dir+'7z.exe') then
begin
S := TResourceStream.Create(HInstance, '7Z', RT_RCDATA);
try
   // create a file mydata.dat in the application directory
   F := TFileStream.Create(ExtractFilePath(ParamStr(0)) + '7z.exe', fmCreate);
   try
     F.CopyFrom(S, S.Size); // copy data from the resource stream to file stream
   finally
     F.Free; // destroy the file stream
   end;
 finally
   S.Free; // destroy the resource stream
 end;
end;
end;


function DownloadFTP(URL, TargetFile: string): boolean;
const
  FTPPort=21;
  FTPScheme='ftp://'; //URI scheme name for FTP URLs
var
  Host: string;
  Port: integer;
  Source: string;
  FoundPos: integer;
begin
  // Strip out scheme info:
  if LeftStr(URL, length(FTPScheme))=FTPScheme then URL:=Copy(URL, length(FTPScheme)+1, length(URL));

  // Crude parsing; could have used URI parsing code in FPC packages...
  FoundPos:=pos('/', URL);
  Host:=LeftStr(URL, FoundPos-1);
  Source:=Copy(URL, FoundPos+1, Length(URL));

  //Check for port numbers:
  FoundPos:=pos(':', Host);
  Port:=FTPPort;
  if FoundPos>0 then
  begin
    Host:=LeftStr(Host, FoundPos-1);
    Port:=StrToIntDef(Copy(Host, FoundPos+1, Length(Host)),21);
  end;
  Result:=FtpGetFile(Host, IntToStr(Port), Source, TargetFile, 'anonymous', 'fpc@example.com');
  if result=false then writeln('DownloadFTP: error downloading '+URL+'. Details: host: '+Host+'; port: '+Inttostr(Port)+'; remote path: '+Source+' to '+TargetFile);
end;
function FtpGetDir(const IP, Port, Path, User, Pass: string; DirList: TStringList): Boolean;
var
  i: Integer;
  s: string;
begin
  Result := False;
  with TFTPSend.Create do
  try
    Username := User;
    Password := Pass;
    TargetHost := IP;
    TargetPort := Port;
    if not Login then
      Exit;
    Result := List(Path, False);
    for i := 0 to FtpList.Count -1 do
    begin
      s := FTPList[i].FileName;
      //DirList.Add(s);
      Form1.ListBox1.Items.Add(s);
    end;
    Logout;
  finally
    Free;
  end;
end;
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
try
////
if (FTP.Login) then
begin

///
      FTP.DirectFileName := LocalPath;
      FTP.DirectFile     := True;
     // FTP.CreateDir('1234567890');
     // FTP.RetrieveFile(RemotePath, True);
      // FTP.s
       //.StoreUniqueFile:=True;
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
// если точно все скачалось....удаляем с локального компа...
//if DeleteDirectory(dir_arh_f,False)then;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    Form1.Close;
end;

procedure TForm1.Button3Click(Sender: TObject);
var loc_dir:string;
begin
RemotePath:='';
loc_dir:=base_dir+'in_box\';
if directoryExists(loc_dir) then else  CreateDir(loc_dir);
 FTP := TFTPSend.Create;
 FTP.TargetHost := server;
 FTP.TargetPort := port;
 FTP.AutoTLS := true;
 FTP.Username := us_name;
 FTP.Password:= pas;
ShowMessage(inttostr(listbox1.ItemIndex));
//listbox1.ItemIndex индекс строки с именем файла
if listbox1.ItemIndex<>-1 then
try
////
if (FTP.Login) then
begin
///
     RemotePath:=listbox1.Items[ListBox1.ItemIndex];
     LocalPath:=loc_dir+listbox1.Items[ListBox1.ItemIndex];
      FTP.DirectFileName := LocalPath;
      FTP.DirectFile     := True;
      ShowMessage(RemotePath);
     FTP.RetrieveFile(RemotePath, True);
  end else ShowMessage('error connect or auth 2 server');
  finally
    FTP.Logout;
    FTP.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var str1:TStringList;
begin
  ListBox1.Clear;  //считываем файлы с фтп сервера
  ftpGetDir(server,port,'',us_name,pas,str1);
end;

procedure TForm1.b_copyarhClick(Sender: TObject);
var cmdline, dir2, d1,d2 :string;
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
ShowMessage(cmdline);
//dir_arh_f:=dir2+'\archive.zip';
dir_arh_f:=dir2+'\'+prefix+FormatDateTime('dd.mm.yyyy', Now)+'.zip';
//пытаемся в одну строку скопировать и архивировать файлы
cmdline:=cmdline+' & '+base_dir+'7z a -tzip -mx5 -r0 -p'+apas+' '+dir_arh_f+' '+dir_temp+ '&& NULL>'+dir_temp +'\ok2.txt';
//ShowMessage(cmdline);
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
var i:string;
begin
  if SelectDirectoryDialog1.Execute then
    begin
dir1:=SelectDirectoryDialog1.FileName;
Ini.WriteString('set','path',dir1);
copy_path.Caption:=dir1;
    end;
end;

procedure TForm1.copy_pathKeyPress(Sender: TObject; var Key: char);
begin

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
//7z a -tzip -mx5 -r0 archive.zip c:\temp
// считываем настройки из ini-файла
Ini:=TIniFile.Create(base_dir+'client_b.ini');
if (FileExists(base_dir+'client_b.ini')) then
begin
dir1:=Ini.ReadString('set','path',copy_path.Caption);
us_name:=Ini.ReadString('set','us_name',Edit4.Caption);
prefix:=Ini.ReadString('set','prefix',Edit3.Caption);
server:=Ini.ReadString('set','server',Edit1.Caption);
end else
begin
  dir1:='Y:\!test_pro\test';
  us_name:='ftp_test#21';
  prefix:='ar1_';
  server:='172.16.12.26';
//  port:='21';
  end ;
// инициализируем настройки
Form1.Left:=10;
Form1.Top:=10;
apas:='dctcnhfyyj100+';
pas:='[htyjdfzyfxbyrfeGtnhjdf';
//планируется встраивать пароль с печеньками
//pas:='3728'+us_name+'cookies_bububu';
poss:=pos('#',us_name);
port:= RightStr(us_name, Length(us_name)-poss);
//ShowMessage(port);
//
prefix:=prefix+'coo';
//папка в кото расположен
base_dir:=ExtractFileDir(Application.ExeName)+'\';
//папка для передачи
copy_path.Text:=dir1;
Edit1.Text:=server;
Edit2.Text:=base_dir;
Edit3.Text:=prefix;
Edit4.Text:=us_name;
Label6.Visible:=false;
Label7.Visible:=false;
Timer1.Enabled:=false;
b_tra2serv.Visible:=false;
Button1.Visible:=false;
extract_;
end;

procedure TForm1.Image1Click(Sender: TObject);
var pass:string;
  ipn:longword;
begin  //настройка
pass := InputBox('settings', 'password', '1000');
if (pass='1111') then
//IniFile.WriteString('local','path1',Edit2.Caption);
server:=Edit1.Text;
us_name:=Edit4.Text;
if (StrToIP(server, ipn)=False) then
ShowMessage('Format IP server not valid'+server+'_'+inttostr(ipn))
//ShowMessage(DoSomething());
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
//config();
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
begin
//  / - \ |
if (Label6.Caption='|') then Label6.Caption:='/'
else if (Label6.Caption='/') then Label6.Caption:='-'
else if (Label6.Caption='-') then Label6.Caption:='\'
else if (Label6.Caption='\') then Label6.Caption:='|';
end;

end.

