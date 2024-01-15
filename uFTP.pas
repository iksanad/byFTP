unit uFTP;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Forms, Vcl.Dialogs, IdFTP, IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack,
  IdSSL, IdSSLOpenSSL, Vcl.StdCtrls, Vcl.Grids, Vcl.ExtCtrls, Data.DB,
  Datasnap.DBClient, System.StrUtils, Vcl.Controls, vcl.wwdbigrd, vcl.wwdbgrid,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdFTPList,
  IdExplicitTLSClientServerBase, sButton, sEdit, sLabel, sCheckBox;

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
    function changeMonth(const bulan: string): string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

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

