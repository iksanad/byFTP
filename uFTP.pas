unit uFTP;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Forms, Vcl.Dialogs, IdFTP, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,
  IdSSL, IdSSLOpenSSL, Vcl.StdCtrls, Vcl.Grids, Vcl.ExtCtrls, Data.DB, ComObj,
  Datasnap.DBClient, System.StrUtils, Vcl.Controls, vcl.wwdbigrd, vcl.wwdbgrid,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdFTPList,
  IdExplicitTLSClientServerBase, sButton, sEdit, sLabel, sCheckBox, System.Diagnostics;

type
  TForm1 = class(TForm)
    IdFTP1: TIdFTP;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    StringGrid1: TwwDBGrid;
    ClientDataSet1: TClientDataSet;
    DataSource1: TDataSource;
    sButton1: TsButton;
    sButton2: TsButton;
    eDirLocal: TsEdit;
    bActioning: TsButton;
    eHost: TsEdit;
    eUser: TsEdit;
    ePass: TsEdit;
    Panel1: TPanel;
    sLabel1: TsLabel;
    sLabel2: TsLabel;
    sLabel3: TsLabel;
    sCheckBox1: TsCheckBox;
    actStatus: TsCheckBox;
    procedure sButton1Click(Sender: TObject);
    procedure sButton2Click(Sender: TObject);
    procedure bActioningClick(Sender: TObject);
    procedure actStatusClick(Sender: TObject);
    procedure ClientDataSet1AfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    LocalFile: String;
    procedure AddFirewallException(const AppPath: string);
    function changeMonth(const bulan: string): string;
    function FirewallRuleExists(const RuleName: string): Boolean;
    function ExecuteCommand(const Command: string; Output: TStrings): Boolean;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.AddFirewallException(const AppPath: string);
var
  Command: AnsiString;
  RuleName: string;
begin
  RuleName := LowerCase(ExtractFileName(AppPath));

  if not FirewallRuleExists(RuleName) then
  begin
    Command := AnsiString(Format('netsh advfirewall firewall add rule name="%s" dir=in action=allow program="%s" enable=yes', [RuleName, AppPath]));
    WinExec(PAnsiChar(Command), SW_HIDE); // Menggunakan SW_HIDE agar tidak muncul peringatan.
    Sleep(1000);
//    Command := Format('netsh advfirewall firewall delete rule name="%s"', [RuleName]);

    if WinExec(PAnsiChar(Command), SW_SHOWNORMAL) <= 31 then
      raise Exception.Create('Failed to add firewall exception.');
  end;
end;

function TForm1.FirewallRuleExists(const RuleName: string): Boolean;
var
  Output: TStringList;
begin
  Output := TStringList.Create;
  try
    Result := ExecuteCommand('netsh advfirewall firewall show rule name="' + RuleName + '"', Output) and (Pos(RuleName, Output.Text) > 0);
  finally
    Output.Free;
  end;
end;

function TForm1.ExecuteCommand(const Command: string; Output: TStrings): Boolean;
var
  SecurityAttrs: TSecurityAttributes;
  ReadPipe, WritePipe: THandle;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Buffer: array [0..255] of AnsiChar;
  BytesRead: DWORD;
begin
  Result := False;
  Output.Clear;

  // Set up security attributes to allow pipes
  SecurityAttrs.nLength := SizeOf(TSecurityAttributes);
  SecurityAttrs.bInheritHandle := True;
  SecurityAttrs.lpSecurityDescriptor := nil;

  // Create a pipe for the child process's STDOUT
  if not CreatePipe(ReadPipe, WritePipe, @SecurityAttrs, 0) then
    Exit;

  // Set up members of the PROCESS_INFORMATION structure
  FillChar(ProcessInfo, SizeOf(TProcessInformation), 0);

  // Set up members of the STARTUPINFO structure
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.hStdError := WritePipe;
  StartupInfo.hStdOutput := WritePipe;
  StartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;

  // Create the child process
  if CreateProcess(nil, PChar(Command), @SecurityAttrs, @SecurityAttrs, True,
    CREATE_NO_WINDOW or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo)
  then
  begin
    CloseHandle(WritePipe);

    // Read output from the child process's pipe for STDOUT
    while ReadFile(ReadPipe, Buffer, SizeOf(Buffer), BytesRead, nil) do
    begin
      if BytesRead > 0 then
        Output.Add(Copy(Buffer, 1, BytesRead));
    end;

    Result := True;

    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(ReadPipe);
  end;
end;

procedure TForm1.sButton1Click(Sender: TObject);
var
  DirectoryListing: TStringList;
  Row: Integer;
  FileName, ItemType: string;
  ModifiedDateStr: string;
  ModifiedDate: TDateTime;
  FileSize: Int64;
begin
  actStatus.ReadOnly := False;

  IdFTP1.Host := eHost.Text;
  IdFTP1.Username := eUser.Text;
  IdFTP1.Password := ePass.Text;

  try
    IdFTP1.Disconnect;
    IdFTP1.Connect;

    AddFirewallException(LowerCase(Application.ExeName));
    Sleep(1000);

    DirectoryListing := TStringList.Create;
    try
      IdFTP1.List(DirectoryListing);

      ClientDataSet1.Close;
      ClientDataSet1.FieldDefs.Clear;
      ClientDataSet1.FieldDefs.Add('FileName', ftString, 50);
      ClientDataSet1.FieldDefs.Add('DateModified', ftDateTime);
      ClientDataSet1.FieldDefs.Add('Type', ftString, 30);
      ClientDataSet1.FieldDefs.Add('Size', ftLargeInt);
      ClientDataSet1.CreateDataSet;

      for Row := 0 to DirectoryListing.Count - 1 do
      begin
        FileName := Trim(DirectoryListing[Row]);
        ItemType := Copy(FileName, 1, 1); // Ambil karakter pertama

        FileName := Trim(Copy(FileName, 56, Length(FileName)));
        ModifiedDateStr := Copy(Trim(DirectoryListing[Row]), 44, 12);
        ModifiedDateStr := Copy(ModifiedDateStr, 5, 2) + '/' + changeMonth(Copy(ModifiedDateStr, 1, 3)) + '/' + Copy(ModifiedDateStr, 9, 4);
        ModifiedDate := StrToDate(ModifiedDateStr);
//        if ItemType = 'd' then
//          FileSize := 0
//        else
//          FileSize := StrToInt64Def(Copy(Trim(DirectoryListing[Row]), 22, 12), 0);
        ItemType := IfThen(ItemType = 'd', 'Folder', 'File');

        ClientDataSet1.Append;
        ClientDataSet1.FieldByName('FileName').AsString := FileName;
        ClientDataSet1.FieldByName('DateModified').AsDateTime := ModifiedDate;
        ClientDataSet1.FieldByName('Type').AsString := ItemType;
        ClientDataSet1.FieldByName('Size').AsLargeInt := FileSize;
        ClientDataSet1.Post;
      end;

      ClientDataSet1.IndexFieldNames := 'Type;FileName';
      ClientDataSet1.Open;
      ClientDataSet1.First;
      ClientDataSet1.ProviderName := '';
    finally
      DirectoryListing.Free;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Error: ' + E.Message);
    end;
  end;
end;

procedure TForm1.sButton2Click(Sender: TObject);
var
  OpenDialog: TFileOpenDialog;
  I: Integer;
begin
  if actStatus.Checked = False then
  begin
    OpenDialog := TFileOpenDialog.Create(nil);
    try
      OpenDialog.Title := 'Pilih File';
  //    OpenDialog.DefaultFolder := 'C:\';
      OpenDialog.Options := [fdoAllowMultiSelect];
      if OpenDialog.Execute then
      begin
        LocalFile := OpenDialog.FileName;
        eDirLocal.Text := ExtractFileName(LocalFile);
      end;
    finally
      OpenDialog.Free;
    end;
  end;
end;

procedure TForm1.bActioningClick(Sender: TObject);
begin
  if eDirLocal.Text = '' then
  begin
    ShowMessage('Pilih File yang ingin di ' + actStatus.Caption + ' Terlebih dahulu');
    sButton2Click(Self);
    abort;
  end;
  if actStatus.Checked = True then
  begin
    if MessageDlg('Ingin Download ' + eDirLocal.Text + ' dari ' + IdFTP1.Host + '?', mtConfirmation, [mbNO, mbYes], 7) = mrYes then
    begin
      if FileExists(LocalFile) then
      begin
        if MessageDlg('File dengan nama tersebut sudah ada. Apakah Anda ingin menimpanya?', mtWarning, [mbNO, mbYes], 0) = mrYes then
          DeleteFile(LocalFile)
        else
          Exit;
      end;

      IdFTP1.Get(LocalFile, LocalFile, False);
      ShowMessage('File ' + eDirLocal.Text + ' berhasil didownload.');
    end;
  end
  else
  begin
    if MessageDlg('Ingin Upload ' + eDirLocal.Text + ' ke ' + IdFTP1.Host + '?', mtConfirmation, [mbNO, mbYes], 7) = mrYes then
    begin
      IdFTP1.Put(LocalFile, ExtractFileName(LocalFile));
      ShowMessage('File ' + eDirLocal.Text + ' berhasil diupload.');
    end;
  end;
end;

procedure TForm1.ClientDataSet1AfterScroll(DataSet: TDataSet);
begin
  if actStatus.Checked = True then
  begin
    if ClientDataSet1.FieldByName('Type').AsString = 'File' then
    begin
      eDirLocal.Text := ClientDataSet1.FieldByName('FileName').AsString;
      LocalFile := ClientDataSet1.FieldByName('FileName').AsString;
    end
    else
    begin
      eDirLocal.Text := '';
      LocalFile := '';
    end;
  end;
end;

procedure TForm1.actStatusClick(Sender: TObject);
begin
  if actStatus.Checked = True then
  begin
    actStatus.Caption := 'Download';
    bActioning.Caption := 'Download';
    if ClientDataSet1.FieldByName('Type').AsString = 'File' then
    begin
      eDirLocal.Text := ClientDataSet1.FieldByName('FileName').AsString;
      LocalFile := ClientDataSet1.FieldByName('FileName').AsString;
    end
    else
    begin
      eDirLocal.Text := '';
      LocalFile := '';
    end;
  end
  else
  if actStatus.Checked = False then
  begin
    actStatus.Caption := 'Upload';
    bActioning.Caption := 'Upload';
    eDirLocal.Text := '';
    LocalFile := '';
  end;
end;

function Tform1.changeMonth(const bulan: string): string;
begin
  if bulan = 'Jan' then
    result := '01'
  else
  if bulan = 'Feb' then
    result := '02'
  else
  if bulan = 'Mar' then
    result := '03'
  else
  if bulan = 'Apr' then
    result := '04'
  else
  if (bulan = 'May') or (bulan = 'Mei') then
    result := '05'
  else
  if bulan = 'Jun' then
    result := '06'
  else
  if bulan = 'Jul' then
    result := '07'
  else
  if (bulan = 'Aug') or (bulan = 'Agu') then
    result := '08'
  else
  if bulan = 'Sep' then
    result := '09'
  else
  if (bulan = 'Oct') or (bulan = 'Okt') then
    result := '10'
  else
  if bulan = 'Nov' then
    result := '11'
  else
  if bulan = 'Des' then
    result := '12';
end;

end.

