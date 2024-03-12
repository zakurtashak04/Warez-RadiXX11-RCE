//------------------------------------------------------------------------------
// Access Password Get Keygen
//
// Product homepage: http://www.accdbpasswordrecovery.com
//
// © 2020, RadiXX11
// https://radixx11rce2.blogspot.com
//
// DISCLAIMER: This source code is distributed AS IS, for educational purposes
// ONLY. No other use is permitted without expressed permission from the author.
//------------------------------------------------------------------------------

program Keygen;

{$APPTYPE CONSOLE}

uses
  MD5,
  SysUtils;

//------------------------------------------------------------------------------

type
  TProductEdition = record
    Name: String;
    Password: String;
    IsPro: Boolean;
  end;

//------------------------------------------------------------------------------

const
  ProductEditions: array[0..2] of TProductEdition = (
    (
      Name: 'Accdb Password Get';
      Password: 'http://accdbpassword.bistonesoft.com';
      IsPro: False;
    ),
    (
      Name: 'Accdb Password Get - Idiot Version';
      Password: 'http://accdbpasswordi.bistonesoft.com';
      IsPro: False;
    ),
    (
      Name: 'Access Password Get Pro';
      Password: 'biapgpro';
      IsPro: True;
    )
  );

//------------------------------------------------------------------------------

function GenerateSerial(const ProductEdition: TProductEdition;
  const UserName: String): String;
var
  I, J, K, Value1, Value2: Integer;
begin
  Result := '';

  if UserName <> '' then
  begin
    // Pro edition uses a different algorithm than non-pro editions. 
    if ProductEdition.IsPro then
    begin
      Value1 := Random(256);
      Result := IntToHex(Value1, 2);
      J := 0;

      for I := 1 to Length(UserName) do
      begin
        if J >= Length(ProductEdition.Password) then
          J := 1
        else
          Inc(J);

        K := Ord(UserName[I]) + Value1;

        if K > 255 then
          K := K - 255;

        Value2 := K xor Ord(ProductEdition.Password[J]);
        Result := Result + IntToHex(Value2, 2);
        Value1 := Value2;
      end;
    end
    // Simple algorithm for non-pro editions, Name must be an email with a valid
    // format.
    else if Pos('@', UserName) > 0 then
      Result := MD5ToString(MD5FromString(UserName + ProductEdition.Password), True);
  end;
end;

//------------------------------------------------------------------------------

var
  UserName: String;
  I: Integer;
  Option: Char;

begin
  Randomize;

  WriteLn('Access Password Get Keygen [by RadiXX11]');
  WriteLn('========================================');

  while True do
  begin
    WriteLn;

    for I := Low(ProductEditions) to High(ProductEditions) do
      WriteLn(I + 1, '. ', ProductEditions[I].Name);

    WriteLn('0. Exit');
    WriteLn;
    Write('Option: ');
    ReadLn(Option);

    if Option in ['0'..'9'] then
    begin
      I := Ord(Option) - 48;

      if I = 0 then Exit;

      Dec(I);

      if (I >= Low(ProductEditions)) and (I <= High(ProductEditions)) then
      begin
        while True do
        begin
          WriteLn;

          if ProductEditions[I].IsPro then
            Write('Name  : ')
          else
            Write('EMail : ');

          ReadLn(UserName);

          if UserName = '' then Break;

          if (not ProductEditions[I].IsPro) and (Pos('@', UserName) = 0) then
            WriteLn('Enter an email with a valid format!')
          else
            Break;
        end;

        if UserName <> '' then
        begin
          WriteLn('Serial: ', GenerateSerial(ProductEditions[I], UserName));
          WriteLn;
          Write('Press ENTER to continue...');
          ReadLn;
        end;
      end;
    end;
  end;
end.
