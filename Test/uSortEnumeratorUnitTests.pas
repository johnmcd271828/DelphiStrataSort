unit uSortEnumeratorUnitTests;

interface

uses
  TestFramework, Generics.Defaults, Generics.Collections, SysUtils,
  StrataSort, uSortTestTypes;

type
  TSortEnumeratorUnitTests = class(TTestCase)
  strict private
    procedure TestSortedEnumerator<T>(const ListSize: Integer;
                                      const GenerateListValues: TGenerateListValuesProc;
                                      const CreateItemFn: TCreateItemFn<T>;
                                      const CreateListFn: TCreateListFn<T>;
                                      const CompareFn: TComparison<T>;
                                      const SortCheckProc: TSortCheckProc<T>);
    procedure OverlapEnumerator<T>(const Enumerable: IEnumerable<T>;
                                   const ListSize: Integer;
                                   const CompareFn: TComparison<T>;
                                   const SortCheckProc: TSortCheckProc<T>);
    procedure TestOverlappedEnumerators<T>(const ListSize: Integer;
                                           const GenerateListValues: TGenerateListValuesProc;
                                           const CreateItemFn: TCreateItemFn<T>;
                                           const CreateListFn: TCreateListFn<T>;
                                           const CompareFn: TComparison<T>;
                                           const SortCheckProc: TSortCheckProc<T>);
    procedure TestNonGenericEnumerator<T>(const ListSize: Integer;
                                          const GenerateListValues: TGenerateListValuesProc;
                                          const CreateItemFn: TCreateItemFn<T>;
                                          const CreateListFn: TCreateListFn<T>;
                                          const CompareFn: TComparison<T>;
                                          const SortCheckProc: TSortCheckProc<T>);
  published
    procedure TestSortedIntegers;
    procedure TestSortedStrings;
    procedure TestSortedObjects;
    procedure TestSortedInterfaces;
    procedure TestSortedRecords;
    procedure TestOverlappedObjectEnumerators;
    procedure TestNonGenericEnumeratorWithIntegers;
    procedure TestNonGenericEnumeratorWithObjects;
    procedure TestNonGenericEnumeratorWithInterfaces;
    procedure TestSortedEnumeratorWithIComparer;
  end;

implementation

procedure TSortEnumeratorUnitTests.TestSortedEnumerator<T>(const ListSize: Integer;
                                                           const GenerateListValues: TGenerateListValuesProc;
                                                           const CreateItemFn: TCreateItemFn<T>;
                                                           const CreateListFn: TCreateListFn<T>;
                                                           const CompareFn: TComparison<T>;
                                                           const SortCheckProc: TSortCheckProc<T>);
 var
  List: TList<T>;
  SortedList: TList<T>;
  SortItem: T;
begin
  List := CreateListFn;
  try
    TTestAssistant.LoadList<T>(GenerateListValues, CreateItemFn, List, ListSize);

    SortedList := TList<T>.Create;    // We don't want this list to own items.
    try
      for SortItem in TStrataSort.Sorted<T>(List, CompareFn) do
        SortedList.Add(SortItem);

      SortCheckProc(SortedList, ListSize, CompareFn, True);
    finally
      SortedList.Free;
    end;
  finally
    List.Free;
  end;
end;


procedure TSortEnumeratorUnitTests.TestSortedIntegers;
begin
  TestSortedEnumerator<Integer>(573, TTestAssistant.RandomListValues,
                                TTestAssistant.CreateIntegerTestItem,
                                TTestAssistant.CreateTList<Integer>,
                                TTestAssistant.CompareInteger,
                                TTestAssistant.IntegerSortCheck);
end;


procedure TSortEnumeratorUnitTests.TestSortedStrings;
begin
  TestSortedEnumerator<string>(1023, TTestAssistant.RandomListValues,
                               TTestAssistant.CreateStringTestItem,
                               TTestAssistant.CreateTList<string>,
                               CompareText,
                               TTestAssistant.StringSortCheck);
end;


procedure TSortEnumeratorUnitTests.TestSortedObjects;
begin
  TestSortedEnumerator<TTestObject>(1024, TTestAssistant.RandomListValues,
                                    TTestObject.CreateTestItem,
                                    TTestAssistant.CreateTObjectList<TTestObject>,
                                    TTestObject.Compare,
                                    TTestObject.SortCheck);
end;


procedure TSortEnumeratorUnitTests.TestSortedInterfaces;
begin
  TestSortedEnumerator<ITestInterface>(1025, TTestAssistant.RandomListValues,
                                       TTestInterfaceObject.CreateTestItem,
                                       TTestAssistant.CreateTList<ITestInterface>,
                                       TTestInterfaceObject.Compare,
                                       TTestInterfaceObject.SortCheck);
end;


procedure TSortEnumeratorUnitTests.TestSortedRecords;
begin
  TestSortedEnumerator<TTestStringRecord>(768, TTestAssistant.RandomListValues,
                                          TTestStringRecord.CreateTestItem,
                                          TTestAssistant.CreateTList<TTestStringRecord>,
                                          TTestStringRecord.Compare,
                                          TTestStringRecord.SortCheck);
end;


procedure TSortEnumeratorUnitTests.OverlapEnumerator<T>(const Enumerable: IEnumerable<T>;
                                                        const ListSize: Integer;
                                                        const CompareFn: TComparison<T>;
                                                        const SortCheckProc: TSortCheckProc<T>);
 var
  SortedList: TList<T>;
  Enumerator: IEnumerator<T>;
begin
  SortedList := TList<T>.Create;
  try
    Enumerator := Enumerable.GetEnumerator;
    while Enumerator.MoveNext do
    begin
      SortedList.Add(Enumerator.Current);
    end;

    SortCheckProc(SortedList, ListSize, CompareFn, True);
  finally
    SortedList.Free;
  end;
end;


// This will iterate through a sorted list, and during this iteration, do independent iterations using the same IEnumerable<T>
procedure TSortEnumeratorUnitTests.TestOverlappedEnumerators<T>(const ListSize: Integer;
                                                                const GenerateListValues: TGenerateListValuesProc;
                                                                const CreateItemFn: TCreateItemFn<T>;
                                                                const CreateListFn: TCreateListFn<T>;
                                                                const CompareFn: TComparison<T>;
                                                                const SortCheckProc: TSortCheckProc<T>);
 var
  List: TList<T>;
  SortedList: TList<T>;
  Enumerable: IEnumerable<T>;
  Enumerator: IEnumerator<T>;
begin
  List := CreateListFn;
  try
    TTestAssistant.LoadList<T>(GenerateListValues, CreateItemFn, List, ListSize);

    SortedList := TList<T>.Create;    // We don't want this list to own items.
    try
      Enumerable := TStrataSort.Sorted<T>(List, CompareFn);
      Enumerator := Enumerable.GetEnumerator;
      while Enumerator.MoveNext do
      begin
        SortedList.Add(Enumerator.Current);

        OverlapEnumerator<T>(Enumerable, ListSize, CompareFn, SortCheckProc);
      end;

      SortCheckProc(SortedList, ListSize, CompareFn, True);
    finally
      SortedList.Free;
    end;
  finally
    List.Free;
  end;
end;


// This will test that a SortEnumerable can be used to create multiple Enumerators
// that don't interfere with each other.
procedure TSortEnumeratorUnitTests.TestOverlappedObjectEnumerators;
begin
  // ListSize should be small or this will take a very long time to complete.
  TestOverlappedEnumerators<TTestObject>(17, TTestAssistant.RandomListValues,
                                         TTestObject.CreateTestItem,
                                         TTestAssistant.CreateTObjectList<TTestObject>,
                                         TTestObject.Compare,
                                         TTestObject.SortCheck);
end;


// This will use the Sorted method and iterate through a sorted list of objects.
// It should work if T is a TObject or descendent, and fail if T is not an object.
procedure TSortEnumeratorUnitTests.TestNonGenericEnumerator<T>(const ListSize: Integer;
                                                               const GenerateListValues: TGenerateListValuesProc;
                                                               const CreateItemFn: TCreateItemFn<T>;
                                                               const CreateListFn: TCreateListFn<T>;
                                                               const CompareFn: TComparison<T>;
                                                               const SortCheckProc: TSortCheckProc<T>);
type
  PT = ^T;
var
  List: TList<T>;
  SortedList: TList<T>;
  SortItem: TObject;
begin
  List := CreateListFn;
  try
    TTestAssistant.LoadList<T>(GenerateListValues, CreateItemFn, List, ListSize);

    SortedList := TList<T>.Create;    // We don't want this list to own items.
    try
      for SortItem in TStrataSort.Sorted<T>(List, CompareFn) do
        SortedList.Add(PT(@SortItem)^);

      SortCheckProc(SortedList, ListSize, CompareFn, True);
    finally
      SortedList.Free;
    end;
  finally
    List.Free;
  end;
end;


// Check that using non-generic enumerator with a list of integers will fail.
procedure TSortEnumeratorUnitTests.TestNonGenericEnumeratorWithIntegers;
begin
  try
    TestNonGenericEnumerator<Integer>(73, TTestAssistant.RandomListValues,
                                      TTestAssistant.CreateIntegerTestItem,
                                      TTestAssistant.CreateTList<Integer>,
                                      TTestAssistant.CompareInteger,
                                      TTestAssistant.IntegerSortCheck);
    raise ESortTestError.Create('TestNonGenericEnumeratorWithIntegers - ESortTestError expected');
  except
    on E: ESortError do
    begin
      CheckEquals('SortItem is not an object.', E.Message);
    end;
  end;
end;


// Check that using non-generic enumerator with a list of objects will work.
procedure TSortEnumeratorUnitTests.TestNonGenericEnumeratorWithObjects;
begin
  TestNonGenericEnumerator<TTestObject>(57, TTestAssistant.RandomListValues,
                                        TTestObject.CreateTestItem,
                                        TTestAssistant.CreateTObjectList<TTestObject>,
                                        TTestObject.Compare,
                                        TTestObject.SortCheck);
end;


// Check that using non-generic enumerator with a list of interfaces will fail.
procedure TSortEnumeratorUnitTests.TestNonGenericEnumeratorWithInterfaces;
begin
  try
    TestNonGenericEnumerator<ITestInterface>(88, TTestAssistant.RandomListValues,
                                             TTestInterfaceObject.CreateTestItem,
                                             TTestAssistant.CreateTList<ITestInterface>,
                                             TTestInterfaceObject.Compare,
                                             TTestInterfaceObject.SortCheck);
    raise ESortTestError.Create('TestNonGenericEnumeratorWithInterfaces - ESortTestError expected');
  except
    on E: ESortError do
    begin
      CheckEquals('SortItem is not an object.', E.Message);
    end;
  end;
end;


procedure TSortEnumeratorUnitTests.TestSortedEnumeratorWithIComparer;
const
  ListSize = 123;
 var
  List: TList<TTestObject>;
  SortedList: TList<TTestObject>;
  SortItem: TTestObject;
begin
  List := TObjectList<TTestObject>.Create;
  try
    TTestAssistant.LoadList<TTestObject>(TTestAssistant.RandomListValues, TTestObject.CreateTestItem, List, ListSize);

    SortedList := TList<TTestObject>.Create;    // We don't want this list to own items.
    try
      for SortItem in TStrataSort.Sorted<TTestObject>(List, TTestObject.Compare) do
        SortedList.Add(SortItem);

      TTestObject.SortCheck(SortedList, ListSize, TTestObject.Compare, True);
    finally
      SortedList.Free;
    end;
  finally
    List.Free;
  end;
end;


initialization
  RegisterTest(TSortEnumeratorUnitTests.Suite);

end.
