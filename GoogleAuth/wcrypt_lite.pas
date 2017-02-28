unit wcrypt_lite;

interface

uses
  Windows;

{Описания для Windows Crypto-API}

const
  PROV_RSA_FULL          = 1;
  CRYPT_VERIFYCONTEXT  = $F0000000;
  ALG_CLASS_HASH         = (4 shl 13);
  ALG_TYPE_ANY           = 0;
  ALG_SID_SHA            = 4;
  CALG_SHA              = (ALG_CLASS_HASH or ALG_TYPE_ANY or ALG_SID_SHA);
  HP_HASHVAL        = $0002; // Hash value

type
  HCRYPTPROV  = ULONG;
  PHCRYPTPROV = ^HCRYPTPROV;
  HCRYPTHASH  = ULONG;
  PHCRYPTHASH = ^HCRYPTHASH;
  HCRYPTKEY   = ULONG;
  {$IFDEF UNICODE}
    LPAWSTR = PWideChar;
  {$ELSE}
    LPAWSTR = PAnsiChar;
  {$ENDIF}
  ALG_ID = ULONG;

function CryptAcquireContextA(phProv       :PHCRYPTPROV;
                              pszContainer :PAnsiChar;
                              pszProvider  :PAnsiChar;
                              dwProvType   :DWORD;
                              dwFlags      :DWORD) :BOOL;stdcall;

function CryptAcquireContext(phProv        :PHCRYPTPROV;
                              pszContainer :LPAWSTR;
                              pszProvider  :LPAWSTR;
                              dwProvType   :DWORD;
                              dwFlags      :DWORD) :BOOL;stdcall;

function CryptAcquireContextW(phProv       :PHCRYPTPROV;
                              pszContainer :PWideChar;
                              pszProvider  :PWideChar;
                              dwProvType   :DWORD;
                              dwFlags      :DWORD) :BOOL ;stdcall;

function CryptCreateHash(hProv   :HCRYPTPROV;
                         Algid   :ALG_ID;
                         hKey    :HCRYPTKEY;
                         dwFlags :DWORD;
                         phHash  :PHCRYPTHASH) :BOOL;stdcall;
                         
function CryptHashData(hHash       :HCRYPTHASH;
                 const pbData      :PBYTE;
                       dwDataLen   :DWORD;
                       dwFlags     :DWORD) :BOOL;stdcall;

function CryptGetHashParam(hHash      :HCRYPTHASH;
                           dwParam    :DWORD;
                           pbData     :PBYTE;
                           pdwDataLen :PDWORD;
                           dwFlags    :DWORD) :BOOL;stdcall;

function CryptDestroyHash(hHash :HCRYPTHASH) :BOOL;stdcall;

function CryptReleaseContext(hProv   :HCRYPTPROV;
                             dwFlags :DWORD) :BOOL;stdcall;

implementation

function CryptAcquireContextA    ;external ADVAPI32 name 'CryptAcquireContextA';
{$IFDEF UNICODE}
function CryptAcquireContext     ;external ADVAPI32 name 'CryptAcquireContextW';
{$ELSE}
function CryptAcquireContext     ;external ADVAPI32 name 'CryptAcquireContextA';
{$ENDIF}
function CryptAcquireContextW    ;external ADVAPI32 name 'CryptAcquireContextW';
function CryptCreateHash         ;external ADVAPI32 name 'CryptCreateHash';
function CryptHashData           ;external ADVAPI32 name 'CryptHashData';
function CryptGetHashParam       ;external ADVAPI32 name 'CryptGetHashParam';
function CryptDestroyHash        ;external ADVAPI32 name 'CryptDestroyHash';
function CryptReleaseContext     ;external ADVAPI32 name 'CryptReleaseContext';

end.