// Copyright: John McDonald 2020
//

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
    procedure TestFailSafe(const GenerateListValues: TGenerateListValuesProc;
                           const ListSize: Integer;
                           const TriggerCount: Int64);
  published
    procedure TestSortIntegers;
    procedure TestSortBytes;
    procedure TestSortStrings;
    procedure TestSortObjects;
    procedure TestSortInterfaces;
    procedure TestSortIntegerRecords;
    procedure TestSortStringRecords;
    procedure TestSortManagedRecords;
    procedure TestSequences;
    procedure TestSortObjectsUsingIComparer;
    procedure TestSortObjectListToObjectList;
    procedure TestSortInterfaceListToInterfaceListComparer;
    procedure TestSortInterfaceListAppendToInterfaceList;
    procedure TestSortObjectListToSameList;
    procedure TestReleaseSortReturn;
    procedure TestReleaseSortReturnUsingIComparer;
    procedure TestCallRunSortTwice;
    procedure TestCallReturnBeforeRunSort;
    procedure TestCallReleaseAfterRunSort;
    procedure TestSortReuse;
    procedure TestFailSafe1;
    procedure TestFailSafe2;
    procedure TestFailSafe3;
    procedure TestFailSafe4;
    procedure TestFailSafe5;
    procedure TestFailSafe6;
    procedure TestFailSafe7;
    procedure TestFailSafe8;
    procedure TestFailSafe9;
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
    TTestAssistant.LoadList<Integer>(TTestAssistant.RandomListValues,
                                     TTestAssistant.CreateIntegerTestItem,
                                     List, ListSize);
    TStrataSort.Sort<Integer>(List, TTestAssistant.CompareInteger);
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
    TTestAssistant.LoadList<Byte>(TTestAssistant.RandomListValues,
                                  TTestAssistant.CreateByteTestItem,
                                  List, ListSize);
    TStrataSort.Sort<Byte>(List, TTestAssistant.CompareByte);
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
    TTestAssistant.LoadList<string>(TTestAssistant.RandomListValues,
                                    TTestAssistant.CreateStringTestItem,
                                    List, ListSize);
    TStrataSort.Sort<string>(List, CompareText);
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
    TTestAssistant.LoadList<TTestObject>(TTestAssistant.RandomListValues,
                                         TTestObject.CreateTestItem,
                                         List, ListSize);
    TStrataSort.Sort<TTestObject>(List, TTestObject.Compare);
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
    TTestAssistant.LoadList<ITestInterface>(TTestAssistant.RandomListValues,
                                            TTestInterfaceObject.CreateTestItem,
                                            List, ListSize);
    TStrataSort.Sort<ITestInterface>(List, TTestInterfaceObject.Compare);
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
    TTestAssistant.LoadList<TTestIntegerRecord>(TTestAssistant.RandomListValues,
                                                TTestIntegerRecord.CreateTestItem,
                                                List, ListSize);
    TStrataSort.Sort<TTestIntegerRecord>(List, TTestIntegerRecord.Compare);
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
    TTestAssistant.LoadList<TTestStringRecord>(TTestAssistant.RandomListValues,
                                               TTestStringRecord.CreateTestItem,
                                               List, ListSize);
    TStrataSort.Sort<TTestStringRecord>(List, TTestStringRecord.Compare);
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
    TTestAssistant.LoadList<TTestManagedRecord>(TTestAssistant.RandomListValues,
                                                TTestManagedRecord.CreateTestItem,
                                                List, ListSize);
    TStrataSort.Sort<TTestManagedRecord>(List, TTestManagedRecord.Compare);
    TTestManagedRecord.SortCheck(List, ListSize, TTestManagedRecord.Compare, True);
  finally
    List.Free;
  end;
end;


// This will test sorting the sequence contained in the first Count items of ValueArray.
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

    TStrataSort.Sort<TSortItem>(SortList, CompareSortItem);

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
  Status(Format('Start TestSequences(%d).  This will take a while.',
                [MaxCount]));
  SequenceTestCount := 0;
  TSequenceGenerator.GenerateSequences(SequenceTest, MaxCount);
  Status(Format('End of TestSequences(%d).  %d sequences sorted.',
                [MaxCount, SequenceTestCount]));
end;


procedure TSortUnitTests.TestSortObjectsUsingIComparer;
var
  List: TObjectList<TTestObject>;
  SortComparer: IComparer<TTestObject>;
const
  ListSize: Integer = 1000;
begin
  List := TObjectList<TTestObject>.Create;
  try
    TTestAssistant.LoadList<TTestObject>(TTestAssistant.RandomListValues,
                                         TTestObject.CreateTestItem,
                                         List, ListSize);
    SortComparer := TComparer<TTestObject>.Construct(TTestObject.Compare);
    TStrataSort.Sort<TTestObject>(List, SortComparer);
    TTestObject.SortCheck(List, ListSize, TTestObject.Compare, True);
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
      TTestAssistant.LoadList<TTestObject>(TTestAssistant.RandomListValues,
                                           TTestObject.CreateTestItem,
                                           SourceList, ListSize);
      TStrataSort.Sort<TTestObject>(SourceList, DestinationList, TTestObject.Compare);
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
      TTestAssistant.LoadList<ITestInterface>(TTestAssistant.RandomListValues,
                                              TTestInterfaceObject.CreateTestItem,
                                              SourceList, ListSize);
      SortComparer := TComparer<ITestInterface>.Construct(TTestInterfaceObject.Compare);
      TStrataSort.Sort<ITestInterface>(SourceList, DestinationList, SortComparer);
      TTestInterfaceObject.SortCheck(DestinationList, ListSize, TTestInterfaceObject.Compare, True);
    finally
      DestinationList.Free;
    end;
  finally
    SourceList.Free;
  end;
end;


procedure TSortUnitTests.TestSortInterfaceListAppendToInterfaceList;
var
  SourceList: TList<ITestInterface>;
  DestinationList: TList<ITestInterface>;
const
  ListSize: Integer = 6;
begin
  SourceList := TList<ITestInterface>.Create;
  try
    TTestAssistant.LoadList<ITestInterface>(TTestAssistant.ReversedListValues,
                                            TTestInterfaceObject.CreateTestItem,
                                            SourceList, ListSize);
    DestinationList := TList<ITestInterface>.Create;
    try
      DestinationList.Add(TTestInterfaceObject.CreateTestItem(8,8));
      DestinationList.Add(TTestInterfaceObject.CreateTestItem(9,9));
      TStrataSort.Sort<ITestInterface>(SourceList, DestinationList, TTestInterfaceObject.Compare);
      CheckEquals(8, DestinationList.Count, ' Incorrect DestinationList.Count');
      CheckEquals(8, DestinationList[0].Value, 'Incorrect value in DestinationList');
      CheckEquals(9, DestinationList[1].Value, 'Incorrect value in DestinationList');
      CheckEquals(1, DestinationList[2].Value, 'Incorrect value in DestinationList');
      CheckEquals(2, DestinationList[3].Value, 'Incorrect value in DestinationList');
      CheckEquals(3, DestinationList[4].Value, 'Incorrect value in DestinationList');
      CheckEquals(4, DestinationList[5].Value, 'Incorrect value in DestinationList');
      CheckEquals(5, DestinationList[6].Value, 'Incorrect value in DestinationList');
      CheckEquals(6, DestinationList[7].Value, 'Incorrect value in DestinationList');
    finally
      DestinationList.Free;
    end;
  finally
    SourceList.Free;
  end;
end;


procedure TSortUnitTests.TestSortObjectListToSameList;
var
  List: TObjectList<TTestObject>;
const
  ListSize: Integer = 10;
begin
  List := TObjectList<TTestObject>.Create(True);
  try
    TTestAssistant.LoadList<TTestObject>(TTestAssistant.RandomListValues,
                                         TTestObject.CreateTestItem,
                                         List, ListSize);
    try
      TStrataSort.Sort<TTestObject>(List, List, TTestObject.Compare);
      raise ESortTestError.Create('TestSortObjectListToSameList - ESortTestError expected');
    except
      on E: ESortError do
      begin
        CheckEquals('StratatSort: Source and Destination lists must not be the same.', E.Message);
      end;
    end;
  finally
    List.Free;
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
      Sorter.Release(TSortItem.Create(I*5 mod 7, I));
    end;
    Sorter.RunSort;
    for I := 0 to 6 do
    begin
      Check(not Sorter.Eof, 'Premature Eof');
      ReturnItem1 := Sorter.Return;
      CheckEquals(I, ReturnItem1.Key, 'ReturnItem1 Order Error');
      Check(not Sorter.Eof, 'Premature Eof');
      ReturnItem2 := Sorter.Return;
      CheckEquals(I, ReturnItem2.Key, 'ReturnItem2 Order Error');
      Check(ReturnItem1.Seq < ReturnItem2.Seq, 'ReturnItem Sequence Error');
    end;
    Check(Sorter.Eof, 'Eof expected.');
  finally
    Sorter.Free;
  end;
end;


procedure TSortUnitTests.TestReleaseSortReturnUsingIComparer;
var
  SortComparer: IComparer<TSortItem>;
  Sorter: TStrataSort<TSortItem>;
  I: Integer;
  ReturnItem: TSortItem;
begin
  SortComparer := TComparer<TSortItem>.Construct(CompareSortItem);
  Sorter := TStrataSort<TSortItem>.Create(SortComparer);
  try
    for I := 1 to 7 do
    begin
      Sorter.Release(TSortItem.Create(I*5 mod 7, I));
    end;
    Sorter.RunSort;
    for I := 0 to 6 do
    begin
      Check(not Sorter.Eof, 'Premature Eof');
      ReturnItem := Sorter.Return;
      CheckEquals(I, ReturnItem.Key, 'ReturnItem Order Error');
    end;
    Check(Sorter.Eof, 'Eof expected.');
  finally
    Sorter.Free;
  end;
end;


procedure TSortUnitTests.TestCallRunSortTwice;
var
  Sorter: TStrataSort<TSortItem>;
begin
  Sorter := TStrataSort<TSortItem>.Create(CompareSortItem);
  try
    Sorter.Release(TSortItem.Create(1, 1));
    Sorter.RunSort;
    try
      Sorter.RunSort;
      raise ESortTestError.Create('ESortTestError expected');
    except
      on E: ESortError do
      begin
        CheckEquals('StrataSort: RunSort called twice.', E.Message);
      end;
    end;
  finally
    Sorter.Free;
  end;
end;


procedure TSortUnitTests.TestCallReturnBeforeRunSort;
var
  Sorter: TStrataSort<TSortItem>;
begin
  Sorter := TStrataSort<TSortItem>.Create(CompareSortItem);
  try
    Sorter.Release(TSortItem.Create(1, 1));
    try
      Sorter.Return;
      raise ESortTestError.Create('ESortTestError expected');
    except
      on E: ESortError do
      begin
        CheckEquals('StrataSort: RunSort must be called before Return.', E.Message);
      end;
    end;
  finally
    Sorter.Free;
  end;
end;


procedure TSortUnitTests.TestCallReleaseAfterRunSort;
var
  Sorter: TStrataSort<TSortItem>;
begin
  Sorter := TStrataSort<TSortItem>.Create(CompareSortItem);
  try
    Sorter.Release(TSortItem.Create(1, 1));
    Sorter.RunSort;
    try
      Sorter.Release(TSortItem.Create(2, 2));
      raise ESortTestError.Create('ESortTestError expected');
    except
      on E: ESortError do
      begin
        CheckEquals('StrataSort: Release called after RunSort.', E.Message);
      end;
    end;
  finally
    Sorter.Free;
  end;
end;


procedure TSortUnitTests.TestSortReuse;
var
  Sorter: TStrataSort<TTestObject>;
  List: TObjectList<TTestObject>;
const
  FirstListSize: Integer = 3000;
  SecondListSize: Integer = 1000;
begin
  Sorter := TStrataSort<TTestObject>.Create(TTestObject.Compare);
  try
    List := TObjectList<TTestObject>.Create;
    try
      TTestAssistant.LoadList<TTestObject>(TTestAssistant.RandomListValues,
                                           TTestObject.CreateTestItem,
                                           List, FirstListSize);
      Sorter.Sort(List);
      TTestObject.SortCheck(List, FirstListSize, TTestObject.Compare, True);

      List.Clear;

      TTestAssistant.LoadList<TTestObject>(TTestAssistant.FourValueListValues,
                                           TTestObject.CreateTestItem,
                                           List, SecondListSize);
      Sorter.Sort(List);
      TTestObject.SortCheck(List, SecondListSize, TTestObject.Compare, True);
    finally
      List.Free;
    end;
  finally
    Sorter.Free;
  end;
end;


procedure TSortUnitTests.TestFailSafe(const GenerateListValues: TGenerateListValuesProc;
                                      const ListSize: Integer;
                                      const TriggerCount: Int64);
var
  List: TObjectList<TTestObject>;
  FailingCompare: TComparison<TTestObject>;
begin
  // Initially List.OwnsObjects will be false to prevent double frees when
  // testing code that is not fail safe.
  // List.OwnsObjects will be set back to true when we have established
  // that the list contains no duplicates.
  List := TObjectList<TTestObject>.Create(False);
  try
    TTestAssistant.LoadList<TTestObject>(GenerateListValues,
                                         TTestObject.CreateTestItem,
                                         List, ListSize);
    FailingCompare := TTestAssistant.MakeFailingCompare<TTestObject>(TTestObject.Compare, TriggerCount);
    try
      TStrataSort.Sort<TTestObject>(List, FailingCompare);
      raise ESortTestError.Create('ETriggeredException was expected, not found.');
    except
      on ETriggeredException do
      begin
        // This exception is expected.
      end;
    end;
    TTestObject.CheckListContainsAllObjects(List, ListSize);
    List.OwnsObjects := True;
  finally
    List.Free;
  end;
end;


// Without the FailSafe recovery code in StrataSort, it is possible that a
// faulty CompareFn can result in a situation where a list contains duplicate
// entries and is missing other entries. If the list is a TObjectList<T> with
// OwnsObjects = True, this can cause double Frees and memory leaks.
// The TestFailSafe tests will test that the FailSafe recovery code is working.
//
// To create the situation where a list would contain duplicate entries
// without the FailSafe recovery code, the compare function has to raise
// an exception after the sorter has started loading the sorted items back
// into the list. This can be done be by creating a FailingCompare that will
// throw an exception on the nth compare, where suitable values for n can be
// found in the following table.
//
// For the following lists, the exception should be triggered between the values given:
//
// ListType                  ListSize     Trigger between
// ReversedListValues          1023        4131 and 5110
// ReversedListValues          1024        4134 and 5120
// ReversedListValues          1025        situation cannot occur.
// ReversedListValues           657        2791 and 2947
// ReversedListValues           695        2890 and 3141
// AlternatingListValues       1023        5926 and 7675
// AlternatingListValues       1024        5929 and 7679
// AlternatingListValues       1025        situation cannot occur.
// AlternatingListValues        657        4108 and 4895
// AlternatingListValues        695        4233 and 5130
// ReverseAllButLastListValues 1025        5123 and 6144

procedure TSortUnitTests.TestFailSafe1;
begin
  TestFailSafe(TTestAssistant.ReversedListValues, 1023, 4200);
end;

procedure TSortUnitTests.TestFailSafe2;
begin
  TestFailSafe(TTestAssistant.ReversedListValues, 1024, 4220);
end;

procedure TSortUnitTests.TestFailSafe3;
begin
  TestFailSafe(TTestAssistant.ReversedListValues, 657, 2800);
end;

procedure TSortUnitTests.TestFailSafe4;
begin
  TestFailSafe(TTestAssistant.ReversedListValues, 695, 3000);
end;

procedure TSortUnitTests.TestFailSafe5;
begin
  TestFailSafe(TTestAssistant.AlternatingListValues, 1023, 7000);
end;

procedure TSortUnitTests.TestFailSafe6;
begin
  TestFailSafe(TTestAssistant.AlternatingListValues, 1024, 6000);
end;

procedure TSortUnitTests.TestFailSafe7;
begin
  TestFailSafe(TTestAssistant.AlternatingListValues, 657, 4500);
end;

procedure TSortUnitTests.TestFailSafe8;
begin
  TestFailSafe(TTestAssistant.AlternatingListValues, 695, 4800);
end;

procedure TSortUnitTests.TestFailSafe9;
begin
  TestFailSafe(TTestAssistant.ReverseAllButLastListValues, 1025, 5140);
end;


initialization
  RegisterTest(TSortUnitTests.Suite);

end.

