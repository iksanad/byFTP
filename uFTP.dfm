object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Program FTP'
  ClientHeight = 691
  ClientWidth = 867
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  PixelsPerInch = 140
  TextHeight = 25
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 867
    Height = 691
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Align = alClient
    Color = 16182204
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 857
    ExplicitHeight = 688
    object sLabel1: TsLabel
      Left = 16
      Top = 16
      Width = 108
      Height = 25
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'HOST NAME'
      ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -18
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
    end
    object sLabel2: TsLabel
      Left = 256
      Top = 16
      Width = 99
      Height = 25
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'USERNAME'
      ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -18
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
    end
    object sLabel3: TsLabel
      Left = 496
      Top = 16
      Width = 100
      Height = 25
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'PASSWORD'
      ParentFont = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -18
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
    end
    object sCheckBox1: TsCheckBox
      Left = 368
      Top = 335
      Width = 120
      Height = 29
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'sCheckBox1'
      TabOrder = 0
    end
    object eDirLocal: TsEdit
      Left = 208
      Top = 96
      Width = 193
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      ReadOnly = True
      TabOrder = 1
    end
    object eHost: TsEdit
      Left = 16
      Top = 48
      Width = 225
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      TabOrder = 2
      Text = '149.129.246.189'
    end
    object ePass: TsEdit
      Left = 496
      Top = 48
      Width = 225
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      PasswordChar = '*'
      TabOrder = 3
      Text = '93vc487c34jfjnfc45n'
    end
    object eUser: TsEdit
      Left = 256
      Top = 48
      Width = 225
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      TabOrder = 4
      Text = 'seventhsoft'
    end
    object sButton1: TsButton
      Left = 736
      Top = 48
      Width = 113
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Connect'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -18
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = sButton1Click
    end
    object sButton2: TsButton
      Left = 144
      Top = 96
      Width = 65
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'File'
      TabOrder = 6
      OnClick = sButton2Click
    end
    object bActioning: TsButton
      Left = 416
      Top = 96
      Width = 113
      Height = 33
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Upload'
      TabOrder = 7
      OnClick = bActioningClick
    end
    object StringGrid1: TwwDBGrid
      Left = 16
      Top = 144
      Width = 833
      Height = 529
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      IniAttributes.Delimiter = ';;'
      IniAttributes.UnicodeIniFile = False
      TitleColor = clBtnFace
      FixedCols = 0
      ShowHorzScrollBar = True
      DataSource = DataSource1
      KeyOptions = []
      ReadOnly = True
      TabOrder = 8
      TitleAlignment = taCenter
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -18
      TitleFont.Name = 'Segoe UI'
      TitleFont.Style = []
      TitleLines = 1
      TitleButtons = False
    end
    object actStatus: TsCheckBox
      Left = 16
      Top = 96
      Width = 91
      Height = 32
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Upload'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -20
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 9
      OnClick = actStatusClick
      ReadOnly = True
    end
  end
  object IdFTP1: TIdFTP
    IOHandler = IdSSLIOHandlerSocketOpenSSL1
    Host = '149.129.246.189'
    ConnectTimeout = 15000
    Password = '93vc487c34jfjnfc45n'
    Username = 'seventhsoft'
    NATKeepAlive.UseKeepAlive = False
    NATKeepAlive.IdleTimeMS = 0
    NATKeepAlive.IntervalMS = 0
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    Left = 61
    Top = 253
  end
  object IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL
    Destination = '149.129.246.189:21'
    Host = '149.129.246.189'
    MaxLineAction = maException
    Port = 21
    DefaultPort = 0
    ReadTimeout = 60000
    SSLOptions.Mode = sslmClient
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 245
    Top = 258
  end
  object ClientDataSet1: TClientDataSet
    Aggregates = <>
    Params = <>
    AfterScroll = ClientDataSet1AfterScroll
    Left = 264
    Top = 155
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 136
    Top = 155
  end
end
