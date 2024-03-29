unit LoadGroupsTRD;

{$mode objfpc}{$H+}

interface

uses
  Classes, Process, SysUtils, Forms, Controls;

type
  StartLoadGroups = class(TThread)
  private

    { Private declarations }
  protected
  var
    S: TStringList;

    procedure Execute; override;
    procedure UpdateGroupBox;
    procedure ShowProgress;
    procedure HideProgress;

  end;

implementation

uses Unit1;

{ TRD }

//Получить список валидных групп
procedure StartLoadGroups.Execute;
var
  ExProcess: TProcess;
begin
  try
    Synchronize(@ShowProgress);

    S := TStringList.Create;
    FreeOnTerminate := True; //Уничтожить по завершении

    //Рабочий процесс
    ExProcess := TProcess.Create(nil);

    ExProcess.Executable := 'bash';
    ExProcess.Parameters.Add('-c');

    ExProcess.Options := [poWaitOnExit, poUsePipes];

    //Получить список валидных групп
    ExProcess.Parameters.Add(
      '[[ $(type -f rpmlint1 2>/dev/null) ]] && rpmlint --explain non-standard-group ' +
      '| grep "\"" | tr "\n" " " | tr "," "\n" | tr -d [".\""] | sed "s/^ *//"');

    Exprocess.Execute;

    S.LoadFromStream(ExProcess.Output);
    S.Text := Trim(S.Text);

    //Если есть, что выводить и SD-Карта существует
    if S.Count <> 0 then
      Synchronize(@UpdateGroupBox);

  finally
    Synchronize(@HideProgress);
    S.Free;
    ExProcess.Free;
    Terminate;
  end;
end;

//Начало
procedure StartLoadGroups.ShowProgress;
begin
  Screen.cursor := crHourGlass;
end;

//Завершение
procedure StartLoadGroups.HideProgress;
begin
  Screen.cursor := crDefault;
end;

{ ВЫВОД }
procedure StartLoadGroups.UpdateGroupBox;
begin
  S.SaveToFile(WorkDir + '/rpm-groups.list');
  MainForm.GroupCBox.Items.Assign(S);
end;

end.
