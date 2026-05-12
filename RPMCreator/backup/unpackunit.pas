unit unpackunit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, XMLPropStorage, Process;

type

  { TUnpackForm }

  TUnpackForm = class(TForm)
    UnpackBtn: TButton;
    EditButton1: TEditButton;
    EditButton2: TEditButton;
    Label1: TLabel;
    Label2: TLabel;
    LogMemo: TMemo;
    OpenDialog1: TOpenDialog;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    UnpackFormStorage: TXMLPropStorage;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure UnpackBtnClick(Sender: TObject);
    procedure EditButton1ButtonClick(Sender: TObject);
    procedure EditButton1Change(Sender: TObject);
    procedure EditButton1KeyPress(Sender: TObject; var Key: char);
    procedure EditButton2ButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UnpackProcess(PackageName: string);
    procedure CreateUnpackScript;

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
procedure TUnpackForm.UnpackProcess(PackageName: string);
var
  ExProcess: TProcess;
  Buffer: array[0..2047] of byte;
  Count: longint;
  S: string;
begin
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;

  ExProcess := TProcess.Create(nil);

  try
    LogMemo.Clear;

    ExProcess.Options := [poUsePipes, poStdErrToOutput];

    ExProcess.Executable := 'bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add(
      'chmod +x ~/.RPMCreator/unpack.sh; ~/.RPMCreator/unpack.sh "' +
      PackageName + '"');

    ExProcess.Execute;

    while ExProcess.Running do
    begin
      while ExProcess.Output.NumBytesAvailable > 0 do
      begin
        Count := ExProcess.Output.Read(Buffer, SizeOf(Buffer));

        if Count > 0 then
        begin
          SetString(S, PChar(@Buffer[0]), Count);
          LogMemo.Text := LogMemo.Text + S;
          Application.ProcessMessages;
        end;
      end;

      Sleep(10);
    end;

    // дочитать остатки
    while ExProcess.Output.NumBytesAvailable > 0 do
    begin
      Count := ExProcess.Output.Read(Buffer, SizeOf(Buffer));

      if Count > 0 then
      begin
        SetString(S, PChar(@Buffer[0]), Count);
        LogMemo.Text := LogMemo.Text + S;
      end;
    end;

  finally
    ExProcess.Free;
    Screen.Cursor := crDefault;
  end;
end;

//Создание скрипта полной распаковки RPM/DEB (включая метаданные)
procedure TUnpackForm.CreateUnpackScript;
var
  S: TStringList;
begin
  try
    S := TStringList.Create;

    S.Add('#!/bin/bash');

    S.Add('');
    //Файл пакета передан?
    S.Add('FILE="$1"');
    S.Add('if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then');
    S.Add('echo "Usage: $0 <package.rpm|.deb>"');
    S.Add('    exit 1');
    S.Add('fi');

    //Проверка наличия rpm2cpio
    S.Add('');
    S.Add('command -v rpm2cpio >/dev/null || {');
    S.Add('echo "rpm2cpio not found"');
    S.Add('exit 1');
    S.Add('}');

    //Проверка наличия dpkg-deb
    S.Add('');
    S.Add('command -v dpkg-deb >/dev/null || {');
    S.Add('echo "dpkg-deb not found"');
    S.Add('exit 1');
    S.Add('}');

    S.Add('');
    S.Add('EXT="${FILE##*.}"');

    //Создаём директорию с именем пакета_full_extract
    S.Add('DIR_NAME=./$(basename "$FILE")_full_extract');
    S.Add('rm -rf "$DIR_NAME"; mkdir -p "$DIR_NAME"');

    S.Add('');
    S.Add('echo -e "--- Full unpacking: $FILE ---\n"');

    S.Add('');
    S.Add('case "$EXT" in');
    S.Add('    deb)');
    S.Add('        # -R (или --extract) извлекает и файлы, и управляющую информацию в подпапку DEBIAN');
    S.Add('        # -v включает подробный вывод (статистику/список файлов');
    S.Add('        dpkg-deb -Rv "$FILE" "$DIR_NAME"');
    S.Add('        ;;');
    S.Add('    rpm)');
    S.Add('        # 1. Извлечение файлов');
    S.Add('        echo "Extracting files..."');
    S.Add('        rpm2cpio "$FILE" | cpio -idmv -D "$DIR_NAME"');
    S.Add('');
    S.Add('        # 2. Извлечение метаданных (скрипты, информация)');
    S.Add('        echo -e "\nExtracting metadata (scripts/info)..."');
    S.Add('        META_DIR="$DIR_NAME/RPM_META"');
    S.Add('        mkdir -p "$META_DIR"');
    S.Add('        rpm -qp --scripts "$FILE" > "$META_DIR/scripts.sh" 2>/dev/null');
    S.Add('        rpm -qpi "$FILE" > "$META_DIR/info.txt" 2>/dev/null');
    S.Add('        rpm -qp --changelog "$FILE" > "$META_DIR/changelog.txt" 2>/dev/null');
    S.Add('        rpm -qpl "$FILE" > "$META_DIR/filelist.txt" 2>/dev/null');
    S.Add('        rpm -qp --requires "$FILE" > "$META_DIR/requires.txt" 2>/dev/null');
    S.Add('        rpm -qp --provides "$FILE" > "$META_DIR/provides.txt" 2>/dev/null');
    S.Add('        rpm -qp --triggers "$FILE" > "$META_DIR/triggers.txt" 2>/dev/null');

    S.Add('');
    S.Add('        echo "Metadata is stored in $META_DIR"');
    S.Add('        ;;');
    S.Add('    *)');
    S.Add('        echo "$EXT format is not supported."');
    S.Add('        exit 1');
    S.Add('        ;;');
    S.Add('esac');
    S.Add('');
    S.Add('echo -e "\n--- Done! Contents in: $DIR_NAME ---"');

    S.Add('');
    S.Add('exit 0');

    S.SaveToFile(GetUserDir + '.RPMCreator/unpack.sh');

  finally
    S.Free;
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
    UnpackBtn.Enabled := False
  else
    UnpackBtn.Enabled := True;
end;

procedure TUnpackForm.EditButton1KeyPress(Sender: TObject; var Key: char);
begin
  Key := #0;
end;

//Распаковка
procedure TUnpackForm.UnpackBtnClick(Sender: TObject);
begin
  //Create ~/.RPMCreator/unpack.sh
  CreateUnpackScript;

  LogMemo.Clear;

  if (not FileExists(EditButton1.Text)) or (not DirectoryExists(EditButton2.Text)) then
    LogMemo.Lines.Add('--- the package file or folder does not exist for unpacking...')
  else
  begin
    LogMemo.Lines.Add('--- the beginning of unpacking, wait...');

    //Текущий каталог = EditButton2.Text (./)
    SetCurrentDir(EditButton2.Text);

    //Отправляем пакет на распаковку
    UnpackProcess(EditButton1.Text);

    //Промотать список вниз
    LogMemo.SelStart := Length(LogMemo.Text);
    LogMemo.SelLength := 0;
  end;
end;

procedure TUnpackForm.FormShow(Sender: TObject);
begin
  UnPackFormStorage.Restore;
  EditButton1.Button.Width := EditButton1.Height;
  EditButton2.Button.Width := EditButton2.Height;
end;

//Отбой на случай зависания скрипта распаковки
procedure TUnpackForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  S: ansistring;
begin
  RunCommand('bash', ['-c',
    'pgrep "unpack.sh" && pkill -f cpio rpm2cpio dpkg-deb unpack.sh'], S);
end;

//Выбор пакета для распаковки (*.rpm, *.deb)
procedure TUnpackForm.EditButton2ButtonClick(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
    EditButton2.Text := SelectDirectoryDialog1.FileName;
end;

end.
