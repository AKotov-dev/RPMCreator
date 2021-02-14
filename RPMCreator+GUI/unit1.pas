unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  XMLPropStorage, ExtCtrls, ComCtrls, Menus, Process, IniFiles, LCLType,
  Buttons, Translations, StrUtils;

type

  { TMainForm }

  TMainForm = class(TForm)
    AboutBtn: TButton;
    AfterInstallEdit: TMemo;
    AfterRemoveEdit: TMemo;
    BeforeInstallEdit: TMemo;
    BeforeRemoveEdit: TMemo;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Button1: TButton;
    UPBtn: TButton;
    DNBtn: TButton;
    UnpackBtn: TButton;
    Button3: TButton;
    BuildLabel: TLabel;
    ToolVersionEdit: TComboBox;
    DevToolEdit: TComboBox;
    SignCheckBox: TCheckBox;
    CreateRepackTxt: TButton;
    Label10: TLabel;
    Label21: TLabel;
    Memo1: TMemo;
    ProgramNameEdit: TEdit;
    TabSheet4: TTabSheet;
    Label16: TLabel;
    Label17: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label23: TLabel;
    LicenseEdit: TComboBox;
    GroupCBox: TComboBox;
    Label15: TLabel;
    InfoMemo: TMemo;
    MetaCheck: TCheckBox;
    NoArchCheck: TCheckBox;
    RPMBtn: TButton;
    BuildBtn: TButton;
    Button7: TButton;
    DepsEdit: TMemo;
    DescEdit: TMemo;
    ImageList1: TImageList;
    Label1: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LangBtn: TButton;
    ListBox1: TListBox;
    LoadBtn: TButton;
    MaintainerEdit: TEdit;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    NameEdit: TEdit;
    OpenFile: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    ReleaseEdit: TEdit;
    SaveBtn: TButton;
    SaveFile: TSaveDialog;
    MainFormStorage: TXMLPropStorage;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    URLCopyEdit: TEdit;
    URLEdit32: TEdit;
    URLEdit64: TEdit;
    VendorEdit: TEdit;
    SummaryEdit: TEdit;
    VersEdit: TEdit;
    procedure AboutBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CreateRepackTxtClick(Sender: TObject);
    procedure DevToolEditChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure LangBtnClick(Sender: TObject);
    procedure LoadBtnClick(Sender: TObject);
    procedure BuildBtnClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure MetaCheckClick(Sender: TObject);
    procedure NameEditChange(Sender: TObject);
    procedure NameEditKeyPress(Sender: TObject; var Key: char);
    procedure RPMBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StartProcess(command, terminal: string);
    procedure SearchDeskTop;
    procedure LangSelect;
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure TrimEdits;
    procedure UnpackBtnClick(Sender: TObject);
    procedure UPBtnClick(Sender: TObject);

  private

  public

  end;

var
  MainForm: TMainForm;
  WorkDir, SymLink: string;
  SaveFlag: boolean;

implementation

uses unit2, selectunit, unpackunit;

{$R *.lfm}

{ TMainForm }

//Проверка - каталог пуст
function DirectoryIsEmpty(Directory: string): boolean;
var
  SR: TSearchRec;
  i: integer;
begin
  Result := False;
  FindFirst(IncludeTrailingPathDelimiter(Directory) + '*', faAnyFile, SR);
  for i := 1 to 2 do
    if (SR.Name = '.') or (SR.Name = '..') then
      Result := FindNext(SR) <> 0;
  FindClose(SR);
end;

//Общая процедура запуска команд
procedure TMainForm.StartProcess(command, terminal: string);
var
  ExProcess: TProcess;
begin
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := terminal;  //sh или sakura
    if terminal <> 'sh' then
    begin
      ExProcess.Parameters.Add('--font');
      ExProcess.Parameters.Add('10');
      ExProcess.Parameters.Add('--columns');
      ExProcess.Parameters.Add('120');
      ExProcess.Parameters.Add('--rows');
      ExProcess.Parameters.Add('40');
      ExProcess.Parameters.Add('--title');
      ExProcess.Parameters.Add('Build RPM-package');
      ExProcess.Parameters.Add('--execute');
    end
    else
      ExProcess.Parameters.Add('-c');

    ExProcess.Parameters.Add(command);
    ExProcess.Options := ExProcess.Options + [poWaitOnExit];
    ExProcess.Execute;
  finally
    ExProcess.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.TrimEdits;
var
  SaveFlagMem: boolean;
begin
  //Запоминаем флаг изменений
  SaveFlagMem := SaveFlag;
  //Вкладка Основное
  NameEdit.Text := Trim(NameEdit.Text);
  VersEdit.Text := Trim(VersEdit.Text);
  ReleaseEdit.Text := Trim(ReleaseEdit.Text);
  DescEdit.Text := Trim(DescEdit.Text);
  MaintainerEdit.Text := Trim(MaintainerEdit.Text);
  VendorEdit.Text := Trim(VendorEdit.Text);
  SummaryEdit.Text := Trim(SummaryEdit.Text);
  URLCopyEdit.Text := Trim(URLCopyEdit.Text);
  LicenseEdit.Text := Trim(LicenseEdit.Text);
  GroupCBox.Text := Trim(GroupCBox.Text);
  DepsEdit.Text := Trim(DepsEdit.Text);
  //Вкладка скриптов
  AfterInstallEdit.Text := Trim(AfterInstallEdit.Text);
  AfterRemoveEdit.Text := Trim(AfterRemoveEdit.Text);
  BeforeInstallEdit.Text := Trim(BeforeInstallEdit.Text);
  BeforeRemoveEdit.Text := Trim(BeforeRemoveEdit.Text);
  //Вкладка repack.txt
  URLEdit32.Text := Trim(URLEdit32.Text);
  URLEdit64.Text := Trim(URLEdit64.Text);
  ProgramNameEdit.Text := Trim(ProgramNameEdit.Text);
  DevToolEdit.Text := Trim(DevToolEdit.Text);
  ToolVersionEdit.Text := Trim(ToolVersionEdit.Text);
  InfoMemo.Text := Trim(InfoMemo.Text);
  //Восстанавливаем флаг изменений
  SaveFlag := SaveFlagMem;
end;

procedure TMainForm.UnpackBtnClick(Sender: TObject);
begin
  UnpackForm.Show;
end;

procedure TMainForm.UPBtnClick(Sender: TObject);
var
  N: integer;
  F: boolean;
begin
  //Есть что перемещать?
  if ListBox1.ItemIndex < 0 then
    Exit;

  //Флаг изменения проекта
  SaveFlag := True;

  if Sender = UPBtn then
    N := ListBox1.ItemIndex - 1
  else
    N := ListBox1.ItemIndex + 1;

  if N = ListBox1.Count then
  begin
    N := 0;
    F := True;
  end
  else if N < 0 then
  begin
    N := ListBox1.Count - 1;
    F := True;
  end
  else
    F := False;

  //Верх/Низ списка достигнут
  if F then
    Exit;

  ListBox1.Items.Move(ListBox1.ItemIndex, N);
  ListBox1.ItemIndex := N;
end;


//Ищем Рабочий Стол
procedure TMainForm.SearchDeskTop;
var
  UserName: string;
begin
  UserName := GetEnvironmentVariable('USER');

  if DirectoryExists('/home/' + UserName + '/Рабочий стол') then
    OpenFile.InitialDir := '/home/' + UserName + '/Рабочий стол'
  else
  if DirectoryExists('/home/' + UserName + '/Desktop') then
    OpenFile.InitialDir := '/home/' + UserName + '/Desktop'
  else
    OpenFile.InitialDir := '/home';

  SaveFile.InitialDir := OpenFile.InitialDir;
end;

//Выбор языка интерфейса
procedure TMainForm.LangSelect;
begin
  if LangBtn.Caption = 'RU' then
  begin
    TabSheet1.Caption := 'Basic';
    TabSheet2.Caption := 'Scripts';
    BuildLabel.Caption := 'creating an archive, wait...';
    Label1.Caption := 'Package name:';
    Label4.Caption := 'Version:';
    Label8.Caption := 'Release:';
    Label5.Caption := 'Description:';
    Label9.Caption := 'Maintainer:';
    Label13.Caption := 'Vendor:';
    Label16.Caption := 'Summary:';
    Label14.Caption := 'License:';
    Label15.Caption := 'Group:';
    Label17.Caption := 'URL of the copy source code (*.src.rpm and etc.):';
    Label10.Caption := 'URL of the author source code (32 bit):';
    Label21.Caption := 'URL of the author source code (64 bit):';
    Label3.Caption := 'Package dependencies:';
    Button1.Caption := '+ Files and folders';
    UnpackBtn.Caption := 'Unpack';
    LoadBtn.Caption := 'Load project';
    SaveBtn.Caption := 'Save project';
    BuildBtn.Caption := 'Build RPM-package';
    Label6.Caption := 'After installation (%post):';
    Label7.Caption := 'After remove (%postun):';
    Label11.Caption := 'Before installation (%pre):';
    Label12.Caption := 'Before remove (%preun):';
    Label2.Caption := 'Program name:';
    Label19.Caption := 'Development tool:';
    Label20.Caption := 'Version:';
    Label23.Caption := 'Additional information:';
    CreateRepackTXT.Caption := 'Create repack.txt';
    //Hint's EN
    LangBtn.Hint := '|Language selection';
    AboutBtn.Hint := '|About';
    RPMBtn.Hint := '|Download the list of package files by package name';
    NameEdit.Hint := '|Name of rpm-package. No spaces allowed';
    VersEdit.Hint := '|Version of rpm-package. Sample: 1.0';
    ReleaseEdit.Hint := '|Release of rpm-package. Sample: 2.mga6';
    DescEdit.Hint :=
      '|Description of the package';
    MaintainerEdit.Hint := '|Maintainer the package';
    VendorEdit.Hint := '|Vendor the package';
    SummaryEdit.Hint := '|Short description of the package';
    LicenseEdit.Hint :=
      '|Program distribution license';
    URLCopyEdit.Hint := '|URL copy of the program source code (*.src.rpm and etc.)';
    URLEdit32.Hint := '|URL to the author source code (32 bit)';
    URLEdit64.Hint := '|URL to the author source code (64 bit)';
    GroupCBox.Hint := '|Group to which the package belongs';
    DepsEdit.Hint := '|Space or comma separated package names';
    MetaCheck.Hint := '|Empty package with dependencies';
    NoArchCheck.Hint := '|Architecture noarch or native';
    SignCheckBox.Hint :=
      '|Signed package. Keys (gpg --gen-key) and ~/.rpmmacros file must be created';
    Button1.Hint := '|Add files and folders to list [for files active Ctrl + Mouse]';
    Button7.Hint := '|Select all entries in the list';
    UPBtn.Hint := '|Move record Up';
    DNBtn.Hint := '|Move record Down';
    Button3.Hint := '|Delete selected list entries';
    UnpackBtn.Hint := '|Unpack *.deb or *.rpm package';
    LoadBtn.Hint := '|Load project from file *.prj';
    SaveBtn.Hint := '|Save project to file *.prj';
    BuildBtn.Hint := '|Start the build rpm-package';
    ListBox1.Hint :=
      '|List of files and folders to build rpm-package [there is a PopUp-menu]';
    AfterInstallEdit.Hint := '|Run this script after installing the package';
    AfterRemoveEdit.Hint := '|Run this script after removing the package';
    BeforeInstallEdit.Hint :=
      '|Run this script before installing the package';
    BeforeRemoveEdit.Hint :=
      '|Run this script before removing the package';

    //PopUP Menu EN
    PopUpMenu1.Items[0].Caption := 'Add objects';
    PopUpMenu1.Items[2].Caption := 'Load project';
    PopUpMenu1.Items[3].Caption := 'Save project';
    PopUpMenu1.Items[5].Caption := 'Build RPM-package';

    //SelectedForm
    SelectForm.Caption := 'Objects selection';
    SelectForm.Button1.Caption := 'Add';
    SelectForm.Button1.Hint := '|Add selected objects to the list of RPM package files';
    SelectForm.Button2.Caption := 'Refresh';
    SelectForm.Button2.Hint := '|Reread the contents of the disc';
    SelectForm.FileListBox1.Hint := '|File selection. Multiple choice [Ctrl+mouse]';
    SelectForm.ShellTreeView1.Hint := '|Selecting the directory';
    SymLink := 'It is a symlink! An absolute path is required!';

    //UnpackForm
    UnpackForm.Caption := 'Unpacker';
    UnpackForm.Label1.Caption := 'Source package (*.deb or *.rpm):';
    UnpackForm.Label2.Caption := 'Content upload folder:';
    UnpackForm.Button1.Hint := '|To start unpacking';

    //AboutForm
    AboutForm.Caption := 'About';
    AboutForm.Label2.Caption :=
      'Build program RPM-packages' + #13#10 + #13#10 + 'License: GNU GPL' +
      #13#10 + 'Compilation: Lazarus 1.8.4' + #13#10 +
      'Author: aLEX_gRANT (C) 2018' + #13#10 + 'Gratitudes: AlexL' +
      #13#10 + 'Used rpmbuild (spec, src)' + #13#10 + #13#10 +
      'Russian Community Forum:' + #13#10 + 'https://forum.mageia.org.ru';

    //Английские диалоги и кнопки
    Translations.TranslateUnitResourceStrings('LCLStrConsts',
      ExtractFilePath(ParamStr(0)) + 'lclstrconsts.po', 'en', 'en');
  end
  else
  begin
    TabSheet1.Caption := 'Основное';
    TabSheet2.Caption := 'Сценарии';
    BuildLabel.Caption := 'создаю архив, ждите...';
    Label1.Caption := 'Имя пакета:';
    Label4.Caption := 'Версия:';
    Label8.Caption := 'Релиз:';
    Label5.Caption := 'Описание пакета:';
    Label9.Caption := 'Мейнтейнер:';
    Label13.Caption := 'Вендор:';
    Label16.Caption := 'Краткое описание пакета:';
    Label14.Caption := 'Лицензия:';
    Label15.Caption := 'Группа:';
    Label17.Caption := 'URL копии исходников (*.src.rpm и др.):';
    Label10.Caption := 'URL на исходники автора (32 bit):';
    Label21.Caption := 'URL на исходники автора (64 bit):';
    Label3.Caption := 'Зависимости пакета:';
    Button1.Caption := '+ Файлы и папки';
    UnpackBtn.Caption := 'Распаковать';
    LoadBtn.Caption := 'Загрузить проект';
    SaveBtn.Caption := 'Сохранить проект';
    BuildBtn.Caption := 'Собрать RPM-пакет';
    Label6.Caption := 'После установки (%post):';
    Label7.Caption := 'После удаления (%postun):';
    Label11.Caption := 'Перед установкой (%pre):';
    Label12.Caption := 'Перед удалением (%preun):';
    Label2.Caption := 'Название программы:';
    Label19.Caption := 'Средство разработки:';
    Label20.Caption := 'Версия:';
    Label23.Caption := 'Дополнительная информация:';
    CreateRepackTXT.Caption := 'Создать repack.txt';
    //Hint's RU
    LangBtn.Hint := '|Выбор языка';
    AboutBtn.Hint := '|О программе';
    RPMBtn.Hint :=
      '|Загрузить список файлов пакета по имени пакета';
    NameEdit.Hint :=
      '|Название rpm-пакета. Пробелы не допускаются';
    VersEdit.Hint := '|Версия rpm-пакета. Пример: 1.0';
    ReleaseEdit.Hint := '|Релиз rpm-пакета. Пример: 2.mga6';
    DescEdit.Hint :=
      '|Описание rpm-пакета';
    MaintainerEdit.Hint :=
      '|Мейнтейнер пакета';
    VendorEdit.Hint :=
      '|Вендор пакета';
    SummaryEdit.Hint :=
      '|Краткое описание пакета (Summary)';
    URLCopyEdit.Hint :=
      '|URL копии исходного кода (*.src.rpm и др.)';
    URLEdit32.Hint :=
      '|URL оригинальных исходников автора (32 bit)';
    URLEdit64.Hint :=
      '|URL оригинальных исходников автора (64 bit)';
    LicenseEdit.Hint :=
      '|Лицензия, под которой распространяется программа';
    GroupCBox.Hint := '|Группа к которой относится пакет';
    DepsEdit.Hint :=
      '|Имена пакетов через запятую или пробел';
    MetaCheck.Hint := '|Пустой пакет с зависимостями';
    NoArchCheck.Hint := '|Архитектура noarch или нативная';
    SignCheckBox.Hint :=
      '|Подписать пакет. Должны быть созданы ключи (gpg --gen-key) и файл ~/.rpmmacros';
    Button1.Hint :=
      '|Добавить файлы и папки в список [для файлов активен Ctrl + Мышь]';
    Button7.Hint := '|Выбрать все записи в списке';
    Button3.Hint := '|Удалить выбранные записи списка';
    UPBtn.Hint := '|Переместить запись вверх';
    DNBtn.Hint := '|Переместить запись вниз';
    UnpackBtn.Hint := '|Распаковать *.deb или *.rpm пакет';
    LoadBtn.Hint := '|Загрузить проект из файла *.prj';
    SaveBtn.Hint := '|Сохранить проект в файл *.prj';
    BuildBtn.Hint := '|Запустить сборку rpm-пакета';
    ListBox1.Hint :=
      '|Список файлов и папок для сборки rpm-пакета [есть PopUp-меню]';
    AfterInstallEdit.Hint :=
      '|Выполнить этот скрипт после установки пакета';
    AfterRemoveEdit.Hint :=
      '|Выполнить этот скрипт после удаления пакета';
    BeforeInstallEdit.Hint :=
      '|Выполнить этот скрипт перед установкой пакета';
    BeforeRemoveEdit.Hint :=
      '|Выполнить этот скрипт перед удалением пакета';

    //PopUP Menu RU
    PopUpMenu1.Items[0].Caption := 'Добавить объекты';
    PopUpMenu1.Items[2].Caption := 'Загрузить проект';
    PopUpMenu1.Items[3].Caption := 'Сохранить проект';
    PopUpMenu1.Items[5].Caption := 'Собрать RPM-пакет';

    //SelectedForm
    SelectForm.Caption := 'Выбор объектов';
    SelectForm.Button1.Caption := 'Добавить';
    SelectForm.Button1.Hint :=
      '|Добавить выбранные объекты в список файлов пакета RPM';
    SelectForm.Button2.Caption := 'Обновить';
    SelectForm.Button2.Hint := '|Перечитать содержимое диска';
    SelectForm.FileListBox1.Hint :=
      '|Выбор файлов. Множественный выбор [Ctrl+мышь]';
    SelectForm.ShellTreeView1.Hint := '|Выбор директории';
    SymLink := 'Это симлинк! Требуется абсолютный путь!';

    //UnpackForm
    UnpackForm.Caption := 'Распаковщик';
    UnpackForm.Label1.Caption := 'Исходный пакет (*.deb или *.rpm):';
    UnpackForm.Label2.Caption := 'Папка выгрузки содержимого:';
    UnpackForm.Button1.Hint := '|Приступить к распаковке';

    //AboutForm
    AboutForm.Caption := 'О программе';
    AboutForm.Label2.Caption :=
      'Программа сборки RPM-пакетов' + #13#10 +
      #13#10 + 'Лицензия: GNU GPL' + #13#10 +
      'Компиляция: Lazarus 1.8.4' + #13#10 +
      'Автор: aLEX_gRANT (C) 2018' + #13#10 +
      'Благодарности: AlexL' + #13#10 +
      'Используется rpmbuild (spec, src)' + #13#10 +
      #13#10 + 'Russian Community Forum:' + #13#10 + 'https://forum.mageia.org.ru';

    //Русские диалоги и кнопки
    Translations.TranslateUnitResourceStrings('LCLStrConsts',
      ExtractFilePath(ParamStr(0)) + 'lclstrconsts.ru.po', 'ru', 'ru');
  end;

  //Смотрим, открыта ли SelectForm...
  if SelectForm.Showing then
  begin
    if SelectForm.Panel1.Caption <> '' then
      SelectForm.Panel1.Caption := SymLink;
    if SelectForm.FileListBox1.SelCount <> 0 then
      SelectForm.FileListBox1.SetFocus;
  end;
end;

procedure TMainForm.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  StatusBar.Canvas.Font.Color := clRed;
  StatusBar.Canvas.Brush.Color := StatusBar1.Color;
  StatusBar.Canvas.TextOut(Rect.Left, Rect.Top, Application.Hint);
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  SelectForm.Show;
end;

procedure TMainForm.AboutBtnClick(Sender: TObject);
begin
  AboutForm.Show;
end;

procedure TMainForm.Button3Click(Sender: TObject);
var
  i: integer;
  msg: string;
begin
  if LangBtn.Caption = 'EN' then
    msg := 'Удалить выбранные записи списка?'
  else
    msg := 'Delete selected list items?';

  if ListBox1.SelCount <> 0 then
    if MessageDlg(msg, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      for i := -1 + ListBox1.Items.Count downto 0 do
        if ListBox1.Selected[i] then
          ListBox1.Items.Delete(i);
      SaveFlag := True;
    end;
end;

procedure TMainForm.CreateRepackTxtClick(Sender: TObject);
var
  RepackTXT: TStringList;
  i: integer;
begin
  //Убираем крайние пробелы
  TrimEdits;

  //Проверка на отсутствие данных
  if (ProgramNameEdit.Text = '') or (VersEdit.Text = '') or
    (DevToolEdit.Text = '') or (ToolVersionEdit.Text = '') or (URLEdit32.Text = '') then
  begin
    if LangBtn.Caption = 'EN' then
      MessageDlg('Не хватает данных для repack.txt!',
        mtWarning, [mbOK], 0)
    else
      MessageDlg('Not enough data for repack.txt!', mtWarning, [mbOK], 0);
    Abort;
  end;

  try
    //Создаём лист
    RepackTXT := TStringList.Create;
    //Наполняем
    with RepackTXT do
    begin
      //Информация о программе
      Add('This repack.txt file was created automatically by ' + Application.Title);
      Add('It contains the necessary information to recreation the program from the source code');
      Add('');
      Add('Information about the program:');
      Add('---');
      Add('Name of program: ' + ProgramNameEdit.Text);
      Add('Version of program: ' + VersEdit.Text);
      Add('Program development tool: ' + DevToolEdit.Text);
      Add('Version of program development tool: ' + ToolVersionEdit.Text);
      Add('URL the sources of the author (32 bit): ' + URLEdit32.Text);
      if URLEdit64.Text = '' then
        Add('URL the sources of the author (64 bit): unknown')
      else
        Add('URL the sources of the author (64 bit): ' + URLEdit64.Text);
      Add('');

      //Информация о rpm-пакете
      Add('Information about the rpm-package:');
      Add('---');
      Add('Build method: Portable RPM');
      Add('Time stamp: ' + DateTimeToStr(NOW));
      Add('');
      Add('Name: ' + NameEdit.Text);
      Add('Version: ' + VersEdit.Text);
      Add('Release: ' + ReleaseEdit.Text);
      Add('Group: ' + GroupCBox.Text);
      Add('License: ' + LicenseEdit.Text);
      Add('Maintainer: ' + MainTainerEdit.Text);
      Add('Vendor: ' + VendorEdit.Text);
      Add('URL of the copy source codes: ' + URLCopyEdit.Text);
      Add('');
      Add('Summary: ' + SummaryEdit.Text);
      Add('');
      //Описание пакета
      if DescEdit.Text <> '' then
      begin
        Add('Description:');
        Add('---');
        for i := 0 to DescEdit.Lines.Count - 1 do
          Add(DescEdit.Lines[i]);
        Add('');
      end;

      //Зависимости пакета
      if DepsEdit.Text <> '' then
      begin
        Add('Package dependencies:');
        Add('---');
        for i := 0 to DepsEdit.Lines.Count - 1 do
          Add(DepsEdit.Lines[i]);
        Add('');
      end;

      //Дополнительная информация
      if InfoMemo.Text <> '' then
      begin
        Add('Additionally information:');
        Add('---');
        for i := 0 to InfoMemo.Lines.Count - 1 do
          Add(InfoMemo.Lines[i]);
        Add('');
      end;

      //Сохраняем repack.txt
      SaveFile.Filter := 'Text files (*.txt)|*.txt';
      SaveFile.FileName := 'repack.txt';
      if SaveFile.Execute then
        RepackTXT.SaveToFile(SaveFile.FileName);
    end;

  finally;
    RepackTXT.Free;
  end;
end;

procedure TMainForm.DevToolEditChange(Sender: TObject);
begin
  SaveFlag := True;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //Очищаем рабочую папку
  if LangBtn.Caption = 'EN' then
    MainForm.Caption := 'Очищаю рабочий каталог...'
  else
    MainForm.Caption := 'Clearing the working directory...';

  StartProcess('find ' + WorkDir + '/* -type f ! -name "*.xml" -delete', 'sh');
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  msg: string;
  ButtonSel: integer;
begin
  if LangBtn.Caption = 'EN' then
    msg := 'Проект изменялся. Сохранить?'
  else
    msg := 'Project changed. Save it?';

  if SaveFlag = True then
  begin
    ButtonSel := MessageDlg(msg, mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    case ButtonSel of
      mrYes:
      begin
        SaveBtn.Click;
        CanClose := True;
      end;
      mrNo: CanClose := True;
      mrCancel: CanClose := False;
    end;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  LangSelect;
  MainForm.Caption := Application.Title;
  PageControl1.ActivePageIndex := 0;
end;

procedure TMainForm.LangBtnClick(Sender: TObject);
begin
  if LangBtn.Caption = 'RU' then
    LangBtn.Caption := 'EN'
  else
    LangBtn.Caption := 'RU';
  LangSelect;
end;

procedure TMainForm.LoadBtnClick(Sender: TObject);
var
  PRJ: TIniFile;
  i: integer;
  S: string;
begin
  //Проект изменялся?
  if SaveFlag then
  begin
    if LangBtn.Caption = 'EN' then
      S := 'Проект изменялся. Сохранить?'
    else
      S := 'The project changed. Save it?';
    if MessageDlg(S, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      SaveBtn.Click;
  end;

  OpenFile.Filter := 'RPMCreator Files (*.prj, *.lst)|*.prj;*.lst|Any files (*)|*';
  OpenFile.FilterIndex := 1;

  if OpenFile.Execute then
  begin
    if OpenFile.FilterIndex = 1 then
    begin
      PRJ := TIniFile.Create(OpenFile.FileName);

      // PathEdit.Text := PRJ.ReadString('PATH', 'path', '');
      NameEdit.Text := PRJ.ReadString('NAME', 'name', '');
      VersEdit.Text := PRJ.ReadString('VERSION', 'version', '');
      ReleaseEdit.Text := PRJ.ReadString('RELEASE', 'release', '');
      GroupCBox.Text := PRJ.ReadString('GROUP', 'group', '');

      //Обрабатываем содержимое DESCRIPTION
      PRJ.ReadSectionValues('DESCRIPTION', DescEdit.Lines);
      //Удаляем имена ключей= из Items[i]
      for i := 0 to DescEdit.Lines.Count - 1 do
      begin
        S := DescEdit.Lines[i];
        Delete(S, 1, Pos('=', S));
        DescEdit.Lines[i] := S;
      end;

      MaintainerEdit.Text := PRJ.ReadString('MAINTAINER', 'maintainer', '');
      VendorEdit.Text := PRJ.ReadString('VENDOR', 'vendor', '');
      SummaryEdit.Text := PRJ.ReadString('SUMMARY', 'summary', '');
      URLCopyEdit.Text := PRJ.ReadString('URLCOPY', 'urlcopy', '');
      LicenseEdit.Text := PRJ.ReadString('LICENSE', 'license', '');
      DepsEdit.Text := PRJ.ReadString('DEPS', 'deps', '');
      MetaCheck.Checked := PRJ.ReadBool('META', 'meta', False);
      NoArchCheck.Checked := PRJ.ReadBool('NOARCH', 'noarch', False);
      SignCheckBox.Checked := PRJ.ReadBool('SIGN', 'sign', False);

      //Обрабатываем содержимое списка файлов
      PRJ.ReadSectionValues('FILES', Listbox1.Items);
      //Удаляем имена ключей= из Items[i]
      for i := 0 to ListBox1.Items.Count - 1 do
      begin
        S := ListBox1.Items[i];
        Delete(S, 1, Pos('=', S));
        ListBox1.Items[i] := S;
      end;

      //Обрабатываем содержимое AfterInstallEdit
      PRJ.ReadSectionValues('AFTERINSTALL', AfterInstallEdit.Lines);
      //Удаляем имена ключей= из Lines[i]
      for i := 0 to AfterInstallEdit.Lines.Count - 1 do
      begin
        S := AfterInstallEdit.Lines[i];
        Delete(S, 1, Pos('=', S));
        AfterInstallEdit.Lines[i] := S;
      end;

      //Обрабатываем содержимое AfterRemoveEdit
      PRJ.ReadSectionValues('AFTERREMOVE', AfterRemoveEdit.Lines);
      //Удаляем имена ключей= из Lines[i]
      for i := 0 to AfterRemoveEdit.Lines.Count - 1 do
      begin
        S := AfterRemoveEdit.Lines[i];
        Delete(S, 1, Pos('=', S));
        AfterRemoveEdit.Lines[i] := S;
      end;

      //Обрабатываем содержимое BeforeInstallEdit
      PRJ.ReadSectionValues('BEFOREINSTALL', BeforeInstallEdit.Lines);
      //Удаляем имена ключей= из Lines[i]
      for i := 0 to BeforeInstallEdit.Lines.Count - 1 do
      begin
        S := BeforeInstallEdit.Lines[i];
        Delete(S, 1, Pos('=', S));
        BeforeInstallEdit.Lines[i] := S;
      end;

      //Обрабатываем содержимое BeforeRemoveEdit
      PRJ.ReadSectionValues('BEFOREREMOVE', BeforeRemoveEdit.Lines);
      //Удаляем имена ключей= из Lines[i]
      for i := 0 to BeforeRemoveEdit.Lines.Count - 1 do
      begin
        S := BeforeRemoveEdit.Lines[i];
        Delete(S, 1, Pos('=', S));
        BeforeRemoveEdit.Lines[i] := S;
      end;

      //Вкладка repack.txt
      URLEdit32.Text := PRJ.ReadString('URL32', 'url32', '');
      URLEdit64.Text := PRJ.ReadString('URL64', 'url64', '');
      ProgramNameEdit.Text := PRJ.ReadString('PROGRAMNAME', 'programname', '');
      DevToolEdit.Text := PRJ.ReadString('DEVTOOL', 'devtool', '');
      ToolVersionEdit.Text := PRJ.ReadString('TOOLVERSION', 'toolversion', '');

      //Обрабатываем содержимое InfoMemo
      PRJ.ReadSectionValues('INFO', InfoMemo.Lines);
      //Удаляем имена ключей= из Items[i]
      for i := 0 to InfoMemo.Lines.Count - 1 do
      begin
        S := InfoMemo.Lines[i];
        Delete(S, 1, Pos('=', S));
        InfoMemo.Lines[i] := S;
      end;

      PRJ.Free;
    end
    else
      ListBox1.Items.LoadFromFile(OpenFile.FileName);

    MainForm.Caption := Application.Title + ' <' +
      ExtractFileName(OpenFile.FileName) + '>';

    PageControl1.ActivePageIndex := 0;

    //Передача фокуса на ListBox1, если не пуст
    if ListBox1.Items.Count > 0 then
    begin
      ListBox1.SetFocus;
      ListBox1.ItemIndex := 0;
    end
    else
      NameEdit.SetFocus;

    SaveFlag := False;
  end;
end;


procedure TMainForm.BuildBtnClick(Sender: TObject);
var
  SPEC, FILES: TStringList;
  i: integer;
begin
  //Обрезаем крайние пробелы
  TrimEdits;

  if (NameEdit.Text = '') or (VersEdit.Text = '') or (ReleaseEdit.Text = '') or
    (SummaryEdit.Text = '') or (GroupCBox.Text = '') or (DescEdit.Text = '') or
    (URLCopyEdit.Text = '') then
  begin
    if LangBtn.Caption = 'EN' then
      MessageDlg(
        'Мало данных о пакете!',
        mtWarning, [mbOK], 0)
    else
      MessageDlg('Not enough data about the package!',
        mtWarning, [mbOK], 0);
    Exit;
  end;

  //Проверка объектов списка есть/нет
  if (ListBox1.Items.Count = 0) and (MetaCheck.Checked = False) then
  begin
    if LangBtn.Caption = 'EN' then
      MessageDlg('Список файлов пуст!', mtWarning, [mbOK], 0)
    else
      MessageDlg('The list of files is empty!', mtWarning, [mbOK], 0);
    exit;
  end;

  //Проверка объектов списка на существование
  for i := 0 to ListBox1.Items.Count - 1 do
  begin
    if (not FileExists(ListBox1.Items[i])) and
      (not DirectoryExists(ListBox1.Items[i])) then
    begin
      if LangBtn.Caption = 'EN' then
        MessageDlg('Объект списка отсутствует: ' +
          #13#10 + ListBox1.Items[i], mtError, [mbOK], 0)
      else
        MessageDlg('No list object:' + #13#10 + ListBox1.Items[i],
          mtError, [mbOK], 0);
      exit;
    end;
  end;

  //Прооверка готовности к подписи пакетов
  if (SignCheckBox.Checked) and
    (not FileExists(GetEnvironmentVariable('HOME') + '/.rpmmacros')) then
  begin
    if LangBtn.Caption = 'EN' then
      MessageDlg('Не найден файл ~/.rpmmacros! К подписи не готов!', mtWarning, [mbOK], 0)
    else
      MessageDlg('No file found ~/.rpmmacros! Not ready to sign packages!',
        mtWarning, [mbOK], 0);
    Exit;
  end;

  try
    BuildBtn.Enabled := False;

    //Показываем метку ожидания
    BuildLabel.Visible := True;

    //Создаём рабочие директории
    StartProcess('mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}', 'sh');

    //Очистка каталогов на случай прерывания порцесса (закрытие окна терминала sakura)
    StartProcess('if [ -d ~/rpmbuild/BUILD/PACKAGE ]; then rm -rf ~/rpmbuild/BUILD/PACKAGE/*; fi', 'sh');
    StartProcess('if [ -d ~/rpmbuild/BUILDROOT ]; then rm -rf ~/rpmbuild/BUILDROOT/*; fi',
      'sh');

    //АРХИВ ИСХОДНИКОВ ДОЛЖЕН БЫТЬ ВСЕГДА!
    //Собираем /home/$USER/rpmbuild/SOURCES/имя_пакета-версия.tar.gz
    ListBox1.Items.SaveToFile(GetEnvironmentVariable('HOME') +
      '/rpmbuild/SOURCES/files.lst');

    //Устанавливаем текущую директорию для tar
    SetCurrentDir(GetEnvironmentVariable('HOME') + '/rpmbuild/SOURCES');

    //Тарим/сжимаем исходники в имя_пакета-версия.tar.gz
    //Удаляем предыдущий архив исходников, чтобы не выполнять append
    if FileExists(NameEdit.Text + '-' + VersEdit.Text + '.tar.gz') then
      DeleteFile(NameEdit.Text + '-' + VersEdit.Text + '.tar.gz');

    //Жмём архив
    StartProcess('nice -n 15 tar -czf ' + NameEdit.Text + '-' +
      VersEdit.Text + '.tar.gz --exclude="*.bak" -T ./files.lst', 'sh');

    //Формируем необработанный список файлов архива исходников
    StartProcess('nice -n 15 tar -tzf ' + NameEdit.Text + '-' +
      VersEdit.Text + '.tar.gz > ./files.lst', 'sh');

    //Скрываем метку ожидания
    BuildLabel.Visible := False;

    //Начитываем и форматируем список файлов из архива исходников
    FILES := TStringList.Create;
    //Ставим начальный слэш и %dir построчно
    FILES.LoadFromFile('./files.lst');
    for i := 0 to FILES.Count - 1 do
      if RightStr(FILES[i], 1) = '/' then
        FILES[i] := '%dir "/' + FILES[i] + '"'
      else
        FILES[i] := '"/' + FILES[i] + '"';

    //Подчищаем временный файл
    DeleteFile('./files.lst');

    //Создаём SPEC-файл
    SPEC := TStringList.Create;

    //Обязательная шапка
    SPEC.Add('#Created automatically by ' + Application.Title);
    SPEC.Add('');
    SPEC.Add('#Allow building noarch packages that contain binaries');
    SPEC.Add('%define _binaries_in_noarch_packages_terminate_build 0');
    SPEC.Add('');
    SPEC.Add('#Disable RPM-s automatic dependency');
    SPEC.Add('AutoReq: no');
    SPEC.Add('AutoProv: no');
    SPEC.Add('AutoReqProv: no');
    SPEC.Add('');
    SPEC.Add('#Disable check shebang (#!/bin/bash <> #!/usr/bin/bash)');
    SPEC.Add('%define __brp_mangle_shebangs %{nil}');
    SPEC.Add('');
    SPEC.Add('#Disable Python dependency');
    SPEC.Add('AutoReqProv: nopython');
    SPEC.Add('%define __python %{nil}');
    SPEC.Add('#Turn off the brp-python-bytecompile script');
    SPEC.Add('%define __brp_python_bytecompile %{nil}');

    SPEC.Add('');
    SPEC.Add('#Disable Java dependency');
    SPEC.Add('%define __jar_repack %{nil}');
    SPEC.Add('');
    SPEC.Add('#Disable build-id');
    SPEC.Add('%global _missing_build_ids_terminate_build 0');
    SPEC.Add('#Disable other dependency');
    SPEC.Add('%global debug_package %{nil}');
    SPEC.Add('');
    SPEC.Add('Name: ' + NameEdit.Text);
    SPEC.Add('Version: ' + VersEdit.Text);
    SPEC.Add('Release: ' + ReleaseEdit.Text);

    if GroupCBox.Text <> '' then
      SPEC.Add('Group: ' + GroupCBox.Text);

    if MainTainerEdit.Text <> '' then
      SPEC.Add('Packager: ' + MaintainerEdit.Text);

    if VendorEdit.Text <> '' then
      SPEC.Add('Vendor: ' + VendorEdit.Text);

    if LicenseEdit.Text <> '' then
      SPEC.Add('License: ' + LicenseEdit.Text)
    else
      SPEC.Add('License: GPLv3+');

    if URLCopyEdit.Text <> '' then
      SPEC.Add('URL: ' + URLCopyEdit.Text);
    SPEC.Add('');

    SPEC.Add('Source: %{name}-%{version}.tar.gz');
    SPEC.Add('');

    if NoArchCheck.Checked then
      SPEC.Add('BuildArch: noarch');

    //Зависимости для сборки
    if DepsEdit.Text <> '' then
    begin
      SPEC.Add('Recommends: ' + DepsEdit.Text);
      SPEC.Add('BuildRequires: ' + DepsEdit.Text);
      SPEC.Add('');
    end;

    SPEC.Add('Summary: ' + SummaryEdit.Text);
    SPEC.Add('');

    //Описание пакета
    SPEC.Add('%description');
    for i := 0 to DescEdit.Lines.Count - 1 do
      SPEC.Add(DescEdit.Lines[i]);
    SPEC.Add('');

    //Секция распаковки имя_архива.tar.gz в ./BUILD/PACKAGE (%prep)
    SPEC.Add('%prep');
    SPEC.Add('%setup -c PACKAGE -n PACKAGE');
    SPEC.Add('');

    //Если не Мета-пакет, скопировать файлы из ./BUILD/PACKAGE в ./BUILDROOT (секция %install)
    if MetaCheck.Checked = False then
    begin
      SPEC.Add('%install');
      SPEC.Add('cp -rf * %{buildroot}');
      SPEC.Add('');
    end;

    //Секция очистки ./BUILDROOT обязательно, если создаётся meta-пакет
    SPEC.Add('%clean');
    SPEC.Add('rm -rf * %{buildroot}');
    SPEC.Add('');

    //Предустановочные/постустановочные скрипты
    //Секция %pre
    if BeforeInstallEdit.Text <> '' then
    begin
      SPEC.Add('%pre');
      for i := 0 to BeforeInstallEdit.Lines.Count - 1 do
        SPEC.Add(BeforeInstallEdit.Lines[i]);
      SPEC.Add('');
    end;

    //Секция %post
    if AfterInstallEdit.Text <> '' then
    begin
      SPEC.Add('%post');
      for i := 0 to AfterInstallEdit.Lines.Count - 1 do
        SPEC.Add(AfterInstallEdit.Lines[i]);
      SPEC.Add('');
    end;

    //Секция %preun
    if BeforeRemoveEdit.Text <> '' then
    begin
      SPEC.Add('%preun');
      for i := 0 to BeforeRemoveEdit.Lines.Count - 1 do
        SPEC.Add(BeforeRemoveEdit.Lines[i]);
      SPEC.Add('');
    end;

    //Секция %postun
    if AfterRemoveEdit.Text <> '' then
    begin
      SPEC.Add('%postun');
      for i := 0 to AfterRemoveEdit.Lines.Count - 1 do
        SPEC.Add(AfterRemoveEdit.Lines[i]);
      SPEC.Add('');
    end;

    //Заполняем секцию %files, если не meta-пакет
    if MetaCheck.Checked = False then
    begin
      SPEC.Add('%files');
      //Атрибуты файлов не менять, владелец = root, папки = 755
      SPEC.Add('%defattr(-, root, root, 755)');
      for i := 0 to FILES.Count - 1 do
        SPEC.Add(FILES[i]);
    end
    else
      SPEC.Add('%files');

    //Сохраняем файл имя_пакета.spec
    SPEC.SaveToFile(GetEnvironmentVariable('HOME') + '/rpmbuild/SPECS/' +
      NameEdit.Text + '.spec');

    //Создаём пускач сборки пакета
    SPEC.Clear;
    SPEC.Add('rpmbuild -ba ~/rpmbuild/SPECS/' + NameEdit.Text + '.spec');

    //Подпись пакетов в ~/rpmbuild/SRPMS RPMS/*/name_package*.rpm
    if SignCheckBox.Checked then
    begin
      SPEC.Add('echo');
      if LangBtn.Caption = 'EN' then
        SPEC.Add('echo "Подписываю пакеты:"')
      else
        SPEC.Add('echo "Sign the packages:"');
      SPEC.Add('echo "---"');
      SPEC.Add('rpm --addsign ~/rpmbuild/SRPMS/' + NameEdit.Text + '*.rpm');
      SPEC.Add('rpm --checksig ~/rpmbuild/SRPMS/' + NameEdit.Text + '*.rpm');

      SPEC.Add('rpm --addsign ~/rpmbuild/RPMS/*/' + NameEdit.Text + '*.rpm');
      SPEC.Add('rpm --checksig ~/rpmbuild/RPMS/*/' + NameEdit.Text + '*.rpm');
    end;

    SPEC.Add('echo');
    SPEC.Add('echo "---"');
    if LangBtn.Caption = 'EN' then
      SPEC.Add(
        'read -p "Завершено. Для продолжения нажмите Enter..."')
    else
      SPEC.Add('read -p "Completed. Press Enter to continue..."');
    SPEC.SaveToFile(WorkDir + '/build.sh');

    //Делаем исполняемым
    StartProcess('chmod +x ' + WorkDir + '/build.sh', 'sh');

    //Собираем пакет rpm + src.rpm
    StartProcess(WorkDir + '/build.sh', 'sakura');

  finally;

    //Освобождаем память списков
    SPEC.Free;
    FILES.Free;

    BuildBtn.Enabled := True;
  end;
end;

procedure TMainForm.Button7Click(Sender: TObject);
begin
  ListBox1.SelectAll;
end;

procedure TMainForm.MetaCheckClick(Sender: TObject);
begin
  if MetaCheck.Checked then
    TabSheet3.TabVisible := False
  else
    TabSheet3.TabVisible := True;
end;

procedure TMainForm.NameEditChange(Sender: TObject);
begin
  SaveFlag := True;
end;

procedure TMainForm.NameEditKeyPress(Sender: TObject; var Key: char);
begin
  if Key = char(VK_SPACE) then
    Key := #0;
end;

procedure TMainForm.RPMBtnClick(Sender: TObject);
var
  RPMName, Str: string;
  i: integer;
begin
  //Грузим список файлов, из которых состоит пакет.rpm
  RPMName := '';

  if LangBtn.Caption = 'EN' then
    Str := 'Пожалуйста, введите имя пакета:'
  else
    Str := 'Please, enter the name of the package:';

  if not InputQuery('RPMCreator', Str, RPMName) or (Trim(RPMName) = '') then
    Exit;

  StartProcess('/usr/bin/rpm -ql ' + RPMName + ' > ' + WorkDir + '/rpm-ql.lst', 'sh');
  ListBox1.Items.LoadFromFile(WorkDir + '/rpm-ql.lst');

  //Исключаем каталоги (кроме пустых), иначе будут повторы
  for i := ListBox1.Items.Count - 1 downto 0 do
    if (DirectoryExists(ListBox1.Items[i])) and (ListBox1.Items[i] <> '/') then
      if not DirectoryIsEmpty(ListBox1.Items[i]) then
        ListBox1.Items.Delete(i);

  //Курсор в начало списка
  if ListBox1.Count > -1 then
    ListBox1.ItemIndex := 0;

  SaveFlag := True;
end;

procedure TMainForm.SaveBtnClick(Sender: TObject);
var
  i: integer;
  PRJ: TIniFile;
begin
  //Обрезаем лишние пробелы в эдитах
  TrimEdits;

  SaveFile.Filter := 'RPMCreator Files (*.prj)|*.prj';
  // SaveFile.FileName := NameEdit.Text + '.prj';

  if SaveFile.Execute then
  begin
    if FileExists(SaveFile.FileName) then
      DeleteFile(SaveFile.FileName);

    PRJ := TIniFile.Create(SaveFile.FileName);

    //Вкладка Основное
    PRJ.WriteString('NAME', 'name', NameEdit.Text);
    PRJ.WriteString('VERSION', 'version', VersEdit.Text);
    PRJ.WriteString('RELEASE', 'release', ReleaseEdit.Text);
    PRJ.WriteString('GROUP', 'group', GroupCBox.Text);

    for i := 0 to DescEdit.Lines.Count - 1 do
      PRJ.WriteString('DESCRIPTION', IntToStr(i), DescEdit.Lines[i]);

    PRJ.WriteString('MAINTAINER', 'maintainer', MaintainerEdit.Text);
    PRJ.WriteString('VENDOR', 'vendor', VendorEdit.Text);
    PRJ.WriteString('SUMMARY', 'summary', SummaryEdit.Text);
    PRJ.WriteString('URLCOPY', 'urlcopy', URLCopyEdit.Text);
    PRJ.WriteString('LICENSE', 'license', LicenseEdit.Text);
    PRJ.WriteString('DEPS', 'deps', DepsEdit.Text);
    PRJ.WriteBool('META', 'meta', MetaCheck.Checked);
    PRJ.WriteBool('NOARCH', 'noarch', NoArchCheck.Checked);
    PRJ.WriteBool('SIGN', 'sign', SignCheckBox.Checked);

    for i := 0 to ListBox1.Items.Count - 1 do
      PRJ.WriteString('FILES', IntToStr(i), ListBox1.Items[i]);

    //Вкладка Сценарии
    for i := 0 to AfterInstallEdit.Lines.Count - 1 do
      PRJ.WriteString('AFTERINSTALL', IntToStr(i), AfterInstallEdit.Lines[i]);

    for i := 0 to AfterRemoveEdit.Lines.Count - 1 do
      PRJ.WriteString('AFTERREMOVE', IntToStr(i), AfterRemoveEdit.Lines[i]);

    for i := 0 to BeforeInstallEdit.Lines.Count - 1 do
      PRJ.WriteString('BEFOREINSTALL', IntToStr(i), BeforeInstallEdit.Lines[i]);

    for i := 0 to BeforeRemoveEdit.Lines.Count - 1 do
      PRJ.WriteString('BEFOREREMOVE', IntToStr(i), BeforeRemoveEdit.Lines[i]);

    //Вкладка repack.txt
    PRJ.WriteString('URL32', 'url32', URLEdit32.Text);
    PRJ.WriteString('URL64', 'url64', URLEdit64.Text);
    PRJ.WriteString('PROGRAMNAME', 'programname', ProgramNameEdit.Text);
    PRJ.WriteString('DEVTOOL', 'devtool', DevToolEdit.Text);
    PRJ.WriteString('TOOLVERSION', 'toolversion', ToolVersionEdit.Text);

    for i := 0 to InfoMemo.Lines.Count - 1 do
      PRJ.WriteString('INFO', IntToStr(i), InfoMemo.Lines[i]);

    MainForm.Caption := Application.Title + ' <' +
      ExtractFileName(SaveFile.FileName) + '>';

    PRJ.Free;
    SaveFlag := False;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  //Флаг сохранения списка
  SaveFlag := False;

  //Рабочая директория в профиле
  WorkDir := GetEnvironmentVariable('HOME') + '/.RPMCreator';

  if not DirectoryExists(WorkDir) then
    MkDir(WorkDir);

  MainFormStorage.FileName := WorkDir + '/settings.xml';

  //Ищем Рабочий стол
  SearchDeskTop;
end;

end.
