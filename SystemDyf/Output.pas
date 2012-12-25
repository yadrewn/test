unit Output;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls;

type
  TfrmOutput = class(TForm)
    Image1: TImage;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Image2: TImage;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmOutput: TfrmOutput;

implementation

uses ProgUnit;

{$R *.dfm}

procedure TfrmOutput.FormActivate(Sender: TObject);
begin
frmSysDyf.SynEdit.Enabled:=true;
frmSysDyf.SynEdit.Color:=clCream;
end;


end.
