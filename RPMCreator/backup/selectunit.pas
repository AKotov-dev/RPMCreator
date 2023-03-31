unit SelectUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ShellCtrls,
  StdCtrls, ExtCtrls, XMLPropStorage, FileCtrl, ComCtrls, BaseUnix, Unix, Types;

type

  { TSelectForm }

  TSelectForm = class(TForm)
    AddBtn: TButton;
    ImageList1: TImageList;
    UpdateBtn: TButton;
    FileListBox1: TFileListBox;
    Panel1: TPanel;
    ShellTreeView1: TShellTreeView;
    Splitter1: TSplitter;
    SelectFormStorage: TXMLPropStorage;
    StatusBar1: TStatusBar;
    procedure AddBtnClick(Sender: TObject);
    procedure FileListBox1DrawItem(Control: TWinControl; Index: integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure ShellTreeView1GetImageIndex(Sender: TObject; Node: TTreeNode);
    procedure UpdateBtnClick(Sender: TObject);
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
    Panel1.Caption := SSymLink
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

procedure TSelectForm.AddBtnClick(Sender: TObject);
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


//Иконки файлов в FileListBox
procedure TSelectForm.FileListBox1DrawItem(Control: TWinControl;
  Index: integer; ARect: TRect; State: TOwnerDrawState);
var
  BitMap: TBitMap;
begin
  try
     BitMap := TBitMap.Create;
     with FileListBox1 do
     begin
       Canvas.FillRect(aRect);
       //Название файла
       //Canvas.TextOut(aRect.Left + 26, aRect.Top + 5, Items[Index]);
       //Название (текст по центру-вертикали)
       Canvas.TextOut(aRect.Left + 26, aRect.Top + ItemHeight div 2 -
         Canvas.TextHeight('A') div 2 + 1, Items[Index]);

       //Иконка файла
       ImageList1.GetBitMap(1, BitMap);
       Canvas.Draw(aRect.Left + 2, aRect.Top + (ItemHeight - 22) div 2 + 2, BitMap);
     end;
   finally
    BitMap.Free;
  end;
end;

procedure TSelectForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if MainForm.ListBox1.Count <> 0 then
    MainForm.ListBox1.ItemIndex := 0;
end;

//Иконки директорий в ShellTreeView1
procedure TSelectForm.ShellTreeView1GetImageIndex(Sender: TObject; Node: TTreeNode);
begin
  Node.ImageIndex := 0;
  Node.SelectedIndex := Node.ImageIndex;
end;

//Перечитать
procedure TSelectForm.UpdateBtnClick(Sender: TObject);
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

//Цвет - указатель панели
procedure TSelectForm.FileListBox1Click(Sender: TObject);
begin
  if FileListBox1.Count <> 0 then
  begin
    ShellTreeView1.Color := clDefault;
    FileListBox1.Color := RGBtoColor(255, 255, 238);
  end;
end;

procedure TSelectForm.FormCreate(Sender: TObject);
begin
  SelectFormStorage.FileName := MainForm.MainFormStorage.FileName;
end;

procedure TSelectForm.FormShow(Sender: TObject);
begin
  SelectFormStorage.Restore;
  UpdateBtn.Click;
end;

end.
