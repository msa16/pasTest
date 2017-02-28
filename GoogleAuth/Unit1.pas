unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    SecretEdit: TEdit;
    Label1: TLabel;
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  wcrypt_lite;

{$R *.dfm}

function HashSHA(const ASrc: TBytes): TBytes;
var
  hProv: HCRYPTPROV;
  hash: HCRYPTHASH;
  SigLen: DWORD;
  SBin, Sign: AnsiString;
  i: integer;
begin
{$WARN SYMBOL_PLATFORM OFF}
  {получаем контекст криптопровайдера}
  Win32Check(CryptAcquireContext(@hProv, nil, nil, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT));
  try
    {создаем хеш-объект}
    Win32Check(CryptCreateHash(hProv, CALG_SHA, 0, 0, @hash));
    try
      {хешируем пароль}
      Win32Check(CryptHashData(hash, @ASrc[0], Length(ASrc), 0));
      {достаём хэш}
      Win32Check(CryptGetHashParam(hash, HP_HASHVAL, nil, Addr(SigLen), 0));
      SetLength(Sign, SigLen);
      Win32Check(CryptGetHashParam(hash, HP_HASHVAL, PByte(PAnsiChar(Sign)), Addr(SigLen), 0));
      SBin := Sign;
    finally
      {уничтожаем хеш-объект}
      Win32Check(CryptDestroyHash(hash));
    end;
  finally
    {освобождаем контекст криптопровайдера}
    Win32Check(CryptReleaseContext(hProv, 0));
  end;
{$WARN SYMBOL_PLATFORM ON}
  SetLength(Result, Length(SBin));
  for i := 1 to Length(SBin) do
    Result [i - 1] := Ord(SBin[i]);
end;


function Base32StringDecode(Src: string): TBytes;
const
  SHIFT = 5;
  MASK = 31;
  CHAR_MAP = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
var
  OutLength, EncodedLength: integer;
  Buffer, BitsLeft, CharIndex: integer;
  C: char;
  PosIndex: integer;
  CurrByteIndex: integer;
begin
  Result := nil;
  Src := StringReplace(Src, ' ', '', [rfReplaceAll]);
  Src := StringReplace(Src, '-', '', [rfReplaceAll]);
  Src := UpperCase(Src);
  if Src = '' then
    Exit;
  EncodedLength := Length(Src);
  OutLength := (EncodedLength * SHIFT) DIV 8;
  SetLength(Result, OutLength);
  CurrByteIndex := 0;
  Buffer := 0;
  BitsLeft := 0;
  for CharIndex := 1 to Length(Src) do
  begin
    C := Src[CharIndex];
    PosIndex := Pos(C, CHAR_MAP) - 1;
    if PosIndex < 0 then
      raise Exception.Create('Illegal character: ' + c);
    Buffer := Buffer shl SHIFT;
    Buffer := Buffer or (PosIndex and MASK);
    inc(BitsLeft, SHIFT);
    if (BitsLeft >= 8) then
    begin
      Result[CurrByteIndex] := (Buffer shr (BitsLeft - 8));
      inc(CurrByteIndex);
      dec(BitsLeft, 8);
    end;
  end;
  // We'll ignore leftover bits for now.
  //
  // if (next != outLength || bitsLeft >= SHIFT) {
  //  throw new DecodingException("Bits left: " + bitsLeft);
  // }
end;

function HMACSHA1(Key, Msg: TBytes): TBytes;
const
  BLOCK_SIZE = 64;
var
  Index, TempSize: integer;
  B: byte;
  Ikeypad, Okeypad, Hash1: TBytes;
begin
  // https://ru.wikipedia.org/wiki/HMAC
  // если слишком длинный, то укорачиваем
  if Length(Key) > BLOCK_SIZE then
    Key := HashSHA(Key);
  // дополняем нулями ключ
  TempSize := Length(Key);
  SetLength(Key, BLOCK_SIZE);
  for Index := TempSize to BLOCK_SIZE - 1 do
    Key[Index] := 0;
  // Выполняем операцию «побитовое исключающее ИЛИ» c константой 0x36 и 0x5C
  SetLength(Ikeypad, BLOCK_SIZE);
  SetLength(Okeypad, BLOCK_SIZE);
  for Index := 0 to BLOCK_SIZE - 1 do
  begin
    B := Key[Index];
    Ikeypad[Index] := B xor $36;
    Okeypad[Index] := B xor $5C;
  end;
  // дополняем сообщением
  SetLength(Ikeypad, BLOCK_SIZE + Length(Msg));
  for Index := 0 to Length(Msg) - 1 do
    Ikeypad[Index + BLOCK_SIZE] := Msg[Index];
  // Применим хэш-функцию SHA-1 к строке, полученной на прошлом шаге
  Hash1 := HashSHA(Ikeypad);
  // к Okeypad дописываем Hash1
  SetLength(Okeypad, BLOCK_SIZE + Length(Hash1));
  for Index := 0 to Length(Hash1) - 1 do
    Okeypad[BLOCK_SIZE + Index] := Hash1[Index];
  Result := HashSHA(Okeypad);
end;

procedure TForm1.Button1Click(Sender: TObject);
const
  CODE_LEN = 6;
var
  Hash, Key, Msg: TBytes;
  UnixTime: int64;
  PB: PByte;
  Index: integer;
  OffSet, TruncatedHash, Code, PadLen: integer;
  Pad: string;
begin
  // https://ru.wikipedia.org/wiki/Google_Authenticator
  Key := Base32StringDecode(SecretEdit.Text);
  UnixTime := Round((Now - UnixDateDelta) * SecsPerDay);
  // floor(current Unix time / 30)
  UnixTime := UnixTime DIV 30;
  dec(UnixTime, 360);
  // копируем "текст"
  PB := Addr(UnixTime);
  SetLength(Msg, SizeOf(UnixTime));
  for Index := SizeOf(UnixTime) - 1 downto 0 do
  begin
    Msg[Index] := PB^;
    inc(PB);
  end;
                       (*
  SetLength(Key, 20);
  for Index := 0 to 19 do
    Key[Index] := $70 + Index;
  S := 'Hello World';
  SetLength(Msg, Length(S));
  for Index := 0 to Length(Msg) - 1 do
    Msg[Index] := Ord(S[Index + 1]);
                         *)
  Hash := HMACSHA1(Key, Msg);
  // last nibble of hash
  Offset := Hash[Length(Hash) - 1] and $0F;
  // truncatedHash := hash[offset..offset+3]  //4 bytes starting at the offset
  PB := Addr(Hash[0]);
  inc(PB, OffSet);
  TruncatedHash := 0;
  for Index := 0 to 3 do
  begin
    TruncatedHash := TruncatedHash shl 8;
    TruncatedHash := TruncatedHash or (PB^);
    inc(PB);
  end;
  // Set the first bit of truncatedHash to zero
  TruncatedHash := TruncatedHash and $7FFFFFFF;
  // code := truncatedHash mod 1000000
  Code := TruncatedHash MOD 1000000;
  // pad code with 0 until length of code is 6
  Pad := IntToStr(Code);
  PadLen := Length(Pad);
  if PadLen < CODE_LEN then
    Pad := StringOfChar('0', CODE_LEN - PadLen) + Pad;

  Memo1.Lines.Add(Pad);  
end;

end.
