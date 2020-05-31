unit lib_pro;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
//public
//function StrToIP(const strIP: AnsiString; out uintIP: Longword): boolean;
// end;
//private

//public

//end;
//type
//  Tlib_pro = record
//  public
// class
  //function DoSomething: string;
function StrToIP(const strIP: AnsiString; out uintIP: Longword): boolean;
//  end;
implementation

function DoSomething: string;
begin
  Result := 'Something done';
end;

function StrToIP(const strIP: AnsiString; out uintIP: Longword): boolean;
var // Автор:Николай Федоровских,fenik17,fenik17@gmail.com 4 октября 2011 г.
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
end.

