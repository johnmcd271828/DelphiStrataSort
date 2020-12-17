// Copyright: John McDonald 2020
//

unit uSortTestTypes;

// This contains record, class and interface types used to test sort routines.
// They contain methods that help create lists of items.
// TTestStringRecord contains strings, to test the effect of reference counting on speed.
//
// TTestAssistant is used for tests sorting integers and strings.
// TTestAssistant also contains methods to create large list of items.
//
// The SortCheck methods check that a list is in the correct order.
// SortCheck methods have a parameter that determines whether to check for sort stability.
// This allows the SortCheck methods to be used to check stable and unstable sorts.

interface

uses
  System.SysUtils, System.Classes, System.Generics.Defaults, System.Generics.Collections;

function CompareInt(const Left, Right: Integer): Integer;

type
  TProcessValueAndSeqProc = reference to procedure(const AValue: Integer;
                                                   const ASequence: Integer);
  TGenerateListValuesProc = reference to procedure(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                                   const ListSize: Integer);
  TCreateListFn<T> = reference to function: TList<T>;
  TCreateItemFn<T> = reference to function(const AValue: Integer;
                                           const ASequence: Integer): T;
  TLoadListProc<T> = reference to procedure(const ProcessValueAndSeq: TProcessValueAndSeqProc;
                                            const List: TList<T>;
                                            const ListSize: Integer);
  TSortProc<T> = reference to procedure(const List: TList<T>;
                                        const CompareFn: TComparison<T>);
  TSortCheckProc<T> = reference to procedure(const List: TList<T>;
                                             const ListSize: Integer;
                                             const CompareFn: TComparison<T>;
                                             const StableSort: Boolean);

  ESortTestError = class(Exception);
  ETriggeredException = class(Exception);

  TTestAssistant = class
  public
    class function CreateTList<T>: TList<T>;
    class function CreateTObjectList<T: class>: TList<T>;
    class procedure SortListCountCheck(const ListCount: Integer;
                                       const ExpectedCount: Integer);

    class function CreateIntegerTestItem(const AValue: Integer;
                                         const ASequence: Integer): Integer;
    class function CompareInteger(const Left, Right: Integer): Integer;
    class procedure IntegerSortCheck(const List: TList<Integer>;
                                     const ListSize: Integer;
                                     const CompareFn: TComparison<Integer>;
                                     const StableSort: Boolean);

    class function CreateByteTestItem(const AValue: Integer;
                                      const ASequence: Integer): Byte;
    class function CompareByte(const Left, Right: Byte): Integer;
    class procedure ByteSortCheck(const List: TList<Byte>;
                                  const ListSize: Integer;
                                  const CompareFn: TComparison<Byte>;
                                  const StableSort: Boolean);

    class function ValueToTestString(const AValue: Integer): string;
    class function CreateStringTestItem(const AValue: Integer;
                                        const ASequence: Integer): string;
    class procedure StringSortCheck(const List: TList<string>;
                                    const ListSize: Integer;
                                    const CompareFn: TComparison<string>;
                                    const StableSort: Boolean);

    class procedure RandomListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                     const ListSize: Integer);
    class procedure SortedListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                     const ListSize: Integer);
    class procedure ReversedListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                       const ListSize: Integer);
    class procedure AlmostSortedListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                           const ListSize: Integer);
    class procedure FourValueListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                        const ListSize: Integer);
    class procedure SingleValueListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                          const ListSize: Integer);
    class procedure AlternatingListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                          const ListSize: Integer);
    class procedure ReverseAllButLastListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                                const ListSize: Integer);
    class procedure LoadList<T>(const GenerateListValues: TGenerateListValuesProc;
                                const CreateItemFn: TCreateItemFn<T>;
                                const List: TList<T>;
                                const ListSize: Integer);
    class function MakeFailingCompare<T>(const CompareFn: TComparison<T>;
                                         const TriggerCount: Int64): TComparison<T>;
  end;


  /// <summary>
  /// A record type containing no reference counted items.
  /// </summary>
  TTestIntegerRecord = record
  strict private
    FValue: Integer;
    FUnused: Integer;
    FSequence: Integer;
  public
    constructor Create(const AValue: Integer;
                       const ASequence: Integer);
    class function CreateTestItem(const AValue: Integer;
                                  const ASequence: Integer): TTestIntegerRecord; static;
    class function Compare(const Left, Right: TTestIntegerRecord): Integer; static;
    class procedure SortCheck(const List: TList<TTestIntegerRecord>;
                              const ListSize: Integer;
                              const CompareFn: TComparison<TTestIntegerRecord>;
                              const StableSort: Boolean); static;
    property Value: Integer read FValue;
    property Sequence: Integer read FSequence;
  end;

  /// <summary>
  /// A record type containing strings, which require reference counting.
  /// </summary>
  TTestStringRecord = record
  strict private
    FValue: string;
    FUnused: string;
    FSequence: Integer;
  public
    constructor Create(const AValue: string;
                       const ASequence: Integer);
    class function CreateTestItem(const AValue: Integer;
                                  const ASequence: Integer): TTestStringRecord; static;
    class function Compare(const Left, Right: TTestStringRecord): Integer; static;
    class procedure SortCheck(const List: TList<TTestStringRecord>;
                              const ListSize: Integer;
                              const CompareFn: TComparison<TTestStringRecord>;
                              const StableSort: Boolean); static;
    property Value: string read FValue;
    property Sequence: Integer read FSequence;
  end;

  /// <summary>
  /// A record type with a default initializer, that will set field values to default values.
  ///  In this test case, the value will be set to a random one or two digit string.
  ///  This is only effective in Delphi 10.4 Sydney and later.
  ///  For earlier versions of Delphi, it will behave like a normal record.
  /// </summary>
  TTestManagedRecord = record
  strict private
    FValue: string;
    FUnused: string;
    FSequence: Integer;
  public
  {$IF CompilerVersion >= 34.0}    // Delphi 10.4 Sydney and later
    class operator Initialize (out Rec: TTestManagedRecord);
  {$IFEND}
    constructor Create(const AValue: string;
                       const ASequence: Integer);
    class function CreateTestItem(const AValue: Integer;
                                  const ASequence: Integer): TTestManagedRecord; static;
    class function Compare(const Left, Right: TTestManagedRecord): Integer; static;
    class procedure SortCheck(const List: TList<TTestManagedRecord>;
                              const ListSize: Integer;
                              const CompareFn: TComparison<TTestManagedRecord>;
                              const StableSort: Boolean); static;
    property Value: string read FValue write FValue;
    property Sequence: Integer read FSequence;
  end;

  TTestObject = class
  strict private
    FValue: Integer;
    FSequence: Integer;
  public
    constructor Create(const AValue: Integer;
                       const ASequence: Integer);
    class function CreateTestItem(const AValue: Integer;
                                  const ASequence: Integer): TTestObject;
    class function Compare(const Left, Right: TTestObject): Integer;
    class procedure SortCheck(const List: TList<TTestObject>;
                              const ListSize: Integer;
                              const CompareFn: TComparison<TTestObject>;
                              const StableSort: Boolean);
    class procedure CheckListContainsAllObjects(const List: TList<TTestObject>;
                                                const ListSize: Integer);
    property Value: Integer read FValue;
    property Sequence: Integer read FSequence;
  end;

  ITestInterface = interface
    function GetValue: Integer;
    function GetSequence: Integer;
    property Value: Integer read GetValue;
    property Sequence: Integer read GetSequence;
  end;

  /// <summary>
  /// A class that implements ITestInterface.
  /// </summary>
  TTestInterfaceObject = class(TInterfacedObject, ITestInterface)
  strict private
    FValue: Integer;
    FSequence: Integer;
    function GetValue: Integer;
    function GetSequence: Integer;
  public
    constructor Create(const AValue: Integer;
                       const ASequence: Integer);
    class function CreateTestItem(const AValue: Integer;
                                  const ASequence: Integer): ITestInterface;
    class function Compare(const Left, Right: ITestInterface): Integer;
    class procedure SortCheck(const List: TList<ITestInterface>;
                              const ListSize: Integer;
                              const CompareFn: TComparison<ITestInterface>;
                              const StableSort: Boolean);
    property Value: Integer read GetValue;
    property Sequence: Integer read GetSequence;
  end;


implementation

uses System.Math;

function CompareInt(const Left, Right: Integer): Integer;
begin
  Result := CompareValue(Left, Right);
end;

{ TTestAssistant }

class function TTestAssistant.CreateTList<T>: TList<T>;
begin
  Result := TList<T>.Create;
end;

class function TTestAssistant.CreateTObjectList<T>: TList<T>;
begin
  Result := TObjectList<T>.Create(True);
end;

class procedure TTestAssistant.SortListCountCheck(const ListCount: Integer;
                                                  const ExpectedCount: Integer);
begin
  if ListCount <> ExpectedCount then
    raise ESortTestError.CreateFmt('SortCheck Count Error: List.Count = %d, Expected Count = %d',
                                   [ListCount, ExpectedCount]);
end;

class function TTestAssistant.CreateIntegerTestItem(const AValue: Integer;
                                                    const ASequence: Integer): Integer;
begin
  Result := AValue;
end;

class function TTestAssistant.CompareInteger(const Left, Right: Integer): Integer;
begin
  Result := CompareValue(Left, Right);
end;

class procedure TTestAssistant.IntegerSortCheck(const List: TList<Integer>;
                                                const ListSize: Integer;
                                                const CompareFn: TComparison<Integer>;
                                                const StableSort: Boolean);
var
  Item: Integer;
  PrevItem: Integer;
  IsFirstItem: Boolean;
begin
  SortListCountCheck(List.Count, ListSize);

  PrevItem := 0;
  IsFirstItem := True;
  for Item in List do
  begin
    if IsFirstItem then
    begin
      IsFirstItem := False;
    end
    else
    begin
      if CompareFn(PrevItem, Item) > 0 then
        raise ESortTestError.CreateFmt('SortCheck Order Error: %d > %d',
                                       [PrevItem, Item]);
    end;
    PrevItem := Item;
  end;
end;

class function TTestAssistant.CreateByteTestItem(const AValue: Integer;
                                                 const ASequence: Integer): Byte;
begin
  Result := AValue;
end;

class function TTestAssistant.CompareByte(const Left, Right: Byte): Integer;
begin
  Result := CompareValue(Left, Right);
end;

class procedure TTestAssistant.ByteSortCheck(const List: TList<Byte>;
                                             const ListSize: Integer;
                                             const CompareFn: TComparison<Byte>;
                                             const StableSort: Boolean);
var
  Item: Byte;
  PrevItem: Byte;
  IsFirstItem: Boolean;
begin
  SortListCountCheck(List.Count, ListSize);

  PrevItem := 0;
  IsFirstItem := True;
  for Item in List do
  begin
    if IsFirstItem then
    begin
      IsFirstItem := False;
    end
    else
    begin
      if CompareFn(PrevItem, Item) > 0 then
        raise ESortTestError.CreateFmt('SortCheck Order Error: %d > %d',
                                       [PrevItem, Item]);
    end;
    PrevItem := Item;
  end;
end;

class function TTestAssistant.ValueToTestString(const AValue: Integer): string;
begin
  Result := Format('SortString%.10d', [AValue]);
end;

class function TTestAssistant.CreateStringTestItem(const AValue: Integer;
                                                   const ASequence: Integer): string;
begin
  Result := ValueToTestString(AValue);
end;

class procedure TTestAssistant.StringSortCheck(const List: TList<string>;
                                               const ListSize: Integer;
                                               const CompareFn: TComparison<string>;
                                               const StableSort: Boolean);
var
  Item: string;
  PrevItem: string;
  IsFirstItem: Boolean;
begin
  SortListCountCheck(List.Count, ListSize);

  PrevItem := '';
  IsFirstItem := True;
  for Item in List do
  begin
    if IsFirstItem then
    begin
      IsFirstItem := False;
    end
    else
    begin
      if CompareFn(PrevItem, Item) > 0 then
        raise ESortTestError.CreateFmt('SortCheck Order Error: ''%s'' > ''%s''',
                                       [PrevItem, Item]);
    end;
    PrevItem := Item;
  end;
end;


class procedure TTestAssistant.RandomListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                                const ListSize: Integer);
var
  Index: Integer;
begin
  RandSeed := 12345678;
  for Index := 1 to ListSize do
  begin
    ProcessValueAndSeqProc(Random(ListSize), Index);
  end;
end;

class procedure TTestAssistant.SortedListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                                const ListSize: Integer);
var
  Index: Integer;
begin
  for Index := 1 to ListSize do
  begin
    ProcessValueAndSeqProc(Index, Index);
  end;
end;

class procedure TTestAssistant.ReversedListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                                  const ListSize: Integer);
var
  Index: Integer;
begin
  for Index := 1 to ListSize do
  begin
    ProcessValueAndSeqProc(ListSize - Index + 1, Index);
  end;
end;

class procedure TTestAssistant.ReverseAllButLastListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                                           const ListSize: Integer);
var
  Index: Integer;
begin
  for Index := 1 to ListSize - 1 do
  begin
    ProcessValueAndSeqProc(ListSize - Index, Index);
  end;
  ProcessValueAndSeqProc(ListSize, ListSize);
end;

class procedure TTestAssistant.AlmostSortedListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                                      const ListSize: Integer);
var
  Index: Integer;
  TargetIndex: Integer;
begin
  TargetIndex := ListSize div 10;
  for Index := 1 to ListSize do
  begin
    if ( Index = TargetIndex ) or
       ( Index = 2 * TargetIndex ) or
       ( Index = 3 * TargetIndex ) or
       ( Index = ListSize - TargetIndex) or
       ( Index = ListSize - 2 * TargetIndex ) or
       ( Index = ListSize - 3 * TargetIndex ) then
      ProcessValueAndSeqProc(ListSize - Index, Index)
    else
      ProcessValueAndSeqProc(Index, Index);
  end;
end;

class procedure TTestAssistant.FourValueListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                                   const ListSize: Integer);
var
  Index: Integer;
begin
  for Index := 1 to ListSize do
  begin
    ProcessValueAndSeqProc(4 - Index mod 4, Index);
  end;
end;

class procedure TTestAssistant.SingleValueListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                                     const ListSize: Integer);
var
  Index: Integer;
begin
  for Index := 1 to ListSize do
  begin
    ProcessValueAndSeqProc(5, Index);
  end;
end;

class procedure TTestAssistant.AlternatingListValues(const ProcessValueAndSeqProc: TProcessValueAndSeqProc;
                                                     const ListSize: Integer);
var
  EvenSize: Integer;
  Index: Integer;
  KeyValue: Integer;
begin
  EvenSize := ( ListSize + 1 ) and ( not 1 );
  for Index := 1 to ListSize do
  begin
    if Odd(Index) then
      KeyValue := EvenSize - Index
    else
      KeyValue := Index;
    ProcessValueAndSeqProc(KeyValue, Index);
  end;
end;

class procedure TTestAssistant.LoadList<T>(const GenerateListValues: TGenerateListValuesProc;
                                           const CreateItemFn: TCreateItemFn<T>;
                                           const List: TList<T>;
                                           const ListSize: Integer);
begin
  List.Capacity := ListSize;
  GenerateListValues(procedure(const AValue: Integer;
                               const ASequence: Integer)
                     begin
                       List.Add(CreateItemFn(AValue, ASequence));
                     end,
                     ListSize);
end;

class function TTestAssistant.MakeFailingCompare<T>(const CompareFn: TComparison<T>;
                                                    const TriggerCount: Int64): TComparison<T>;
var
  CompareCount: Integer;
begin
  CompareCount := 0;
  Result := function(const Left, Right: T): Integer
            begin
              Inc(CompareCount);
              if CompareCount >= TriggerCount then
              begin
                raise ETriggeredException.Create('Exception raised to test FailSafe code.');
              end;
              Result := CompareFn(Left, Right);
            end;
end;

{ TTestIntegerRecord }

constructor TTestIntegerRecord.Create(const AValue: Integer;
                                      const ASequence: Integer);
begin
  FValue := AValue;
  FUnused := AValue;
  FSequence := ASequence;
end;

class function TTestIntegerRecord.CreateTestItem(const AValue: Integer;
                                                 const ASequence: Integer): TTestIntegerRecord;
begin
  Result.Create(AValue, ASequence);
end;

class function TTestIntegerRecord.Compare(const Left, Right: TTestIntegerRecord): Integer;
begin
  Result := CompareValue(Left.Value, Right.Value);
end;

class procedure TTestIntegerRecord.SortCheck(const List: TList<TTestIntegerRecord>;
                                             const ListSize: Integer;
                                             const CompareFn: TComparison<TTestIntegerRecord>;
                                             const StableSort: Boolean);
var
  Item: TTestIntegerRecord;
  PrevItem: TTestIntegerRecord;
  IsFirstItem: Boolean;
begin
  TTestAssistant.SortListCountCheck(List.Count, ListSize);

  IsFirstItem := True;
  for Item in List do
  begin
    if IsFirstItem then
    begin
      IsFirstItem := False;
    end
    else
    begin
      if CompareFn(PrevItem, Item) > 0 then
        raise ESortTestError.CreateFmt('SortCheck Order Error: %d > %d',
                                       [PrevItem.Value, Item.Value])
      else if StableSort and
              ( CompareFn(PrevItem, Item) = 0 ) then
      begin
        if PrevItem.Sequence = Item.Sequence then
          raise ESortTestError.CreateFmt('SortCheck Duplicate Error: Value = %d, Seq: %d',
                                         [Item.Value, Item.Sequence])
        else if PrevItem.Sequence > Item.Sequence then
          raise ESortTestError.CreateFmt('SortCheck Stability Error: Value = %d, Seq: %d > %d',
                                         [Item.Value, PrevItem.Sequence, Item.Sequence]);
      end;
    end;
    PrevItem := Item;
  end;
end;

{ TTestStringRecord }

constructor TTestStringRecord.Create(const AValue: string;
                                     const ASequence: Integer);
begin
  FValue := AValue;
  FUnused := AValue;
  FSequence := ASequence;
end;

class function TTestStringRecord.CreateTestItem(const AValue: Integer;
                                                const ASequence: Integer): TTestStringRecord;
begin
  Result.Create(TTestAssistant.ValueToTestString(AValue), ASequence);
end;

class function TTestStringRecord.Compare(const Left, Right: TTestStringRecord): Integer;
begin
  Result := CompareText(Left.Value, Right.Value);
end;

class procedure TTestStringRecord.SortCheck(const List: TList<TTestStringRecord>;
                                            const ListSize: Integer;
                                            const CompareFn: TComparison<TTestStringRecord>;
                                            const StableSort: Boolean);
var
  Item: TTestStringRecord;
  PrevItem: TTestStringRecord;
  IsFirstItem: Boolean;
begin
  TTestAssistant.SortListCountCheck(List.Count, ListSize);

  IsFirstItem := True;
  for Item in List do
  begin
    if IsFirstItem then
    begin
      IsFirstItem := False;
    end
    else
    begin
      if CompareFn(PrevItem, Item) > 0 then
        raise ESortTestError.CreateFmt('SortCheck Order Error: ''%s'' > ''%s''',
                                       [PrevItem.Value, Item.Value])
      else if StableSort and
              ( CompareFn(PrevItem, Item) = 0 ) then
      begin
        if PrevItem.Sequence = Item.Sequence then
          raise ESortTestError.CreateFmt('SortCheck Duplicate Error: Value = ''%s'', Seq: %d',
                                         [Item.Value, Item.Sequence])
        else if PrevItem.Sequence > Item.Sequence then
          raise ESortTestError.CreateFmt('SortCheck Stability Error: Value = ''%s'', Seq: %d > %d',
                                         [Item.Value, PrevItem.Sequence, Item.Sequence]);
      end;
    end;
    PrevItem := Item;
  end;
end;

{ TTestManagedRecord }

{$IF CompilerVersion >= 34.0}    // Delphi 10.4 Sydney and later
class operator TTestManagedRecord.Initialize(out Rec: TTestManagedRecord);
begin
  Rec.Value := IntToStr(Random(100));
end;
{$IFEND}

constructor TTestManagedRecord.Create(const AValue: string;
                                      const ASequence: Integer);
begin
  FValue := AValue;
  FUnused := AValue;
  FSequence := ASequence;
end;

class function TTestManagedRecord.CreateTestItem(const AValue: Integer;
                                                 const ASequence: Integer): TTestManagedRecord;
begin
  Result.Create(TTestAssistant.ValueToTestString(AValue), ASequence);
end;

class function TTestManagedRecord.Compare(const Left, Right: TTestManagedRecord): Integer;
begin
  Result := CompareText(Left.Value, Right.Value);
end;

class procedure TTestManagedRecord.SortCheck(const List: TList<TTestManagedRecord>;
                                             const ListSize: Integer;
                                             const CompareFn: TComparison<TTestManagedRecord>;
                                             const StableSort: Boolean);
var
  Item: TTestManagedRecord;
  PrevItem: TTestManagedRecord;
  IsFirstItem: Boolean;
begin
  TTestAssistant.SortListCountCheck(List.Count, ListSize);

  IsFirstItem := True;
  for Item in List do
  begin
    if IsFirstItem then
    begin
      IsFirstItem := False;
    end
    else
    begin
      if CompareFn(PrevItem, Item) > 0 then
        raise ESortTestError.CreateFmt('SortCheck Order Error: ''%s'' > ''%s''',
                                       [PrevItem.Value, Item.Value])
      else if StableSort and
              ( CompareFn(PrevItem, Item) = 0 ) then
      begin
        if PrevItem.Sequence = Item.Sequence then
          raise ESortTestError.CreateFmt('SortCheck Duplicate Error: Value = ''%s'', Seq: %d',
                                         [Item.Value, Item.Sequence])
        else if PrevItem.Sequence > Item.Sequence then
          raise ESortTestError.CreateFmt('SortCheck Stability Error: Value = ''%s'', Seq: %d > %d',
                                         [Item.Value, PrevItem.Sequence, Item.Sequence]);
      end;
    end;
    PrevItem := Item;
  end;
end;

{ TTestObject }

constructor TTestObject.Create(const AValue: Integer;
                               const ASequence: Integer);
begin
  inherited Create;
  FValue := AValue;
  FSequence := ASequence;
end;

class function TTestObject.CreateTestItem(const AValue: Integer;
                                          const ASequence: Integer): TTestObject;
begin
  Result := Create(AValue, ASequence);
end;

class function TTestObject.Compare(const Left, Right: TTestObject): Integer;
begin
  Result := CompareInt(Left.Value, Right.Value);
end;

class procedure TTestObject.SortCheck(const List: TList<TTestObject>;
                                      const ListSize: Integer;
                                      const CompareFn: TComparison<TTestObject>;
                                      const StableSort: Boolean);
var
  Item: TTestObject;
  PrevItem: TTestObject;
  IsFirstItem: Boolean;
begin
  TTestAssistant.SortListCountCheck(List.Count, ListSize);

  PrevItem := nil;
  IsFirstItem := True;
  for Item in List do
  begin
    if IsFirstItem then
    begin
      IsFirstItem := False;
    end
    else
    begin
      if CompareFn(PrevItem, Item) > 0 then
        raise ESortTestError.CreateFmt('SortCheck Order Error: %d > %d',
                                       [PrevItem.Value, Item.Value])
      else if StableSort and
              ( CompareFn(PrevItem, Item) = 0 ) then
      begin
        if PrevItem.Sequence = Item.Sequence then
          raise ESortTestError.CreateFmt('SortCheck Duplicate Error: Value = %d, Seq: %d',
                                         [Item.Value, Item.Sequence])
        else if PrevItem.Sequence > Item.Sequence then
          raise ESortTestError.CreateFmt('SortCheck Stability Error: Value = %d, Seq: %d > %d',
                                         [Item.Value, PrevItem.Sequence, Item.Sequence]);
      end;
    end;
    PrevItem := Item;
  end;
end;

class procedure TTestObject.CheckListContainsAllObjects(const List: TList<TTestObject>;
                                                        const ListSize: Integer);
var
  CheckArray: TBytes;    // CheckArray[TestObject.Sequence - 1] is set to 1 if TestObject.Sequence has been seen.
  TestObject: TTestObject;
  ListIndex: Integer;
  ArrayIndex: Integer;
begin
  //  This checks that List contains Objects with all sequences from 1 to ListSize, with no duplicates.
  if List.Count <> ListSize then
    raise ESortTestError.CreateFmt('CheckListContainsAllObjects Count Error: List.Count = %d, ListSize = %d',
                                   [List.Count, ListSize]);
  SetLength(CheckArray, ListSize);
  for ListIndex := 0 to List.Count - 1 do
  begin
    TestObject := List[ListIndex];
    if not Assigned(TestObject) then
      raise ESortTestError.CreateFmt('CheckListContainsAllObjects Error: List contains nil object at %d',
                                     [ListIndex]);
    if ( TestObject.Sequence < 1 ) or
       ( TestObject.Sequence > ListSize ) then
      raise ESortTestError.CreateFmt('CheckListContainsAllObjects Error: Unexpected TestObject.Sequence %d at %d',
                                     [TestObject.Sequence, ListIndex]);
    if CheckArray[TestObject.Sequence - 1] <> 0 then
      raise ESortTestError.CreateFmt('CheckListContainsAllObjects Error: Duplicate TestObject.Sequence %d at %d',
                                     [TestObject.Sequence, ListIndex]);
    CheckArray[TestObject.Sequence - 1] := 1;
  end;
  // The following loop isn't really necessary.
  for ArrayIndex := 0 to ArrayIndex.Size - 1 do
  begin
    if CheckArray[ArrayIndex] <> 1 then
      raise ESortTestError.CreateFmt('CheckListContainsAllObjects Error: Missing TestObject.Sequence %d',
                                     [ArrayIndex + 1]);

  end;
end;

{ TTestInterfaceObject }

constructor TTestInterfaceObject.Create(const AValue: Integer;
                                        const ASequence: Integer);
begin
  inherited Create;
  FValue := AValue;
  FSequence := ASequence;
end;

class function TTestInterfaceObject.CreateTestItem(const AValue: Integer;
                                                   const ASequence: Integer): ITestInterface;
begin
  Result := Create(AValue, ASequence);
end;

function TTestInterfaceObject.GetValue: Integer;
begin
  Result := FValue;
end;

function TTestInterfaceObject.GetSequence: Integer;
begin
  Result := FSequence;
end;

class function TTestInterfaceObject.Compare(const Left, Right: ITestInterface): Integer;
begin
  Result := CompareInt(Left.Value, Right.Value);
end;

class procedure TTestInterfaceObject.SortCheck(const List: TList<ITestInterface>;
                                               const ListSize: Integer;
                                               const CompareFn: TComparison<ITestInterface>;
                                               const StableSort: Boolean);
var
  Item: ITestInterface;
  PrevItem: ITestInterface;
  IsFirstItem: Boolean;
begin
  TTestAssistant.SortListCountCheck(List.Count, ListSize);

  PrevItem := nil;
  IsFirstItem := True;
  for Item in List do
  begin
    if IsFirstItem then
    begin
      IsFirstItem := False;
    end
    else
    begin
      if CompareFn(PrevItem, Item) > 0 then
        raise ESortTestError.CreateFmt('SortCheck Order Error: %d > %d',
                                       [PrevItem.Value, Item.Value])
      else if StableSort and
              ( CompareFn(PrevItem, Item) = 0 ) then
      begin
        if PrevItem.Sequence = Item.Sequence then
          raise ESortTestError.CreateFmt('SortCheck Duplicate Error: Value = %d, Seq: %d',
                                         [Item.Value, Item.Sequence])
        else if PrevItem.Sequence > Item.Sequence then
          raise ESortTestError.CreateFmt('SortCheck Stability Error: Value = %d, Seq: %d > %d',
                                         [Item.Value, PrevItem.Sequence, Item.Sequence]);
      end;
    end;
    PrevItem := Item;
  end;
end;

end.
