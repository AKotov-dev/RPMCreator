unit unpackunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, XMLPropStorage, Process;

type

  { TUnpackForm }

  TUnpackForm = class(TForm)
    Button1: TButton;
    EditButton1: TEditButton;
    EditButton2: TEditButton;
    Label1: TLabel;
    Label2: TLabel;
    LogMemo: TMemo;
    OpenDialog1: TOpenDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    UnpackFormStorage: TXMLPropStorage;
    procedure Button1Click(Sender: TObject);
    procedure EditButton1ButtonClick(Sender: TObject);
    procedure EditButton1Change(Sender: TObject);
    procedure EditButton1KeyPress(Sender: TObject; var Key: char);
    procedure EditButton2ButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UnpackProcess(Command: string);
  private

  public

  end;

var
  UnpackForm: TUnpackForm;

implementation

uses unit1;

{$R *.lfm}

{ TUnpackForm }

//Процедура запуска распаковки
procedure TUnpackForm.UnpackProcess(Command: string);
var
  ExProcess: TProcess;
begin
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;
  try
    ExProcess := TProcess.Create(nil);
    LogMemo.Clear;

    ExProcess.Options := ExProcess.Options + [poWaitOnExit, poUsePipes,
      poStdErrToOutput];

    ExProcess.Executable := 'sh';
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add(Command);

    ExProcess.Execute;
    LogMemo.Lines.LoadFromStream(ExProcess.Output);

  finally
    ExProcess.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TUnpackForm.FormCreate(Sender: TObject);
begin
  UnpackForm.UnpackFormStorage.FileName := MainForm.MainFormStorage.FileName;
end;

procedure TUnpackForm.EditButton1ButtonClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    EditButton1.Text := OpenDialog1.FileName;
end;

procedure TUnpackForm.EditButton1Change(Sender: TObject);
begin
  if (EditButton1.Text = '') or (EditButton2.Text = '') then
    Button1.Enabled := False
  else
    Button1.Enabled := True;
  LogMemo.Clear;
end;

procedure TUnpackForm.EditButton1KeyPress(Sender: TObject; var Key: char);
begin
  Key := #0;
end;

//Распаковка
procedure TUnpackForm.Button1Click(Sender: TObject);
begin
  LogMemo.Clear;

  if (not FileExists(EditButton1.Text)) or (not DirectoryExists(EditButton2.Text)) then
    LogMemo.Lines.Add('---the package file or folder does not exist for unpacking...')
  else
  begin
    LogMemo.Lines.Add('---unpack started, please wait...');

    //Текущий каталог
    SetCurrentDir(EditButton2.Text);

    if Copy(EditButton1.Text, Length(EditButton1.Text) - 3, 4) = '.rpm' then
      UnpackProcess('rm -rf ./tmp ./rpm; mkdir ./tmp ./rpm; 7z x -y ' +
        EditButton1.Text + ' -o./tmp; 7z x -y ./tmp/*.cpio -o./rpm; rm -rf ./tmp')
    else
      UnpackProcess('rm -rf ./tmp ./deb; mkdir ./tmp ./deb; 7z x -y ' +
        EditButton1.Text +
        ' -o./tmp; rm -rf ./deb; mkdir ./deb; tar -xvf ./tmp/*.tar -C ./deb; rm -rf ./tmp');
  end;
end;

procedure TUnpackForm.EditButton2ButtonClick(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
    EditButton2.Text := SelectDirectoryDialog1.FileName;
end;

end.
