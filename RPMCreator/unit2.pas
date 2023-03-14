unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls;

type

  { TAboutForm }

  TAboutForm = class(TForm)
    Bevel1: TBevel;
    OkBtn: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
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

procedure TAboutForm.FormShow(Sender: TObject);
begin
  //Авторазмер
  AboutForm.Width := Label2.Left + Label2.Width + 50;
  AboutForm.Height := OkBtn.Top + OkBtn.Height + 8;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  Label1.Caption := Application.Title;
end;

end.
