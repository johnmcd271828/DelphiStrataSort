object SortSpeedTestForm: TSortSpeedTestForm
  Left = 0
  Top = 0
  Caption = 'Sort Speed Test'
  ClientHeight = 557
  ClientWidth = 934
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 934
    Height = 193
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      934
      193)
    object ListSizePanel: TPanel
      Left = 0
      Top = 0
      Width = 185
      Height = 193
      Anchors = [akLeft, akTop, akBottom]
      TabOrder = 0
      DesignSize = (
        185
        193)
      object Label1: TLabel
        Left = 12
        Top = 12
        Width = 64
        Height = 18
        Caption = 'List Size'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ListSizeMemoBox: TMemo
        Left = 12
        Top = 40
        Width = 157
        Height = 137
        Anchors = [akLeft, akTop, akRight, akBottom]
        Lines.Strings = (
          '12000'
          '120000'
          '1200000')
        TabOrder = 0
      end
    end
    object ItemTypePanel: TPanel
      Left = 370
      Top = 0
      Width = 185
      Height = 193
      Anchors = [akLeft, akTop, akBottom]
      TabOrder = 2
      object Label2: TLabel
        Left = 12
        Top = 12
        Width = 80
        Height = 18
        Caption = 'Item Type:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object IntegerItemCheckBox: TCheckBox
        Left = 12
        Top = 40
        Width = 150
        Height = 18
        Caption = 'Integer'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object StringItemCheckBox: TCheckBox
        Left = 12
        Top = 64
        Width = 150
        Height = 17
        Caption = 'String'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
      object IntegerRecordCheckBox: TCheckBox
        Left = 12
        Top = 88
        Width = 150
        Height = 17
        Caption = 'Integer Record'
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
      object StringRecordCheckBox: TCheckBox
        Left = 12
        Top = 112
        Width = 150
        Height = 17
        Caption = 'String Record'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object ObjectItemCheckBox: TCheckBox
        Left = 12
        Top = 136
        Width = 150
        Height = 17
        Caption = 'Object'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object InterfaceItemCheckBox: TCheckBox
        Left = 12
        Top = 160
        Width = 150
        Height = 17
        Caption = 'Interface'
        Checked = True
        State = cbChecked
        TabOrder = 5
      end
      object ItemTypeAllButton: TButton
        Left = 136
        Top = 10
        Width = 43
        Height = 25
        Caption = 'All'
        TabOrder = 6
        OnClick = ItemTypeAllButtonClick
      end
      object ItemTypeClearButton: TButton
        Left = 134
        Top = 160
        Width = 43
        Height = 25
        Caption = 'Clear'
        TabOrder = 7
        OnClick = ItemTypeClearButtonClick
      end
    end
    object ListSequencePanel: TPanel
      Left = 185
      Top = 0
      Width = 185
      Height = 193
      Anchors = [akLeft, akTop, akBottom]
      TabOrder = 1
      object Label3: TLabel
        Left = 12
        Top = 12
        Width = 33
        Height = 18
        Caption = 'List:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object RandomListCheckBox: TCheckBox
        Left = 12
        Top = 40
        Width = 150
        Height = 18
        Caption = 'Random List'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object SortedListCheckBox: TCheckBox
        Left = 12
        Top = 64
        Width = 150
        Height = 17
        Caption = 'Sorted List'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
      object ReversedListCheckBox: TCheckBox
        Left = 12
        Top = 88
        Width = 150
        Height = 17
        Caption = 'Reversed List'
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
      object AlmostSortedCheckBox: TCheckBox
        Left = 12
        Top = 112
        Width = 150
        Height = 17
        Caption = 'Almost Sorted List'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object FourValueListCheckBox: TCheckBox
        Left = 12
        Top = 136
        Width = 150
        Height = 17
        Caption = 'Four Value List'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object ListTypeAllButton: TButton
        Left = 136
        Top = 10
        Width = 43
        Height = 25
        Caption = 'All'
        TabOrder = 5
        OnClick = ListTypeAllButtonClick
      end
      object ListTypeClearButton: TButton
        Left = 134
        Top = 160
        Width = 43
        Height = 25
        Caption = 'Clear'
        TabOrder = 6
        OnClick = ListTypeClearButtonClick
      end
    end
    object SortTypePanel: TPanel
      Left = 555
      Top = 0
      Width = 185
      Height = 193
      Anchors = [akLeft, akTop, akBottom]
      TabOrder = 3
      object Label4: TLabel
        Left = 12
        Top = 12
        Width = 77
        Height = 18
        Caption = 'Sort Type:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object StrataSortCheckBox: TCheckBox
        Left = 12
        Top = 40
        Width = 150
        Height = 18
        Caption = 'StrataSort'
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object QuickSortCheckBox: TCheckBox
        Left = 12
        Top = 64
        Width = 150
        Height = 17
        Caption = 'QuickSort'
        Checked = True
        State = cbChecked
        TabOrder = 1
      end
      object SortTypeAllButton: TButton
        Left = 134
        Top = 10
        Width = 43
        Height = 25
        Caption = 'All'
        TabOrder = 2
        OnClick = SortTypeAllButtonClick
      end
      object SortTypeClearButton: TButton
        Left = 134
        Top = 160
        Width = 43
        Height = 25
        Caption = 'Clear'
        TabOrder = 3
        OnClick = SortTypeClearButtonClick
      end
    end
    object PlatformPanel: TPanel
      Left = 740
      Top = 0
      Width = 193
      Height = 193
      Anchors = [akLeft, akTop, akBottom]
      TabOrder = 4
      object Label5: TLabel
        Left = 6
        Top = 12
        Width = 93
        Height = 18
        Caption = 'Exe Platform: '
      end
      object ExePlatformDisplay: TLabel
        Left = 100
        Top = 12
        Width = 44
        Height = 18
        Caption = 'XX bit'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object Panel6: TPanel
    Left = 0
    Top = 508
    Width = 934
    Height = 49
    Align = alBottom
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object RunButton: TButton
      Left = 16
      Top = 10
      Width = 75
      Height = 28
      Caption = 'Run'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = RunButtonClick
    end
    object WriteResultsButton: TButton
      Left = 108
      Top = 10
      Width = 169
      Height = 28
      Caption = 'Write Results to File'
      TabOrder = 1
      OnClick = WriteResultsButtonClick
    end
    object ClearButton: TButton
      Left = 295
      Top = 10
      Width = 75
      Height = 28
      Caption = 'Clear'
      TabOrder = 2
      OnClick = ClearButtonClick
    end
  end
  object ResultsMemoBox: TMemo
    Left = 0
    Top = 193
    Width = 934
    Height = 315
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
end
