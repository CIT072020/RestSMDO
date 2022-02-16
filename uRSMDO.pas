unit uRSMDO;

interface

uses
  Classes,
  Types,
  DB,
  kbmMemTable,
  superobject,
  superdate,
  blcksock,
  SasaINiFile,
  uUseful,
  uRSMDOService,
  uRSMDOPkg;

const
  JSON_PACKAGE_FILE = 'mail_body.json';

type
  //TSockentEventHandler = procedure of object;

  // ������ �� ������ ����� ��������
  TAttach = class(TObject)
  private
    FOk: Boolean;
    FGUIDPackage: String;
    FPath: String;
    FError: String;
    FGUIDFile: String;
    FCode: String;
    FFileName: String;
    procedure SetCode(const Value: String);
    procedure SetError(const Value: String);
    procedure SetFileName(const Value: String);
    procedure SetGUIDFile(const Value: String);
    procedure SetGUIDPackage(const Value: String);
    procedure SetOk(const Value: Boolean);
    procedure SetPath(const Value: String);
  public
    property GUIDPackage:String read FGUIDPackage write SetGUIDPackage;
    property GUIDFile:String read FGUIDFile write SetGUIDFile;
    property Path:String read FPath write SetPath;
    property FileName:String read FFileName write SetFileName;
    property Error:String read FError write SetError;
    property Code:String read FCode write SetCode;
    property Ok:Boolean read FOk write SetOk;
    constructor Create;
    destructor Destroy; override;
  end;


  // �������������� � ��� ��
  TRouterMV = class
    //FOwn     : TComponent;
    FMeta    : TSasaIniFile;
    FHost    : THostRSMDO;
    FHTTP    : THTTPSendEx;
    FSecure  : TSecureRSMDO;
    FResHTTP : TResultHTTP;

    FPkgSend : TPackageSend;
    FPkgRcv  : TPackageReceive;

    FShowProgress : TShowProgress;

    function FullPath(RequestCode: string; PId: string = ''; Aid : string = ''; CId : string = ''): string;
  public
    //SynaGetPkgList : TSocketEventHandler;
    // ��������� �����������, ��� � ������������
    property Secure : TSecureRSMDO read FSecure;
    // ����� ��� ��������
    property PkgSend : TPackageSend read FPkgSend write FPkgSend;
    // ��������� ������� ������ (GET/POST)
    property ResHTTP : TResultHTTP read FResHTTP;

    function SetRetCode(SrvRet: Boolean; ReqRes: TResultHTTP; var sErr: string):
        integer;
    // ������ � �������
    function CallRouter(const ReqId, URL: string; StreamDoc : TMemoryStream = nil): Integer;

    (*
       === ������������ �������� ������
    *)
    // ������������ ����� � �������� ������
    function SendMail(MailPackage: ISuperObject; Attachs: TStringList; MailPath: String = ''): Boolean;

    // ������������ ������ ���������� ���������� �����
    function GetMailList(SRet : ISuperObject) : Integer;
    // ��������� ���������� ������
    function GetMail(SO : ISuperObject) : Integer;


    (*
       === ������ ��������� � REST-API
    *)
    // �������� ����� �����������
    function GetApiAuthToken : Boolean;

    // ������������ �����
    function CreatePkg(MailPkg: ISuperObject; JSONFile : string = '') : Boolean;
    // �������� �������� � ������
    function AddAttach2Pkg(const PkgId : string; Attachs : TStringList): Integer;

    // ��������� �����
    function SendPkg(const PkgId: string): Boolean;
    // ������ ��������� ������
    function CancelSendPkg(SO: ISuperObject): Integer;



    function SetProgressVisible(NewVal : Boolean = True; AOff : Boolean = True) : Boolean;
    procedure SynaGetPkgList(Sender: TObject; Reason: THookSocketReason; const Value: String);

    constructor Create(MetaINI : TSasaIniFile; Own : TComponent);
    destructor Destroy; override;
  end;


implementation

uses
  SysUtils,
  synautil;

//type
  //TSocketEventHandler = procedure(Sender: TObject; Reason: THookSocketReason; const Value: String) of object;




constructor TAttach.Create;
begin
  Ok:=true;
  Code:='';
end;

destructor TAttach.Destroy;
begin
//
  inherited;
end;

procedure TAttach.SetCode(const Value: String);
begin
  FCode := Value;
end;

procedure TAttach.SetError(const Value: String);
begin
  FError := Value;
end;

procedure TAttach.SetFileName(const Value: String);
begin
  FFileName := Value;
end;

procedure TAttach.SetGUIDFile(const Value: String);
begin
  FGUIDFile := Value;
end;

procedure TAttach.SetGUIDPackage(const Value: String);
begin
  FGUIDPackage := Value;
end;

procedure TAttach.SetOk(const Value: Boolean);
begin
  FOk := Value;
end;

procedure TAttach.SetPath(const Value: String);
begin
  FPath := Value;
end;



// ������� ������� INI
constructor TRouterMV.Create(MetaINI : TSasaIniFile; Own : TComponent);
begin
  inherited Create;
  FMeta    := MetaINI;
  //FOwn     := Own;
  FHost    := THostRSMDO.Create(MetaINI);
  FHTTP    := THTTPSendEx.Create( FullPathSubDir(
                MetaINI.ReadString(SCT_ADMIN, 'SYNADLL', '') ) );
  FSecure  := TSecureRSMDO.Create(MetaINI);

  FResHTTP := TResultHTTP.Create;
  FShowProgress := TShowProgress.Create;
end;

destructor TRouterMV.Destroy;
begin
  FreeAndNil(FShowProgress);
  FreeAndNil(FSecure);
  FreeAndNil(FHTTP);
  FreeAndNil(FHost);
  FreeAndNil(FResHTTP);
  inherited;
end;


// ������ ���� ��� ��������� ������� � �����������
function TRouterMV.FullPath(RequestCode: string; PId: string = ''; AId : string = ''; CId : string = ''): string;
var
  i : Integer;
  RPath : string;
  Req   : TRoutRequestInf;
begin
  try
    i := RouterRequests.IndexOf(RequestCode);
    Req := TRoutRequestInf(RouterRequests.Objects[i]);
    RPath := '/package' + Iif(Req.PackageId = True, '/' + PId, '') +
      Iif(Req.AttachId = True, '/' + AId, '') +
      Iif(Req.ConfirmId = True, '/' + CId, '') +
      Iif(Req.ResourcePath <> '', '/' + Req.ResourcePath, '');

  Result := FHost.URL + Req.Context + FHost.Vers + FHost.UserType + FHost.HeaderId + RPath;
  except
    Result := '';
  end;
end;






// ��������� ����� �������� ����� HTTPSend
function TRouterMV.SetRetCode(SrvRet: Boolean; ReqRes: TResultHTTP; var sErr : string): integer;
var
  UTF8Ans : UTF8String;
  //SOAnswer : ISuperObject;
begin
  sErr   := '';
  Result := FHTTP.ResultCode;

  FHTTP.Headers.SaveToFile(HEADS_ANS);
  try
    try
      if (SrvRet = True) then begin
      // ���������� ���� �����������
        if (FHTTP.Document.Size > 0) then begin
          UTF8Ans := ReadStrFromStream(FHTTP.Document, FHTTP.Document.Size);
          if (IsJSON(UTF8Ans) = True) then
            ReqRes.SOAnswer := SO(UTF8Decode(UTF8Ans))
          else
          // ���� ������ - �� JSON
            ReqRes.StrInf := Utf8ToAnsi(UTF8Ans);
        end;

        if (FHTTP.ResultCode >= 400) then begin
          // ���-�� ����� �� ���, �������� �������� ������
            sErr := FHTTP.Headers[0];
            if (FHTTP.ResultCode = 404) then
              sErr := sErr + ERR404_MSG
            else begin
              if (ReqRes.StrInf <> '') then
              // ����������� � ���� JSON ���
                sErr := ReqRes.StrInf + CRLF + FHTTP.Headers[0];
            end;
          raise Exception.Create(sErr);
        end;

        // ������, ������ �� ����
        Result := 0;
        if (sErr = '') then
          sErr := FHTTP.ResultString;
      end else begin
      // ���������� �� ���� �����������, ���-�� � ��������/������
        Result := FHTTP.sock.LastError;
        sErr   := FHTTP.sock.LastErrorDesc;
        raise Exception.Create(sErr);
      end;
    except
      on E: Exception do begin
        if (sErr <> '') then
          sErr := E.Message;
      end;
    end;
  finally
    ReqRes.ResCode := Result;
    ReqRes.ResMsg  := sErr;
  end;
end;


// ��������/��������� ����������� ��������� ������ � ���������������
function TRouterMV.SetProgressVisible(NewVal : Boolean = True; AOff : Boolean = True) : Boolean;
begin
  Result := FShowProgress.SetProgressVisible(NewVal, AOff);
end;

// �������� ����� �����������
function TRouterMV.GetApiAuthToken: Boolean;
var
  i : Integer;
  sErr, URL: string;
  Req: TRoutRequestInf;
  ReqRes: TResultHTTP;
begin
  Result := False;
  FSecure.SetApiAuth('', '');
  Req := TRoutRequestInf(RouterRequests.Objects[RouterRequests.IndexOf(REQ_GET_TOKEN)]);
  URL := FHost.URL + Req.Context + Iif(Req.ResourcePars = '', '', '?' + Req.ResourcePars);

  ReqRes := TResultHTTP.Create(REQ_GET_TOKEN);
  try
    FHTTP.Clear;
    FHTTP.Headers.Add('Authorization: ' + FSecure.AccessAuth);
    FHTTP.Headers.Add('Content-Type: ' + Req.ContentType);
    sErr := '';
    i := SetRetCode(FHTTP.HTTPMethodEx(Req.Method, URL), ReqRes, sErr);
    if (i = 0) and Assigned(ReqRes.SOAnswer) and (ReqRes.SOAnswer.DataType = superobject.stObject) then begin
      Result := True;
      FSecure.SetApiAuth(ReqRes.SOAnswer.S['access_token'], ReqRes.SOAnswer.S['token_type']);
    end;
  finally
    if (Result = True) then
      FreeAndNil(ReqRes)
    else begin
      // ������ � �������� ���������� � ����������
      FreeAndNil(FResHTTP);
      FResHTTP := ReqRes;
    end;
  end;
end;




// �������� ������ �� ������
function TRouterMV.CallRouter(const ReqId, URL: string; StreamDoc : TMemoryStream = nil): Integer;
const
  MAX_TRIES = 2;
var
  bActualApiAuth: Boolean;
  i: Integer;
  sErr, s: string;
  Req: TRoutRequestInf;
begin
  sErr := '';
  Req := TRoutRequestInf(RouterRequests.Objects[RouterRequests.IndexOf(ReqId)]);

  if (FSecure.IsEmptyAuth = True) then begin
    // ����� ����������� �������� �� ��������
    // ��� ������ ��������� �������� ����������� ����������� ��� ������
    bActualApiAuth := GetApiAuthToken;
  end else
    // ������������, ��� ����������� ��� �� ��������
    bActualApiAuth := True;
  i := 1;
  while (bActualApiAuth = True) AND (i <= MAX_TRIES) do begin
    sErr := '';
    i := i + 1;

    // ���� � ������������ ��� ������
    ResHTTP.ClearRes(ReqId);
    FHTTP.Clear;
    //FHTTP.MimeType := 'application/json;charset=UTF-8';
    //FHTTP.MimeType := Req.ContentType;
    FHTTP.Headers.Add('Authorization: ' + Secure.ApiAuth);
    if Assigned(StreamDoc) then begin
      FHTTP.Document.CopyFrom(StreamDoc, 0);
      FHTTP.Headers.Add('Content-Type: ' + Req.ContentType);
    end;

    bActualApiAuth := FHTTP.HTTPMethodEx(Req.Method, URL);
    if (bActualApiAuth = True) then begin
      if (FHTTP.ResultCode = 401) then begin
        sErr := ERR401_MSG;
        if (i <= MAX_TRIES) then
        // ����� ����������� ������, �������� �� �����
          bActualApiAuth := GetApiAuthToken;
      end;
    end;
  end;
  if (ResHTTP.ReqId <> REQ_GET_TOKEN) then begin
    Result := SetRetCode(bActualApiAuth, ResHTTP, s);
    if (sErr <> '') then
      ResHTTP.ResMsg := sErr + ' ' + s;
  end else
    // SetRetCode ��� ���������
    Result := ResHTTP.ResCode;
end;

//=== REST-������
// ������������ �����
function TRouterMV.CreatePkg(MailPkg: ISuperObject; JSONFile : string = '') : Boolean;
var
  i,
  Ret : Integer;
  URL : string;
  xJSON : TObject;
  xPkgSend : TPackageSend;
begin
  Result := False;
  URL := FullPath(REQ_CREATE_PKG);
  if (Assigned(FPkgSend)) then
    FreeAndNil(FPkgSend);
  xPkgSend := TPackageSend.Create;
  FPkgSend := xPkgSend;
  if (JSONFile = '') then
    MailPkg.SaveTo(xPkgSend.Doc)
  else
    xPkgSend.Doc.LoadFromFile(JSONFile);
  Ret := CallRouter(REQ_CREATE_PKG, URL, xPkgSend.Doc);
  if (Ret = 0) then begin
    xPkgSend.Id            := ResHTTP.SOAnswer.S['packageId'];
    MailPkg.S['packageId'] := xPkgSend.Id;
    Result := True;
  end;
end;


// �������� �������� � ������
function TRouterMV.AddAttach2Pkg(const PkgId: string; Attachs: TStringList): Integer;
var
  Ret, i, j: Integer;
  FName, URL: string;
  HTTPStream, FileStream: TMemoryStream;
  xAtt: TAttach;
begin
  Result := 0;
  URL := FullPath(REQ_ADD_ATTACH, PkgId);
  FileStream := TMemoryStream.Create;
  HTTPStream := TMemoryStream.Create;
  try
    for i := 0 to Attachs.Count - 1 do begin
      FName := Attachs[i];
      xAtt := TAttach(Attachs.Objects[i]);
      xAtt.FGUIDPackage := PkgId;
      FileStream.Clear;
      HTTPStream.Clear;
      FileStream.LoadFromFile(IncludeTrailingPathDelimiter(xAtt.FPath) + FName);
      if (PrepareFile4Post(FName, FileStream, HTTPStream) = True) then begin
        ResHTTP.ClearRes(REQ_ADD_ATTACH);
        Ret := CallRouter(REQ_ADD_ATTACH, URL, HTTPStream);
        if (Ret = 0) then begin
          xAtt.FOk := True;
          xAtt.FGUIDFile := ResHTTP.SOAnswer.S['id'];
        end else begin
          xAtt.FOk := False;
          xAtt.FGUIDFile := '';
        end;
        Result := Result + Ret;
      end;
    end;
  finally
    FreeAndNil(HTTPStream);
    FreeAndNil(FileStream);
  end;
end;




// ��������� �����
function TRouterMV.SendPkg(const PkgId: string): Boolean;
var
  Ret: Integer;
  URL: string;
begin
  URL := FullPath(REQ_SEND_PKG, PkgId);
  ResHTTP.ClearRes(REQ_SEND_PKG);
  Result := False;
  if (CallRouter(REQ_SEND_PKG, URL) = 0) then
    Result := True;
end;


// ������ ��������� ������
function TRouterMV.CancelSendPkg(SO: ISuperObject): Integer;
begin
  Result := 0;
end;


//=== ���������� ������
// ������������ ����� � �������� ������
function TRouterMV.SendMail(MailPackage: ISuperObject; Attachs: TStringList; MailPath: String = ''): Boolean;
var
  MailInJSON : string;
  xPkgSend : TPackageSend;
begin
  ResHTTP.ClearRes(REQ_CREATE_PKG);
  // ������������ ������ �� �������

  MailInJSON := Iif(MailPath = '', '',
    IncludeTrailingPathDelimiter(MailPath) + JSON_PACKAGE_FILE);
  if (CreatePkg(MailPackage, MailInJSON) )then begin

    // ���������� ������ ��������
    if (AddAttach2Pkg(PkgSend.Id, Attachs) = 0) then begin
    // ��������� ����� �� ��������� (������ ������)
      SendPkg(PkgSend.Id);
    end;

  end;
  Result := Iif(ResHTTP.ResCode = 0, True, False);
end;


// ������-����� ��� ������� ��������� ����� � �������
function Filter2Str(Page : Integer = 0; MailOnPage : Integer = 100; OnlyNew : Boolean = True; dSince : TDateTime = 0) : UTF8String;
var
  NewMail,
  StartDate,
  URL : string;
  d : TDateTime;
  sFilt : UTF8String;
begin
  NewMail := Iif(OnlyNew, '"true"', '"false"');
  StartDate := Iif( Double(d) = 0, '', DelphiDateTimeToISO8601Date(dSince));
  Result := AnsiToUtf8( Format('{"page":%d,"size":%d,"onlyNew":%s,"dateExec":"%s"}',
                  [Page, MailOnPage, NewMail, StartDate]) );
end;

// ��������� ���������� ������
function StoreMailPkgs : Boolean;
var
  URL : string;
begin
  Result := True;
end;


// ������������ ������ ���������� ���������� �����
function TRouterMV.GetMailList(SRet : ISuperObject) : Integer;
var
  OnlyNew,
  bQuit : Boolean;
  nMAilOnPage,
  nPage,
  Ret, i, j: Integer;
  URL: string;
  s : UTF8String;
  dStart : TDateTime;
  HTTPStream : TMemoryStream;
begin
  Result := 0;
  URL := FullPath(REQ_GET_PKGLIST);
  HTTPStream := TMemoryStream.Create;
  try
    bQuit := False;
    nPage       := 0;
    nMAilOnPage := 100;
    OnlyNew     := True;
    dStart      := 0;
    while (NOT bQuit) do begin
      HTTPStream.Clear;
      s := Filter2Str(nPage, nMAilOnPage, OnlyNew, dStart);
      WriteStrToStream(HTTPStream, s);
      ResHTTP.ClearRes(REQ_GET_PKGLIST);
      Ret := CallRouter(REQ_GET_PKGLIST, URL, HTTPStream);
      if (Ret = 0) then begin
        StoreMailPkgs;
        bQuit := NOT ResHTTP.SOAnswer.B['hasNext'];
      end else begin
        bQuit := True;
      end;
      nPage := nPage + 1;
    end;
  finally
    FreeAndNil(HTTPStream);
  end;
  Result := ResHTTP.ResCode;
end;




procedure TRouterMV.SynaGetPkgList(Sender: TObject; Reason: THookSocketReason; const Value: String);
var
  i, Current: Integer;
  s: string;
begin
  if Reason = HR_ReadCount then begin
     Current := StrToIntDef(Value, 0);
     FShowProgress.RawCurr := FShowProgress.RawCurr + Current;
    if (FShowProgress.WhenReact) then begin
      if FShowProgress.RawTot > 0 then begin
        i := Trunc(FShowProgress.RawCurr * FShowProgress.RawK);
        FShowProgress.ChangeSingleShow(i, Format('Loaded - %d Receive now - %d', [FShowProgress.RawCurr, Current]));
      //FShowProgress.ChangeSingleShow(i);
      end
      else begin
        s := '';
        FShowProgress.PrepareSingleShow(s);
      end;
    end;
  end;
end;








// ��������� ���������� ������
function TRouterMV.GetMail(SO: ISuperObject): Integer;
const
  MAXLOAD = 3;
var
  Ret : Boolean;
  i: Integer;
  StreamSize: Int64;
  dlFile: string;
begin

  dlFile := 'https://vc.brest.by/download/SetupLAIS.exe';
  FHTTP.Sock.OnStatus := SynaGetPkgList;
  SetProgressVisible;
  try
    FShowProgress.PrepareShow('��������� �����', '', MAXLOAD);
    FShowProgress.WhenReact(300);
    FHTTP.Sock.OnStatus := SynaGetPkgList;
    FHTTP.Sock.SizeRecvBuffer := 1024 * 32;
    for i := 1 to MAXLOAD do begin
      FShowProgress.RawTot := GetDLoadSize(dlFile);
      FShowProgress.ChangeShow(i-1, Format('�������� Lais%d - %d', [i, FShowProgress.RawTot]));
      if (FShowProgress.RawTot > 0) then begin
        FShowProgress.RawCurr := 0;
        FShowProgress.RawK := 100 / FShowProgress.RawTot;
        FShowProgress.PrepareSingleShow(Format('�������� Lais%d - %d', [i, FShowProgress.RawTot]));
        FHTTP.Clear;
        Ret := FHTTP.HTTPMethodEx('GET', dlFile);
        if (Ret) then begin


        end;
        FShowProgress.AdjustSingleVals(-1, 100);
      end;
    end;
    FShowProgress.AdjustTotalVals(-1, MAXLOAD);

  finally
    FShowProgress.CloseShow;
    FHTTP.Sock.OnStatus := nil;
  end;

end;


end.
