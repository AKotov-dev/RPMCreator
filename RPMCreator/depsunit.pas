unit depsunit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  XMLPropStorage, Process, ClipBrd, Buttons;

type

  { TDepsForm }

  TDepsForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    OpenBtn: TButton;
    Edit1: TEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    OpenDialog1: TOpenDialog;
    DepsFormStorage: TXMLPropStorage;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  DepsForm: TDepsForm;

implementation

uses unit1;

  {$R *.lfm}

  { TDepsForm }


// Функция возврата вывода команды
function RunBashCommand(const Command: string; out OutputStr: string): boolean;
const
  BUF_SIZE = 2048;
var
  AProcess: TProcess;
  Buffer: array[0..BUF_SIZE - 1] of byte;
  BytesRead: longint;
  OutputStream: TStringStream;
begin
  Result := False;
  OutputStr := '';

  AProcess := TProcess.Create(nil);
  OutputStream := TStringStream.Create('');
  try
    // Зашиваем bash и его параметры прямо сюда
    AProcess.Executable := 'bash';
    AProcess.Parameters.Add('-c');
    AProcess.Parameters.Add(Command);

    AProcess.Options := [poUsePipes, poStderrToOutput, poNoConsole];
    AProcess.Execute;

    while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do
    begin
      if AProcess.Output.NumBytesAvailable > 0 then
      begin
        BytesRead := AProcess.Output.Read(Buffer, BUF_SIZE);
        if BytesRead > 0 then
          OutputStream.Write(Buffer, BytesRead);
      end
      else
        Sleep(10);
    end;

    OutputStr := OutputStream.DataString;
    Result := (AProcess.ExitCode = 0);
  finally
    OutputStream.Free;
    AProcess.Free;
  end;
end;

procedure TDepsForm.FormShow(Sender: TObject);
begin
  DepsFormStorage.Restore;

  OpenBtn.Width := OpenBtn.Height;

  //В центр
  Left := MainForm.Left + MainForm.Width div 2 - Width div 2;
  Top := MainForm.Top + MainForm.Height div 2 - Height div 2;
end;

procedure TDepsForm.OpenBtnClick(Sender: TObject);
var
  S, Cmd: string;
begin
  S := '';
  Cmd := '';

  if OpenDialog1.Execute then
  begin
    Edit1.Text := OpenDialog1.FileName;

    Memo1.Clear;
    Memo2.Clear;
    Memo3.Clear;

    // Requires
    Cmd := 'rpmspec -q --requires "' + OpenDialog1.FileName +
      '" | cut -f1 -d" " | sort -u | sed ' + '''' + 's/.*(.*)/"&"/' + '''';

    if RunBashCommand(Cmd, S) then Memo1.Text := S;

    // BuildRequires
    Cmd := 'rpmspec -q --buildrequires "' + OpenDialog1.FileName +
      '" | cut -f1 -d" " | sort -u | sed ' + '''' + 's/.*(.*)/"&"/' + '''';

    if RunBashCommand(Cmd, S) then Memo2.Text := S;

    // Recommends
    Cmd := 'rpmspec -q --recommends "' + OpenDialog1.FileName +
      '" | cut -f1 -d" " | sort -u | sed ' + '''' + 's/.*(.*)/"&"/' + '''';

    if RunBashCommand(Cmd, S) then Memo3.Text := S;
  end;
end;

//Выравнивание по ширине
procedure TDepsForm.FormResize(Sender: TObject);
begin
  Memo1.Width := DepsForm.Width div 3 - 10;
  Memo2.Width := Memo1.Width;
  Memo3.Width := Memo1.Width;
end;

procedure TDepsForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  DepsFormStorage.Save;
end;

procedure TDepsForm.Label1Click(Sender: TObject);
begin
  ClipBoard.AsText := Trim(StringReplace(Memo1.Text, sLineBreak, ' ', [rfReplaceAll]));
end;

procedure TDepsForm.Label2Click(Sender: TObject);
begin
  ClipBoard.AsText := Trim(StringReplace(Memo2.Text, sLineBreak, ' ', [rfReplaceAll]));
end;

procedure TDepsForm.Label3Click(Sender: TObject);
begin
  ClipBoard.AsText := Trim(StringReplace(Memo3.Text, sLineBreak, ' ', [rfReplaceAll]));
end;

procedure TDepsForm.FormCreate(Sender: TObject);
begin
  DepsFormStorage.FileName := MainForm.MainFormStorage.FileName;
end;

end.
