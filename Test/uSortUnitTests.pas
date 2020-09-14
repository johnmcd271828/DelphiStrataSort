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
    procedure TestSortIntegers;
    procedure TestSortBytes;
    procedure TestSortStrings;
    procedure TestSortObjects;
    procedure TestSortInterfaces;
    procedure TestSortIntegerRecords;
    procedure TestSortStringRecords;
    procedure TestSortManagedRecords;
    procedure TestSortObjectListToObjectList;
    procedure TestSortInterfaceListToInterfaceListComparer;
    procedure TestReleaseSortReturn;
    procedure TestSortReuse;
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

procedure TSortUnitTests.TestSortIntegers;
var
  List: TList<Integer>;
const
  ListSize: Integer = 1000;
begin
  List := TList<Integer>.Create;
  try
    TTestAssistant.LoadRandomList<Integer>(TTestAssistant.CreateIntegerTestItem, List, ListSize);
    TStrataSort<Integer>.Sort(List, TTestAssistant.CompareInteger);
    TTestAssistant.IntegerSortCheck(List, ListSize, TTestAssistant.CompareInteger, True);
  finally
    List.Free;
  end;
end;

procedure TSortUnitTests.TestSortBytes;
var
  List: TList<Byte>;
const
  ListSize: Integer = 256;
begin
  List := TList<Byte>.Create;
  try
    TTestAssistant.LoadRandomList<Byte>(TTestAssistant.CreateByteTestItem, List, ListSize);
    TStrataSort<Byte>.Sort(List, TTestAssistant.CompareByte);
    TTestAssistant.ByteSortCheck(List, ListSize, TTestAssistant.CompareByte, True);
  finally
    List.Free;
  end;
end;

procedure TSortUnitTests.TestSortStrings;
var
  List: TList<string>;
const
  ListSize: Integer = 1000;
begin
  List := TList<string>.Create;
  try
    TTestAssistant.LoadRandomList<string>(TTestAssistant.CreateStringTestItem, List, ListSize);
    TStrataSort<string>.Sort(List, CompareText);
    TTestAssistant.StringSortCheck(List, ListSize, CompareText, True);
  finally
    List.Free;
  end;
end;

procedure TSortUnitTests.TestSortObjects;
var
  List: TObjectList<TTestObject>;
const
  ListSize: Integer = 1000;
begin
  List := TObjectList<TTestObject>.Create;
  try
    TTestAssistant.LoadRandomList<TTestObject>(TTestObject.CreateTestItem, List, ListSize);
    TStrataSort<TTestObject>.Sort(List, TTestObject.Compare);
    TTestObject.SortCheck(List, ListSize, TTestObject.Compare, True);
  finally
    List.Free;
  end;
end;

procedure TSortUnitTests.TestSortInterfaces;
var
  List: TList<ITestInterface>;
const
  ListSize: Integer = 1000;
begin
  List := TList<ITestInterface>.Create;
  try
    TTestAssistant.LoadRandomList<ITestInterface>(TTestInterfaceObject.CreateTestItem, List, ListSize);
    TStrataSort<ITestInterface>.Sort(List, TTestInterfaceObject.Compare);
    TTestInterfaceObject.SortCheck(List, ListSize, TTestInterfaceObject.Compare, True);
  finally
    List.Free;
  end;
end;

procedure TSortUnitTests.TestSortIntegerRecords;
var
  List: TList<TTestIntegerRecord>;
const
  ListSize: Integer = 1000;
begin
  List := TList<TTestIntegerRecord>.Create;
  try
    TTestAssistant.LoadRandomList<TTestIntegerRecord>(TTestIntegerRecord.CreateTestItem, List, ListSize);
    TStrataSort<TTestIntegerRecord>.Sort(List, TTestIntegerRecord.Compare);
    TTestIntegerRecord.SortCheck(List, ListSize, TTestIntegerRecord.Compare, True);
  finally
    List.Free;
  end;
end;

procedure TSortUnitTests.TestSortStringRecords;
var
  List: TList<TTestStringRecord>;
const
  ListSize: Integer = 1000;
begin
  List := TList<TTestStringRecord>.Create;
  try
    TTestAssistant.LoadRandomList<TTestStringRecord>(TTestStringRecord.CreateTestItem, List, ListSize);
    TStrataSort<TTestStringRecord>.Sort(List, TTestStringRecord.Compare);
    TTestStringRecord.SortCheck(List, ListSize, TTestStringRecord.Compare, True);
  finally
    List.Free;
  end;
end;

procedure TSortUnitTests.TestSortManagedRecords;
var
  List: TList<TTestManagedRecord>;
const
  ListSize: Integer = 1000;
begin
  List := TList<TTestManagedRecord>.Create;
  try
    TTestAssistant.LoadRandomList<TTestManagedRecord>(TTestManagedRecord.CreateTestItem, List, ListSize);
    TStrataSort<TTestManagedRecord>.Sort(List, TTestManagedRecord.Compare);
    TTestManagedRecord.SortCheck(List, ListSize, TTestManagedRecord.Compare, True);
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
      TTestObject.SortCheck(DestinationList, ListSize, TTestObject.Compare, True);
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
      TTestInterfaceObject.SortCheck(DestinationList, ListSize, TTestInterfaceObject.Compare, True);
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


procedure TSortUnitTests.TestSortReuse;
var
  Sorter: TStrataSort<TTestObject>;
  List: TObjectList<TTestObject>;
const
  ListSize: Integer = 1000;
begin
  Sorter := TStrataSort<TTestObject>.Create(TTestObject.Compare);
  try
    List := TObjectList<TTestObject>.Create;
    try
      TTestAssistant.LoadRandomList<TTestObject>(TTestObject.CreateTestItem , List, ListSize);
      Sorter.Sort(List);
      TTestObject.SortCheck(List, ListSize, TTestObject.Compare, True);

      List.Clear;

      TTestAssistant.LoadFourValueList<TTestObject>(TTestObject.CreateTestItem , List, ListSize);
      Sorter.Sort(List);
      TTestObject.SortCheck(List, ListSize, TTestObject.Compare, True);
    finally
      List.Free;
    end;
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

