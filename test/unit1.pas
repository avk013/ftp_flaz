unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Ipfilebroker, FTPsend, ShellApi, FileUtil, LazFileUtils, Windows, Types;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    b_tra2serv: TButton;
    b_copyarh: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Image1: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    ListBox1: TListBox;
    PageControl1: TPageControl;
    get_sheet: TTabSheet;
    setup_sheet: TTabSheet;
    post_sheet: TTabSheet;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure b_tra2servClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure b_copyarhClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure get_sheetContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
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
implementation

{$R *.lfm}

{ TForm1 }
//synapse library
procedure config();
begin

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
begin
RemotePath:='';
 FTP := TFTPSend.Create;
 FTP.TargetHost := server;
 FTP.TargetPort := port;
 FTP.AutoTLS := true;
 FTP.Username := us_name;
 FTP.Password:= pas;
// RemotePath:=prefix+FormatDateTime('dd.mm.yyyy', Now)+'.7z';
ShowMessage(inttostr(listbox1.ItemIndex));
if listbox1.ItemIndex<>-1 then
// RemotePath:='1.txt';
try
////
if (FTP.Login) then
begin
///
     RemotePath:=listbox1.Items[ListBox1.ItemIndex];
      LocalPath:='C:\Users\Administrator\Documents\ftp_3\in\'+listbox1.Items[ListBox1.ItemIndex];
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
          ListBox1.Clear;
  ftpGetDir('172.16.12.26','21','','ftp_test',pas,str1);
end;

procedure TForm1.b_copyarhClick(Sender: TObject);
var cmdline, dir2, d1,d2 :string;
begin
///копирование
b_copyarh.Visible:=False;
dir2:=base_dir+'Archive';
CreateDir(dir2);
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

procedure TForm1.Button4Click(Sender: TObject);
begin
  showmessage(listbox1.Items[ListBox1.ItemIndex]);
end;

procedure TForm1.Button5Click(Sender: TObject);
begin

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//7z a -tzip -mx5 -r0 c:\temp\archive.zip c:\temp
apas:='dctcnhfyyj100+';
pas:='[htyjdfzyfxbyrfeGtnhjdf';
prefix:='ar1_';
server:='172.16.12.26';
port:='21';
us_name:='ftp_test';
//папка в кото расположен
base_dir:=ExtractFileDir(Application.ExeName)+'\';
//папка для передачи
dir1:='Y:\!test_pro\test';
Edit1.Text:=dir1;
Edit2.Text:=base_dir;
Edit3.Text:=   '';
Edit4.Text:=      '';
Label6.Visible:=false;
Label7.Visible:=false;
Timer1.Enabled:=false;
//b_tra2serv.Enabled:=false;
b_tra2serv.Visible:=false;
Button1.Visible:=false;
end;

procedure TForm1.Image1Click(Sender: TObject);
var pass:string;
begin  //настройка
pass := InputBox('settings', 'password', '1000');
if (pass='1111') then
//config();
end;

procedure TForm1.get_sheetContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

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

