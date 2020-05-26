unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Ipfilebroker, FTPsend;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ListBox1: TListBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  FTP: TFTPSend;
  LocalPath, RemotePath:string;
implementation

{$R *.lfm}

{ TForm1 }
//synapse library
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
procedure TForm1.Button1Click(Sender: TObject);
begin
 FTP := TFTPSend.Create;
  try
////
FTP.TargetHost := '172.16.12.26';
FTP.TargetPort := '21';
//FTP.AutoTLS := true;
FTP.Username := 'ftp_usr';
FTP.Password:= 'passssss';
FTP.CreateDir('1234567890');
LocalPath:='Y:\!2020\test.txt';
RemotePath:='test+.txt';
FTP.Login ;
///
      FTP.DirectFileName := LocalPath;
      FTP.DirectFile     := True;
     // FTP.RetrieveFile(RemotePath, True);
       // FTP.StoreUniqueFile := True;
      FTP.StoreFile(RemotePath, True);
  finally
    FTP.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var str1:TStringList;
begin
  ftpGetDir('172.16.12.26','21','','ftp_usr','passssss',str1);
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
//7z a -tzip -mx5 -r0 c:\temp\archive.zip c:\temp

end;

end.

