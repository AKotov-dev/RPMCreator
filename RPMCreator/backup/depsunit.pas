unit depsunit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  XMLPropStorage, Process, ClipBrd;

type

  { TDepsForm }

  TDepsForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
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
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
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
  S: string;
begin
  S := '';

  if OpenDialog1.Execute then
  begin
    Edit1.Text := OpenDialog1.FileName;

    RunCommand('bash', ['-c', 'rpmspec -q --requires "' +
      OpenDialog1.FileName + '" 2>/dev/null | sort -u | sed ' + '''' +
      's/.*(.*)/"&"/' + ''''], S);

    Memo1.Text := S;

    RunCommand('bash', ['-c', 'rpmspec -q --buildrequires "' +
      OpenDialog1.FileName + '" 2>/dev/null | sort -u | sed ' + '''' +
      's/.*(.*)/"&"/' + ''''], S);

    Memo2.Text := S;

    RunCommand('bash', ['-c', 'rpmspec -q --recommends "' +
      OpenDialog1.FileName + '" 2>/dev/null | sort -u | sed ' + '''' +
      's/.*(.*)/"&"/' + ''''], S);

    Memo3.Text := S;
  end;

end;

//Выравнивание по ширине
procedure TDepsForm.FormResize(Sender: TObject);
begin
  Memo1.Width := DepsForm.Width div 3 - 10;
  Memo2.Width := Memo1.Width;
  Memo3.Width := Memo1.Width;
end;

procedure TDepsForm.Button1Click(Sender: TObject);
begin
  ClipBoard.AsText := Trim(StringReplace(Memo1.Text, sLineBreak, ' ', [rfReplaceAll]));
end;

procedure TDepsForm.Button2Click(Sender: TObject);
begin
  ClipBoard.AsText := Trim(StringReplace(Memo2.Text, sLineBreak, ' ', [rfReplaceAll]));
end;

procedure TDepsForm.Button3Click(Sender: TObject);
begin
  ClipBoard.AsText := Trim(StringReplace(Memo3.Text, sLineBreak, ' ', [rfReplaceAll]));
end;

procedure TDepsForm.FormCreate(Sender: TObject);
begin
  DepsFormStorage.FileName := MainForm.MainFormStorage.FileName;
end;

end.
