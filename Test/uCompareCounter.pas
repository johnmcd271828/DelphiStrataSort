// Copyright: John McDonald 2020
//

unit uCompareCounter;

interface
  uses SysUtils, Classes, Generics.Defaults;

type
  // CompareCounter is used to count the number of times Compare is called during a sort.
  // CompareCounter must be created using TCompareCounter<T>.MakeCompareCounter
  // and referenced as an ICompareCounter<T>;
  ICompareCounter<T> = interface
    procedure Clear;
    function  GetCompare: TComparison<T>;
    function  GetCount: Int64;
    property Compare: TComparison<T> read GetCompare;
    property Count: Int64 read GetCount;
  end;

  TCompareCounter<T> = class(TInterfacedObject, ICompareCounter<T>)
  private
    FCount: Int64;
    FCompareFn: TComparison<T>;
    function  Compare(const Left, Right: T): Integer;
    procedure Clear;
    function  GetCompare: TComparison<T>;
    function  GetCount: Int64;
    constructor Create(const ACompareFn: TComparison<T>);
  public
    class function MakeCompareCounter(const ACompareFn: TComparison<T>): ICompareCounter<T>;
  end;

implementation

{ TCompareCounter<T> }

function TCompareCounter<T>.Compare(const Left, Right: T): Integer;
begin
  Inc(FCount);
  Result := FCompareFn(Left, Right);
end;

procedure TCompareCounter<T>.Clear;
begin
  FCount := 0;
end;

function TCompareCounter<T>.GetCompare: TComparison<T>;
begin
  Result := Compare;
end;

function TCompareCounter<T>.GetCount: Int64;
begin
  Result := FCount;
end;

constructor TCompareCounter<T>.Create(const ACompareFn: TComparison<T>);
begin
  FCompareFn := ACompareFn;
  FCount := 0;
end;

class function TCompareCounter<T>.MakeCompareCounter(const ACompareFn: TComparison<T>): ICompareCounter<T>;
begin
  Result := Create(ACompareFn);
end;

end.
