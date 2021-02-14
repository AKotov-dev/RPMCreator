unit unique_utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, simpleipc;

type

  TOnUniqueInstanceMessage = procedure(Sender: TObject; Params: array of string;
    ParamCount: integer) of object;

  { TUniqueInstance }

  TUniqueInstance = class
  private
    fcli: TSimpleIPCClient;
    fOnMessage: TOnUniqueInstanceMessage;
    fsrv: TSimpleIPCServer;
    fName: string;

    procedure OnNative(Sender: TObject);

    procedure CreateSrv;
    procedure CreateCli;
  public
    property OnMessage: TOnUniqueInstanceMessage read fOnMessage write fOnMessage;

    function IsRunInstance: boolean;
    procedure SendParams;
    procedure SendString(aStr: string);

    procedure RunListen;
    procedure StopListen;

    constructor Create(aName: string);
    destructor Destroy; override;
  end;

implementation

uses strutils;

{ TUniqueInstance }

procedure TUniqueInstance.OnNative(Sender: TObject);
var
  Str: array of string;
  Cnt, i: integer;

  procedure GetParams(const AStr: string);
  var
    pos1, pos2: integer;
  begin
    SetLength(Str, Cnt);
    i := 0;
    pos1 := 1;
    pos2 := pos(#1, AStr);
    while pos1 < pos2 do
    begin
      str[i] := Copy(AStr, pos1, pos2 - pos1);
      pos1 := pos2 + 1;
      pos2 := posex(#1, AStr, pos1);
      Inc(i);
    end;
  end;

begin
  if Assigned(fOnMessage) then
  begin
    Cnt := fsrv.MsgType;
    GetParams(fsrv.StringMessage);
    fOnMessage(Self, Str, Cnt);
    SetLength(Str, 0);
  end;
end;

procedure TUniqueInstance.CreateSrv;
begin
  if fsrv = nil then
  begin
    fsrv := TSimpleIPCServer.Create(nil);
    fsrv.OnMessage := @OnNative;
  end;
  if fcli <> nil then
    FreeAndNil(fcli);
end;

procedure TUniqueInstance.CreateCli;
begin
  if fcli = nil then
    fcli := TSimpleIPCClient.Create(nil);
end;

function TUniqueInstance.IsRunInstance: boolean;
begin
  CreateCli;
  fcli.ServerID := fName;
  Result := fcli.ServerRunning;
end;

procedure TUniqueInstance.SendParams;
var
  t: string;
  j: integer;
begin
  CreateCli;
  fcli.ServerID := fName;
  if not fcli.ServerRunning then
    Exit;
  t := '';
  for j := 1 to ParamCount do
    t := t + #1 + AnsiToUtf8(ParamStr(j));
  try
    fcli.Connect;
    fcli.SendStringMessage(ParamCount, t);
  finally
    fcli.Disconnect;
  end;
end;

procedure TUniqueInstance.SendString(aStr: string);
begin
  CreateCli;
  fcli.ServerID := fName;
  if not fcli.ServerRunning then
    Exit;
  try
    fcli.Connect;
    fcli.SendStringMessage(1, aStr + #1);
  finally
    fcli.Disconnect;
  end;
end;

procedure TUniqueInstance.RunListen;
begin
  CreateSrv;
  fsrv.ServerID := fName;
  fsrv.Global := True;
  fsrv.StartServer;
end;

procedure TUniqueInstance.StopListen;
begin
  if fsrv = nil then
    Exit;
  fsrv.StopServer;
end;

constructor TUniqueInstance.Create(aName: string);
begin
  fName := aName;
end;

destructor TUniqueInstance.Destroy;
begin
  if fcli <> nil then
    fcli.Free;
  if fsrv <> nil then
    fsrv.Free;
  inherited Destroy;
end;

end.
