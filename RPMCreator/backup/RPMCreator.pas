program RPMCreator;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  unique_utils,
  SysUtils,
  Dialogs,
  Unit2, SelectUnit, unpackunit { you can add units after this };

var
  MyProg: TUniqueInstance;

{$R *.res}

begin
  Application.Title:='RPMCreator v2.0';
  //Создаём объект с уникальным идентификатором
  MyProg := TUniqueInstance.Create('RPMCreator');

  //Проверяем, нет ли в системе объекта с таким ID
  if MyProg.IsRunInstance then
  begin
    MessageDlg('Application is running!', mtWarning, [mbOK], 0);
    MyProg.Free;
    Halt(1);
  end
  else
    MyProg.RunListen;

  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TSelectForm, SelectForm);
  Application.CreateForm(TUnpackForm, UnpackForm);
  Application.Run;
end.
