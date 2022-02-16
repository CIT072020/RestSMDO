unit uServRSMDO;

interface

uses
  Classes,
  Types,
  DB,
  kbmMemTable,
  superobject,
  superdate,
  SasaINiFile;

type
(*
 Выходные результаты для GET/POST
*)
  TResultHTTP = class
  private
    FCode   : Integer;
    FMsg    : string;
    FStrInf : string;
    FQuery  : Integer;
  protected
  public
    // Результат запроса, 0 - все гут
    property ResCode : Integer read FCode write FCode;
    // Сообщение об ошибке
    property ResMsg  : string read FMsg write FMsg;
    // Результат запроса в виде символьной строки (например, временный ИН)
    property StrInf  : string read FStrInf write FStrInf;

    procedure ClearRes(QueryCode: Integer);

    constructor Create;
    destructor Destroy; override;
  end;


implementation


// Результат GET/POST
constructor TResultHTTP.Create;
begin
  inherited Create;
  ClearRes(0);
end;

destructor TResultHTTP.Destroy;
begin
  inherited;
end;


// Очистка результата HTTP-запроса
procedure TResultHTTP.ClearRes(QueryCode: Integer);
begin
  FCode    := 0;
  FMsg     := '';
  FStrInf  := '';
  FQuery   := QueryCode;
end;




end.
