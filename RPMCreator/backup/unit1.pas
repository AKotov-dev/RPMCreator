unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  XMLPropStorage, ExtCtrls, ComCtrls, Menus, Process, IniFiles, LCLType,
  Buttons, StrUtils, DefaultTranslator, Types;

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
    Button1: TButton;
    DEBCheckBox: TCheckBox;
    EditItem: TMenuItem;
    ImageList2: TImageList;
    UPBtn: TButton;
    DNBtn: TButton;
    UnpackBtn: TButton;
    Button3: TButton;
    BuildLabel: TLabel;
    ToolVersionEdit: TComboBox;
    DevToolEdit: TComboBox;
    CreateRepackTxt: TButton;
    Label10: TLabel;
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
    AddItem: TMenuItem;
    BuildItem: TMenuItem;
    MenuItem6: TMenuItem;
    LoadItem: TMenuItem;
    SaveItem: TMenuItem;
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
    VendorEdit: TEdit;
    SummaryEdit: TEdit;
    VersEdit: TEdit;
    procedure AboutBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CreateRepackTxtClick(Sender: TObject);
    procedure DevToolEditChange(Sender: TObject);
    procedure EditItemClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormShow(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure ListBox1DrawItem(Control: TWinControl; Index: integer;
      ARect: TRect; State: TOwnerDrawState);
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
    // procedure SearchDeskTop;
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure TrimEdits;
    procedure UnpackBtnClick(Sender: TObject);
    procedure UPBtnClick(Sender: TObject);
    procedure LoadProject(FileName: string; Sender: TObject);
    procedure SaveProject(FileName: string);

  private

  public

  end;

resourcestring
  SDeleteRecords = 'Delete selected items?';
  SNoData = 'Not enough data for build package!';
  //SClearWorkDir = 'Clearing the working directory...';
  SProjectChange = 'Project changed. Save it?';
  SFileListEmpty = 'The list of files is empty!';
  SNoListObject = 'No list object:';
  //SMacrosNotFound = 'No file found ~/.rpmmacros! Not ready to sign packages!';
  //SSignRPM = 'Sign the packages:';
  SCompleted = 'Completed. Press Enter to continue...';
  SInputName = 'Please, enter the name of the package:';
  SSymLink = 'This is SymLink! Need a real target!';
  SEditRecord = 'Editing an entry:';
  SAppRunning = 'The program is already running!';

var
  MainForm: TMainForm;
  WorkDir: string;
  SaveFlag: boolean;

implementation

uses unit2, LoadGroupsTRD, selectunit, unpackunit;

{$R *.lfm}

{ TMainForm }

//Открыть проект
procedure TMainForm.LoadProject(FileName: string; Sender: TObject);
var
  PRJ: TIniFile;
  i: integer;
  S: string;
begin
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;

  //Загрузка с кнопки или из параметра?
  if (Sender = LoadBtn) or (Sender = LoadItem) then
  begin
    PRJ := TIniFile.Create(OpenFile.FileName);
    MainForm.Caption := Application.Title + ' <' +
      ExtractFileName(OpenFile.FileName) + '>';
  end
  else
  begin
    PRJ := TIniFile.Create(ParamStr(1));
    OpenFile.InitialDir := ExtractFilePath(ParamStr(1));
    SaveFile.InitialDir := OpenFile.InitialDir;
    MainForm.Caption := Application.Title + ' <' + ExtractFileName(ParamStr(1)) + '>';
  end;

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
  //SignCheckBox.Checked := PRJ.ReadBool('SIGN', 'sign', False);
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
  //URLEdit64.Text := PRJ.ReadString('URL64', 'url64', '');
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
  //Курсор вначало InfoMemo после наполнения
  InfoMemo.SelStart := 0;

  PRJ.Free;

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

  Screen.Cursor := crDefault;
end;

//Сохранить проект
procedure TMainForm.SaveProject(FileName: string);
var
  i: integer;
  PRJ: TIniFile;
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
  //PRJ.WriteBool('SIGN', 'sign', SignCheckBox.Checked);
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
  // PRJ.WriteString('URL64', 'url64', URLEdit64.Text);
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
    ExProcess.Executable := terminal;  //sh или xterm
    if terminal <> 'sh' then
    begin
      ExProcess.Parameters.Add('-fa'); //имя шрифта
      ExProcess.Parameters.Add('monospace');
      ExProcess.Parameters.Add('-fs'); //размер шрифта
      ExProcess.Parameters.Add('10');

      ExProcess.Parameters.Add('-xrm');
      ExProcess.Parameters.Add('XTerm*foreground:white');
      ExProcess.Parameters.Add('-xrm');
      ExProcess.Parameters.Add('XTerm*background:black');
      ExProcess.Parameters.Add('-xrm');
      ExProcess.Parameters.Add('XTerm*allowTitleOps:false');
      ExProcess.Parameters.Add('-T');
      ExProcess.Parameters.Add('Build RPM-package');
      ExProcess.Parameters.Add('-g');
      ExProcess.Parameters.Add('120x40+10+10');
      ExProcess.Parameters.Add('-xrm');
      ExProcess.Parameters.Add('XTerm*cursorColor:red'); //цвет курсора
      ExProcess.Parameters.Add('-xrm');
      ExProcess.Parameters.Add('XTerm*cursorBlink:true'); //мигающий курсор
      ExProcess.Parameters.Add('-e');
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
  //URLEdit64.Text := Trim(URLEdit64.Text);
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

{//Ищем Рабочий Стол
procedure TMainForm.SearchDeskTop;
begin
  if DirectoryExists(GetUserDir + 'Рабочий стол') then
    OpenFile.InitialDir := GetUserDir + 'Рабочий стол'
  else
  if DirectoryExists(GetUserDir + 'Desktop') then
    OpenFile.InitialDir := GetUserDir + 'Desktop'
  else
    OpenFile.InitialDir := '/home';

  SaveFile.InitialDir := OpenFile.InitialDir;
end;}

procedure TMainForm.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  with StatusBar.Canvas do
  begin
    Font.Size := 10;
    Font.Style := [fsBold];
    //  Font.Color := clRed;
    Brush.Color := StatusBar1.Color;
    TextOut(Rect.Left, Rect.Top, Application.Hint);
  end;
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
  output: ansistring;
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
      Add('URL the sources + binaries of the author: ' + URLEdit32.Text);
     { if URLEdit64.Text = '' then
        Add('URL the sources of the author (64 bit): unknown')
      else
        Add('URL the sources of the author (64 bit): ' + URLEdit64.Text);}
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

      //Сохраняем через pkexec в /usr/share/doc/имя_пакета
      RepackTXT.Text := Trim(RepackTXT.Text);
      RepackTXT.SaveToFile(WorkDir + '/repack.txt');
      Application.ProcessMessages;

      RunCommand('/bin/bash',
        ['-c', 'pkexec /bin/bash -c "[ -d /usr/share/doc/' + NameEdit.Text +
        '] || mkdir /usr/share/doc/' + NameEdit.Text + '; mv -f ' +
        WorkDir + '/repack.txt ' + '/usr/share/doc/' + NameEdit.Text +
        '/repack.txt"; echo $?'],
        output);

      //Ловим отмену и ошибку аутентификации pkexec
      if (Trim(output) <> '126') and (Trim(output) <> '127') then

        //Добавляем папку /usr/share/doc/имя_пакета в список файлов, если её там нет
        if ListBox1.Items.IndexOf('/usr/share/doc/' + NameEdit.Text + '/') = -1 then
        begin
          ListBox1.Items.Append('/usr/share/doc/' + NameEdit.Text + '/');
          SaveFlag := True;
        end;
    end;

  finally;
    RepackTXT.Free;
  end;
end;

procedure TMainForm.DevToolEditChange(Sender: TObject);
begin
  SaveFlag := True;
end;

//Редактирование записей списка файлов и папок
procedure TMainForm.EditItemClick(Sender: TObject);
var
  S: string;
begin
  if ListBox1.Count <> 0 then
  begin
    S := ListBox1.Items.Strings[ListBox1.ItemIndex];
    if not InputQuery('RPMCreator', SEditRecord, S) or (Trim(S) = '') then
      Exit
    else
    begin
      ListBox1.Items.Strings[ListBox1.ItemIndex] := S;
      SaveFlag := True;
    end;
  end;

end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  //Очищаем рабочую папку
{  MainForm.Caption := SClearWorkDir;
  StartProcess('find ' + WorkDir + '/* -type f ! -name "*.xml" -delete', 'sh'); }
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
var //Поток считывания валидных групп
  FStartLoadGroups: TThread;
begin
  //For Plasma
  MainFormStorage.Restore;

  MainForm.Caption := Application.Title;

  PageControl1.ActivePageIndex := 0;
  AboutBtn.Width := AboutBtn.Height;

  //Получить список валидных групп RPM
  if not FileExists(WorkDir + '/rpm-groups.list') then
  begin
    FStartLoadGroups := StartLoadGroups.Create(False);
    FStartLoadGroups.Priority := tpNormal;
  end
  else
    GroupCBox.Items.LoadFromFile(WorkDir + '/rpm-groups.list');

  //Параметры
  if ParamStr(1) <> '' then LoadProject(ParamStr(1), nil);
end;

//Редактирование записей списка файлов и папок
procedure TMainForm.ListBox1DblClick(Sender: TObject);
begin
  EditItem.Click;
end;

//Иконки в списке файлов
procedure TMainForm.ListBox1DrawItem(Control: TWinControl; Index: integer;
  ARect: TRect; State: TOwnerDrawState);
var
  BitMap: TBitMap;
begin
  try
    BitMap := TBitMap.Create;
    with ListBox1 do
    begin
      Canvas.FillRect(aRect);
      //Название файла
      //Canvas.TextOut(aRect.Left + 26, aRect.Top + 5, Items[Index]);
      //Название (текст по центру-вертикали)
      Canvas.TextOut(aRect.Left + 24, aRect.Top + ItemHeight div 2 -
        Canvas.TextHeight('A') div 2 + 1, Items[Index]);

      //Иконка файла
      if Items[Index][Length(Items[Index])] = '/' then
        ImageList2.GetBitMap(0, BitMap)
      else
        ImageList2.GetBitMap(1, BitMap);

      Canvas.Draw(aRect.Left + 2, aRect.Top + (ItemHeight - 16) div 2 + 1, BitMap);
    end;
  finally
    BitMap.Free;
  end;
end;

procedure TMainForm.LoadBtnClick(Sender: TObject);
begin
  //Проект изменялся?
  if SaveFlag then
    if MessageDlg(SProjectChange, mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      SaveBtn.Click;

  if OpenFile.Execute then
    LoadProject(OpenFile.FileName, Sender);
end;


procedure TMainForm.BuildBtnClick(Sender: TObject);
var
  i: integer;
  deps, size: ansistring;
  SPEC, FILES: TStringList;
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
 { if (SignCheckBox.Checked) and (not FileExists(GetUserDir + '.rpmmacros')) then
  begin
    MessageDlg(SMacrosNotFound, mtWarning, [mbOK], 0);
    Exit;
  end;}

  try
    BuildBtn.Enabled := False;

    //Показываем метку ожидания
    BuildLabel.Visible := True;

    //Пересоздаём рабочие директории для сборки RPM
    StartProcess('[ -d ~/rpmbuild ] && rm -rf ~/rpmbuild/*', 'sh');
    StartProcess('mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}', 'sh');

    //Пересоздаём рабочие директории для сборки DEB
    StartProcess('[ -d ~/debbuild ] && rm -rf ~/debbuild/*', 'sh');
    StartProcess('mkdir -p ~/debbuild/tmp/DEBIAN', 'sh');

    //АРХИВ ИСХОДНИКОВ ДОЛЖЕН БЫТЬ ВСЕГДА!
    //Собираем /home/$USER/rpmbuild/SOURCES/имя_пакета-версия.tar.gz
    ListBox1.Items.SaveToFile(GetUserDir + 'rpmbuild/SOURCES/files.lst');

    //Устанавливаем текущую директорию для tar
    SetCurrentDir(GetUserDir + 'rpmbuild/SOURCES');

    //Жмём архив
    StartProcess('nice -n 15 tar -czf ' + NameEdit.Text + '-' +
      VersEdit.Text + '.tar.gz --exclude="*.bak" --exclude="*.or" -T ./files.lst', 'sh');

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
      if not MetaCheck.Checked then
        StartProcess('nice -n 15 tar -xvzf ' + NameEdit.Text + '-' +
          VersEdit.Text + '.tar.gz' + ' -C ~/debbuild/tmp', 'sh');

      SPEC.Add('Package: ' + NameEdit.Text);
      SPEC.Add('Version: ' + VersEdit.Text + '-' + ReleaseEdit.Text);

      //Выставляем архитектуру пакета DEB
      if NoArchCheck.Checked then
        SPEC.Add('Architecture: all')
      else
      if string({$I %FPCTARGETCPU%}) = 'x86_64' then
        SPEC.Add('Architecture: amd64')
      else
        SPEC.Add('Architecture: i386');

      SPEC.Add('Maintainer: ' + MaintainerEdit.Text);

      //Если в зависимостях нет запятых, заменяем пробелы запятыми
     { if pos(',', DepsEdit.Text) = 0 then
        SPEC.Add('Depends: ' + Trim(StringReplace(DepsEdit.Text, ' ',
          ',', [rfReplaceAll])))
      else
        SPEC.Add('Depends: ' + Trim(DepsEdit.Text));}
      if RunCommand('/bin/bash', ['-c', 'echo "' + Trim(DepsEdit.Text) +
        '" | tr -s [:space:][:punct:] | tr " " "," | tr -s [:punct:] | sed "s/,/, /g"'],
        deps) then
        SPEC.Add('Depends: ' + Trim(deps));


      SPEC.Add('Priority: extra');
      SPEC.Add('Section: misc');
      SPEC.Add('Homepage: ' + URLCopyEdit.Text);

      //Installed-Size в KiB (килобайты)
      if RunCommand('/bin/bash',
        ['-c', 'du -schk ~/debbuild/tmp/*[^DEBIAN] | tail -n1 | cut -f1 '], size) then
        SPEC.Add('Installed-Size: ' + Trim(size));

      //Description (Short + Long) https://linux.die.net/man/5/deb-control
      SPEC.Add('Description: ' + SummaryEdit.Text);
      for i := 0 to DescEdit.Lines.Count - 1 do
        if Length(Trim(DescEdit.Lines[i])) = 0 then
          SPEC.Add(' .')
        else
          SPEC.Add(' ' + Trim(DescEdit.Lines[i]));

      SPEC.SaveToFile(GetUserDir + 'debbuild/tmp/DEBIAN/control');

      //Контрольная сумма файлов из корня пакета DEB
      if not MetaCheck.Checked then
        StartProcess(
          'cd ~/debbuild/tmp; md5sum $(find *[^DEBIAN] -type f) > ~/debbuild/tmp/DEBIAN/md5sums; cd -',
          'sh');

      //pre/post скрипты
      if Trim(BeforeInstallEdit.Text) <> '' then
        BeforeInstallEdit.Lines.SaveToFile(GetUserDir + 'debbuild/tmp/DEBIAN/preinst');

      if Trim(AfterInstallEdit.Text) <> '' then
        AfterInstallEdit.Lines.SaveToFile(GetUserDir + 'debbuild/tmp/DEBIAN/postinst');

      if Trim(BeforeRemoveEdit.Text) <> '' then
        BeforeRemoveEdit.Lines.SaveToFile(GetUserDir + 'debbuild/tmp/DEBIAN/prerm');

      if Trim(AfterRemoveEdit.Text) <> '' then
        AfterRemoveEdit.Lines.SaveToFile(GetUserDir + 'debbuild/tmp/DEBIAN/postrm');

      //Права на скрипты pre/post (755)
      StartProcess('chmod 755 ~/debbuild/tmp/DEBIAN/{pre*,post*}', 'sh');

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
   { SPEC.Add('#ROSA rpmlint bypass; from /usr/share/rpmlint/config.d/rosa.error.list');
    SPEC.Add('%define _binary_or_shlib_defines_rpath_on_system_dir 0');
    SPEC.Add('%define _buildprereq_use 0');
    SPEC.Add('%define _debuginfo_without_sources 0');
    SPEC.Add('%define _description_line_too_long 0');
    SPEC.Add('%define _dir_or_file_in_home 0');
    SPEC.Add('%define _dir_or_file_in_mnt 0');
    SPEC.Add('%define _dir_or_file_in_opt 0');
    SPEC.Add('%define _dir_or_file_in_tmp 0');
    SPEC.Add('%define _dir_or_file_in_usr_local 0');
    SPEC.Add('%define _dir_or_file_in_var_local 0');
    SPEC.Add('%define _double_slash_in_path 0');
    SPEC.Add('%define _empty_debuginfo_package 0');
    //    SPEC.Add('%define _empty_%pre 0');
    //    SPEC.Add('%define _empty_%pretrans 0');
    //    SPEC.Add('%define _empty_%preun 0');
    //    SPEC.Add('%define _empty_%post 0');
    //    SPEC.Add('%define _empty_%posttrans 0');
    //    SPEC.Add('%define _empty_%postun 0');
    SPEC.Add('%define _external_depfilter_with_internal_depgen 0');
    SPEC.Add('%define _incoherent_version_in_name 0');
    SPEC.Add('%define _info_dir_file 0');
    SPEC.Add('%define _info_files_with_install_info_postin 0');
    SPEC.Add('%define _info_files_with_install_info_postun 0');
    SPEC.Add('%define _non_ghost_in_var_lock 0');
    SPEC.Add('%define _non_ghost_in_var_run 0');
    SPEC.Add('%define _non_standard_group 0');
    SPEC.Add('%define _percent_in_conflicts 0');
    SPEC.Add('%define _percent_in_dependency 0');
    SPEC.Add('%define _percent_in_obsoletes 0');
    SPEC.Add('%define _percent_in_provides 0');
    SPEC.Add('%define _prereq_use 0');
    SPEC.Add('%define _requires_on_install_info 0');
    SPEC.Add('%define _shared_lib_not_executable 0');
    //    SPEC.Add('%define _standard_dir_owned_by-package 0');
    SPEC.Add('%define _summary_ended_with_dot 0');
    SPEC.Add('%define _summary_on_multiple_lines 0');
    SPEC.Add('%define _summary_too_long 0');
    SPEC.Add('%define _unexpanded_macro 0');
    SPEC.Add('%define _unstripped_binary_or_object 0'); }

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
    if Trim(BeforeInstallEdit.Text) <> '' then
    begin
      SPEC.Add('%pre');
      for i := 0 to BeforeInstallEdit.Lines.Count - 1 do
        SPEC.Add(BeforeInstallEdit.Lines[i]);
      SPEC.Add('');
    end;

    //Секция %post
    if Trim(AfterInstallEdit.Text) <> '' then
    begin
      SPEC.Add('%post');
      for i := 0 to AfterInstallEdit.Lines.Count - 1 do
        SPEC.Add(AfterInstallEdit.Lines[i]);
      SPEC.Add('');
    end;

    //Секция %preun
    if Trim(BeforeRemoveEdit.Text) <> '' then
    begin
      SPEC.Add('%preun');
      for i := 0 to BeforeRemoveEdit.Lines.Count - 1 do
        SPEC.Add(BeforeRemoveEdit.Lines[i]);
      SPEC.Add('');
    end;

    //Секция %postun
    if Trim(AfterRemoveEdit.Text) <> '' then
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
    SPEC.SaveToFile(GetUserDir + 'rpmbuild/SPECS/' + NameEdit.Text + '.spec');

    //Создаём пускач сборки пакета
    SPEC.Clear;
    SPEC.Add('rpmbuild -ba ~/rpmbuild/SPECS/' + NameEdit.Text + '.spec');

    //Подпись пакетов в ~/rpmbuild/SRPMS RPMS/*/name_package*.rpm
    {if SignCheckBox.Checked then
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
    StartProcess(WorkDir + '/build.sh', 'xterm'); }

    //Собираем пакет rpm + src.rpm
    StartProcess('rpmbuild -ba ~/rpmbuild/SPECS/' + NameEdit.Text +
      '.spec; echo -e "\n---"; read -p "' + SCompleted + '"', 'xterm');

  finally;

    //Освобождаем память списков
    SPEC.Free;
    FILES.Free;

    //Возвращаем в SaveFile CurrentDirectory, если проект изменялся
    SaveFile.InitialDir := OpenFile.InitialDir;

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

//Флаг изменения проекта
procedure TMainForm.NameEditChange(Sender: TObject);
begin
  SaveFlag := True;
end;

//Запрет пробелов в определенных полях
procedure TMainForm.NameEditKeyPress(Sender: TObject; var Key: char);
begin
  if Key = char(VK_SPACE) then
    Key := #0;
end;

//Список файлов по имени пакета
procedure TMainForm.RPMBtnClick(Sender: TObject);
var
  i: integer;
  RPMName: string;
begin
  //Грузим список файлов, из которых состоит пакет.rpm
  RPMName := '';

  if not InputQuery('RPMCreator', SInputName, RPMName) or (Trim(RPMName) = '') then
    Exit;

  StartProcess('rpm -ql ' + RPMName + ' > ' + WorkDir + '/rpm-ql.lst', 'sh');
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

begin
  //Обрезаем лишние пробелы в эдитах
  TrimEdits;

  if SaveFile.Execute then
    SaveProject(SaveFile.FileName);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  //Флаг сохранения списка
  SaveFlag := False;

  //Рабочая директория в профиле
  WorkDir := GetUserDir + '.RPMCreator';

  if not DirectoryExists(WorkDir) then
    MkDir(WorkDir);

  MainFormStorage.FileName := WorkDir + '/settings.xml';
end;

end.
