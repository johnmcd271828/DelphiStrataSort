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
    Panel2: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    IntegerItemCheckBox: TCheckBox;
    StringItemCheckBox: TCheckBox;
    IntegerRecordCheckBox: TCheckBox;
    StringRecordCheckBox: TCheckBox;
    ObjectItemCheckBox: TCheckBox;
    InterfaceItemCheckBox: TCheckBox;
    Panel4: TPanel;
    Label3: TLabel;
    RandomListCheckBox: TCheckBox;
    SortedListCheckBox: TCheckBox;
    ReversedListCheckBox: TCheckBox;
    AlmostSortedCheckBox: TCheckBox;
    FourValueListCheckBox: TCheckBox;
    Panel5: TPanel;
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
    Panel7: TPanel;
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
    procedure WriteSpeedResultsToFile(const FileName: string);

    function  MakeCountingCompare<T>(const CompareFn: TComparison<T>;
                                     out GetCompareCount: TFunc<Int64>): TComparison<T>;

    procedure StrataSortProc<T>(const List: TList<T>;
                                const CompareFn: TComparison<T>);
    procedure QuickSortProc<T>(const List: TList<T>;
                               const CompareFn: TComparison<T>);

    procedure TestBigLists<T>(const ListSize: Integer;
                              const CreateItemFn: TCreateItemFn<T>;
                              const CreateListFn: TCreateListFn<T>;
                              const CompareFn: TComparison<T>;
                              const SortCheckProc: TSortCheckProc<T>;
                              const LoadListProc: TLoadListProc<T>;
                              const ListDescription: string;
                              const SortProc: TSortProc<T>;
                              const SortDescription: string;
                              const StableSort: Boolean); overload;
    procedure TestBigLists<T>(const ListSize: Integer;
                              const CreateItemFn: TCreateItemFn<T>;
                              const CreateListFn: TCreateListFn<T>;
                              const CompareFn: TComparison<T>;
                              const SortCheckProc: TSortCheckProc<T>;
                              const LoadListProc: TLoadListProc<T>;
                              const ListDescription: string);  overload;
    procedure TestBigLists<T>(const ListSize: Integer;
                              const CreateItemFn: TCreateItemFn<T>;
                              const CreateListFn: TCreateListFn<T>;
                              const CompareFn: TComparison<T>;
                              const SortCheckProc: TSortCheckProc<T>); overload;
    procedure TestBigLists(const ListSize: Integer); overload;
    procedure TestBigLists(const ListSizeList: TList<Integer>); overload;
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
  TStrataSort<T>.Sort(List, CompareFn);
end;

procedure TSortSpeedTestForm.QuickSortProc<T>(const List: TList<T>;
                                              const CompareFn: TComparison<T>);
begin
  List.Sort(TComparer<T>.Construct(CompareFn));
end;


procedure TSortSpeedTestForm.TestBigLists<T>(const ListSize: Integer;
                                             const CreateItemFn: TCreateItemFn<T>;
                                             const CreateListFn: TCreateListFn<T>;
                                             const CompareFn: TComparison<T>;
                                             const SortCheckProc: TSortCheckProc<T>;
                                             const LoadListProc: TLoadListProc<T>;
                                             const ListDescription: string;
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
    LoadListProc(CreateItemFn, List, ListSize);
    CountingCompareFn := MakeCountingCompare<T>(CompareFn, GetCompareCount);

    StopWatch := TStopWatch.StartNew;
    SortProc(List, CountingCompareFn);
    StopWatch.Stop;
    Display(SortDescription + '. ' +
            ListDescription  + ' of ' + IntToStr(ListSize) + ' ' +
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

procedure TSortSpeedTestForm.TestBigLists<T>(const ListSize: Integer;
                                             const CreateItemFn: TCreateItemFn<T>;
                                             const CreateListFn: TCreateListFn<T>;
                                             const CompareFn: TComparison<T>;
                                             const SortCheckProc: TSortCheckProc<T>;
                                             const LoadListProc: TLoadListProc<T>;
                                             const ListDescription: string);
begin
  if StrataSortCheckBox.Checked then
    TestBigLists<T>(ListSize, CreateItemFn, CreateListFn, CompareFn, SortCheckProc,
                    LoadListProc, ListDescription,
                    StrataSortProc<T>, 'StrataSort', True);
  if QuickSortCheckBox.Checked then
    TestBigLists<T>(ListSize, CreateItemFn, CreateListFn, CompareFn, SortCheckProc,
                    LoadListProc, ListDescription,
                    QuickSortProc<T>, 'QuickSort', False);
end;

procedure TSortSpeedTestForm.TestBigLists<T>(const ListSize: Integer;
                                             const CreateItemFn: TCreateItemFn<T>;
                                             const CreateListFn: TCreateListFn<T>;
                                             const CompareFn: TComparison<T>;
                                             const SortCheckProc: TSortCheckProc<T>);
begin
  if RandomListCheckBox.Checked then
    TestBigLists<T>(ListSize, CreateItemFn, CreateListFn, CompareFn, SortCheckProc,
                    TTestAssistant.LoadRandomList<T>, 'Random List');
  if SortedListCheckBox.Checked then
    TestBigLists<T>(ListSize, CreateItemFn, CreateListFn, CompareFn, SortCheckProc,
                    TTestAssistant.LoadSortedList<T>, 'Sorted List');
  if ReversedListCheckBox.Checked then
    TestBigLists<T>(ListSize, CreateItemFn, CreateListFn, CompareFn, SortCheckProc,
                    TTestAssistant.LoadReversedList<T>, 'Reversed List');
  if AlmostSortedCheckBox.Checked then
    TestBigLists<T>(ListSize, CreateItemFn, CreateListFn, CompareFn, SortCheckProc,
                    TTestAssistant.LoadAlmostSortedList<T>, 'Almost Sorted List');
  if FourValueListCheckBox.Checked then
    TestBigLists<T>(ListSize, CreateItemFn, CreateListFn, CompareFn, SortCheckProc,
                    TTestAssistant.LoadFourValueList<T>, 'Four Value List');
end;

procedure TSortSpeedTestForm.TestBigLists(const ListSize: Integer);
begin
  if IntegerItemCheckBox.Checked then
    TestBigLists<Integer>(ListSize,
                          TTestAssistant.CreateIntegerTestItem,
                          TTestAssistant.CreateTList<Integer>,
                          TTestAssistant.CompareInteger,
                          TTestAssistant.IntegerSortCheck);
  if StringItemCheckBox.Checked then
    TestBigLists<string>(ListSize,
                         TTestAssistant.CreateStringTestItem,
                         TTestAssistant.CreateTList<string>,
                         CompareText,
                         TTestAssistant.StringSortCheck);
  if IntegerRecordCheckBox.Checked then
    TestBigLists<TTestIntegerRecord>(ListSize,
                                     TTestIntegerRecord.CreateTestItem,
                                     TTestAssistant.CreateTList<TTestIntegerRecord>,
                                     TTestIntegerRecord.Compare,
                                     TTestIntegerRecord.SortCheck);
  if StringRecordCheckBox.Checked then
    TestBigLists<TTestStringRecord>(ListSize,
                                    TTestStringRecord.CreateTestItem,
                                    TTestAssistant.CreateTList<TTestStringRecord>,
                                    TTestStringRecord.Compare,
                                    TTestStringRecord.SortCheck);
  if ObjectItemCheckBox.Checked then
    TestBigLists<TTestObject>(ListSize,
                              TTestObject.CreateTestItem,
                              TTestAssistant.CreateTObjectList<TTestObject>,
                              TTestObject.Compare,
                              TTestObject.SortCheck);
  if InterfaceItemCheckBox.Checked then
    TestBigLists<ITestInterface>(ListSize,
                                 TTestInterfaceObject.CreateTestItem,
                                 TTestAssistant.CreateTList<ITestInterface>,
                                 TTestInterfaceObject.Compare,
                                 TTestInterfaceObject.SortCheck);
end;

procedure TSortSpeedTestForm.TestBigLists(const ListSizeList: TList<Integer>);
var
  ListSize: Integer;
begin
  Display('Start SpeedTest');
  try
    for ListSize in ListSizeList do
      TestBigLists(ListSize);
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
      TestBigLists(ListSizeList);

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
