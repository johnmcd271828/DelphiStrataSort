object SortTestForm: TSortTestForm
  Left = 0
  Top = 0
  Caption = 'Sort Test'
  ClientHeight = 474
  ClientWidth = 528
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object MemoBox: TMemo
    Left = 0
    Top = 0
    Width = 528
    Height = 419
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Pitch = fpFixed
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object ButtonPanel: TPanel
    Left = 0
    Top = 419
    Width = 528
    Height = 55
    Align = alBottom
    TabOrder = 0
    object LoadButton: TButton
      Left = 16
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Load'
      TabOrder = 0
      OnClick = LoadButtonClick
    end
    object SortAlphabeticallyButton: TButton
      Left = 97
      Top = 16
      Width = 113
      Height = 25
      Caption = 'Sort Alphabetically'
      TabOrder = 1
      OnClick = SortAlphabeticallyButtonClick
    end
    object SortByLengthButton: TButton
      Left = 216
      Top = 16
      Width = 113
      Height = 25
      Caption = 'Sort By Length'
      TabOrder = 2
      OnClick = SortByLengthButtonClick
    end
    object ShuffleButton: TButton
      Left = 335
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Shuffle'
      TabOrder = 3
      OnClick = ShuffleButtonClick
    end
    object ClearButton: TButton
      Left = 416
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 4
      OnClick = ClearButtonClick
    end
  end
end
