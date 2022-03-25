object Form1: TForm1
  Left = 418
  Top = 123
  Width = 1237
  Height = 803
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblSSovCode: TLabel
    Left = 16
    Top = 9
    Width = 83
    Height = 13
    Caption = #1050#1086#1076' '#1086#1090#1076#1077#1083#1072' '#1043#1080#1052
  end
  object lblIndNum: TLabel
    Left = 304
    Top = 9
    Width = 105
    Height = 13
    Caption = #1048#1085#1076#1080#1074#1080#1076#1091#1072#1083#1100#1085#1099#1081' '#8470
  end
  object lblNsiType: TLabel
    Left = 160
    Top = 9
    Width = 88
    Height = 13
    Caption = #1050#1086#1076' '#1089#1087#1088#1072#1074#1086#1095#1085#1080#1082#1072
  end
  object lblFirst: TLabel
    Left = 16
    Top = 112
    Width = 60
    Height = 13
    Caption = #1053#1072#1095#1072#1090#1100' '#1089' ...'
  end
  object lblCount: TLabel
    Left = 160
    Top = 112
    Width = 87
    Height = 13
    Caption = #1042#1099#1073#1088#1072#1090#1100' '#1079#1072#1087#1080#1089#1077#1081
  end
  object lblDepartFromDate: TLabel
    Left = 16
    Top = 64
    Width = 70
    Height = 13
    Caption = #1059#1073#1099#1074#1096#1080#1077' '#1089' ...'
  end
  object lblINs: TLabel
    Left = 472
    Top = 9
    Width = 85
    Height = 13
    Caption = #1057#1087#1080#1089#1086#1082' '#1091#1073#1099#1074#1096#1080#1093
  end
  object lblDSD: TLabel
    Left = 472
    Top = 195
    Width = 126
    Height = 13
    Caption = #1057#1074#1077#1076#1077#1085#1080#1103' '#1086' '#1088#1077#1075#1080#1089#1090#1088#1072#1094#1080#1080
  end
  object lblChilds: TLabel
    Left = 472
    Top = 396
    Width = 26
    Height = 13
    Caption = #1044#1077#1090#1080
  end
  object lblNSI: TLabel
    Left = 472
    Top = 556
    Width = 61
    Height = 13
    Caption = #1057#1087#1088#1072#1074#1086#1095#1085#1080#1082
  end
  object edMemo: TMemo
    Left = 16
    Top = 387
    Width = 425
    Height = 297
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object gdIDs: TDBGridEh
    Left = 472
    Top = 30
    Width = 721
    Height = 143
    DataSource = DataSource1
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'Tahoma'
    FooterFont.Style = []
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object gdDocs: TDBGridEh
    Left = 472
    Top = 216
    Width = 721
    Height = 169
    DataSource = dsDocs
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'Tahoma'
    FooterFont.Style = []
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object gdChild: TDBGridEh
    Left = 472
    Top = 419
    Width = 721
    Height = 128
    DataSource = dsChild
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'Tahoma'
    FooterFont.Style = []
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object btnGetDocs: TButton
    Left = 24
    Top = 352
    Width = 121
    Height = 25
    Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100' '#1087#1086#1095#1090#1091
    TabOrder = 4
    OnClick = btnGetDocsClick
  end
  object dtBegin: TDBDateTimeEditEh
    Left = 16
    Top = 84
    Width = 121
    Height = 21
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 5
    Visible = True
  end
  object dtEnd: TDBDateTimeEditEh
    Left = 160
    Top = 84
    Width = 121
    Height = 21
    EditButtons = <>
    Kind = dtkDateEh
    TabOrder = 6
    Visible = True
  end
  object edOrgan: TDBEditEh
    Left = 16
    Top = 30
    Width = 121
    Height = 21
    EditButtons = <>
    TabOrder = 7
    Text = '11'
    Visible = True
  end
  object edFirst: TDBEditEh
    Left = 16
    Top = 130
    Width = 121
    Height = 21
    EditButtons = <>
    TabOrder = 8
    Text = '1'
    Visible = True
  end
  object edCount: TDBEditEh
    Left = 160
    Top = 130
    Width = 121
    Height = 21
    EditButtons = <>
    TabOrder = 9
    Text = '14'
    Visible = True
  end
  object btnPostDoc: TButton
    Left = 160
    Top = 212
    Width = 119
    Height = 25
    Caption = #1055#1072#1082#1077#1090' ---> Router'
    TabOrder = 10
    OnClick = btnPostDocClick
  end
  object btnGetActual: TButton
    Left = 160
    Top = 252
    Width = 121
    Height = 25
    Caption = #1055#1072#1082#1077#1090' ---> '#1054#1073#1088#1072#1073#1086#1090#1082#1072
    TabOrder = 11
    OnClick = btnGetActualClick
  end
  object lstINs: TListBox
    Left = 304
    Top = 80
    Width = 121
    Height = 73
    ItemHeight = 13
    MultiSelect = True
    TabOrder = 12
  end
  object edtIN: TDBEditEh
    Left = 304
    Top = 30
    Width = 121
    Height = 21
    EditButtons = <>
    TabOrder = 13
    Text = '3141066C030PB2'
    Visible = True
  end
  object btnGetNSI: TButton
    Left = 152
    Top = 704
    Width = 121
    Height = 25
    Caption = #1055#1088#1086#1074#1077#1088#1082#1072' Progress'
    TabOrder = 14
    OnClick = btnGetNSIClick
  end
  object edNsiType: TDBEditEh
    Left = 160
    Top = 30
    Width = 65
    Height = 21
    EditButtons = <>
    TabOrder = 15
    Text = '1'
    Visible = True
  end
  object gdNsi: TDBGridEh
    Left = 472
    Top = 576
    Width = 721
    Height = 121
    DataSource = dsNsi
    FooterColor = clWindow
    FooterFont.Charset = DEFAULT_CHARSET
    FooterFont.Color = clWindowText
    FooterFont.Height = -11
    FooterFont.Name = 'Tahoma'
    FooterFont.Style = []
    TabOrder = 16
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object edNsiCode: TDBEditEh
    Left = 240
    Top = 30
    Width = 41
    Height = 21
    EditButtons = <>
    TabOrder = 17
    Visible = True
  end
  object cbSrcPost: TDBComboBoxEh
    Left = 16
    Top = 214
    Width = 121
    Height = 21
    EditButtons = <>
    Items.Strings = (
      'package.json'
      'j4SendMail.json'
      'j4GetMailList.json'
      'j4GetMailList-1.json')
    TabOrder = 18
    Text = 'cbSrcPost'
    Visible = True
  end
  object cbAdsCvrt: TDBCheckBoxEh
    Left = 1120
    Top = 555
    Width = 97
    Height = 17
    Caption = 'ADS-'#1082#1086#1087#1080#1103
    Checked = True
    State = cbChecked
    TabOrder = 19
    ValueChecked = 'True'
    ValueUnchecked = 'False'
  end
  object cbESTP: TDBCheckBoxEh
    Left = 16
    Top = 240
    Width = 121
    Height = 17
    Caption = #1069#1062#1055' '#1076#1083#1103' POST'
    Checked = True
    State = cbChecked
    TabOrder = 20
    ValueChecked = 'True'
    ValueUnchecked = 'False'
  end
  object cbClearLog: TDBCheckBoxEh
    Left = 344
    Top = 712
    Width = 97
    Height = 17
    Caption = #1054#1095#1080#1089#1090#1082#1072' '#1083#1086#1075#1072
    TabOrder = 21
    ValueChecked = 'True'
    ValueUnchecked = 'False'
  end
  object btnGetTempIN: TButton
    Left = 160
    Top = 352
    Width = 121
    Height = 25
    Caption = #1055#1086#1083#1091#1095#1080#1090#1100' '#1087#1086#1095#1090#1091
    TabOrder = 22
    OnClick = btnGetTempINClick
  end
  object btnServReady: TButton
    Left = 304
    Top = 352
    Width = 121
    Height = 25
    Caption = #1055#1086#1083#1091#1095#1080#1090#1100' '#1074#1083#1086#1078#1077#1085#1080#1077
    TabOrder = 23
    OnClick = btnServReadyClick
  end
  object btnCursWait: TButton
    Left = 656
    Top = 707
    Width = 121
    Height = 25
    Caption = 'Wait-Cursor'
    TabOrder = 24
    OnClick = btnCursWaitClick
  end
  object btnCursNorm: TButton
    Left = 800
    Top = 707
    Width = 121
    Height = 25
    Caption = 'JavaDT->Delphi'
    TabOrder = 25
    OnClick = btnCursNormClick
  end
  object edJavaDate: TDBEditEh
    Left = 936
    Top = 710
    Width = 121
    Height = 21
    EditButtons = <>
    TabOrder = 26
    Text = '1628629200000'
    Visible = True
  end
  object btnGetINsOnly: TButton
    Left = 16
    Top = 171
    Width = 121
    Height = 25
    Caption = #1055#1086#1083#1091#1095#1080#1090#1100' '#1090#1086#1082#1077#1085' AUTH'
    TabOrder = 27
    OnClick = btnGetINsOnlyClick
  end
  object cbINsOnly: TDBCheckBoxEh
    Left = 1080
    Top = 712
    Width = 121
    Height = 17
    Caption = #1058#1086#1083#1100#1082#1086' '#1048#1053
    TabOrder = 28
    ValueChecked = 'True'
    ValueUnchecked = 'False'
  end
  object btnGetNsiRSMDO: TButton
    Left = 160
    Top = 172
    Width = 119
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1089#1087#1088#1072#1074#1086#1095#1085#1080#1082
    TabOrder = 29
    OnClick = btnGetNsiRSMDOClick
  end
  object DataSource1: TDataSource
    Left = 664
    Top = 74
  end
  object dsDocs: TDataSource
    Left = 592
    Top = 309
  end
  object dsChild: TDataSource
    Left = 648
    Top = 469
  end
  object dsNsi: TDataSource
    Left = 633
    Top = 633
  end
  object cnctNsi: TAdsConnection
    ConnectPath = 'D:\App\'#1051#1040#1048#1057#1095'\Spr\ROC\'
    AdsServerTypes = [stADS_LOCAL]
    LoginPrompt = False
    Username = 'ADSSYS'
    Password = 'sysdba'
    AdsCollation = 'ANSI:ru_RU_ADS_CI'
    Left = 1183
    Top = 9
  end
end
