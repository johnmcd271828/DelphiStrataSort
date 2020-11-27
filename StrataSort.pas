// Copyright: John McDonald 1990 - 2020
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
  TStrataSort<T> = class
  strict private
    /// <summary>
    /// The SortStack contains a list of these items. Each SortStackItem can contain SortItems.
    /// The first SortStackItem can contain 1, the second 1, the third 2, the fourth 4, and so on.
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
      // The following three fields; FIndex, FCurrent and FEof are only valid after GetFirst or GetNext has been called.
      FIndex: Integer;    // The index of the next item in sortItems.
      FEof: Boolean;      // True when there are no more items at this or lower levels that haven't already been passed up to higher levels.
      FCurrent: T;        // The current item in the sort from either sortItems or prevStackItem.
                          // FCurrent is the earliest item that we know about at this level, that hasn't already been passed up to a higher level.
    public
      constructor Create(const ACapacity: Integer;
                         const APrevStackItem: TSortStackItem;
                         const ASortCompare: TComparison<T>);
      procedure Clear;
      procedure AddSingleItem(const Item: T); inline;
      procedure GetNext;
      procedure GetFirst;
      procedure LoadFromPreviousLevels;
      property Count: Integer read FCount;
      property Current: T read FCurrent;    // Eof is only valid after GetFirst or GetNext has been called.
      property Eof: Boolean read FEof;    // Eof is only valid after GetFirst or GetNext has been called.
    end;

  private
    /// <summary>
    /// This record type is just used to allow the sort to work with an IComparer<T>.
    /// </summary>
    type  TComparerInterfaceAdapter = record
    strict private
      FComparer: IComparer<T>;
    public
      constructor Create(const AComparer: IComparer<T>);
      function Compare(const Left, Right: T): Integer;
    end;
  strict private
    SortCompare: TComparison<T>;
    SortStack: TObjectList<TSortStackItem>;
    FirstSortStackItem: TSortStackItem;
    StackTop: Integer;
    TopSortStackItem: TSortStackItem;    // TopSortStackItem is null before RunSort and assigned after.
    procedure Clear;
    procedure GetNext; inline;
    function  GetCurrent: T; inline;
    function  GetEof: Boolean; inline;
    procedure SortRelease(const Item: T);
    function  SortReturn: T; inline;
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
    property Eof: Boolean read GetEof;
  end;

  TStrataSort = class
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
  end;

type
  ESortError = class(Exception);

implementation

{ TStrataSort<T>.TSortStackItem }

constructor TStrataSort<T>.TSortStackItem.Create(const ACapacity: Integer;
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
  FEof := True;
end;

procedure TStrataSort<T>.TSortStackItem.Clear;
begin
  FCount := 0;
  FIndex := -1;
  FCurrent := Default(T);
  FEof := True;
  if Assigned(PrevStackItem) then
    PrevStackItem.Clear;
end;

// This should only be called for the first SortStackItem in the SortStack.
procedure TStrataSort<T>.TSortStackItem.AddSingleItem(const Item: T);
begin
  SortItems[0] := Item;
  FCount := 1;
end;

/// This will set Current, FIndex and Eof.
/// Note that Current will never be the same item in more than one SortStackItem.
procedure TStrataSort<T>.TSortStackItem.GetNext;
begin
  if ( PrevStackItem = nil ) or
     PrevStackItem.Eof then
  begin
    if FIndex >= Count then
    begin
      FEof := True;
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
// It sets up FIndex, FCurrent and FEof.
procedure TStrataSort<T>.TSortStackItem.GetFirst;
begin
  if Assigned(PrevStackItem) then
  begin
    PrevStackItem.GetFirst;
  end;
  FIndex := 0;
  FEof := False;
  GetNext;
end;

// This method will merge all the SortStackItems from previous levels, and load them into this level.
// It will only be called when this level is empty.
// It will only be called when all previous levels are full, and the method will fill the sortItems array.
procedure TStrataSort<T>.TSortStackItem.LoadFromPreviousLevels;
var
  ArrayIndex: Integer;
begin
  Assert(Count = 0, 'LoadFromPreviousLevels: Count should be 0.');
  if Assigned(PrevStackItem) then
  begin
    PrevStackItem.GetFirst;
    ArrayIndex := 0;
    while not PrevStackItem.Eof do
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


{ TStrataSort<T>.TComparerInterfaceAdapter<T> }

constructor TStrataSort<T>.TComparerInterfaceAdapter.Create(const AComparer: IComparer<T>);
begin
  FComparer := AComparer;
end;

function TStrataSort<T>.TComparerInterfaceAdapter.Compare(const Left, Right: T): Integer;
begin
  Result := FComparer.Compare(Left, Right);
end;


{ TStrataSort<T> }

/// <summary>
/// This is used to clear everything at the start of a new sort,
/// and to free memory and reference counts at the end of a sort.
/// </summary>
procedure TStrataSort<T>.Clear;
begin
  SortStack.Clear;
  FirstSortStackItem := TSortStackItem.Create(1, nil, SortCompare);
  SortStack.Add(FirstSortStackItem);
  StackTop := 0;    // leave StackTop pointing to the first SortStackItem.
  TopSortStackItem := nil;
end;

/// This method will load the items to be sorted, one at a time, into the SortStack.
procedure TStrataSort<T>.SortRelease(const Item: T);
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

procedure TStrataSort<T>.Release(const Item: T);
begin
  if Assigned(TopSortStackItem) then
    raise ESortError.Create('StrataSort: Release called after RunSort.');
  SortRelease(Item);
end;

// This method sets values in preparation for the sorted items to be retrieved.
procedure TStrataSort<T>.RunSort;
begin
  if Assigned(TopSortStackItem) then
    raise ESortError.Create('StrataSort: RunSort called twice.');
  TopSortStackItem := SortStack[StackTop];
  TopSortStackItem.GetFirst;
end;

// This is not valid until after RunSort.
procedure TStrataSort<T>.GetNext;
begin
  TopSortStackItem.GetNext;
end;

// This is not valid until after RunSort.
function TStrataSort<T>.GetCurrent: T;
begin
  Result := TopSortStackItem.Current;
end;

// This is not valid until after RunSort.
function TStrataSort<T>.GetEof: Boolean;
begin
  Result := TopSortStackItem.Eof;
end;

function TStrataSort<T>.SortReturn: T;
begin
  Result := Current;
  GetNext;
end;

function  TStrataSort<T>.Return: T;
begin
  if not Assigned(TopSortStackItem) then
    raise ESortError.Create('StrataSort: RunSort must be called before Return.');
  Result := SortReturn;
end;

// Sort a list into the specified order.
procedure TStrataSort<T>.Sort(const AList: TList<T>);
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

    for Index := 0 to AList.Count - 1 do
    begin
      Assert(not Eof, 'Sort: Premature Eof.');
      InternalList[Index] := Current;
      GetNext;
    end;
    Assert(Eof, 'Sort: Eof expected.');
  finally
    Clear;
  end;
end;

// Sort everything from one list into another.
procedure TStrataSort<T>.Sort(const ASourceList: TList<T>;
                              const ADestinationList: TList<T>);
var
  Item: T;
begin
  if ADestinationList = ASourceList then
    raise ESortError.Create('Source and Destination lists must not be the same.');
  if ADestinationList.Count > 0 then
    raise ESortError.Create('Destination lists must be empty.');

  Clear;
  try
    for Item in ASourceList do
      SortRelease(Item);

    RunSort;

    ADestinationList.Capacity := ADestinationList.Capacity + ASourceList.Count;
    while not Eof do
      ADestinationList.Add(SortReturn);
  finally
    Clear;
  end;
end;


constructor TStrataSort<T>.Create;
begin
  raise ESortError.Create('TSorter<T>.Create - SortCompare or SortComparer parameter is required.');
end;

constructor TStrataSort<T>.Create(const ASortCompare: TComparison<T>);
begin
  inherited Create;
  SortCompare := ASortCompare;
  SortStack := TObjectList<TSortStackItem>.Create;
  FirstSortStackItem := TSortStackItem.Create(1, nil, SortCompare);
  SortStack.Add(FirstSortStackItem);
  StackTop := 0;    // leave StackTop pointing to the first SortStackItem.
  TopSortStackItem := nil;
end;

constructor TStrataSort<T>.Create(const ASortComparer: IComparer<T>);
begin
  Create(TComparerInterfaceAdapter.Create(ASortComparer).Compare);
end;

destructor TStrataSort<T>.Destroy;
begin
  SortStack.Free;
  inherited;
end;


{ TStrataSort }

// Sort a list into the specified order.
class procedure TStrataSort.Sort<T>(const AList: TList<T>;
                                    const ASortCompare: TComparison<T>);
var
  StrataSort: TStrataSort<T>;
begin
  StrataSort := TStrataSort<T>.Create(ASortCompare);
  try
    StrataSort.Sort(AList);
  finally
    StrataSort.Free;
  end;
end;

class procedure TStrataSort.Sort<T>(const AList: TList<T>;
                                    const ASortComparer: IComparer<T>);
begin
  Sort<T>(AList,
          TStrataSort<T>.TComparerInterfaceAdapter.Create(ASortComparer).Compare);
end;

class procedure TStrataSort.Sort<T>(const ASourceList: TList<T>;
                                    const ADestinationList: TList<T>;
                                    const ASortCompare: TComparison<T>);
var
  StrataSort: TStrataSort<T>;
begin
  StrataSort := TStrataSort<T>.Create(ASortCompare);
  try
    StrataSort.Sort(ASourceList, ADestinationList);
  finally
    StrataSort.Free;
  end;
end;

class procedure TStrataSort.Sort<T>(const ASourceList: TList<T>;
                                    const ADestinationList: TList<T>;
                                    const ASortComparer: IComparer<T>);
begin
  Sort<T>(ASourceList, ADestinationList,
          TStrataSort<T>.TComparerInterfaceAdapter.Create(ASortComparer).Compare);
end;

end.
