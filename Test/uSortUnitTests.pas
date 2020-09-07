unit uSortUnitTests;

//  Tests for class TStrataSort.
//  Most tests raise an exception when problems are found, so there are few explicit Checks.

interface

uses
  TestFramework, Generics.Defaults, Generics.Collections, SysUtils,
  StrataSort, uSortTestTypes;

type
  TSortUnitTests = class(TTestCase)
  strict private
    SequenceTestCount: Integer;
    procedure SequenceTest(const ValueArray: TArray<Integer>;
                           const Count: Integer);
  published
    procedure TestSortRecordListComparisonFn;
    procedure TestSortObjectListComparisonFn;
    procedure TestSortInterfaceListComparisonFn;
    procedure TestSortObjectListToObjectList;
    procedure TestSortInterfaceListToInterfaceListComparer;
    procedure TestReleaseSortReturn;
    procedure TestSequences;
  end;

implementation

uses Math, uSequenceGenerator;

{ TSortItem }

type
  TSortItem = record
    Key: Integer;
    Seq: Integer;
    constructor Create(const AKey: Integer;
                       const ASeq: Integer);
    class procedure SortCheck(const List: TList<TSortItem>;
                              const ListSize: Integer); static;
  end;

constructor TSortItem.Create(const AKey, ASeq: Integer);
begin
  Key := AKey;
  Seq := ASeq;
end;

function CompareSortItem(const S1, S2: TSortItem): Integer;
begin
  Result := CompareValue(S1.Key, S2.Key);
end;

class procedure TSortItem.SortCheck(const List: TList<TSortItem>;
                                    const ListSize: Integer);
var
  I: Integer;
  PrevKey: Integer;
  PrevSeq: Integer;
begin
  if List.Count <> ListSize then
  begin
    raise ESortTestError.Create('SortList.Count Error');
  end;

  PrevKey := Integer.MinValue;
  PrevSeq := Integer.MinValue;
  for I := 0 to ListSize - 1 do
  begin
    if ( PrevKey < List[I].Key ) or
       ( ( PrevKey = List[I].Key ) and
         ( PrevSeq < List[I].Seq ) )  then
    begin
      PrevKey := List[I].Key;
      PrevSeq := List[I].Seq;
    end
    else
    begin
      raise ESortError.Create('SortItem is out of order.');
    end;
  end;
end;

{ TSortUnitTests }

procedure TSortUnitTests.TestSortRecordListComparisonFn;
var
  List: TList<TTestIntegerRecord>;
const
  ListSize: Integer = 1000;
begin
  List := TList<TTestIntegerRecord>.Create;
  try
    TTestAssistant.LoadRandomList<TTestIntegerRecord>(TTestIntegerRecord.CreateTestItem, List, ListSize);
    TStrataSort<TTestIntegerRecord>.Sort(List, TTestIntegerRecord.Compare);
    TTestIntegerRecord.SortCheck(List, ListSize, True);
  finally
    List.Free;
  end;
end;

procedure TSortUnitTests.TestSortObjectListComparisonFn;
var
  List: TObjectList<TTestObject>;
const
  ListSize: Integer = 1000;
begin
  List := TObjectList<TTestObject>.Create;
  try
    TTestAssistant.LoadRandomList<TTestObject>(TTestObject.CreateTestItem, List, ListSize);
    TStrataSort<TTestObject>.Sort(List, TTestObject.Compare);
    TTestObject.SortCheck(List, ListSize, True);
  finally
    List.Free;
  end;
end;

procedure TSortUnitTests.TestSortInterfaceListComparisonFn;
var
  List: TList<ITestInterface>;
const
  ListSize: Integer = 1000;
begin
  List := TList<ITestInterface>.Create;
  try
    TTestAssistant.LoadRandomList<ITestInterface>(TTestInterfaceObject.CreateTestItem, List, ListSize);
    TStrataSort<ITestInterface>.Sort(List, TTestInterfaceObject.Compare);
    TTestInterfaceObject.SortCheck(List, ListSize, True);
  finally
    List.Free;
  end;
end;

procedure TSortUnitTests.TestSortObjectListToObjectList;
var
  SourceList: TObjectList<TTestObject>;
  DestinationList: TObjectList<TTestObject>;
const
  ListSize: Integer = 1000;
begin
  SourceList := TObjectList<TTestObject>.Create(True);
  try
    DestinationList := TObjectList<TTestObject>.Create(False);
    try
      TTestAssistant.LoadRandomList<TTestObject>(TTestObject.CreateTestItem, SourceList, ListSize);
      TStrataSort<TTestObject>.Sort(SourceList, DestinationList, TTestObject.Compare);
      TTestObject.SortCheck(DestinationList, ListSize, True);
    finally
      DestinationList.Free;
    end;
  finally
    SourceList.Free;
  end;
end;

procedure TSortUnitTests.TestSortInterfaceListToInterfaceListComparer;
var
  SourceList: TList<ITestInterface>;
  DestinationList: TList<ITestInterface>;
  SortComparer: IComparer<ITestInterface>;
const
  ListSize: Integer = 1000;
begin
  SourceList := TList<ITestInterface>.Create;
  try
    DestinationList := TList<ITestInterface>.Create;
    try
      TTestAssistant.LoadRandomList<ITestInterface>(TTestInterfaceObject.CreateTestItem, SourceList, ListSize);
      SortComparer := TComparer<ITestInterface>.Construct(TTestInterfaceObject.Compare);
      TStrataSort<ITestInterface>.Sort(SourceList, DestinationList, SortComparer);
      TTestInterfaceObject.SortCheck(DestinationList, ListSize, True);
    finally
      DestinationList.Free;
    end;
  finally
    SourceList.Free;
  end;
end;


procedure TSortUnitTests.TestReleaseSortReturn;
var
  Sorter: TStrataSort<TSortItem>;
  I: Integer;
  ReturnItem1: TSortItem;
  ReturnItem2: TSortItem;
begin
  Sorter := TStrataSort<TSortItem>.Create(CompareSortItem);
  try
    for I := 1 to 14 do
    begin
      Sorter.SortRelease(TSortItem.Create(I*5 mod 7, I));
    end;
    Sorter.RunSort;
    for I := 0 to 6 do
    begin
      Check(not Sorter.Eof, 'TestReleaseSortReturn premature Eof');
      ReturnItem1 := Sorter.SortReturn;
      CheckEquals(I, ReturnItem1.Key, 'ReturnItem1 Order Error');
      Check(not Sorter.Eof, 'TestReleaseSortReturn premature Eof');
      ReturnItem2 := Sorter.SortReturn;
      CheckEquals(I, ReturnItem2.Key, 'ReturnItem2 Order Error');
      Check(ReturnItem1.Seq < ReturnItem2.Seq, 'ReturnItem Sequence Error');
    end;
    Check(Sorter.Eof, 'TestReleaseSortReturn Eof expected.');
  finally
    Sorter.Free;
  end;
end;


procedure TSortUnitTests.SequenceTest(const ValueArray: TArray<Integer>;
                                      const Count: Integer);
var
  SortList: TList<TSortItem>;
  I: Integer;
begin
  SortList := TList<TSortItem>.Create;
  try
    for I := 0 to Count - 1 do
    begin
      SortList.Add(TSortItem.Create(ValueArray[I], I));
    end;

    TStrataSort<TSortItem>.Sort(SortList, CompareSortItem);

    TSortItem.SortCheck(SortList, Count);
  finally
    SortList.Free;
  end;
  Inc(SequenceTestCount);
end;


// This will test sorting every significantly different list
// of every length up to MaxCount.
procedure TSortUnitTests.TestSequences;
const
  MaxCount = 9;
begin
  Status('Start TestSequences(' + IntToStr(MaxCount) + ').  ' +
         'This will take a while.');
  SequenceTestCount := 0;
  GenerateSequences(SequenceTest, MaxCount);
  Status('End of TestSequences(' + IntToStr(MaxCount) + ').  ' +
         IntToStr(SequenceTestCount) + ' sequences sorted.');
end;


initialization
  RegisterTest(TSortUnitTests.Suite);

end.

