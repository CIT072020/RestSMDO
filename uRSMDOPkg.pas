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

  // ����� ����� ������� �������������� � ���������������
  TPackageGen = class
  public
    Id    : string;
    Doc   : TMemoryStream;
    SOPkg : ISuperObject;

    constructor Create;
    destructor Destroy; override;

  end;

  TPackageSend = class(TPackageGen)
  // ����� ��� �������� �� PackageReceiver
  public
    Org  : TOrganization;
    Pers : TPrivatePerson;
  end;

  // ������� ����� � ��������� �� PackageSender
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
 