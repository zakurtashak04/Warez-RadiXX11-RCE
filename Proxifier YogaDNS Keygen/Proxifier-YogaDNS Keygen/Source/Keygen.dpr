program Keygen;

uses
  Forms,
  FormMain in 'Forms\FormMain.pas' {MainForm},
  License in 'Units\License.pas';

{$R *.res}

begin
  Randomize;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Proxifier/YogaDNS Keygen';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
