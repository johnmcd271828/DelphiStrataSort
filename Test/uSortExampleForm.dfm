object SortExampleForm: TSortExampleForm
  Left = 0
  Top = 0
  Caption = 'Sort Test'
  ClientHeight = 518
  ClientWidth = 641
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
    Width = 641
    Height = 463
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
    WordWrap = False
    ExplicitWidth = 528
    ExplicitHeight = 419
  end
  object ButtonPanel: TPanel
    Left = 0
    Top = 463
    Width = 641
    Height = 55
    Align = alBottom
    TabOrder = 0
    ExplicitLeft = 8
    ExplicitTop = 419
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
      Left = 455
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Shuffle'
      TabOrder = 4
      OnClick = ShuffleButtonClick
    end
    object ClearButton: TButton
      Left = 536
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Clear'
      TabOrder = 5
      OnClick = ClearButtonClick
    end
    object SortedEnumeratorButton: TButton
      Left = 335
      Top = 16
      Width = 113
      Height = 25
      Caption = 'Sorted Enumerator'
      TabOrder = 3
      OnClick = SortedEnumeratorButtonClick
    end
  end
end
