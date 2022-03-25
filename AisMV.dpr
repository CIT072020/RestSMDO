
program AisMV;

uses
  ExceptionLog,
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  fPIN4Av in 'fPIN4Av.pas' {fPINGet},
  uRSMDO in '..\Lais7\OAIS\uRSMDO.pas',
  uRSMDOService in '..\Lais7\OAIS\uRSMDOService.pas',
  uRSMDODTO in 'uRSMDODTO.pas',
  uRSMDOPkg in 'uRSMDOPkg.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TfPINGet, fPINGet);
  Application.Run;
end.
