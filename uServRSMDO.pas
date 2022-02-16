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
 �������� ���������� ��� GET/POST
*)
  TResultHTTP = class
  private
    FCode   : Integer;
    FMsg    : string;
    FStrInf : string;
    FQuery  : Integer;
  protected
  public
    // ��������� �������, 0 - ��� ���
    property ResCode : Integer read FCode write FCode;
    // ��������� �� ������
    property ResMsg  : string read FMsg write FMsg;
    // ��������� ������� � ���� ���������� ������ (��������, ��������� ��)
    property StrInf  : string read FStrInf write FStrInf;

    procedure ClearRes(QueryCode: Integer);

    constructor Create;
    destructor Destroy; override;
  end;


implementation


// ��������� GET/POST
constructor TResultHTTP.Create;
begin
  inherited Create;
  ClearRes(0);
end;

destructor TResultHTTP.Destroy;
begin
  inherited;
end;


// ������� ���������� HTTP-�������
procedure TResultHTTP.ClearRes(QueryCode: Integer);
begin
  FCode    := 0;
  FMsg     := '';
  FStrInf  := '';
  FQuery   := QueryCode;
end;




end.
