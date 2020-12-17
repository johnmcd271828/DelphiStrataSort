// Copyright: John McDonald 2020
//

unit uSequenceGenerator;

interface

type
  TSequenceProc = reference to procedure(const ValueArray: TArray<Integer>;
                                         const Count: Integer);

  TSequenceGenerator = class
  private
    class procedure CreateSequences(const ValueArray: TArray<Integer>;
                                    const Count: Integer;
                                    const UniqueArray: TArray<Integer>;
                                    const UniqueCount: Integer;
                                    const MaxCount: Integer;
                                    const SequenceProc: TSequenceProc);
  public
    // This will generate every significantly different list of integers of
    // every length up to MaxCount length.
    // For example, if MaxCount = 3, it will test sequences equivalent to:
    // (), (1), (1,1), (1,2), (2,1),
    // (1,1,1), (1,1,2), (1,2,1), (2,1,1), (1,2,2), (2,1,2), (2,2,1),
    // (1,2,3), (1,3,2), (2,1,3), (2,3,1), (3,1,2), (3,2,1)
    //
    // It won't generate (2,2,2) because that is the same as (1,1,1),
    // it won't generate (2,2,3) because that is the same as (1,1,2).
    //
    // The actual sequences generated for MaxCount = 3 are
    // (), (4), (4,4), (4,6), (4,2)
    // (4,4,4), (4,4,5), (4,6,4), (4,2,2), (4,6,6), (4,2,4), (4,4,1)
    // (4,6,7), (4,6,5), (4,2,5), (4,6,1), (4,2,3), (4,2,1)
    // but these are equivalent to the sequences above for MaxCount = 3.
    //
    // When MaxCount =  8, it generates 598,445 sequences which take about 3 seconds to sort on my test PC.
    // When MaxCount =  9, it generates 7,685,706 sequences which take about 30 seconds to sort on my test PC.
    // When MaxCount = 10, it generates 109,933,269 sequences which take about 9 minutes to sort on my test PC.

    /// <summary>
    /// This will generate every significantly different list of integers of
    /// every length up to MaxCount length.
    /// </summary>
    /// <param name="SequenceProc">
    /// A procedure to be called for each sequence
    /// - the sequence will be the first Count values of its ValueArray argument.
    /// </param>
    /// <param name="MaxCount">
    /// The maximum length of a sequence.
    /// </param>
    class procedure GenerateSequences(const SequenceProc: TSequenceProc;
                                      const MaxCount: Integer);
  end;

implementation

class procedure TSequenceGenerator.CreateSequences(const ValueArray: TArray<Integer>;
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
    //
    // The values are initially spaced far apart, so that we can add
    // later values in between previously generated values.

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

class procedure TSequenceGenerator.GenerateSequences(const SequenceProc: TSequenceProc;
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
