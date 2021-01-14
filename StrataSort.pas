// Copyright: John McDonald 1990 - 2021
// MS Pascal version created 1990.
// C# version created 2007 - 2011.
// Scala version created 2016.
// Delphi version created May 2018.
//

unit StrataSort;

interface

uses
  SysUtils, System.Classes, Generics.Defaults, Generics.Collections;

type
  /// <summary>
  /// A stable sort algorithm. ~O(n.log(n)), seems reasonably fast.
  /// The sort may be a little faster for presorted, almost sorted, and reverse sequence inputs.
  /// For most of the sort, lists of equal lengths are being merged.
  /// One of the lists being merged is contained in a SortStackItem,
  /// the other is made up of all the items in the previous SortStackItems.
  /// </summary>
  TStrataSorter<T> = class
  strict private
    /// <summary>
    /// The SortStack contains a list of these items. Each SortStackItem can contain SortItems.
    /// The first SortStackItem can contain 1 SortItem, the second 1, the third 2, the fourth 4, and so on.
    /// Apart from the first, each SortStackItem can contain 2^(n-1) SortItems, where n is its index in the SortStack.
    /// Each SortStackItem can contain the same number of items as all the SortStackItems below it.
    /// Each SortStackItem contains pointers to the SortStackItem below it in the SortStack.
    /// </summary>
    type  TSortStackItem = class
    strict private
      SortCompare: TComparison<T>;
      PrevStackItem: TSortStackItem;    // A reference to the SortStackItem below this in the SortStack.
      SortItems: array of T;    // An array of Max(1, 2*(n-1)) SortItems, where n is the index of this SortStackItem in the SortStack.
      FCount: Integer;    // count of valid items in sortItems. ( there may still be obsolete items left in sortItems )
      // The following three fields; FIndex, FCurrent and FEndOfSort are only valid after GetFirst or GetNext has been called.
      FIndex: Integer;    // The index of the next item in sortItems.
      FEndOfSort: Boolean;      // True when there are no more items at this or lower levels that haven't already been passed up to higher levels.
      FCurrent: T;        // The current item in the sort from either sortItems or prevStackItem.
                          // FCurrent is the earliest item that we know about at this level, that hasn't already been passed up to a higher level.
    public
      constructor Create(const ACapacity: Integer;
                         const APrevStackItem: TSortStackItem;
                         const ASortCompare: TComparison<T>);
    constructor CreateClone(const ASortStackItem: TSortStackItem;
                            const APrevStackItem: TSortStackItem);
      procedure Clear;
      procedure AddSingleItem(const Item: T); inline;
      procedure GetNext;
      procedure GetFirst;
      procedure RecoverNext;
      procedure RecoverFirst;
      procedure LoadFromPreviousLevels;
      property Count: Integer read FCount;
      property Current: T read FCurrent;    // Current is only valid after GetFirst or GetNext has been called.
      property EndOfSort: Boolean read FEndOfSort;    // EndOfSort is only valid after GetFirst or GetNext has been called.
    end;

  private
  type
    TSortEnumerator = class(TInterfacedObject, IEnumerator<T>, IEnumerator)
    strict private
      FSortEnumerable: IInterface;
      SortStack: TObjectList<TSortStackItem>;
      TopSortStackItem: TSortStackItem;
      BeginningOfSort: Boolean;    // This is true before MoveNext is called for the first time.

      procedure Reset;
      function  MoveNext: Boolean;
      function  GetCurrent: TObject;
      function  GenericGetCurrent: T;
      function  IEnumerator<T>.GetCurrent = GenericGetCurrent;
    public
      constructor Create(const ASortEnumerable: IInterface;
                         const AStrataSorter: TStrataSorter<T>);
      destructor Destroy; override;
    end;
    TSortEnumerable = class(TInterfacedObject, IEnumerable<T>, IEnumerable)
    strict private
      FStrataSorter: TStrataSorter<T>;
      FOwnsStrataSorter: Boolean;

      function GetGenericEnumerator: IEnumerator<T>;
      function GetEnumerator: IEnumerator;
      function IEnumerable<T>.GetEnumerator = GetGenericEnumerator;
    public
      constructor Create(const AStrataSorter: TStrataSorter<T>;
                         const AOwnsStrataSorter: Boolean = True);
      destructor Destroy; override;
    end;

    class function MakeTComparison(const AComparer: IComparer<T>): TComparison<T>;
  strict private
    SortCompare: TComparison<T>;
    SortStack: TObjectList<TSortStackItem>;
    FirstSortStackItem: TSortStackItem;
    StackTop: Integer;
    TopSortStackItem: TSortStackItem;    // TopSortStackItem is null before RunSort and assigned after.
    procedure Clear;
    procedure GetNext; inline;
    procedure RecoverFirst;
    procedure RecoverNext;
    function  GetCurrent: T; inline;
    function  GetEndOfSort: Boolean; inline;
    procedure SortRelease(const Item: T);
    function  SortReturn: T; inline;
    procedure FailSafeRecovery(const AList: TList<T>);
    property Current: T read GetCurrent;
  public
    constructor Create; overload;  deprecated 'SortCompare or SortComparer parameter is required.';
    constructor Create(const ASortCompare: TComparison<T>); overload;
    constructor Create(const ASortComparer: IComparer<T>); overload;
    destructor Destroy; override;
    procedure Release(const Item: T); inline;
    procedure RunSort;
    function  Return: T; inline;
    procedure Sort(const AList: TList<T>); overload;
    procedure Sort(const ASourceList: TList<T>;
                   const ADestinationList: TList<T>); overload;
    property EndOfSort: Boolean read GetEndOfSort;
  end;

  TStrataSort = class
  strict private
    class function MakeIndexCompareFn<T>(const ACompareFn: TComparison<T>;
                                         const AList: TList<T>): TComparison<Integer>;
    class procedure LoadSortedIndexList<T>(const AIndexList: TList<Integer>;
                                           const AList: TList<T>;
                                           const ASortCompare: TComparison<T>);
    class function MakeQuickSortIndexCompareFn<T>(const ACompareFn: TComparison<T>;
                                                  const AList: TList<T>): TComparison<Integer>;
    class procedure LoadQuickSortedIndexList<T>(const AIndexList: TList<Integer>;
                                                const AList: TList<T>;
                                                const ASortCompare: TComparison<T>);
    class procedure ReorderListByIndex<T>(const AList: TList<T>;
                                          const AIndexList: TList<Integer>);
  public
    class procedure Sort<T>(const AList: TList<T>;
                            const ASortCompare: TComparison<T>); overload;
    class procedure Sort<T>(const AList: TList<T>;
                            const ASortComparer: IComparer<T>); overload;
    class procedure Sort<T>(const ASourceList: TList<T>;
                            const ADestinationList: TList<T>;
                            const ASortCompare: TComparison<T>); overload;
    class procedure Sort<T>(const ASourceList: TList<T>;
                            const ADestinationList: TList<T>;
                            const ASortComparer: IComparer<T>); overload;
    class function  Sorted<T>(const AList: TList<T>;
                              const ASortCompare: TComparison<T>): IEnumerable<T>; overload;
    class function Sorted<T>(const AList: TList<T>;
                             const ASortComparer: IComparer<T>): IEnumerable<T>; overload;

    class procedure IndexSort<T>(const AList: TList<T>;
                                 const ASortCompare: TComparison<T>); overload;
    class procedure IndexQuickSort<T>(const AList: TList<T>;
                                      const ASortCompare: TComparison<T>); overload;
  end;

type
  ESortError = class(Exception);

implementation

uses System.Math, TypInfo;

{ TStrataSorter<T>.TSortStackItem }

constructor TStrataSorter<T>.TSortStackItem.Create(const ACapacity: Integer;
                                                   const APrevStackItem: TSortStackItem;
                                                   const ASortCompare: TComparison<T>);
begin
  inherited Create;
  SortCompare := ASortCompare;
  PrevStackItem := APrevStackItem;
  SetLength(SortItems, ACapacity);
  FCount := 0;
  FIndex := -1;
  FCurrent := Default(T);
  FEndOfSort := True;
end;

// This is used to create a copy of a SortStackItem for an enumerator.
// It should not be used until after RunSort.
// It creates a copy of a SortStackItem that shares the original SortItems array,
// but links to a PrevStackItem in its own SortStack.
// It has the same Count, but Index, Count and Current are independent.
constructor TStrataSorter<T>.TSortStackItem.CreateClone(const ASortStackItem: TSortStackItem;
                                                        const APrevStackItem: TSortStackItem);
begin
  inherited Create;
  SortCompare := ASortStackItem.SortCompare;
  PrevStackItem := APrevStackItem;
  SortItems := ASortStackItem.SortItems;
  FCount := ASortStackItem.Count;
  FIndex := -1;
  FCurrent := Default(T);
  FEndOfSort := True;
end;

procedure TStrataSorter<T>.TSortStackItem.Clear;
begin
  FCount := 0;
  FIndex := -1;
  FCurrent := Default(T);
  FEndOfSort := True;
  if Assigned(PrevStackItem) then
    PrevStackItem.Clear;
end;

// This should only be called for the first SortStackItem in the SortStack.
procedure TStrataSorter<T>.TSortStackItem.AddSingleItem(const Item: T);
begin
  SortItems[0] := Item;
  FCount := 1;
end;

/// This will set Current, FIndex and EndOfSort.
/// Note that Current will never be the same item in more than one SortStackItem.
procedure TStrataSorter<T>.TSortStackItem.GetNext;
begin
  if ( PrevStackItem = nil ) or
     PrevStackItem.EndOfSort then
  begin
    if FIndex >= Count then
    begin
      FEndOfSort := True;
      FCurrent := Default(T);
    end
    else
    begin
      FCurrent := SortItems[FIndex];
      Inc(FIndex);
    end;
  end
  else if FIndex >= Count then
  begin
    FCurrent := PrevStackItem.Current;
    PrevStackItem.GetNext;
  end
  else
  begin
    if SortCompare(SortItems[FIndex], PrevStackItem.Current) <= 0 then
    begin
      FCurrent := SortItems[FIndex];
      Inc(FIndex);
    end
    else
    begin
      FCurrent := PrevStackItem.Current;
      PrevStackItem.GetNext;
    end;
  end;
end;

// This method will prepare this level and levels below it for merging.
// It sets up FIndex, FCurrent and FEndOfSort.
procedure TStrataSorter<T>.TSortStackItem.GetFirst;
begin
  if Assigned(PrevStackItem) then
  begin
    PrevStackItem.GetFirst;
  end;
  FIndex := 0;
  FEndOfSort := False;
  GetNext;
end;

/// This method is only used to recover a list from a faulty CompareFn failing at a critical point.
/// This code will very rarely be used.
procedure TStrataSorter<T>.TSortStackItem.RecoverNext;
begin
  if FIndex < Count then
  begin
    FCurrent := SortItems[FIndex];
    Inc(FIndex);
  end
  else if Assigned(PrevStackItem) and
          not PrevStackItem.EndOfSort then
  begin
    FCurrent := PrevStackItem.Current;
    PrevStackItem.RecoverNext;
  end
  else
  begin
    FEndOfSort := True;
    FCurrent := Default(T);
  end;
end;

/// This method is only used to recover a list from a faulty CompareFn failing at a critical point.
/// This code will very rarely be used.
procedure TStrataSorter<T>.TSortStackItem.RecoverFirst;
begin
  if Assigned(PrevStackItem) then
  begin
    PrevStackItem.RecoverFirst;
  end;
  FIndex := 0;
  FEndOfSort := False;
  RecoverNext;
end;

// This method will merge all the SortStackItems from previous levels, and load them into this level.
// It will only be called when this level is empty.
// It will only be called when all previous levels are full, and the method will fill the sortItems array.
procedure TStrataSorter<T>.TSortStackItem.LoadFromPreviousLevels;
var
  ArrayIndex: Integer;
begin
  Assert(Count = 0, 'LoadFromPreviousLevels: Count should be 0.');
  if Assigned(PrevStackItem) then
  begin
    PrevStackItem.GetFirst;
    ArrayIndex := 0;
    while not PrevStackItem.EndOfSort do
    begin
      SortItems[ArrayIndex] := PrevStackItem.Current;
      Inc(ArrayIndex);
      PrevStackItem.GetNext;
    end;
    Assert(ArrayIndex = Length(SortItems), 'LoadFromPreviousLevels: Should have filled array.');
    FCount := ArrayIndex;
    PrevStackItem.Clear;
  end;
end;


{ TStrataSorter<T> }

class function TStrataSorter<T>.MakeTComparison(const AComparer: IComparer<T>): TComparison<T>;
begin
  Result := function(const Left, Right: T): Integer
            begin
              Result := AComparer.Compare(Left, Right);
            end;
end;

/// <summary>
/// This is used to clear everything at the start of a new sort,
/// and to free memory and reference counts at the end of a sort.
/// </summary>
procedure TStrataSorter<T>.Clear;
begin
  SortStack.Clear;
  FirstSortStackItem := TSortStackItem.Create(1, nil, SortCompare);
  SortStack.Add(FirstSortStackItem);
  StackTop := 0;    // leave StackTop pointing to the first SortStackItem.
  TopSortStackItem := nil;
end;

/// This method will load the items to be sorted, one at a time, into the SortStack.
procedure TStrataSorter<T>.SortRelease(const Item: T);
var
  StackIndex: Integer;
  StackItemCapacity: Integer;
begin
  StackIndex := 0;
  while ( StackIndex <= StackTop ) and
        ( SortStack[stackIndex].Count > 0 ) do
  begin
    Inc(StackIndex);
  end;
  if StackIndex > StackTop then
  begin
    if StackIndex < SortStack.Count then
    begin
      StackTop := StackIndex;
    end
    else
    begin
      StackItemCapacity := 1 shl StackTop;
      SortStack.Add(TSortStackItem.Create(StackItemCapacity, SortStack[stackTop], SortCompare));
      Inc(StackTop);
    end;
  end;
  SortStack[StackIndex].LoadFromPreviousLevels;
  FirstSortStackItem.AddSingleItem(Item);
end;

procedure TStrataSorter<T>.Release(const Item: T);
begin
  if Assigned(TopSortStackItem) then
    raise ESortError.Create('StrataSorter: Release called after RunSort.');
  SortRelease(Item);
end;

// This method sets values in preparation for the sorted items to be retrieved.
procedure TStrataSorter<T>.RunSort;
begin
  if Assigned(TopSortStackItem) then
    raise ESortError.Create('StrataSorter: RunSort called twice.');
  TopSortStackItem := SortStack[StackTop];
  TopSortStackItem.GetFirst;
end;

// This is not valid until after RunSort.
procedure TStrataSorter<T>.GetNext;
begin
  TopSortStackItem.GetNext;
end;

/// This method is only used to recover a list from a faulty CompareFn failing at a critical point.
/// This code will very rarely be used.
procedure TStrataSorter<T>.RecoverFirst;
begin
  TopSortStackItem.RecoverFirst;
end;

/// This method is only used to recover a list from a faulty CompareFn failing at a critical point.
procedure TStrataSorter<T>.RecoverNext;
begin
  TopSortStackItem.RecoverNext;
end;

// This is not valid until after RunSort.
function TStrataSorter<T>.GetCurrent: T;
begin
  Result := TopSortStackItem.Current;
end;

// This is not valid until after RunSort.
function TStrataSorter<T>.GetEndOfSort: Boolean;
begin
  Result := TopSortStackItem.EndOfSort;
end;

function TStrataSorter<T>.SortReturn: T;
begin
  Result := Current;
  GetNext;
end;

function  TStrataSorter<T>.Return: T;
begin
  if not Assigned(TopSortStackItem) then
    raise ESortError.Create('StrataSorter: RunSort must be called before Return.');
  Result := SortReturn;
end;

// If a list is being sorted, and the CompareFn fails while the sorted values are
// being loaded back into the list, the list may contain duplicate entries and
// may be missing other entries.
// If it is a TObjectList<T> with OwnsObjects = True, this can result in some
// objects being freed twice, and other objects never being freed.
// To prevent this, any exception that is raised while the sorted values are being
// loaded back into the list is caught, all the objects being sorted are loaded
// back into the list in arbitrary order by the following method, and the
// exception is re-raised.
// This situation will be very rare, because it requires a faulty CompareFn that
// gets through most of the sort without failing, then fails right near the end.
// But it is possible, and the sort should cope with it in a civilised way.
procedure TStrataSorter<T>.FailSafeRecovery(const AList: TList<T>);
type
  TArrayofT = array of T;
var
  Index: Integer;
  InternalList: TArrayofT;
begin
  InternalList := TArrayofT(AList.List);

  RecoverFirst;
  for Index := 0 to AList.Count - 1 do
  begin
    InternalList[Index] := Current;
    RecoverNext;
  end;
end;

// Sort a list into the specified order.
procedure TStrataSorter<T>.Sort(const AList: TList<T>);
type
  TArrayofT = array of T;
var
  Index: Integer;
  InternalList: TArrayofT;
begin
  Clear;
  try
    // If we are sorting a TObjectList with OwnsObjects = True, overwriting an
    // object reference via the Items property will result in objects being destroyed.
    // To prevent this happening while we are loading sorted items back into the list,
    // we access the internal list via the List property.
    InternalList := TArrayofT(AList.List);

    for Index := 0 to AList.Count - 1 do
      SortRelease(InternalList[Index]);

    RunSort;

    try
      for Index := 0 to AList.Count - 1 do
      begin
        InternalList[Index] := Current;
        GetNext;
      end;
    except
      FailSafeRecovery(AList);
      raise;
    end;
  finally
    Clear;
  end;
end;

// Sort everything from one list into another.
procedure TStrataSorter<T>.Sort(const ASourceList: TList<T>;
                                const ADestinationList: TList<T>);
var
  Item: T;
begin
  if ADestinationList = ASourceList then
    raise ESortError.Create('StratatSort: Source and Destination lists must not be the same.');

  Clear;
  try
    for Item in ASourceList do
      SortRelease(Item);

    RunSort;

    ADestinationList.Capacity := ADestinationList.Count + ASourceList.Count;
    while not EndOfSort do
      ADestinationList.Add(SortReturn);
  finally
    Clear;
  end;
end;


constructor TStrataSorter<T>.Create;
begin
  raise ESortError.Create('TStrataSorter<T>.Create: SortCompare or SortComparer parameter is required.');
end;

constructor TStrataSorter<T>.Create(const ASortCompare: TComparison<T>);
begin
  inherited Create;
  SortCompare := ASortCompare;
  SortStack := TObjectList<TSortStackItem>.Create;
  FirstSortStackItem := TSortStackItem.Create(1, nil, SortCompare);
  SortStack.Add(FirstSortStackItem);
  StackTop := 0;    // leave StackTop pointing to the first SortStackItem.
  TopSortStackItem := nil;
end;

constructor TStrataSorter<T>.Create(const ASortComparer: IComparer<T>);
begin
  Create(MakeTComparison(ASortComparer));
end;

destructor TStrataSorter<T>.Destroy;
begin
  SortStack.Free;
  inherited;
end;


{ TStrataSorter<T>.TSortEnumerator }

constructor TStrataSorter<T>.TSortEnumerator.Create(const ASortEnumerable: IInterface;
                                                    const AStrataSorter: TStrataSorter<T>);
var
  OrigSortStackItem: TSortStackItem;
  PrevSortStackItem: TSortStackItem;
begin
  inherited Create;
  if not Assigned(AStrataSorter.TopSortStackItem) then
    raise ESortError.Create('RunSort must be called before creating SortEnumerator.');
  FSortEnumerable := ASortEnumerable;
  SortStack := TObjectList<TSortStackItem>.Create;
  SortStack.Capacity := AStrataSorter.SortStack.Count;
  PrevSortStackItem := nil;
  TopSortStackItem := nil;
  for OrigSortStackItem in AStrataSorter.SortStack do
  begin
    TopSortStackItem := TSortStackItem.CreateClone(OrigSortStackItem, PrevSortStackItem);
    PrevSortStackItem := TopSortStackItem;
    SortStack.Add(TopSortStackItem);
  end;

  BeginningOfSort := True;
end;

destructor TStrataSorter<T>.TSortEnumerator.Destroy;
begin
  SortStack.Free;
  inherited;
end;

procedure TStrataSorter<T>.TSortEnumerator.Reset;
begin
  BeginningOfSort := True;
end;

function TStrataSorter<T>.TSortEnumerator.MoveNext: Boolean;
begin
  if BeginningOfSort then
  begin
    TopSortStackItem.GetFirst;
    BeginningOfSort := False;
  end
  else
    TopSortStackItem.GetNext;
  Result := not TopSortStackItem.EndOfSort;
end;

function TStrataSorter<T>.TSortEnumerator.GenericGetCurrent: T;
begin
  Result := TopSortStackItem.Current;
end;

function TStrataSorter<T>.TSortEnumerator.GetCurrent: TObject;
var
  CurrentItem: T;
begin
  if PTypeInfo(TypeInfo(T)).Kind = tkClass then
  begin
    CurrentItem := TopSortStackItem.Current;
    Result :=  PObject(@CurrentItem)^;
  end
  else
    raise ESortError.Create('SortItem is not an object.');
end;

{ TStrataSorter<T>.TSortEnumerable }

constructor TStrataSorter<T>.TSortEnumerable.Create(const AStrataSorter: TStrataSorter<T>;
                                                    const AOwnsStrataSorter: Boolean);
begin
  inherited Create;
  FStrataSorter := AStrataSorter;
  FOwnsStrataSorter := AOwnsStrataSorter;
end;

destructor TStrataSorter<T>.TSortEnumerable.Destroy;
begin
  if FOwnsStrataSorter then
    FStrataSorter.Free;
  inherited;
end;

function TStrataSorter<T>.TSortEnumerable.GetEnumerator: IEnumerator;
begin
  if PTypeInfo(TypeInfo(T)).Kind = tkClass then
    Result := TSortEnumerator.Create(Self, FStrataSorter)
  else
    raise ESortError.Create('SortItem is not an object.');
end;

function TStrataSorter<T>.TSortEnumerable.GetGenericEnumerator: IEnumerator<T>;
begin
  Result := TSortEnumerator.Create(Self, FStrataSorter);
end;


{ TStrataSort }

// Sort a list into the specified order.
class procedure TStrataSort.Sort<T>(const AList: TList<T>;
                                    const ASortCompare: TComparison<T>);
var
  StrataSorter: TStrataSorter<T>;
begin
  StrataSorter := TStrataSorter<T>.Create(ASortCompare);
  try
    StrataSorter.Sort(AList);
  finally
    StrataSorter.Free;
  end;
end;

class procedure TStrataSort.Sort<T>(const AList: TList<T>;
                                    const ASortComparer: IComparer<T>);
begin
  Sort<T>(AList,
          TStrataSorter<T>.MakeTComparison(ASortComparer));
end;

class procedure TStrataSort.Sort<T>(const ASourceList: TList<T>;
                                    const ADestinationList: TList<T>;
                                    const ASortCompare: TComparison<T>);
var
  StrataSorter: TStrataSorter<T>;
begin
  StrataSorter := TStrataSorter<T>.Create(ASortCompare);
  try
    StrataSorter.Sort(ASourceList, ADestinationList);
  finally
    StrataSorter.Free;
  end;
end;

class procedure TStrataSort.Sort<T>(const ASourceList: TList<T>;
                                    const ADestinationList: TList<T>;
                                    const ASortComparer: IComparer<T>);
begin
  Sort<T>(ASourceList, ADestinationList,
          TStrataSorter<T>.MakeTComparison(ASortComparer));
end;

// Create a sorted iterator for the list.
class function TStrataSort.Sorted<T>(const AList: TList<T>;
                                     const ASortCompare: TComparison<T>): IEnumerable<T>;
var
  StrataSorter: TStrataSorter<T>;
  ListItem: T;
begin
  StrataSorter := TStrataSorter<T>.Create(ASortCompare);
  try
    for ListItem in AList do
      StrataSorter.Release(ListItem);

    StrataSorter.RunSort;

    Result := TStrataSorter<T>.TSortEnumerable.Create(StrataSorter);
  except
    StrataSorter.Free;
    raise;
  end;
end;

// Create a sorted iterator for the list.
class function TStrataSort.Sorted<T>(const AList: TList<T>;
                                     const ASortComparer: IComparer<T>): IEnumerable<T>;
begin
  Result := Sorted<T>(AList,
                      TStrataSorter<T>.MakeTComparison(ASortComparer))
end;

class function TStrataSort.MakeIndexCompareFn<T>(const ACompareFn: TComparison<T>;
                                                 const AList: TList<T>): TComparison<Integer>;
type
  TArrayofT = array of T;
var
  InternalList: TArrayofT;
begin
  InternalList := TArrayofT(AList.List);
  Result := function(const Left, Right: Integer): Integer
            begin
              Result := ACompareFn(InternalList[Left], InternalList[Right]);
            end;
end;



class procedure TStrataSort.LoadSortedIndexList<T>(const AIndexList: TList<Integer>;
                                                   const AList: TList<T>;
                                                   const ASortCompare: TComparison<T>);
var
  IndexCompareFn: TComparison<Integer>;
  IndexSorter: TStrataSorter<Integer>;
  Index: Integer;
begin
  IndexCompareFn := MakeIndexCompareFn<T>(ASortCompare, AList);
  IndexSorter := TStrataSorter<Integer>.Create(IndexCompareFn);
  try
    for Index := 0 to AList.Count - 1 do
      IndexSorter.Release(Index);

    IndexSorter.RunSort;

    AIndexList.Capacity := AList.Count;
    while not IndexSorter.EndOfSort do
      AIndexList.Add(IndexSorter.Return);
  finally
    IndexSorter.Free;
  end;
end;

// This creates a function that can be used with an unstable sort like QuickSort to implement a stable IndexSort.
class function TStrataSort.MakeQuickSortIndexCompareFn<T>(const ACompareFn: TComparison<T>;
                                                          const AList: TList<T>): TComparison<Integer>;
type
  TArrayofT = array of T;
var
  InternalList: TArrayofT;
begin
  InternalList := TArrayofT(AList.List);
  Result := function(const Left, Right: Integer): Integer
            begin
              Result := ACompareFn(InternalList[Left], InternalList[Right]);
              if Result = 0 then
                Result := CompareValue(Left, Right);
            end;
end;

class procedure TStrataSort.LoadQuickSortedIndexList<T>(const AIndexList: TList<Integer>;
                                                        const AList: TList<T>;
                                                        const ASortCompare: TComparison<T>);
var
  IndexCompareFn: TComparison<Integer>;
  Index: Integer;
begin
  IndexCompareFn := MakeQuickSortIndexCompareFn<T>(ASortCompare, AList);
  AIndexList.Capacity := AList.Count;
  for Index := 0 to AList.Count - 1 do
    AIndexList.Add(Index);
  AIndexList.Sort(TComparer<Integer>.Construct(IndexCompareFn));
end;

class procedure TStrataSort.ReorderListByIndex<T>(const AList: TList<T>;
                                                  const AIndexList: TList<Integer>);
type
  TArrayofT = array of T;
var
  InternalList: TArrayofT;
  StartIndex: Integer;
  DestIndex: Integer;
  SourceIndex: Integer;
  SaveItem: T;
begin
  // We now have a list of the current index of what should be at each location.
  // Some items could already be in their correct location.
  // All the other items belong to a cycle of objects.
  // There might be one cycle that includes all the out of place items, or there
  // might be many shorter cycles.
  // For each cycle we find, we save what is in the starting position, then work out
  // what should be in that position. We move that item to where it should be, then
  // find what should be in the position that we moved an item from. We continue that
  // until we get to the position where we need the item that we saved from the starting
  // position.
  // This strategy means that each item only needs to be moved once, and we need very
  // little temporary storage for this reordering.
  InternalList := TArrayofT(AList.List);

  for StartIndex := 0 to AIndexList.Count - 1 do
  begin
    DestIndex := StartIndex;
    SourceIndex := AIndexList[DestIndex];
    if SourceIndex <> DestIndex then
    begin
      SaveItem := InternalList[DestIndex];
      while SourceIndex <> StartIndex do
      begin
        InternalList[DestIndex] := InternalList[SourceIndex];
        AIndexList[DestIndex] := DestIndex;
        DestIndex := SourceIndex;
        SourceIndex := AIndexList[DestIndex];
      end;
      InternalList[DestIndex] := SaveItem;
      AIndexList[DestIndex] := DestIndex;
    end;
  end;
end;

// IndexSort can be used to speed up sorting of reference counted items such as
// Interfaces, strings, and records that contain reference counted fields.
// StrataSort and QuickSort of reference counted items are relatively slow because
// of the reference counting. IndexSort will only move each item once or twice, so
// the reference counting overheads are reduced.
class procedure TStrataSort.IndexSort<T>(const AList: TList<T>;
                                         const ASortCompare: TComparison<T>);
var
  IndexList: TList<Integer>;
begin
  IndexList := TList<Integer>.Create;
  try
    LoadSortedIndexList<T>(IndexList, AList, ASortCompare);
    ReorderListByIndex<T>(AList, IndexList);
  finally
    IndexList.Free;
  end;
end;

// This is a stable sort based on an unstable sort - QuickSort.
// It was implemented mainly to provide a reference to match StrataSort against.
class procedure TStrataSort.IndexQuickSort<T>(const AList: TList<T>;
                                              const ASortCompare: TComparison<T>);
var
  IndexList: TList<Integer>;
begin
  IndexList := TList<Integer>.Create;
  try
    LoadQuickSortedIndexList<T>(IndexList, AList, ASortCompare);
    ReorderListByIndex<T>(AList, IndexList);
  finally
    IndexList.Free;
  end;
end;

end.
