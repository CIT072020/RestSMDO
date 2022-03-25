unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, DateUtils,
  nativexml,
  funcpr,
  superdate, superobject,
  StdCtrls, Mask,
  DBCtrlsEh,
  DB, Grids, DBGridEh,
  adsdata, adsfunc, adstable, adscnnct,
  HTTPSend,
  ssl_openssl, ssl_openssl_lib,
  SasaINiFile,
  TasksEx,
  //fPIN4Av,
  uUseful,
  uRSMDOService,
  uRSMDO;

const
  INI_NAME = '..\Lais7\Service\smdo.ini';
const
  JDAT_PATH = 'TestPost\';



type
  TForm1 = class(TForm)
    edMemo: TMemo;
    gdIDs: TDBGridEh;
    DataSource1: TDataSource;
    gdDocs: TDBGridEh;
    dsDocs: TDataSource;
    gdChild: TDBGridEh;
    dsChild: TDataSource;
    btnGetDocs: TButton;
    dtBegin: TDBDateTimeEditEh;
    dtEnd: TDBDateTimeEditEh;
    edOrgan: TDBEditEh;
    edFirst: TDBEditEh;
    edCount: TDBEditEh;
    btnPostDoc: TButton;
    btnGetActual: TButton;
    lstINs: TListBox;
    edtIN: TDBEditEh;
    btnGetNSI: TButton;
    lblSSovCode: TLabel;
    lblIndNum: TLabel;
    edNsiType: TDBEditEh;
    lblNsiType: TLabel;
    gdNsi: TDBGridEh;
    dsNsi: TDataSource;
    edNsiCode: TDBEditEh;
    cbSrcPost: TDBComboBoxEh;
    cnctNsi: TAdsConnection;
    cbAdsCvrt: TDBCheckBoxEh;
    cbESTP: TDBCheckBoxEh;
    cbClearLog: TDBCheckBoxEh;
    lblFirst: TLabel;
    lblCount: TLabel;
    lblDepartFromDate: TLabel;
    lblINs: TLabel;
    lblDSD: TLabel;
    lblChilds: TLabel;
    lblNSI: TLabel;
    btnGetTempIN: TButton;
    btnServReady: TButton;
    btnCursWait: TButton;
    btnCursNorm: TButton;
    edJavaDate: TDBEditEh;
    btnGetINsOnly: TButton;
    cbINsOnly: TDBCheckBoxEh;
    btnGetNsiRSMDO: TButton;
    procedure btnCursNormClick(Sender: TObject);
    procedure btnCursWaitClick(Sender: TObject);
    procedure btnGetActualClick(Sender: TObject);
    procedure btnGetDocsClick(Sender: TObject);
    procedure btnGetINsOnlyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnGetNSIClick(Sender: TObject);
    procedure btnGetNsiRSMDOClick(Sender: TObject);
    procedure btnPostDocClick(Sender: TObject);
    procedure btnGetTempINClick(Sender: TObject);
    procedure btnServReadyClick(Sender: TObject);
  private
    { Private declarations }
    procedure ShowDeb(const s: string; ClearAll: Boolean = True);
  public
    { Public declarations }
  end;


var
  Form1: TForm1;
  IniFile : TSasaIniFile;
  RSMDO : TRouterMV;
  ShowM : TMemo;
  OldCurs : HICON;

implementation


uses
  kbmMemTable,
  DBFunc,
  synautil,
  //superobject,
  uAvest,
  fPIN4Av;

{$R *.dfm}


// Вывод отладки в Memo
procedure TForm1.ShowDeb(const s: string; ClearAll: Boolean = True);
var
  AddS: string;
begin
  AddS := '';
  ClearAll := cbClearLog.Checked;
  if (ClearAll = True) then
    ShowM.Text := ''
  else
    AddS := CRLF;
  ShowM.Text := ShowM.Text + AddS + s;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // ???
  ShowM := edMemo;
  edOrgan.Text  := '26';
  // Todes
  //dtBegin.Value := StrToDate('01.08.2021');
  //dtEnd.Value   := StrToDate('03.08.2021');
  // OAIS
  dtBegin.Value := StrToDate('01.10.2021');
  dtEnd.Value   := StrToDate('01.01.2022');
  edFirst.Text  := '0';
  edCount.Text  := '100';
  cbSrcPost.ItemIndex := 0;

  //IniFile  := TSasaIniFile.Create(INI_NAME);
  RSMDO := TRouterMV.Create(INI_NAME);
  Self.Caption := 'Обмен с адресом: ' + RSMDO.FHost.URLNsi;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  //FreeAndNil(IniFile);
  FreeAndNil(RSMDO);
end;



// Актуальные установочные данные для ИН
procedure TForm1.btnGetActualClick(Sender: TObject);
begin
end;

// Сохранить PIN
function SetAvestPass(Avest: TAvest): Boolean;
var
  sPin: string;
begin
  Result := False;
  if (Length(Avest.Password) = 0)
    OR (Avest.hDefSession = nil) then begin
    // Подключаться еще не пытались, нужен PIN
    fPINGet := TfPINGet.Create(nil);
    try
      if (fPINGet.ShowModal = mrOk) then begin
        fPINGet.SetResult(sPin);
        if (Length(sPin) > 0) then begin
          Avest.SetLoginParams(sPin, '');
          Result := True;
        end;
      end;
    finally
      fPINGet.Free;
      fPINGet := nil;
    end;
  end
  else
    Result := True;
end;


//----------------------------------------------

// Пакет -> Router
procedure TForm1.btnPostDocClick(Sender: TObject);
var
  iSrc  : Integer;
  aRec  : TCurrentRecord;
begin
  iSrc  := cbSrcPost.ItemIndex;
  if (iSrc in [0..1]) then begin
    // из MemTable
    if (cbSrcPost.ItemIndex = 0) then begin
    // передача только текущей
    end;
  end
  else begin
    // из JSON-файла
  end;

(*
  RSMDO.Secure.SignPost := cbESTP.Checked;
  if (RSMDO.Secure.SignPost = True) then
    if (SetAvestPass(RSMDO.Secure.Avest) = False) then
      Exit;
*)

  RSMDO.Secure.Avest.Debug := True;
  ShowDeb(IntToStr(RSMDO.FResHTTP.ResCode) + ' ' + RSMDO.FResHTTP.ResMsg);

end;


// Справочник
procedure TForm1.btnGetNSIClick(Sender: TObject);
var
  i : Integer;
begin
  i := RSMDO.GetMail(nil);
end;






procedure TForm1.btnCursWaitClick(Sender: TObject);
begin
  OldCurs := SetCursor(OCR_WAIT);
  Application.ProcessMessages;
end;

procedure TForm1.btnCursNormClick(Sender: TObject);
var
  JD : LongInt;
begin
  TButton(Sender).Caption := DateTimeToStr(JavaToDelphiDateTime(StrToInt64(edJavaDate.Text)));;
end;

// SendMail
procedure TForm1.btnGetDocsClick(Sender: TObject);
const
  at1 = '1234';
  at2 = '12345';
  ATT_NAME = 'attach';
var
  Ret : Boolean;
  i,
  iSrc  : Integer;
  t1, te : Cardinal;
  sErr,
  sAttName,
  sAttPath,
  sJFName : string;
  SOPkg : ISuperObject;
  AttFile : TAttach;
  Atts  : TStringList;
begin
  iSrc    := cbSrcPost.ItemIndex;
  sJFName := cbSrcPost.Items[iSrc];
  sAttPath := FullPathSubDir(JDAT_PATH);
  SOPkg   := TSuperObject.ParseFile(sAttPath + sJFName, False);
  Atts    := TStringList.Create;

  i := 1;
  sAttName := ATT_NAME + IntToStr(i);
  while (FileExists(sAttPath + sAttName)) do begin
    AttFile := TAttach.Create(sAttName);
    AttFile.FileName := sAttName;
    AttFile.Path := sAttPath;
    Atts.AddObject(sAttName, AttFile);
    i := i + 1;
    sAttName := ATT_NAME + IntToStr(i);
  end;

  EnterWorkerThread;
  try
    t1  := GetTick;
    Ret := RSMDO.SendMail(SOPkg, sAttPath, False, Atts, sErr);
    te  := TickDelta(t1, GetTick);
    if (Ret) then
      sErr := 'OK - Выполнено';
  finally
    LeaveWorkerThread;
    FreeNilWObj(Atts);
  end;
  sErr := Format('MSec - %d', [te]) + CRLF + sErr;
  ShowDeb(sErr);
end;





// Получить пакеты
procedure TForm1.btnGetTempINClick(Sender: TObject);
var
  bRet : Boolean;
  i : Integer;
  s : string;
  SAllCont : ISuperObject;
begin
  bRet := RSMDO.GetNewMailList(SAllCont, s);
  if (bRet) then
    s := Format('Загружено пакетов - %d', [SAllCont.AsArray.Length]);
  ShowDeb(s);
end;


// Загрузить Attach
procedure TForm1.btnServReadyClick(Sender: TObject);
var
  Ret : Boolean;
  i, GoodAtt : Integer;
  PkgId,
  AttId,
  s : string;
  Atts : TStringList;
  AttFile : TAttach;
begin
  Atts  := TStringList.Create;
//* - 1 - 1 attach

(*
  PkgId := 'cd0d96e0-ea89-4603-91de-87921302ed66';
  AttId := '084be1f5-fbdb-4d0c-91b9-9cd6b1923358';
  AttFile := TAttach.Create(AttId);
  AttFile.GUIDPackage := PkgId;
  AttFile.GUIDFile    := AttId;
  AttFile.FileName    := '1647970479366';
  AttFile.Path        := FullPathSubDir(JDAT_PATH);
  Atts.AddObject(AttId, AttFile);
*)

(*
//* - 2 - 3 attachs
  PkgId := 'd85a9d49-b177-4cbf-9365-6032e1259009';
  AttId := '06c210f6-ac4e-4faf-bb6d-0652ad866084';
  AttFile := TAttach.Create(AttId);
  AttFile.GUIDPackage := PkgId;
  AttFile.GUIDFile    := AttId;
  AttFile.FileName    := '1647970678662';
  AttFile.Path        := FullPathSubDir(JDAT_PATH);
  Atts.AddObject(AttId, AttFile);

  AttId := 'd28f8ab6-f28a-4303-a638-b45a1f7ceff6';
  AttFile := TAttach.Create(AttId);
  AttFile.GUIDPackage := PkgId;
  AttFile.GUIDFile    := AttId;
  AttFile.FileName    := '1647970685605';
  AttFile.Path        := FullPathSubDir(JDAT_PATH);
  Atts.AddObject(AttId, AttFile);

  AttId := '25a3b538-9456-4eb1-92b1-893e3b27a8df';
  AttFile := TAttach.Create(AttId);
  AttFile.GUIDPackage := PkgId;
  AttFile.GUIDFile    := AttId;
  AttFile.FileName    := '1647970670990';
  AttFile.Path        := FullPathSubDir(JDAT_PATH);
  Atts.AddObject(AttId, AttFile);
*)


// - 3- 1 attach big size
  PkgId := '92fb63f5-2c36-415a-8dc3-c5e78a93c2d5';
  AttId := '706e379c-49ea-44be-88f0-888fbc1ce757';
  AttFile := TAttach.Create(AttId);
  AttFile.GUIDPackage := PkgId;
  AttFile.GUIDFile    := AttId;
  AttFile.FileName    := '1647976730797';
  AttFile.Path        := FullPathSubDir(JDAT_PATH);
  Atts.AddObject(AttId, AttFile);

  Ret := RSMDO.GetMailAttachs(Atts);
  GoodAtt := 0;
  s := '';
  for i := 0 to Atts.Count - 1 do begin
    AttFile := TAttach(Atts.Objects[i]);
    if (AttFile.Ok) then
      GoodAtt := GoodAtt + 1
    else begin
      //s := s + AttFile.Error + CRLF;
    end;
    s := s + AttFile.Error + CRLF;
  end;

  if (Ret) then begin
    s := s + Format('Успешно принято - %d, ошибочных - %d',[GoodAtt, Atts.Count - GoodAtt])
  end else
    s := 'Были ошибки:' + s;
  ShowDeb(s);

end;




procedure TForm1.btnGetINsOnlyClick(Sender: TObject);
var
  Ret : Boolean;
  i : Integer;
  sE  : string;
  RQRes : TResultHTTP;
begin
  RQRes := nil;
  Ret := RSMDO.GetApiAuthToken(RQRes);
  if (Ret = True) then
    sE := Format('Auth: %s', [RSMDO.FSecure.GetApiAuth])
  else begin
    sE := Format('Код ошибки %d %s', [RQRes.ResCode, RQRes.ResMsg]);
    FreeAndNil(RQRes);
  end;
  ShowDeb(sE);
end;

procedure TForm1.btnGetNsiRSMDOClick(Sender: TObject);
var
  Ret : Boolean;
  i : Integer;
  s,
  sE  : string;
  SONsi,
  Filter : ISuperObject;
  RQRes : TResultHTTP;
begin
  Filter := nil;
  Ret := RSMDO.GetNsi(REQ_NSI_TYPDOC, True, Filter, SONsi, sE);
  if (Ret) then begin
    s := Format('Загружено записей - %d', [SONsi.AsArray.Length]);
  end else begin
    s := 'Ошибки при загрузке НСИ ';
  end;
  s := s + sE;
  ShowDeb(s);
end;

end.


