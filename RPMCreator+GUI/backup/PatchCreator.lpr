program PatchCreator;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1, unique_utils, SysUtils,
  Dialogs
  { you can add units after this };
  var
  MyProg: TUniqueInstance;

{$R *.res}

begin
 { //Запускаем от Root
  if GetEnvironmentVariable('USER') <> 'root' then
  begin
    MainForm.StartProcess('"' + ExtractFilePath(ParamStr(0)) +
      'StartAsRoot"', 'sh');
    Halt(1);
  end;}

  //Создаём объект с уникальным идентификатором
  MyProg := TUniqueInstance.Create('PatchCreator');

  //Проверяем, нет ли в системе объекта с таким ID
  if MyProg.IsRunInstance then
  begin
    MessageDlg('Приложение уже запущено!', mtWarning, [mbOK], 0);
    MyProg.Free;
    Halt(1);
  end
  else
    MyProg.RunListen;

  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

