unit uRSMDOPkg;

interface

uses
  Classes,
  superobject;


type

  TOrganization = class
  end;
  TPrivatePerson = class
  end;

  // Общая часть пакетов взаимодействия с маршрутизатором
  TPackageGen = class
  public
    Id    : string;
    Doc   : TMemoryStream;
    SOPkg : ISuperObject;

    constructor Create;
    destructor Destroy; override;

  end;

  TPackageSend = class(TPackageGen)
  // Пакет для отправки на PackageReceiver
  public
    Org  : TOrganization;
    Pers : TPrivatePerson;
  end;

  // Текущий пакет в получении от PackageSender
  TPackageReceive = class(TPackageGen)
  public
    Org  : TOrganization;
    Pers : TPrivatePerson;
  end;


implementation

uses
  SysUtils;

constructor TPackageGen.Create;
begin
  inherited Create;
  Doc := TMemoryStream.Create;
end;

destructor TPackageGen.Destroy;
begin
  FreeAndNil(Doc);
  inherited;
end;



end.
 