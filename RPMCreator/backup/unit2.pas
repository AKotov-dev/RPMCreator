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
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
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

procedure TAboutForm.Button1Click(Sender: TObject);
begin
  AboutForm.Close;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  AboutForm.AboutFormStorage.FileName := MainForm.MainFormStorage.FileName;
end;

end.




