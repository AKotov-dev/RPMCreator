unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, XMLPropStorage;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    AboutFormStorage: TXMLPropStorage;
    Bevel1: TBevel;
    OkBtn: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure OkBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

uses unit1;

{$R *.lfm}

{ TAboutForm }

procedure TAboutForm.OkBtnClick(Sender: TObject);
begin
  AboutForm.Close;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  Label1.Caption := Application.Title;
  AboutFormStorage.FileName := MainForm.MainFormStorage.FileName;
end;

end.




