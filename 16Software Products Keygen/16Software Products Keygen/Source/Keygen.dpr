program Keygen;

uses
  Forms,
  FormMain in 'Forms\FormMain.pas' {MainForm},
  License in 'Units\License.pas',
  Base64 in 'Units\Base64.pas',
  HashUtils in 'Units\HashUtils.pas',
  MD5 in 'Units\MD5.pas';

{$R *.res}

begin
  Randomize;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := '16Software Products Keygen';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
