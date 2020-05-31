unit lib_pro;

{$mode objfpc}{$H+}

interface

//uses
//  Classes, SysUtils, Dialogs;
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Ipfilebroker, FileUtil, LazFileUtils,Windows;
//пребраз.строки в айпи
function StrToIP(const strIP: AnsiString; out uintIP: Longword): boolean;
//распаковка из файла ресурсов
procedure extract_rc(name_rc:string;name_file_full:string);
implementation

function StrToIP(const strIP: AnsiString; out uintIP: Longword): boolean;
var // Автор функции:Николай Федоровских,fenik17,fenik17@gmail.com 04.10.2011
  pCurChar: ^byte;
  prevChar: byte;
  i, dotCount, digitCount: integer;
  x: longword;
begin
  if strIP <> '' then
  begin
    uintIP := 0;
    x := 0;
    dotCount := 0;
    pCurChar := @strIP[1];
    digitCount := 0;
    prevChar := ord('.');
    for i := length(strIP)-1 downto 0 do
    begin
      if (pCurChar^ >= ord('0')) and (pCurChar^ <= ord('9')) then
      begin
        if digitCount = 3 then break;
        x := x*10 + pCurChar^ - ord('0');
        if x > 255 then break;
        if i = 0 then
        begin
          if dotCount <> 3 then break;
          uintIP := uintIP shl 8 + x;
          Result := true;
          exit;
        end;
        inc(digitCount);
      end
      else if pCurChar^ = ord('.') then
      begin
        if (dotCount = 3) or (prevChar = pCurChar^) then break;
        inc(dotCount);
        uintIP := uintIP shl 8 + x;
        x := 0;
        digitCount := 0;
      end
      else break;
      prevChar := pCurChar^;
      inc(pCurChar);
    end;
  end;
  Result := false;
  uintIP := 0;
end;
///// ftp
///// RC
procedure extract_rc(name_rc:string;name_file_full:string);
var // распаковка из файла ресурсов
  S: TResourceStream;
  F: TFileStream;
begin //распаковка файла если  его нет
if not FileExists(name_file_full) then
begin
S := TResourceStream.Create(HInstance, name_rc, RT_RCDATA);
try
   F := TFileStream.Create(name_file_full, fmCreate);
   try
     F.CopyFrom(S, S.Size); // copy data from the resource stream to file stream
   finally
     F.Free; // destroy the file stream
   end;
 finally
   S.Free; // destroy the resource stream
 end;
end;// else ShowMessage('OK'+name_file_full);
end;
end.

