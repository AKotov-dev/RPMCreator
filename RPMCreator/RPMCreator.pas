program RPMCreator;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX}
  cthreads,     {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  SysUtils,
  Classes,
  Process,
  Dialogs,
  Unit2,
  SelectUnit,
  unpackunit,
  LoadGroupsTRD { you can add units after this };

{$R *.res}

//--- Определяем, запущена ли копия программы
var
  PID: TStringList;
  ExProcess: TProcess;

begin
  ExProcess := TProcess.Create(nil);
  PID := TStringList.Create;
  try
    ExProcess.Executable := 'bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add('pidof RPMCreator'); //Имя приложения
    ExProcess.Options := ExProcess.Options + [poUsePipes];

    ExProcess.Execute;
    PID.LoadFromStream(ExProcess.Output);

  finally
    ExProcess.Free;
  end;

  //Количество запущенных копий > 1 = не запускать новый экземпляр
  if Pos(' ', PID.Text) <> 0 then //пробел = более одного pid
  begin
    MessageDlg(SAppRunning, mtWarning, [mbOK], 0);
    PID.Free;
    Application.Free;
    Halt(1);
  end;
  PID.Free;

  //---

  Application.Scaled:=True;
  Application.Title:='RPMCreator v2.6';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TSelectForm, SelectForm);
  Application.CreateForm(TUnpackForm, UnpackForm);
  Application.Run;
end.
