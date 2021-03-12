unit SelectUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ShellCtrls,
  StdCtrls, ExtCtrls, XMLPropStorage, FileCtrl, ComCtrls, BaseUnix, Unix;

type

  { TSelectForm }

  TSelectForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    FileListBox1: TFileListBox;
    Panel1: TPanel;
    ShellTreeView1: TShellTreeView;
    Splitter1: TSplitter;
    SelectFormStorage: TXMLPropStorage;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FileListBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure ShellTreeView1Click(Sender: TObject);
  private

  public

  end;

var
  SelectForm: TSelectForm;

implementation

uses unit1;

{$R *.lfm}

{ TSelectForm }

procedure TSelectForm.ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  Screen.Cursor := crHourGlass;

  //Проверяем каталог на симлинк
  if fpReadLink(ExcludeTrailingPathDelimiter(ShellTreeView1.Path)) <> '' then
    Panel1.Caption := SymLink
  else
    Panel1.Caption := '';

  FileListBox1.Directory := ShellTreeView1.Path;
  Screen.Cursor := crDefault;
end;

procedure TSelectForm.ShellTreeView1Click(Sender: TObject);
begin
  ShellTreeView1.Color := RGBtoColor(255, 255, 238);
  FileListBox1.Color := clWindow;
end;

procedure TSelectForm.Button1Click(Sender: TObject);
var
  i: integer;
begin
  //Если что-то выделено, обработать пути
  if (ShellTreeView1.Selected <> nil) or (FileListBox1.SelCount <> 0) then
  begin
    if ShellTreeView1.Color = clDefault then
    begin
      for i := 0 to FileListBox1.Items.Count - 1 do
        if FileListBox1.Selected[i] then
          MainForm.ListBox1.Items.Append(Concat(FileListBox1.Directory,
            FileListBox1.Items[i]));
    end
    else
    if ShellTreeView1.GetPathFromNode(ShellTreeView1.Selected) <> '/' then
      MainForm.ListBox1.Items.Append(ShellTreeView1.GetPathFromNode(
        ShellTreeView1.Selected));

    //Если выбирались файлы, возвращаем курсор в FileListBox
    if FileListbox1.SelCount <> 0 then
      FileListBox1.SetFocus;

    SaveFlag := True;
  end;
end;

//Перечитать
procedure TSelectForm.Button2Click(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  //Выбираем топ-ноду и делаем рефреш всего
  ShellTreeView1.Select(ShellTreeView1.Items[0]);
  ShellTreeView1.Refresh(ShellTreeView1.Selected.Parent);
  ShellTreeView1.Select(ShellTreeView1.Items[0]);

  //Обновить список файлов
  FileListBox1.UpdateFileList;

  ShellTreeView1.Color := RGBtoColor(255, 255, 238);
  FileListBox1.Color := clWindow;

  Screen.Cursor := crDefault;
end;

procedure TSelectForm.FileListBox1Click(Sender: TObject);
begin
  if FileListBox1.Count <> 0 then
    ShellTreeView1.Color := clDefault;
end;

procedure TSelectForm.FormCreate(Sender: TObject);
begin
  SelectFormStorage.FileName := MainForm.MainFormStorage.FileName;
end;

procedure TSelectForm.FormShow(Sender: TObject);
begin
  Button2.Click;
end;

end.
