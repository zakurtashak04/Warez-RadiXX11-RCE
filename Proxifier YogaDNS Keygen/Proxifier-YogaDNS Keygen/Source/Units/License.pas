unit License;

interface

type
  TProductInfo = record
    Name: String;
    Id: LongWord;
  end;

const
  ProductList: array[0..2] of TProductInfo = (
    (Name: 'Proxifier Standard'; Id: 0),
    (Name: 'Proxifier Portable'; Id: 1),
    (Name: 'YogaDNS'; Id: 3)
  );

function GenerateLicenseKey(ProductId: LongWord; ExpYear, ExpMonth: Word): String;

implementation

//--------------------------------------------------------------------------------------------------
  
const
  Base32Charset = '0123456789ABCDEFGHIJKLMNOPQRSTUV';

//--------------------------------------------------------------------------------------------------

function DecimalToBase32(Value: LongWord; Len: Integer): String;
begin
  Result := '';

  repeat
    Result := Result + Base32Charset[(Value mod 32) + 1];
    Value := Value div 32;
  until Value = 0;

  Result := Result + StringOfChar('0', Len - Length(Result));
end;

//--------------------------------------------------------------------------------------------------

function GenerateLicenseKey(ProductId: LongWord; ExpYear, ExpMonth: Word): String;
var
  Buffer: array[0..11] of Byte;
  Value1, Value2, Value3, Value4, Value5, ProductVersion, OlderVersion, Unknown: LongWord;
  I, J, Checksum: Integer;
begin
  // Setup main license parameters /////////////////////////////////////////////////////////////////

  ProductVersion := 0;        // This value must be 0 in all products.
  OlderVersion := $7FF;       // Max possible value, should be compatible with any version.
  Unknown := Random(MaxInt);  // Unknown value/parameter, seems not to be used.

  // Encode license parameters /////////////////////////////////////////////////////////////////////

  // This value encodes the majority of the license parameters.
  Value1 := ((ProductId and $7FF) shl 21) or ((ProductVersion and $1F) shl 16) or ((OlderVersion and $7FF) shl 5) or (Unknown and $1F);
  // The high word of this value encodes the expiration date (Year/Month). If it is set to 0, indicates
  // no expiration. The low word value seems to be not used.
  Value2 := $FFFF;

  if (ExpYear >= 2000) and (ExpMonth < 12) then
    Value2 := Value2 or (Word(((ExpYear - 2000) * 12) + ExpMonth) shl 16);
  // Unknown value/parameter, seems not to be used.
  Value3 := Random(MaxInt) and $1FFFFFF;

  // Calculate checksum of encoded parameters //////////////////////////////////////////////////////

  PLongWord(@Buffer[0])^ := Value1;
  PLongWord(@Buffer[4])^ := Value2;
  PLongWord(@Buffer[8])^ := Value3;
  Checksum := -1;

  for I := 0 to 11 do
  begin
    Checksum := Checksum xor Buffer[I] shl 24;

    for J := 1 to 8 do
    begin
      if Checksum >= 0 then
        Checksum := Checksum * 2
      else
        Checksum := (Checksum * 2) xor $4C11DB7;
    end;
  end;

  // Convert encoded license parameters to Base32 //////////////////////////////////////////////////

  Value4 := LongWord(Checksum and $1FFFFFF);
  Value5 := Value4 xor (Value4 shl 7);
  Result := DecimalToBase32(Value1 xor Value5 xor $12345678, 7) + DecimalToBase32(Value2 xor Value5 xor $87654321, 7);
  Result := Result + Result[3] + DecimalToBase32(Value3, 5) + DecimalToBase32(Value4, 5);
  Result[3] := Base32Charset[Random(Length(Base32Charset) + 1)];

  // Format the output key /////////////////////////////////////////////////////////////////////////

  Insert('-', Result, 6);
  Insert('-', Result, 12);
  Insert('-', Result, 18);
  Insert('-', Result, 24);
end;

{
function Base32ToDecimal(const S: String): LongWord;
var
  I: Integer;
  C: Char;
begin
  Result := 0;

  for I := Length(S) downto 1 do
  begin
    Result := Result shl 5;
    C := S[I];

    case C of
      'W':
        begin
          C := '0';
          Dec(Result, 48);
        end;
      'X':
        begin
          C := 'O';
          Dec(Result, 55);
        end;
      'Y':
        begin
          C := '1';
          Dec(Result, 48);
        end;
      'Z':
        begin
          C := 'I';
          Dec(Result, 55);
        end;
    else
      if (Ord(C) - 48) <= 9 then
        Dec(Result, 48)
      else
        Dec(Result, 55);
    end;

    Inc(Result, Ord(C));
  end;
end;

procedure DebugLicenseKey(const Key: String);
var
  Parameter: array[0..7] of LongWord;
  Buffer: array[0..11] of Byte;
  S: String;
  KeyHash, Value1, Value2, Value3, Value4: LongWord;
  I, J, Checksum: Integer;
begin
  WriteLn('Key: ', Key);

  S := StringReplace(Key, '-', '', [rfReplaceAll]);
  S[3] := S[15];

  KeyHash := Base32ToDecimal(Copy(S, 21, 5));
  Value4 := KeyHash xor (KeyHash shl 7);

  Value1 := Base32ToDecimal(Copy(S, 1, 7)) xor Value4 xor $12345678;
  Value2 := Base32ToDecimal(Copy(S, 8, 7)) xor Value4 xor $87654321;
  Value3 := Base32ToDecimal(Copy(S, 16, 5));

  PLongWord(@Buffer[0])^ := Value1;
  PLongWord(@Buffer[4])^ := Value2;
  PLongWord(@Buffer[8])^ := Value3;
  Checksum := -1;

  for I := 0 to 11 do
  begin
    Checksum := Checksum xor Buffer[I] shl 24;

    for J := 1 to 8 do
    begin
      if Checksum >= 0 then
        Checksum := Checksum * 2
      else
        Checksum := (Checksum * 2) xor $4C11DB7;
    end;
  end;

  WriteLn('IsValid: ', KeyHash = LongWord(Checksum and $1FFFFFF));

//
// Value1 Bits: XXXXXXXXXXX XXXXX XXXXXXXXXXX XXXXX
//                   0        1        2        3
//
// Value2 Bits: XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX
//                     0                1

  Parameter[0] := Value1 shr 21; // Value1:0
  Parameter[1] := Word(Value1 shr 16) and $1F; // Value1:1
  Parameter[2] := Word(Value1) shr 5;  // Value1:2
  Parameter[3] := Word(Value1) and $1F;  // Value1:3
  Parameter[6] := Word(Value2);  // Value2:1
  Parameter[7] := Value3;

  Value4 := Word(Value2 shr 16); // Value2:0

  if (Value4 <> 0) then
  begin
    Parameter[4] := Value4 div 12 + 2000;
    Value4 := Value4 mod 12;
  end
  else
    Parameter[4] := Value4;

  Parameter[5] := Value4;

  for I := 0 to 7 do
    WriteLn(format('Parameter[%d] = %.8X',[I, Parameter[I]]));
end;
}

end.
