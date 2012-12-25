program SystemDyf;

uses
  vcl.Forms,
  ProgUnit in 'ProgUnit.pas' {frmSysDyf},
  Output in 'Output.pas' {frmOutput};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmSysDyf, frmSysDyf);
  Application.CreateForm(TfrmOutput, frmOutput);
  Application.Run;
end.
