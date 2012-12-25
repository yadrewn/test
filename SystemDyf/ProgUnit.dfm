object frmSysDyf: TfrmSysDyf
  Left = 244
  Top = 55
  Caption = 'SysDyf'
  ClientHeight = 554
  ClientWidth = 592
  Color = clActiveCaption
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 592
    Height = 554
    Align = alClient
    TabOrder = 1
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 590
      Height = 112
      Align = alTop
      TabOrder = 0
      Visible = False
    end
    object Memo2: TMemo
      Left = 1
      Top = 345
      Width = 590
      Height = 96
      Align = alBottom
      TabOrder = 2
      Visible = False
    end
    object Memo3: TMemo
      Left = 1
      Top = 113
      Width = 590
      Height = 232
      Align = alClient
      TabOrder = 1
      Visible = False
    end
    object Memo4: TMemo
      Left = 1
      Top = 441
      Width = 590
      Height = 112
      Align = alBottom
      TabOrder = 3
      Visible = False
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 592
    Height = 554
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 0
    object SynEdit: TSynEdit
      Left = 1
      Top = 1
      Width = 590
      Height = 412
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Lucida Sans Typewriter'
      Font.Pitch = fpFixed
      Font.Style = []
      TabOrder = 0
      Gutter.DigitCount = 2
      Gutter.Font.Charset = DEFAULT_CHARSET
      Gutter.Font.Color = clWindowText
      Gutter.Font.Height = -11
      Gutter.Font.Name = 'Courier New'
      Gutter.Font.Style = []
      Gutter.ShowLineNumbers = True
      Gutter.Width = 20
      Lines.Strings = (
        'program test1;'
        'given dxdt'
        'dxdt(1)=x(1)-5*x(2);'
        'dxdt(2)=2*x(1)-x(2);'
        'koef'
        'cauchy'
        'tspan=[0,1];'
        'h=0.1;'
        'x0=[0.5;-0.5]'
        'method'
        '>ode45;'
        '>euler;'
        'get'
        '>plot [x(1), x(2)];;'
        'end.')
      OnChange = SynEditChange
      FontSmoothing = fsmNone
    end
    object SynEdit2: TSynEdit
      Left = 1
      Top = 437
      Width = 590
      Height = 116
      Align = alBottom
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Lucida Console'
      Font.Style = []
      TabOrder = 2
      Gutter.Font.Charset = DEFAULT_CHARSET
      Gutter.Font.Color = clWindowText
      Gutter.Font.Height = -11
      Gutter.Font.Name = 'Courier New'
      Gutter.Font.Style = []
      ScrollBars = ssNone
      FontSmoothing = fsmNone
    end
    object Panel2: TPanel
      Left = 1
      Top = 413
      Width = 590
      Height = 24
      Align = alBottom
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHotLight
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object MainMenu1: TMainMenu
    Left = 268
    Top = 64
    object File1: TMenuItem
      Caption = 'File'
      object Open1: TMenuItem
        Caption = 'New'
        OnClick = Open1Click
      end
      object Open2: TMenuItem
        Caption = 'Open'
        OnClick = Open2Click
      end
      object Save1: TMenuItem
        Caption = 'Save as'
        OnClick = Save1Click
      end
      object Save2: TMenuItem
        Caption = 'Save'
        Enabled = False
        ShortCut = 32851
        OnClick = Save2Click
      end
    end
    object r1: TMenuItem
      Caption = 'Run'
      object miRun: TMenuItem
        Caption = 'Run'
        ShortCut = 120
        OnClick = miRunClick
      end
      object miViewGraph: TMenuItem
        Caption = 'View graph'
        ShortCut = 116
        OnClick = miViewGraphClick
      end
    end
  end
  object OpenDialog: TOpenDialog
    Filter = #1090#1077#1082#1089#1090#1086#1074#1099#1081'(*.txt)|*.txt;'
    Left = 268
    Top = 120
  end
  object SaveDialog: TSaveDialog
    Filter = #1090#1077#1082#1089#1090#1086#1074#1099#1081'(*.txt)|*.txt'
    Left = 268
    Top = 8
  end
end
