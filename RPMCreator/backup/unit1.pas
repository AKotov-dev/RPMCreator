unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  XMLPropStorage, ExtCtrls, ComCtrls, Menus, Process, IniFiles, LCLType,
  Buttons, StrUtils, LCLTranslator, DefaultTranslator;

type

  { TMainForm }

  TMainForm = class(TForm)
    AboutBtn: TButton;
    AfterInstallEdit: TMemo;
    AfterRemoveEdit: TMemo;
    BeforeInstallEdit: TMemo;
    BeforeRemoveEdit: TMemo;
    Bevel1: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Button1: TButton;
    DEBCheckBox: TCheckBox;
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
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure TrimEdits;
    procedure UnpackBtnClick(Sender: TObject);
    procedure UPBtnClick(Sender: TObject);

  private

  public

  end;

resourcestring
  SDeleteRecords = 'Delete selected items?';
  SNoData = 'Not enough data for build package!';
  SClearWorkDir = 'Clearing the working directory...';
  SProjectChange = 'Project changed. Save it?';
  SFileListEmpty = 'The list of files is empty!';
  SNoListObject = 'No list object:';
  SMacrosNotFound = 'No file found ~/.rpmmacros! Not ready to sign packages!';
  SSignRPM = 'Sign the packages:';
  SCompleted = 'Completed. Press Enter to continue...';
  SInputName = 'Please, enter the name of the package:';
  SSymLink = 'This is SymLink! Need a real target!';

var
  MainForm: TMainForm;
  WorkDir: string;
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
begin
  if ListBox1.SelCount <> 0 then
    if MessageDlg(SDeleteRecords, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
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
    MessageDlg(SNoData, mtWarning, [mbOK], 0);
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
  MainForm.Caption := SClearWorkDir;
  StartProcess('find ' + WorkDir + '/* -type f ! -name "*.xml" -delete', 'sh');
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  ButtonSel: integer;
begin
  if SaveFlag = True then
  begin
    ButtonSel := MessageDlg(SProjectChange, mtConfirmation, [mbYes, mbNo, mbCancel], 0);
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
  MainForm.Caption := Application.Title;
  PageControl1.ActivePageIndex := 0;
end;

procedure TMainForm.LoadBtnClick(Sender: TObject);
var
  PRJ: TIniFile;
  i: integer;
  S: string;
begin
  //Проект изменялся?
  if SaveFlag then
    if MessageDlg(SProjectChange, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      SaveBtn.Click;

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
      DEBCheckBox.Checked := PRJ.ReadBool('DEB', 'deb', False);

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
  size: ansistring;
begin
  //Обрезаем крайние пробелы
  TrimEdits;

  if (NameEdit.Text = '') or (VersEdit.Text = '') or (ReleaseEdit.Text = '') or
    (SummaryEdit.Text = '') or (GroupCBox.Text = '') or (DescEdit.Text = '') or
    (URLCopyEdit.Text = '') then
  begin
    MessageDlg(SNoData, mtWarning, [mbOK], 0);
    Exit;
  end;

  //Проверка объектов списка есть/нет
  if (ListBox1.Items.Count = 0) and (MetaCheck.Checked = False) then
  begin
    MessageDlg(SFileListEmpty, mtWarning, [mbOK], 0);
    Exit;
  end;

  //Проверка объектов списка на существование
  for i := 0 to ListBox1.Items.Count - 1 do
  begin
    if (not FileExists(ListBox1.Items[i])) and
      (not DirectoryExists(ListBox1.Items[i])) then
    begin
      MessageDlg(SNoListObject + #13#10 + ListBox1.Items[i],
        mtError, [mbOK], 0);
      exit;
    end;
  end;

  //Прооверка готовности к подписи пакетов
  if (SignCheckBox.Checked) and
    (not FileExists(GetEnvironmentVariable('HOME') + '/.rpmmacros')) then
  begin
    MessageDlg(SMacrosNotFound, mtWarning, [mbOK], 0);
    Exit;
  end;

  try
    BuildBtn.Enabled := False;

    //Показываем метку ожидания
    BuildLabel.Visible := True;

    //Создаём рабочие директории для сборки RPM
    StartProcess('mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}', 'sh');
    //Создаём рабочие директории для сборки DEB
    StartProcess('mkdir -p ~/debbuild/tmp/DEBIAN', 'sh');

    //Очистка каталогов RPM на случай прерывания процесса (закрытие окна терминала sakura)
    StartProcess('[ -d ~/rpmbuild/BUILD/PACKAGE ] && rm -rf ~/rpmbuild/BUILD/PACKAGE/*',
      'sh');
    StartProcess('[ -d ~/rpmbuild/BUILDROOT ] && rm -rf ~/rpmbuild/BUILDROOT/*', 'sh');
    //Очистка каталогов DEB на случай прерывания процесса (закрытие окна терминала sakura)
    StartProcess('[ -d ~/debbuild/tmp ] && rm -rf ~/debbuild/tmp/*[^DEBIAN]', 'sh');

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

    //Для списка
    SPEC := TStringList.Create;

    //------------Сборка DEB------------

    if DEBCheckBox.Checked then
    begin
      //Распаковываем архив для deb-пакета
      StartProcess('nice -n 15 tar -xvzf ' + NameEdit.Text + '-' +
        VersEdit.Text + '.tar.gz' + ' -C ~/debbuild/tmp', 'sh');

      SPEC.Add('Package: ' + NameEdit.Text);
      SPEC.Add('Version: ' + VersEdit.Text + '-' + ReleaseEdit.Text);

      //Выставляем архитектуру пакета DEB
      if NoArchCheck.Checked then
        SPEC.Add('Architecture: all')
      else
      if string(
{$I %FPCTARGETCPU%}
        ) = 'x86_64' then
        SPEC.Add('Architecture: amd64')
      else
        SPEC.Add('Architecture: i386');

      SPEC.Add('Maintainer: ' + MaintainerEdit.Text);

      //Если в зависимостях нет запятых, заменяем пробелы запятыми
      if pos(',', DepsEdit.Text) = 0 then
        SPEC.Add('Depends: ' + Trim(StringReplace(DepsEdit.Text, ' ',
          ',', [rfReplaceAll])))
      else
        SPEC.Add('Depends: ' + Trim(DepsEdit.Text));

      SPEC.Add('Priority: extra');
      SPEC.Add('Section: misc');

      //Ставим размер в KiB (килобайты)
      if RunCommand('/bin/bash', ['-c', 'du -sk ~/debbuild/tmp | awk ' +
        '''' + '{ print $1 }' + ''''], size) then
        SPEC.Add('Installed-Size: ' + Trim(size));

      SPEC.Add('Description: ' + SummaryEdit.Text);

      SPEC.SaveToFile(GetEnvironmentVariable('HOME') + '/debbuild/tmp/DEBIAN/control');

      //Собираем DEB-пакет в ~/debbuild
      StartProcess('dpkg-deb -b ~/debbuild/tmp ~/debbuild', 'sh');
    end;

    //Скрываем метку ожидания
    BuildLabel.Visible := False;

    //------------Сборка RPM------------
    //Создаём SPEC-файл

    SPEC.Clear;
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
      SPEC.Add('Requires: ' + DepsEdit.Text);
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
      SPEC.Add('echo "' + SSignRPM + '"');
      SPEC.Add('echo "---"');
      SPEC.Add('rpm --addsign ~/rpmbuild/SRPMS/' + NameEdit.Text + '*.rpm');
      SPEC.Add('rpm --checksig ~/rpmbuild/SRPMS/' + NameEdit.Text + '*.rpm');

      SPEC.Add('rpm --addsign ~/rpmbuild/RPMS/*/' + NameEdit.Text + '*.rpm');
      SPEC.Add('rpm --checksig ~/rpmbuild/RPMS/*/' + NameEdit.Text + '*.rpm');
    end;

    SPEC.Add('echo');
    SPEC.Add('echo "---"');
    SPEC.Add('read -p "' + SCompleted + '"');
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
  RPMName: string;
  i: integer;
begin
  //Грузим список файлов, из которых состоит пакет.rpm
  RPMName := '';

  if not InputQuery('RPMCreator', SInputName, RPMName) or (Trim(RPMName) = '') then
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
    PRJ.WriteBool('DEB', 'deb', DEBCheckBox.Checked);

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
