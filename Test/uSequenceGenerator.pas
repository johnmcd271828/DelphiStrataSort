unit uSequenceGenerator;

interface

type
  TSequenceProc = reference to procedure(const ValueArray: TArray<Integer>;
                                         const Count: Integer);

// This will generate every significantly different list of integers of
// every length up to MaxCount length.
// For example, if MaxCount = 3, it will test:
// (), (1), (1,1), (1,2), (2,1),
// (1,1,1), (1,1,2), (1,2,1), (2,1,1), (1,2,2), (2,1,2), (2,2,1),
// (1,2,3), (1,3,2), (2,1,3), (2,3,1), (3,1,2), (3,2,1)
//
// It won't generate (2,2,2) because that is the same as (1,1,1),
// it won't generate (2,2,3) because that is the same as (1,1,2).
//
// When MaxCount =  8, it runs 598,445 tests and takes about 3 seconds to run on B7.
// When MaxCount =  9, it runs 7,685,706 tests and takes about 30 seconds to run on B7.
// When MaxCount = 10, it runs 109,933,269 tests and takes about 9 minutes to run on B7.
//
// SequenceProc will be called for each sequence,
// - the sequence is in the first Count values of its ValueArray argument.
//
procedure GenerateSequences(const SequenceProc: TSequenceProc;
                            const MaxCount: Integer);

implementation

procedure CreateSequences(const ValueArray: TArray<Integer>;
                          const Count: Integer;
                          const UniqueArray: TArray<Integer>;
                          const UniqueCount: Integer;
                          const MaxCount: Integer;
                          const SequenceProc: TSequenceProc);
var
  I: Integer;
  NewValue: Integer;
begin
  SequenceProc(ValueArray, Count);
  if Count < MaxCount then
  begin
    // We create new sequences by adding a value to the end of an existing sequence.
    // We can add a value that we have used previously,
    // a value that is greater than all the existing values,
    // a value that is smaller than all the existing values,
    // or a value that is in-between existing values.

    for I := 0 to UniqueCount - 1 do
    begin
      // Add a value which is equal to one of the existing values to the end of the sequence.
      ValueArray[Count] := UniqueArray[I];
      CreateSequences(ValueArray, Count + 1, UniqueArray, UniqueCount, MaxCount, SequenceProc);
    end;

    // Add a value which is less than any of the existing values to the end of the sequence.
    NewValue := 1 shl ( MaxCount - Count - 1 );
    ValueArray[Count] := NewValue;
    UniqueArray[UniqueCount] := NewValue;
    CreateSequences(ValueArray, Count + 1, UniqueArray, UniqueCount + 1, MaxCount, SequenceProc);

    for I := 0 to UniqueCount - 1 do
    begin
      // Add a value which is a little more than one of the existing values to the end of the sequence.
      NewValue := UniqueArray[I] + ( 1 shl ( MaxCount - Count - 1 ) );
      ValueArray[Count] := NewValue;
      UniqueArray[UniqueCount] := NewValue;
      CreateSequences(ValueArray, Count + 1, UniqueArray, UniqueCount + 1, MaxCount, SequenceProc);
    end;
  end;
end;

procedure GenerateSequences(const SequenceProc: TSequenceProc;
                            const MaxCount: Integer);
var
  ValueArray: TArray<Integer>;
  UniqueArray: TArray<Integer>;
begin
  SetLength(ValueArray, MaxCount);
  SetLength(UniqueArray, MaxCount);
  CreateSequences(ValueArray, 0,
                  UniqueArray, 0,
                  MaxCount,
                  SequenceProc);
end;

end.
