// Copyright: John McDonald 2020
//

unit uSortSpeedTest;

interface

uses
  System.SysUtils, System.Classes, System.Diagnostics, System.UITypes, StrUtils,
  Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Graphics,
  Vcl.ExtCtrls, Generics.Defaults, Generics.Collections,
  StrataSort, uSortTestTypes;

type
  TSortSpeedTestForm = class(TForm)
    Panel1: TPanel;
    ListSizePanel: TPanel;
    ItemTypePanel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    IntegerItemCheckBox: TCheckBox;
    StringItemCheckBox: TCheckBox;
    IntegerRecordCheckBox: TCheckBox;
    StringRecordCheckBox: TCheckBox;
    ObjectItemCheckBox: TCheckBox;
    InterfaceItemCheckBox: TCheckBox;
    ListSequencePanel: TPanel;
    Label3: TLabel;
    RandomListCheckBox: TCheckBox;
    SortedListCheckBox: TCheckBox;
    ReversedListCheckBox: TCheckBox;
    AlmostSortedCheckBox: TCheckBox;
    FourValueListCheckBox: TCheckBox;
    SortTypePanel: TPanel;
    Label4: TLabel;
    StrataSortCheckBox: TCheckBox;
    QuickSortCheckBox: TCheckBox;
    ListSizeMemoBox: TMemo;
    Panel6: TPanel;
    RunButton: TButton;
    ResultsMemoBox: TMemo;
    ItemTypeAllButton: TButton;
    ItemTypeClearButton: TButton;
    ListTypeAllButton: TButton;
    ListTypeClearButton: TButton;
    SortTypeAllButton: TButton;
    SortTypeClearButton: TButton;
    WriteResultsButton: TButton;
    ClearButton: TButton;
    PlatformPanel: TPanel;
    Label5: TLabel;
    ExePlatformDisplay: TLabel;
    procedure ItemTypeAllButtonClick(Sender: TObject);
    procedure ItemTypeClearButtonClick(Sender: TObject);
    procedure ListTypeAllButtonClick(Sender: TObject);
    procedure ListTypeClearButtonClick(Sender: TObject);
    procedure SortTypeAllButtonClick(Sender: TObject);
    procedure SortTypeClearButtonClick(Sender: TObject);
    procedure RunButtonClick(Sender: TObject);
    procedure WriteResultsButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
  private
    const TAB: Char = #09;    // This can't be a local if it is referenced in a generic method.
  private
    SpeedResults: TList<string>;
    procedure Display(const Msg: string);
    procedure DisplayUserError(const Msg: string;
                               const Control: TWinControl = nil);
    function  FormatElapsedTime(const StopWatch: TStopWatch): string;
    function  FormatListSize(const ListSize: Integer): string;
    procedure WriteSpeedResultsToFile(const FileName: string);

    function  MakeCountingCompare<T>(const CompareFn: TComparison<T>;
                                     out GetCompareCount: TFunc<Int64>): TComparison<T>;

    procedure StrataSortProc<T>(const List: TList<T>;
                                const CompareFn: TComparison<T>);
    procedure QuickSortProc<T>(const List: TList<T>;
                               const CompareFn: TComparison<T>);

    procedure TestListSort<T>(const ListSize: Integer;
                              const GenerateListValues: TGenerateListValuesProc;
                              const ListDescription: string;
                              const CreateItemFn: TCreateItemFn<T>;
                              const CreateListFn: TCreateListFn<T>;
                              const CompareFn: TComparison<T>;
                              const SortCheckProc: TSortCheckProc<T>;
                              const SortProc: TSortProc<T>;
                              const SortDescription: string;
                              const StableSort: Boolean); overload;
    procedure TestListSort<T>(const ListSize: Integer;
                              const GenerateListValues: TGenerateListValuesProc;
                              const ListDescription: string;
                              const CreateItemFn: TCreateItemFn<T>;
                              const CreateListFn: TCreateListFn<T>;
                              const CompareFn: TComparison<T>;
                              const SortCheckProc: TSortCheckProc<T>); overload;
    procedure TestListSort(const ListSize: Integer;
                           const GenerateListValues: TGenerateListValuesProc;
                           const ListDescription: string); overload;
    procedure TestListSort(const ListSize: Integer); overload;
    procedure TestListSort(const ListSizeList: TList<Integer>); overload;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  end;

var
  SortSpeedTestForm: TSortSpeedTestForm;

implementation

uses TypInfo;

{$R *.dfm}

procedure TSortSpeedTestForm.Display(const Msg: string);
begin
  ResultsMemoBox.Lines.Add(Msg);
end;

procedure TSortSpeedTestForm.DisplayUserError(const Msg: string;
                                              const Control: TWinControl = nil);
begin
  if Assigned(Control) and
     Control.CanFocus then
    Control.SetFocus;
  MessageDlg(Msg, mtError, [mbOk], 0);
end;

function TSortSpeedTestForm.FormatElapsedTime(const StopWatch: TStopWatch): string;
begin
  Result := Format('%.3n', [StopWatch.Elapsed.TotalSeconds]) + ' seconds';
end;

function TSortSpeedTestForm.FormatListSize(const ListSize: Integer): string;
begin
  // To get thousands separators, we need to convert ListSize to a double, and use %.0n formatting.
  Result := Format('%.0n', [ListSize + 0.0]);
end;

procedure TSortSpeedTestForm.WriteSpeedResultsToFile(const FileName: string);
var
  FileStream: TStream;
  StreamWriter: TStreamWriter;
  ResultsLine: string;
begin
  FileStream := TFileStream.Create(FileName,(fmCreate or fmShareExclusive));
  try
    StreamWriter := TStreamWriter.Create(FileStream, TEncoding.UTF8);
    try
      for ResultsLine in SpeedResults do
        StreamWriter.WriteLine(ResultsLine);
    finally
      StreamWriter.Free;
    end;
  finally
    FileStream.Free;
  end;
end;

function TSortSpeedTestForm.MakeCountingCompare<T>(const CompareFn: TComparison<T>;
                                                   out GetCompareCount: TFunc<Int64>): TComparison<T>;
var
  CompareCount: Int64;
begin
  CompareCount := 0;
  GetCompareCount := function: Int64
                     begin
                       Result := CompareCount;
                     end;
  Result := function(const Left, Right: T): Integer
            begin
              Inc(CompareCount);
              Result := CompareFn(Left, Right);
            end;
end;

procedure TSortSpeedTestForm.StrataSortProc<T>(const List: TList<T>;
                                               const CompareFn: TComparison<T>);
begin
  TStrataSort.Sort<T>(List, CompareFn);
end;

procedure TSortSpeedTestForm.QuickSortProc<T>(const List: TList<T>;
                                              const CompareFn: TComparison<T>);
begin
  List.Sort(TComparer<T>.Construct(CompareFn));
end;


procedure TSortSpeedTestForm.TestListSort<T>(const ListSize: Integer;
                                             const GenerateListValues: TGenerateListValuesProc;
                                             const ListDescription: string;
                                             const CreateItemFn: TCreateItemFn<T>;
                                             const CreateListFn: TCreateListFn<T>;
                                             const CompareFn: TComparison<T>;
                                             const SortCheckProc: TSortCheckProc<T>;
                                             const SortProc: TSortProc<T>;
                                             const SortDescription: string;
                                             const StableSort: Boolean);
var
  List: TList<T>;
  GetCompareCount: TFunc<Int64>;
  CountingCompareFn: TComparison<T>;
  StopWatch: TStopWatch;
begin
  List := CreateListFn;
  try
    TTestAssistant.LoadList<T>(GenerateListValues, CreateItemFn, List, ListSize);
    CountingCompareFn := MakeCountingCompare<T>(CompareFn, GetCompareCount);

    StopWatch := TStopWatch.StartNew;
    SortProc(List, CountingCompareFn);
    StopWatch.Stop;
    Display(SortDescription + '. ' +
            ListDescription  + ' of ' + FormatListSize(ListSize) + ' ' +
            GetTypeName(TypeInfo(T)) + ' Items in ' +
            FormatElapsedTime(StopWatch) + '.   ' +
            IntToStr(GetCompareCount) + ' compares.');
    SpeedResults.Add(SortDescription + TAB +
                     ListDescription  + TAB + IntToStr(ListSize) + TAB +
                     GetTypeName(TypeInfo(T)) + TAB +
                     Format('%g', [StopWatch.Elapsed.TotalSeconds]) + TAB +
                     IntToStr(GetCompareCount) + TAB +
                     IntToStr(SizeOf(Pointer) * 8));
    if Assigned(SortCheckProc) then
      SortCheckProc(List, ListSize, CompareFn, StableSort)
    else if List.Count <> ListSize then
      raise ESortTestError.Create('SortCheck Count Error: List.Count = ' + IntToStr(List.Count) +
                                  ', ListSize = ' + IntToStr(ListSize));
  finally
    List.Free;
  end;
end;

procedure TSortSpeedTestForm.TestListSort<T>(const ListSize: Integer;
                                             const GenerateListValues: TGenerateListValuesProc;
                                             const ListDescription: string;
                                             const CreateItemFn: TCreateItemFn<T>;
                                             const CreateListFn: TCreateListFn<T>;
                                             const CompareFn: TComparison<T>;
                                             const SortCheckProc: TSortCheckProc<T>);
begin
  if StrataSortCheckBox.Checked then
    TestListSort<T>(ListSize,
                    GenerateListValues, ListDescription,
                    CreateItemFn, CreateListFn, CompareFn, SortCheckProc,
                    StrataSortProc<T>, 'StrataSort', True);
  if QuickSortCheckBox.Checked then
    TestListSort<T>(ListSize,
                    GenerateListValues, ListDescription,
                    CreateItemFn, CreateListFn, CompareFn, SortCheckProc,
                    QuickSortProc<T>, 'QuickSort', False);
end;

procedure TSortSpeedTestForm.TestListSort(const ListSize: Integer;
                                          const GenerateListValues: TGenerateListValuesProc;
                                          const ListDescription: string);
begin
  if IntegerItemCheckBox.Checked then
    TestListSort<Integer>(ListSize,
                          GenerateListValues,
                          ListDescription,
                          TTestAssistant.CreateIntegerTestItem,
                          TTestAssistant.CreateTList<Integer>,
                          TTestAssistant.CompareInteger,
                          TTestAssistant.IntegerSortCheck);
  if StringItemCheckBox.Checked then
    TestListSort<string>(ListSize,
                         GenerateListValues,
                         ListDescription,
                         TTestAssistant.CreateStringTestItem,
                         TTestAssistant.CreateTList<string>,
                         CompareText,
                         TTestAssistant.StringSortCheck);
  if IntegerRecordCheckBox.Checked then
    TestListSort<TTestIntegerRecord>(ListSize,
                                     GenerateListValues,
                                     ListDescription,
                                     TTestIntegerRecord.CreateTestItem,
                                     TTestAssistant.CreateTList<TTestIntegerRecord>,
                                     TTestIntegerRecord.Compare,
                                     TTestIntegerRecord.SortCheck);
  if StringRecordCheckBox.Checked then
    TestListSort<TTestStringRecord>(ListSize,
                                    GenerateListValues,
                                    ListDescription,
                                    TTestStringRecord.CreateTestItem,
                                    TTestAssistant.CreateTList<TTestStringRecord>,
                                    TTestStringRecord.Compare,
                                    TTestStringRecord.SortCheck);
  if ObjectItemCheckBox.Checked then
    TestListSort<TTestObject>(ListSize,
                              GenerateListValues,
                              ListDescription,
                              TTestObject.CreateTestItem,
                              TTestAssistant.CreateTObjectList<TTestObject>,
                              TTestObject.Compare,
                              TTestObject.SortCheck);
  if InterfaceItemCheckBox.Checked then
    TestListSort<ITestInterface>(ListSize,
                                 GenerateListValues,
                                 ListDescription,
                                 TTestInterfaceObject.CreateTestItem,
                                 TTestAssistant.CreateTList<ITestInterface>,
                                 TTestInterfaceObject.Compare,
                                 TTestInterfaceObject.SortCheck);
end;

procedure TSortSpeedTestForm.TestListSort(const ListSize: Integer);
begin
  if RandomListCheckBox.Checked then
    TestListSort(ListSize, TTestAssistant.RandomListValues, 'Random List');
  if SortedListCheckBox.Checked then
    TestListSort(ListSize, TTestAssistant.SortedListValues, 'Sorted List');
  if ReversedListCheckBox.Checked then
    TestListSort(ListSize, TTestAssistant.ReversedListValues, 'Reversed List');
  if AlmostSortedCheckBox.Checked then
    TestListSort(ListSize, TTestAssistant.AlmostSortedListValues, 'Almost Sorted List');
  if FourValueListCheckBox.Checked then
    TestListSort(ListSize, TTestAssistant.FourValueListValues, 'Four Value List');
end;

procedure TSortSpeedTestForm.TestListSort(const ListSizeList: TList<Integer>);
var
  ListSize: Integer;
begin
  Display('Start SpeedTest');
  try
    for ListSize in ListSizeList do
      TestListSort(ListSize);
  except
    on E: Exception do
    begin
      Display('SpeedTest Exception ' + E.ClassName + ': ' + E.Message);
    end;
  end;
  Display('End of SpeedTest');
end;

constructor TSortSpeedTestForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SpeedResults := TList<string>.Create;
  ExePlatformDisplay.Caption := IntToStr(SizeOf(Pointer) * 8) + ' bit.';
end;

destructor TSortSpeedTestForm.Destroy;
begin
  FreeAndNil(SpeedResults);
  inherited Destroy;
end;

{ Event Handlers }

procedure TSortSpeedTestForm.ItemTypeAllButtonClick(Sender: TObject);
begin
  IntegerItemCheckBox.Checked := True;
  StringItemCheckBox.Checked := True;
  IntegerRecordCheckBox.Checked := True;
  StringRecordCheckBox.Checked := True;
  ObjectItemCheckBox.Checked := True;
  InterfaceItemCheckBox.Checked := True;
end;

procedure TSortSpeedTestForm.ItemTypeClearButtonClick(Sender: TObject);
begin
  IntegerItemCheckBox.Checked := False;
  StringItemCheckBox.Checked := False;
  IntegerRecordCheckBox.Checked := False;
  StringRecordCheckBox.Checked := False;
  ObjectItemCheckBox.Checked := False;
  InterfaceItemCheckBox.Checked := False;
end;

procedure TSortSpeedTestForm.ListTypeAllButtonClick(Sender: TObject);
begin
  RandomListCheckBox.Checked := True;
  SortedListCheckBox.Checked := True;
  ReversedListCheckBox.Checked := True;
  AlmostSortedCheckBox.Checked := True;
  FourValueListCheckBox.Checked := True;
end;

procedure TSortSpeedTestForm.ListTypeClearButtonClick(Sender: TObject);
begin
  RandomListCheckBox.Checked := False;
  SortedListCheckBox.Checked := False;
  ReversedListCheckBox.Checked := False;
  AlmostSortedCheckBox.Checked := False;
  FourValueListCheckBox.Checked := False;
end;

procedure TSortSpeedTestForm.SortTypeAllButtonClick(Sender: TObject);
begin
  StrataSortCheckBox.Checked := True;
  QuickSortCheckBox.Checked := True;
end;

procedure TSortSpeedTestForm.SortTypeClearButtonClick(Sender: TObject);
begin
  StrataSortCheckBox.Checked := False;
  QuickSortCheckBox.Checked := False;
end;

procedure TSortSpeedTestForm.RunButtonClick(Sender: TObject);
var
  ListSizeList: TList<Integer>;
  ListSizeStr: string;
  ListSize: Integer;
  ListSizeError: Boolean;
begin
  ListSizeList := TList<Integer>.Create;
  try
    ListSizeError := False;
    for ListSizeStr in ListSizeMemoBox.Lines do
    begin
      if ( Trim(ListSizeStr) <> '' ) then
      begin
        ListSize := StrToIntDef(Trim(ListSizeStr), -1);
        if ListSize >= 0 then
          ListSizeList.Add(ListSize)
        else
          ListSizeError := True;
      end;
    end;

    if ListSizeError then
      DisplayUserError('Invalid List Size.', ListSizeMemoBox)
    else if ListSizeList.Count = 0 then
      DisplayUserError('At least one List Size must be entered.', ListSizeMemoBox)
    else if not ( IntegerItemCheckBox.Checked or
                  StringItemCheckBox.Checked or
                  IntegerRecordCheckBox.Checked or
                  StringRecordCheckBox.Checked or
                  ObjectItemCheckBox.Checked or
                  InterfaceItemCheckBox.Checked ) then
      DisplayUserError('At least one Item Type must be selected', IntegerItemCheckBox)
    else if not ( RandomListCheckBox.Checked or
                  SortedListCheckBox.Checked or
                  ReversedListCheckBox.Checked or
                  AlmostSortedCheckBox.Checked or
                  FourValueListCheckBox.Checked ) then
      DisplayUserError('At least one List Type must be selected', RandomListCheckBox)
    else if not ( StrataSortCheckBox.Checked or
                  QuickSortCheckBox.Checked ) then
      DisplayUserError('At least one Sort Type must be selected', StrataSortCheckBox)
    else
      TestListSort(ListSizeList);

  finally
    ListSizeList.Free;
  end;
end;

procedure TSortSpeedTestForm.WriteResultsButtonClick(Sender: TObject);
var
  SaveDialog: TSaveDialog;
begin
  if SpeedResults.Count < 1 then
    MessageDlg('No results to output', mtError, [mbOk], 0)
  else
  begin
    SaveDialog:=TSaveDialog.Create(nil);
    try
      SaveDialog.Title:='Save Results to';
      SaveDialog.DefaultExt:='sortspeed';
      SaveDialog.Filter:='sortspeed file (*.sortspeed)|*.sortspeed|all files (*.*)|*.*';
      SaveDialog.FilterIndex:=1;
      SaveDialog.HelpContext:=0;
      SaveDialog.Options:=[ofOverwritePrompt, ofPathMustExist, ofHideReadOnly, ofNoReadOnlyReturn];
      SaveDialog.Filename:='';
      if SaveDialog.Execute then
      begin
        WriteSpeedResultsToFile(SaveDialog.FileName);
      end;
    finally
      SaveDialog.Free;
    end;
  end;
end;

procedure TSortSpeedTestForm.ClearButtonClick(Sender: TObject);
begin
  ResultsMemoBox.Clear;
  SpeedResults.Clear;
end;

end.
