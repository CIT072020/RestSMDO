unit uRSMDODTO;

{$DEFINE SIGN}
{$DEFINE AVEST_GISUN}

interface

uses
  Classes,
  Types,
  DB,
  kbmMemTable,
  superobject,
  superdate,
  SasaINiFile,
  uServRSMDO;

const

  DATETIME_FMT_BY = 'dd.MM.yyyy';
type
  // Чтение/Запись установочных данных
  TMailDTO = class
  private
    // MemTable with Docs
    FMail : TDataSet;
    FSO : ISuperObject;
  public

    constructor Create;
    destructor Destroy;

    class function SOMail2JSON(SOMail: ISuperObject; StreamDoc: TStringStream; var sErr : string): Boolean;
  end;

implementation

uses
  Forms,
  SysUtils,
  DateUtils,
  Variants,
  FuncPr;

constructor TMailDTO.Create;
begin
  inherited Create;
end;


destructor TMailDTO.Destroy;
begin
  inherited;
end;


// Подготовка и создание пакета в маршрутизаторе
class function TMailDTO.SOMail2JSON(SOMail: ISuperObject; StreamDoc: TStringStream; var sErr : string): Boolean;
var
  sCurErr,
  sTmp : String;
  sUTF : UTF8String;

  // Вставить число
  // Вставить логическое
  // Вставить значение ключа
  procedure NumBool2JSON(const JsonProp: string; sV: Variant); overload;
  begin
    sV := AnsiLowerCase(VarToStrDef(sV, 'null'));
    StreamDoc.WriteString('"' + JsonProp + '":' + sV + ',');
  end;

  // Вставить null
  procedure NumBool2JSON(const JsonProp: string); overload;
  begin
       NumBool2JSON(JsonProp, null);
  end;

  // Вставить строку
  procedure Str2JSON(const JsonProp: string; sVal: Variant; NeedUp : Boolean = False);
  begin
    if (sVal = null) then
      NumBool2JSON(JsonProp)
    else begin
      if (NeedUp = True) then
        sVal := AnsiUpperCase(sVal);
      if (Pos('"', sVal) > 0) then
        sVal := StringReplace(sVal, '"', '\"', [rfReplaceAll]);
      sVal := '"' + sVal + '"';
      StreamDoc.WriteString('"' + JsonProp + '": ' + sVal + ',');
    end;
  end;

  // Вставить дату (JavaFormat)
    procedure DateJava2JSON(JsonProp: String; dValue: TDateTime);
  begin
    if (dValue = 0) or (Dtos(dValue) = '19700101') then
      sTmp := 'null'
    else
      sTmp := IntToStr(DelphiToJavaDateTime(dValue));
    StreamDoc.WriteString('"' + JsonProp + '": ' + sTmp + ',');
  end;




begin
  try
    StreamDoc.WriteString('{');

    // Пакет
    sCurErr := 'Заголовок пакета';
    Str2JSON('packageId', '');

  // Последней была запятая, вернемся для записи конца объекта
    StreamDoc.Seek(-1, soCurrent);
    StreamDoc.WriteString('}');

    sUTF := AnsiToUtf8(StreamDoc.DataString);
    StreamDoc.Seek(0, soBeginning);
    StreamDoc.WriteString(sUTF);
    Result  := True;
    sCurErr := '';
  except
    Result  := False;
    sCurErr := 'секция ' + sCurErr;
  end;
  sErr := sCurErr;
end;




end.
