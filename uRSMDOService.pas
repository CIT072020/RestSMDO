unit uRSMDOService;

interface

{$DEFINE SYNA}
{$DEFINE DEBUG_SYNA}

{$WARN SYMBOL_PLATFORM OFF}

uses
  SysUtils,
  Classes,
  Types,
  DB,
  kbmMemTable,
  superobject,
  superdate,
  synacode,
 {$IFDEF SYNA} httpsend,  {$ENDIF}
  uAvest,
  AvCryptMail,
  SasaINiFile;

const

  // Секции INI-файла
  SCT_ADMIN   = 'ADMIN';
  SCT_HOST    = 'REST-HOST';
  SCT_SECURE  = 'REST-SECURE';
  SCT_NSI     = 'NSI';

  // Запросы к Маршрутизатору СМДО (символьные коды)
  REQ_GET_TOKEN   = 'GET_TOKEN';
  REQ_CREATE_PKG  = 'CREATE_PKG';
  REQ_ADD_ATTACH  = 'ADD_ATTACH';
  REQ_SEND_PKG    = 'SEND_PKG';
  REQ_GET_PKGLIST = 'GET_PKGLIST';


  // Строка-разделитель в теле запроса при передаче файлов
  FILE_BOUND = '=Cit^B=B04C839E-508D-4198-A7C0-7003285F5C06=Cit^B=';

  // Тип содержимого в HTTP-запросе
  CNT_TYPE_ATTACH = 'multipart/form-data; boundary=';


  // Режим формирования ЭЦП
  SIGN_NO         = 0;    // Подпись не требуется
  SIGN_WITH_DATA  = 1;
  SIGN_WITH_CERT  = 2;
  SIGN_ONLY       = 3;

  // Режим работы с RAW ЭЦП
  SIGN_WITH_ASN   = 1;
  SIGN_NO_ASN     = 2;

  // Имя файлов запрос/ответ
  HEADS_REQ       = 'Запрос-Заголовки-RSMDO.log';
  HEADS_ANS       = 'Ответ-Заголовки-RSMDO.log';

  //
  ERR404_MSG = ' Упс! Что-то пошло не так...';
  ERR401_MSG = 'Токен авторизации не действителен';
  ERR401_NOTK_MSG = 'Токен авторизации не получен';

type
  // Настройки для сервера
  THostRSMDO = class(TObject)
  public
  // путь к сервису
    URL        : string;
    Vers       : string;
    UserType   : string;
    HeaderId   : string;
    ResourcePath    : string;

    ResPathTest  : string;
    MaxDays    : Integer;
    MaxPersData: Integer;
    GetFormat  : string;
    PostFormat : string;

    constructor Create(Meta : TSasaIniFile);
    destructor Destroy; override;
  end;

  // Парметры допустимых HTTP-запросов
  TRoutRequestInf = class
  private
  public
    Method       : string;
    Context      : string;

    PackageId    : Boolean;
    AttachId     : Boolean;
    ConfirmId    : Boolean;

    ResourcePath : string;
    ResourcePars : string;

    ContentType  : string;

    constructor Create(const Meth, Ctxt : string; AttId : Boolean = False; CfmId : Boolean = False);
  end;

  // Synapse расширенный (свои DLL)
  THTTPSendEx = class(THTTPSend)
  private
    FSynaDllPath : string;
    procedure WriteSynaLog(HeadersList : TStringList);
    function InitSSLInterfaceEx(OpenSSLPath : string) : Boolean;
  public
    function HTTPMethodEx(const Method, URL: string) : Boolean;

    constructor Create(OpenSSLPath : string);
  end;


  // Поддержка ЭЦП и сертификатов
  TSecureRSMDO = class
  private
    FMeta       : TSasaIniFile;
    FAvest      : TAvest;

    FLoginRSMDO : string;
    FPasswRSMDO : string;
    FAccessAuthType : string;
    FAccessAuth  : string;

    FApiAuthType: string;
    FApiAuth    : string;

    //FSign     : string;
    //FSignRaw  : string;
    //FCertif   : string;
    //FAuth     : string;
    //FSrvTest  : string;

    //FPubKey   : string;
    //FSignPost : Boolean;
    // Способ формирования ЭЦП для сообщения
    FSignMode : Integer;
    // Использование формата ASN при формировании ЭЦП для RAW
    FASNMode  : Integer;

    //FSignGet  : Boolean;
    // Запрос пароля только 1 раз
    FAskPassOnce  : Boolean;

    procedure DebSec(FileDeb: String; x: Variant);
    function AvestReady(var strErr: String): Boolean;
    function TryOpenSess(var hSession: AvCmHc; UseDef : Boolean = True) : DWORD;

    function SignTextRaw(var sText, sSign: ANSIString; var sCert:String; lOpenDefSession: Boolean; AsnMode : DWORD) : Boolean;
    function VerifyTextRaw(sText: ANSIString; sSign: ANSIString; sCert: String; lOpenDefSession: Boolean; AsnMode : DWORD) : Boolean;
    function GetAccessAuth : string;
    function GetApiAuth : string;
  public
    property Meta : TSasaIniFile read FMeta;
    property Avest : TAvest read FAvest write FAvest;

    property UserRSMDO : string read FLoginRSMDO;
    property PassRSMDO : string read FPasswRSMDO;
    property AccessAuthType : string read FAccessAuthType;
    property AccessAuth : string read GetAccessAuth;

    property ApiAuthType : string read FApiAuthType write FApiAuthType;
    property ApiAuth : string read GetApiAuth;

    //property Sign : string read FSign write FSign;
    //property Certif : string read FCertif write FCertif;
    //property PubKey : string read FPubKey write FPubKey;
    //property SignRaw : string read FSignRaw write FSignRaw;
    //property Auth : string read FAuth write FAuth;


    //property SignPost : Boolean read FSignPost write FSignPost;
    //property SignMode : Integer read FSignMode write FSignMode;
    //property SignGet : Boolean read FSignGet write FSignGet;

    procedure SetAccessAuth(AUser : string = ' '; APass : string = ' '; AType : string = ' ');
    procedure SetApiAuth(AVal : string = ' '; AType : string = ' ');
    function IsEmptyAuth : Boolean;
    function CreateESign(var sUtf8: Utf8String; SignType : Integer; var strErr: String): Boolean;
    function VerifyESign(var sSignedUTF: Utf8String; const sSign, sCert, sSignRaw : string; var strErr: String): Boolean;

    constructor Create(MetaINI : TSasaIniFile);
    destructor Destroy; override;
  end;




(*
 Выходные результаты для GET/POST
*)
  TResultHTTP = class
  private
    FCode    : Integer;
    FMsg     : string;
    FStrInf  : string;
    FRequest : string;
    FSOAns   : ISuperObject;
  protected
  public
    // Код запроса
    property ReqId    : string read FRequest write FRequest;
    // Результат запроса, 0 - все гут
    property ResCode  : Integer read FCode write FCode;
    // Сообщение об ошибке
    property ResMsg   : string read FMsg write FMsg;
    // Результат запроса в виде символьной строки (например, временный ИН)
    property StrInf   : string read FStrInf write FStrInf;
    // JSON-ответ в виде SuperObject
    property SOAnswer : ISuperObject read FSOAns write FSOAns;

    procedure ClearRes(ReqCode: string);

    constructor Create(ReqCode : string = '');
    destructor Destroy; override;
  end;

  // Отображение прогресса обработки
  TShowProgress = class
  private
    FAutoOf,
    FNeedShow : Boolean;
    FSingleMax,
    FSingleCurrent,
    FTotMax,
    FTotCurrent : Integer;
    FRawTot,
    FRawCurrent : Int64;
    FRawK : Double;
    FDivider : Integer;
    FEventRise : Integer;
  public

    // Абсолютные значения
    property RawTot  : int64 read FRawTot write FRawTot;
    property RawCurr : int64 read FRawCurrent write FRawCurrent;
    property RawK    : Double read FRawK write FRawK;
    property Divider  : integer read FDivider write FDivider;

    // Установка режима отображения прогресса обработки
    function SetProgressVisible(ShowNow: Boolean = True; AOff : Boolean = True): Boolean;
    function WhenReact(SetDivider : integer = -1): Boolean;

    // Настройка отображения прогресса обработки всего пакета
    procedure PrepareShow(const WinCaption, TotInf: string; TotMax: Integer = 100);
    // Прогресс обработки всего пакета
    procedure ChangeShow(TotPos: Integer; TotInf: string = '');
    // Уточнение и отображение обработки всего пакета
    function AdjustTotalVals(NewMaxVal : Integer = -1; NewCurVal : Integer = -1) : Integer;
    function AdjustSingleVals(NewMaxVal: Integer = -1; NewCurVal: Integer = -1): Integer;

    // Настройка текущей обработки из пакета
    procedure PrepareSingleShow(const SingleInf: string; MaxVal : Integer = 100);
    // Прогресс текущей обработки из пакета
    procedure ChangeSingleShow(SinglePos : Integer; SingleInf : string = '');

    procedure CloseShow;

    constructor Create;
  end;

function GetDLoadSize(const URL: string): Int64;
function PrepareFile4Post(const FileName: string; const DataFile, DocStream: TStream): Boolean;

var
  Bound : string;
  RouterRequests : TStringList;



implementation

uses
  {$IFDEF SSL} ssl_openssl, ssl_openssl_lib, blcksock,{$ENDIF}
  synautil,
  fmProgress,
  FuncPr,
  uUseful;
  
var
  i : Integer;
  ReqInf : TRoutRequestInf;

// Описание одного HTTP-запроса GET/POST
constructor TRoutRequestInf.Create(const Meth, Ctxt : string; AttId : Boolean = False; CfmId : Boolean = False);
begin
  inherited Create;
  Method       := Meth;
  Context      := Ctxt;

  PackageId    := True;
  AttachId     := AttId;
  ConfirmId    := CfmId;

  ResourcePath := '';
  ResourcePars := '';

  ContentType  := 'application/json';
end;


// Поддержка ЭЦП и сертификатов
constructor TSecureRSMDO.Create(MetaINI : TSasaIniFile);
var
  s : string;
begin
  inherited Create;
  //FSign    := 'amlsnandwkn&@871099udlaukbdeslfug12p91883y1hpd91h';
  //FCertif  := '109uu21nu0t17togdy70-fuib';
  FMeta := MetaINI;
  Avest := TAvest.Create;
  Avest.FDeleteCRLF := True;
  Avest.Debug := False;
  FAskPassOnce := True;

  Avest.Debug := Meta.ReadBool(SCT_ADMIN, 'DEBUG', Avest.Debug);

  SetAccessAuth( Meta.ReadString(SCT_SECURE, 'LOGIN_RSMDO', ''),
                Meta.ReadString(SCT_SECURE, 'PASSW_RSMDO', ''),
                Meta.ReadString(SCT_SECURE, 'AUTH_RSMDO', 'Basic'));
  SetApiAuth('', '');

(*
  FAuth := Meta.ReadString(SCT_SECURE, 'AUTHOR', '');
  s     := Meta.ReadString(SCT_SECURE, 'AUTHOR_TYPE', '');
  if (FAuth <> '') then
    if (s <> '') then
      FAuth := s + ' ' + FAuth;
  FSrvTest := Meta.ReadString(SCT_SECURE, 'SRV_TEST', '');
  if (FSrvTest <> '') then
    if (s <> '') then
      FSrvTest := s + ' ' + FSrvTest;

  SignPost := Meta.ReadBool(SCT_SECURE, 'SIGNPOST', False);
  // Default - AVCMF_ADD_SIGN_CERT
  SignMode := Meta.ReadInteger(SCT_SECURE, 'SIGNMODE', SIGN_WITH_DATA);
  SignGet  := Meta.ReadBool(SCT_SECURE, 'SIGNGET', False);
*)

  FASNMode := SIGN_NO_ASN;

  FAskPassOnce := Meta.ReadBool(SCT_SECURE, 'ONLY1PASS', FAskPassOnce);
end;

destructor TSecureRSMDO.Destroy;
begin
  FreeAndNil(FAvest);
  inherited;
end;

function TSecureRSMDO.GetAccessAuth : string;
begin
  Result := FAccessAuthType + ' ' + FAccessAuth;
end;
procedure TSecureRSMDO.SetAccessAuth(AUser : string = ' '; APass : string = ' '; AType : string = ' ');
begin
  if (AUser <> ' ') then
    FLoginRSMDO := AUser;
  if (APass <> ' ') then
    FPasswRSMDO := APass;
  if (AType <> ' ') then
    FAccessAuthType := AType;
  FAccessAuth := EncodeBase64(FLoginRSMDO + ':' + FPasswRSMDO);
end;

function TSecureRSMDO.GetApiAuth : string;
begin
  Result := FApiAuthType + ' ' + FApiAuth;
end;


function TSecureRSMDO.IsEmptyAuth : Boolean;
begin
  Result := Iif( (Length(Trim(FApiAuthType)) = 0) or
                 (Length(Trim(FApiAuth)) = 0), True, False);
end;


procedure TSecureRSMDO.SetApiAuth(AVal : string = ' '; AType : string = ' ');
begin
  if (AVal <> ' ') then
    FApiAuth := AVal;
  if (AType <> ' ') then
    FApiAuthType := AType;
end;


// Результат GET/POST
constructor THostRSMDO.Create(Meta : TSasaIniFile);
begin
  inherited Create;
  URL      := Meta.ReadString(SCT_HOST, 'URL', 'https://gw.nces.by/api');
  Vers     := Meta.ReadString(SCT_HOST, 'VERS', '/1.0.0');
  UserType := Meta.ReadString(SCT_HOST, 'USERTYPE', '/org');
  HeaderId := Meta.ReadString(SCT_HOST, 'HEADERID', '/smdo~1.0.0');
  ResourcePath  := Meta.ReadString(SCT_HOST, 'ResourcePath', '/package');
end;

destructor THostRSMDO.Destroy;
begin
  inherited;
end;




constructor THTTPSendEx.Create(OpenSSLPath : string);
begin
  InitSSLInterfaceEx(OpenSSLPath);
  inherited Create;
  Protocol     := '1.1';
  FSynaDllPath := OpenSSLPath;
end;


function THTTPSendEx.InitSSLInterfaceEx(OpenSSLPath : string) : Boolean;
begin
  {$IFNDEF DELAYED_SSL_INIT}
    // Библиотеки SSL уже загружены из секции инициализации
    Result := True;
  {$ELSE}
    Result := False;
    if (NOT ssl_openssl_lib.IsSSLloaded) then begin
      Result := InitSSLInterface(OpenSSLPath);
      if (Result = True) then
        blcksock.SSLImplementation := TSSLOpenSSL;
    end;
  {$ENDIF}
end;

procedure THTTPSendEx.WriteSynaLog(HeadersList : TStringList);
begin
{$IFDEF DEBUG_SYNA}
  HeadersList.SaveToFile(HEADS_REQ);
{$ENDIF}
end;

function THTTPSendEx.HTTPMethodEx(const Method, URL: string) : Boolean;
var
  s : string;
begin
{$IFDEF DEBUG_SYNA}
  // Обработчик отладочного вывода заголовков
  httpsend.LogHeaders := WriteSynaLog;
{$ENDIF}
  Result := inherited HTTPMethod(Method, URL);
{$IFDEF DEBUG_SYNA}
  httpsend.LogHeaders := nil;
{$ENDIF}
end;



// Результат GET/POST
constructor TResultHTTP.Create(ReqCode : string = '');
begin
  inherited Create;
  ClearRes(ReqCode);
end;

destructor TResultHTTP.Destroy;
begin
  inherited;
end;


// Очистка результата HTTP-запроса
procedure TResultHTTP.ClearRes(ReqCode: string);
begin
  FCode    := 0;
  FMsg     := '';
  FStrInf  := '';
  FSOAns   := nil;
  FRequest := ReqCode;
end;


(* Secure routines *)
//----------------------------------------------------------------
procedure TSecureRSMDO.DebSec(FileDeb: String; x: Variant);
begin
  if (Avest.Debug = True) then begin
    MemoWrite(FileDeb, x);
  end;
end;

function TSecureRSMDO.AvestReady(var strErr: String): Boolean;
var
  s: string;
begin
  Result := Avest.IsActive;
  if (Result = False) then begin
    s := Meta.ReadString(SCT_SECURE, 'CSPNAME', NAME_AVEST_DLL);
    Result := Avest.LoadDLL(s, strErr);
  end;
end;


function TSecureRSMDO.TryOpenSess(var hSession: AvCmHc; UseDef: Boolean = True): DWORD;
begin
  if (UseDef = True) then begin
    Result := Avest.InitSession(True);   // если сессия не открыта, то откроем, но закрывать не будем !!!
    if (Result = AVCMR_SUCCESS) then
      hSession := Avest.hDefSession;
  end else
    Result := Avest.ActivateSession(hSession, True);
end;


//-------------------------------------------------------
function TSecureRSMDO.SignTextRaw(var sText, sSign: ANSIString; var sCert:String; lOpenDefSession: Boolean; AsnMode : DWORD) : Boolean;
var
  ret : Boolean;
  hSession: AvCmHc;
  //res,
  w : DWORD;
begin
  ret := True;
  try
    Avest.CheckMsg(TryOpenSess(hSession, lOpenDefSession), True);
    Avest.CheckMsg(AvCmSignRawData(hSession, nil, @sText[1], Length(sText), nil, w, AsnMode), True);
    SetLength(sSign, w);
    Avest.CheckMsg(AvCmSignRawData(hSession, nil, @sText[1], Length(sText), @sSign[1], w, AsnMode), True);
    if (sCert = '+') then begin
      sCert := '';
      Avest.CheckMsg(Avest.GetCert(hSession, sCert), True);
    end;
    if (NOT lOpenDefSession) then
      Avest.CheckMsg(Avest.DeactivateSession(hSession), True);
  except
    ret := False;
  end;
  Result := ret;
end;

//-------------------------------------------------------
function TSecureRSMDO.VerifyTextRaw(sText: ANSIString; sSign: ANSIString; sCert: String; lOpenDefSession: Boolean; AsnMode : DWORD): Boolean;
var
  ret : Boolean;
  w : DWORD;
  hSession: AvCmHc;
  hMycert: AvCmHcert;
begin
  ret := True;
  try
    Avest.CheckMsg(TryOpenSess(hSession, lOpenDefSession), True);
    if (sCert = '') then begin
      w := SizeOf(hMycert);
      Avest.CheckMsg(AvCmGetObjectInfo(hSession, AVCM_MY_CERT, @hMycert, w, 0), True);
    end
    else
      Avest.CheckMsg(AvCmOpenCert(hSession, @sCert[1], Length(sCert), hMycert, 0), True);
    Avest.CheckMsg(AvCmVerifyRawDataSign(hMycert, nil, @sText[1], Length(sText), @sSign[1], Length(sSign), AsnMode), True);
    if (NOT lOpenDefSession) then
      Avest.CheckMsg(Avest.DeactivateSession(hSession), True);
  except
    ret := False;
  end;
  Result := ret;
end;



//----------------------------------------------------------------
// Подписать JSON-документ и преобразовать в Base64
function TSecureRSMDO.CreateESign(var sUtf8: Utf8String; SignType : Integer; var strErr: String): Boolean;
var
  sSignRaw, sCertRaw,
  sPubKey,
  sCert, sSignedUTF : String;
  ASNMode : DWORD;
  //l,
  lOpenDefSession : Boolean;
begin
  strErr  := '';
  Result  := True;
  sCert   := '';
  sPubKey := '';
  sSignedUTF := '';
  sSignRaw := '';

  //if (SignPost = True) then begin
  if (SignType <> SIGN_NO) then begin
    if (AvestReady(strErr)) then begin
      //DebSec('ЗапросRU.json', sUtf8);
      Avest.slError.Clear;
      try
        lOpenDefSession := True;
        //lOpenDefSession := FAskPassOnce;
        //AvestSignType := 1; // AVCMF_ADD_SIGN_CERT
        //AvestSignType := 2; // AVCMF_DETACHED + AVCMF_ADD_SIGN_CERT
        //AvestSignType := 3; // AVCMF_DETACHED

        sCert := '+';  // !!! вернуть сертификат в переменную sCert !!!
        Avest.CheckMsg(Avest.SignText(ANSIString(sUtf8), sSignedUTF, sCert, lOpenDefSession, SignType, true), True);
        //Avest.CheckMsg(Avest.SignText(ANSIString(sUtf8), sSignedUTF, sCert, FAskPassOnce, SignType, true), True);
        sCertRaw := '+';  // !!! вернуть сертификат !!!
        if (FASNMode = SIGN_WITH_ASN) then
          ASNMode := 0
        else
          ASNMode := AVCMF_RAW_SIGN;

        if (SignTextRaw(ANSIString(sUtf8), sSignRaw, sCertRaw, lOpenDefSession, ASNMode) = True) then begin

{$IFDEF DEMOAPP}
          // Подписанное сообщение
          DebSec('ЗапросRU_sign.json', sSignedUTF);
          // DER-представление сертификата
          DebSec('ЗапросRU_Cert64.json', sCert);
{$ENDIF}

          Avest.CheckMsg(Avest.GetPublicKey(Avest.hDefSession, sPubKey), True);
          //DebSec('Запрос-ОКлюч.json', sPubKey);
          sPubKey := EncodeBase64(sPubKey);
          //DebSec('Запрос-ОКлюч-64.json', sPubKey);
        end
        else
          Result := false;
      except
          Result := false;
      end;
      if (Result = False) then begin
          strErr := 'Ошибка ЭЦП: ' + Avest.slError[Avest.slError.Count - 1];
        // получить сертификат не удалось ?
          sCert := ''; // !!!
      end;
    end
    else
      Result := False;
  end;
  //Certif  := sCert;
  //PubKey  := sPubKey;
  //Sign    := sSignedUTF;
  //SignRaw := sSignRaw;
end;


//----------------------------------------------------------------
// Проверить подпись
function TSecureRSMDO.VerifyESign(var sSignedUTF: Utf8String; const sSign, sCert,sSignRaw : string; var strErr: String): Boolean;
var
  sUtf8 : Utf8String;
  RetAv,
  ASNMode : DWORD;
  //l,
  lOpenDefSession : Boolean;
  LSigns : TStringList;

begin
  strErr := '';
  Result := True;
  //if (SignGet = True)
    //AND (Length(sSign) + Length(sCert) > 0) then begin
  if (Length(sSign) + Length(sCert) > 0) then begin
    if (AvestReady(strErr)) then begin
      Avest.slError.Clear;
      //DebSec('SignedBody', sSignedUTF);
      //sUtf8 := DecodeString(sSignedUTF);
      sUtf8 := sSignedUTF;
      try
        lOpenDefSession := True;
        if (FASNMode = SIGN_WITH_ASN) then
          ASNMode := 0
        else
          ASNMode := AVCMF_RAW_SIGN;
        if (VerifyTextRaw(ANSIString(sUtf8), sSignRaw, sCert, lOpenDefSession, ASNMode) = True) then begin
          LSigns := TStringList.Create;
          LSigns.Add(sSign);
          Avest.FBase64 := False;
          RetAv := Avest.SMDOVerify(AnsiString(sSignedUTF), LSigns, False, 0);

          // Подписанное сообщение
          //DebSec('BodyUnsigned.JSON', sUtf8);
          sSignedUTF := sUTF8;
        end
        else begin
          Result := false;
          strErr := 'Ошибка ЭЦП: ' + Avest.slError[Avest.slError.Count - 1];
        end;

      finally
      end;

    end
    else
      Result := False;
  end;

end;





function GetDLoadSize(const URL: string): Int64;
var
  i : integer;
begin
  Result := -1;
  with THTTPSend.Create do
    if HTTPMethod('HEAD', URL) then begin
      for i := 0 to Headers.Count - 1 do begin
        if pos('content-length', lowercase(Headers[i])) > 0 then begin
          Result := StrToInt64Def(SelectNumOne(Headers[i], Length(Headers[i]), 16), 0);
          if (Result > 0) then
            Result := Result + Length(Headers.Text);
          Break;
        end;
      end;
    end;
end;


constructor TShowProgress.Create;
begin
  inherited Create;
  FNeedShow := False;
end;

procedure TShowProgress.PrepareShow(const WinCaption, TotInf: string; TotMax:
    Integer = 100);
begin
  if (FNeedShow = True) then begin
    FTotMax := TotMax;
    CreateProgress(WinCaption, TotInf, TotMax);
  end;
end;

procedure TShowProgress.CloseShow;
begin
  if (FNeedShow = True) then begin
    if (FAutoOf = True) then
      FNeedShow := False;
    CloseProgress;
  end;
end;

procedure TShowProgress.ChangeShow(TotPos: Integer; TotInf: string = '');
begin
  if (FNeedShow = True) then begin
    ChangeProgress(TotPos, TotInf);
  end;
end;

function TShowProgress.AdjustTotalVals(NewMaxVal: Integer = -1; NewCurVal: Integer = -1): Integer;
begin
  Result := FTotMax;
  if (FNeedShow = True) then begin
    if (NewMaxVal > 0) then begin
      FTotMax := NewMaxVal;
      InitProgress(NewMaxVal, '');
    end;
    if (NewCurVal > 0) then
      ChangeProgress(NewCurVal, '');
  end;
end;

function TShowProgress.AdjustSingleVals(NewMaxVal: Integer = -1; NewCurVal: Integer = -1): Integer;
begin
  Result := FSingleMax;
  if (FNeedShow = True) then begin
    if (NewMaxVal > 0) then begin
      FSingleMax := NewMaxVal;
      //InitProgress(NewMaxVal, '');
    end;
    if (NewCurVal > 0) then
      ChangeProgress2(NewCurVal, '');
  end;
end;



procedure TShowProgress.PrepareSingleShow(const SingleInf: string; MaxVal : Integer = 100);
begin
  if (FNeedShow = True) then begin
    FSingleMax := MaxVal;
    ChangeProgress2(0, SingleInf);
  end;
end;

procedure TShowProgress.ChangeSingleShow(SinglePos : Integer; SingleInf : string = '');
begin
  if (FNeedShow = True) then begin
    if (SingleInf = '') then
      ChangeProgress2(SinglePos)
    else
      ChangeProgress2(SinglePos, SingleInf)
  end;
end;

function TShowProgress.SetProgressVisible(ShowNow: Boolean = True; AOff : Boolean = True): Boolean;
begin
  Result    := FNeedShow;
  FNeedShow := ShowNow;
  FAutoOf   := AOff;
end;

function TShowProgress.WhenReact(SetDivider : integer = -1): Boolean;
begin
  Result := False;
  if (SetDivider > 0) then begin
  // настройка частоты реакции обработчика на события
    FEventRise := 0;
    FDivider   := SetDivider;
  end else begin
    FEventRise := FEventRise + 1;
    if (FEventRise mod FDivider) = 0 then
      Result := True;
  end;
end;

function PrepareFile4Post(const FileName: string; const DataFile, DocStream: TStream): Boolean;
var
  s : string;
begin
  try
    s := '--' + Bound + CRLF;
    s := s + 'Content-Disposition: form-data; name="file";';
    s := s + ' filename="' + FileName +'"' + CRLF;
    s := s + 'Content-Type: Application/octet-stream' + CRLF + CRLF;
    WriteStrToStream(DocStream, s);
    DocStream.CopyFrom(DataFile, 0);
    s := CRLF + '--' + Bound + '--' + CRLF;
    WriteStrToStream(DocStream, s);
    //HTTP.MimeType := 'multipart/form-DataFile; boundary=' + Bound;
  finally
  end;
end;



initialization
  // Разделитель для отправки файлов
  //Bound := NewGuid;
  //Randomize;
  //Bound := FILE_BOUND + IntToHex(Random(MaxInt), 8) + FILE_BOUND;
  Bound := FILE_BOUND;

  RouterRequests := TStringList.Create;
  RouterRequests.Sorted := False;

  // Получить токен авторизации
  ReqInf := TRoutRequestInf.Create('POST', '/token');
  ReqInf.PackageId    := False;
  ReqInf.ResourcePars := 'scope=application&grant_type=client_credentials';
  ReqInf.ContentType  := 'application/x-www-form-urlencoded';
  RouterRequests.AddObject(REQ_GET_TOKEN, ReqInf);

  //-*-*-* Запросы к Receiver
  // Разместить пакет на сервере
  ReqInf := TRoutRequestInf.Create('POST', '/receiver');
  ReqInf.PackageId := False;
  RouterRequests.AddObject(REQ_CREATE_PKG, ReqInf);

  // Добавить вложение к пакету на сервере
  ReqInf := TRoutRequestInf.Create('POST', '/receiver');
  ReqInf.ContentType  := CNT_TYPE_ATTACH + Bound;
  ReqInf.ResourcePath := '/attach';
  RouterRequests.AddObject(REQ_ADD_ATTACH, ReqInf);

  // Отправить пакет
  ReqInf := TRoutRequestInf.Create('GET', '/receiver');
  ReqInf.ResourcePath := '/send';
  RouterRequests.AddObject(REQ_SEND_PKG, ReqInf);

  //-*-*-* Запросы к Sender
  // Получить список писем по фильтру
  ReqInf := TRoutRequestInf.Create('POST', '/sender');
  ReqInf.PackageId := False;
  RouterRequests.AddObject(REQ_GET_PKGLIST, ReqInf);



finalization
  for i := 0 to (RouterRequests.Count - 1) do begin
    ReqInf := TRoutRequestInf(RouterRequests.Objects[i]);
    FreeAndNil(ReqInf);
  end;
  FreeAndNil(RouterRequests);

end.
