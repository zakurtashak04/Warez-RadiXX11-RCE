unit FormMain;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, ComCtrls, ExtCtrls, jpeg;

type
  TMainForm = class(TForm)
    Bevel: TBevel;
    btnCopy: TButton;
    cbProduct: TComboBox;
    edtKey: TEdit;
    imgBanner: TImage;
    lblKey: TLabel;
    lblCopyright: TLabel;
    lblProduct: TLabel;
    btnGenerate: TButton;
    procedure btnCopyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure UpdateKey(Sender: TObject);
    procedure btnGenerateClick(Sender: TObject);
  private
    procedure PopulateProductList;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  License;

//--------------------------------------------------------------------------------------------------

procedure TMainForm.btnCopyClick(Sender: TObject);
begin
  edtKey.SelectAll;
  edtKey.CopyToClipboard;
  edtKey.SelLength := 0;
end;

//--------------------------------------------------------------------------------------------------

procedure TMainForm.btnGenerateClick(Sender: TObject);
begin
  UpdateKey(nil);
end;

//--------------------------------------------------------------------------------------------------

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Caption := Application.Title;
  PopulateProductList;
  UpdateKey(nil);
end;

//--------------------------------------------------------------------------------------------------

procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
    Close;
end;

//--------------------------------------------------------------------------------------------------

procedure TMainForm.PopulateProductList;
var
  I: Integer;
begin
  cbProduct.Items.BeginUpdate;
  try
    cbProduct.Items.Clear;

    for I := Low(ProductList) to High(ProductList) do
      cbProduct.Items.Add(ProductList[I].Name);
  finally
    cbProduct.Items.EndUpdate;

    if cbProduct.Items.Count > 0 then
      cbProduct.ItemIndex := 0;
  end;
end;

//--------------------------------------------------------------------------------------------------

procedure TMainForm.UpdateKey(Sender: TObject);
begin
  if cbProduct.ItemIndex >= 0 then
    edtKey.Text := GenerateLicenseKey(ProductList[cbProduct.ItemIndex].Id, 0, 0);
end;

end.
