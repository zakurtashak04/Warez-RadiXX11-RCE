unit License;

interface

type
  TProductInfo = record
    Name: String;
    XorPassword: String;
    MD5IterCount: Integer;
  end;

const
  ProductList: array[0..1] of TProductInfo = (
    (
      Name: 'Breevy';
      XorPassword: 'https://';
      MD5IterCount: 5;
    ),
    (
      Name: 'IcyScreen';
      XorPassword: '[*] Error: Password length _must_ be greater than 0.';
      MD5IterCount: 4;
    )
  );
  
function GenerateKey(const Product: TProductInfo; const Name: String): String;
function GetUserName: String;

implementation

uses
  Windows,
  Base64,
  MD5,
  SysUtils;

//--------------------------------------------------------------------------------------------------

function ByteSwapUInt32(Value: LongWord): LongWord;
begin
  Result := ((Value and $FF) shl 24) or ((Value and $FF00) shl 8) or ((Value and $FF0000) shr 8) or ((Value and $FF000000) shr 24);
end;

//--------------------------------------------------------------------------------------------------

function IsAlpha(C: Char): Boolean;
begin
  Result := UpCase(C) in ['A'..'Z'];
end;

//--------------------------------------------------------------------------------------------------

function IsDigit(C: Char): Boolean;
begin
  Result := C in ['0'..'9'];
end;

//--------------------------------------------------------------------------------------------------

function IsHexLetter(C: Char): Boolean;
begin
  Result := UpCase(C) in ['A'..'F'];
end;

//--------------------------------------------------------------------------------------------------

function IsLower(C: Char): Boolean;
begin
  Result := C in ['a'..'z'];
end;

//--------------------------------------------------------------------------------------------------

function DigitCount(const S: String): Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 1 to Length(S) do
  begin
    if IsDigit(S[I]) then
      Inc(Result);
  end;
end;

//--------------------------------------------------------------------------------------------------

function DigitToLetterEquiv(C: Char; Flag1, Flag2: Boolean): Char;
var
  v4, v5: Byte;
begin
  Result := C;
  v4 := Ord(C) - 48;

  if v4 <= 9 then
  begin
    if Flag1 then
      v5 := 0
    else
      v5 := 32;

    if Flag2 then
      Result := Chr(v5 + 90 - v4)
    else
      Result := Chr(v5 + v4 + 65);
  end;
end;

//--------------------------------------------------------------------------------------------------

function MD5ToStrAlt(const Digest: TMD5Digest): String;
begin
  Result := LowerCase(Format('%x%x%x%x', [ByteSwapUInt32(Digest.Longs[0]), ByteSwapUInt32(Digest.Longs[1]), ByteSwapUInt32(Digest.Longs[2]), ByteSwapUInt32(Digest.Longs[3])]));
end;

//--------------------------------------------------------------------------------------------------

function Rot13Char(C: Char): Char;
var
  v1, v3, v4: Byte;
begin
  v1 := Ord(C);

  if IsAlpha(C) then
  begin
    if IsLower(C) then
    begin
      v3 := 122;
      v4 := 97;
    end
    else
    begin
      v3 := 90;
      v4 := 65;
    end;

    v1 := Ord(C) + 13;

    if v1 > v3 then
    begin
      Result := Chr(v4 + v1 - v3 - 1);
      Exit;
    end;
  end;

  Result := Chr(v1);
end;

//--------------------------------------------------------------------------------------------------

function Rot13EveryOtherHexChar(const S: String; Flag: Boolean): String;
var
  P: PChar;
  I: Integer;
  C: Char;
  IsHex: Boolean;
begin
  Result := S;
  P := PChar(Result);
  C := P^;

  if C <> #0 then
  begin
    I := 0;

    repeat
      while True do
      begin
        if (I <> 0) and Flag and ((I and 1) <> 0) then
          IsHex := IsHexLetter(Rot13Char(C))
        else
          IsHex := IsHexLetter(C);

        if IsHex then
        begin
          Inc(I);

          if (I and 1) = 0 then
            Break;
        end;

        Inc(P);
        C := P^;

        if C = #0 then
          Exit;
      end;

      P^ := Rot13Char(P^);
      Inc(P);
      C := P^;
    until C = #0;
  end;
end;

//--------------------------------------------------------------------------------------------------

function XorEncrypt(const S, Password: String): String;
var
  I: Integer;
begin
  Result := '';

  for I := 1 to Length(S) do
    Result := Result + LowerCase(IntToHex(Ord(S[I]) xor Ord(Password[((I - 1) mod Length(Password)) + 1]), 2));
end;

//--------------------------------------------------------------------------------------------------

function RoastString(const S, Password: String): String;
begin
  Result := Rot13EveryOtherHexChar(XorEncrypt(Base64Encode(S), Password), False);
end;

//--------------------------------------------------------------------------------------------------

function GenerateKey(const Product: TProductInfo; const Name: String): String;
const
  Charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
var
  S1, S2, S3: String;
  I, J: Integer;
begin
  SetLength(Result, 6);

  for I := 1 to 6 do
    Result[I] := Charset[Random(Length(Charset)) + 1];

  S1 := RoastString(Name + Result, Product.XorPassword);

  for I := 1 to Product.MD5IterCount do
    S1 := MD5ToStrAlt(MD5FromString(S1));

  S3 := '';
  I := 1;

  while I < 24 do
  begin
    S2 := Copy(S1, I, 6);

    if DigitCount(S2) > 2 then
    begin
      for J := 1 to 6 do
      begin
        if (J and 1) = 0 then
          S2[J] := DigitToLetterEquiv(S2[J], True, True);
      end;
    end;

    S3 := S3 + S2;

    Inc(I, 6);
  end;

  Delete(S3, 18, 6);
  Insert(Result, S3, 18);

  Result := UpperCase(S3);
end;

//--------------------------------------------------------------------------------------------------

function GetUserName: String;
var
  Buffer: array[0..255] of Char;
  Size: LongWord;
begin
  Size := 255;
  
  if Windows.GetUserName(Buffer, Size) then
    Result := Buffer
  else
    Result := '';
end;

end.
