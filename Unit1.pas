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
  uUseful,
  uRSMDO,
  uROCExchg;

const  
  INI_NAME = '..\Lais7\Service\smdo.ini';

 

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
    procedure btnCursNormClick(Sender: TObject);
    procedure btnCursWaitClick(Sender: TObject);
    procedure btnGetActualClick(Sender: TObject);
    procedure btnGetINsOnlyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnGetNSIClick(Sender: TObject);
    procedure btnPostDocClick(Sender: TObject);
    procedure btnGetTempINClick(Sender: TObject);
    procedure btnServReadyClick(Sender: TObject);
  private
    { Private declarations }
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
  uAvest,
  fPIN4Av;

{$R *.dfm}


// Вывод отладки в Memo
procedure ShowDeb(const s: string; const ClearAll: Boolean = True);
var
  AddS: string;
begin
  AddS := '';
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

  IniFile  := TSasaIniFile.Create(INI_NAME);
  RSMDO := TRouterMV.Create(IniFile, Form1);
  Self.Caption := 'Обмен с адресом: ' + RSMDO.FHost.URL;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(IniFile);
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




// Получить пакеты
procedure TForm1.btnGetTempINClick(Sender: TObject);
var
  i : Integer;
  s : string;
begin
  i := RSMDO.GetMailList(nil);
end;

procedure TForm1.btnServReadyClick(Sender: TObject);
var
  Ret : Boolean;
  s : string;
begin
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

procedure TForm1.btnGetINsOnlyClick(Sender: TObject);
var
  Ret : Boolean;
  i : Integer;
  sE  : string;
begin
  Ret := RSMDO.GetApiAuthToken;
  i := RSMDO.SetRetCode(Ret, RSMDO.ResHTTP, sE);
  ShowDeb(IntToStr(i) + ' ' + sE);
end;

end.


