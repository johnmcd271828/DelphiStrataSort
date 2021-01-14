// Copyright: John McDonald 2020
//

unit uSortExampleForm;

//  This is a simple example of using the Sort function.
//  It's just intended to show the syntax required to use StrataSort.
//
//  If a lot of data is put into the memo, sorting the memo will be slow
//  because of the time required to reload the memo.

interface

uses
  System.SysUtils, System.Classes, StrUtils, Diagnostics,
  Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Graphics,
  Vcl.ExtCtrls, Generics.Defaults, Generics.Collections,
  StrataSort;

type
  TSortExampleForm = class(TForm)
    MemoBox: TMemo;
    ButtonPanel: TPanel;
    LoadButton: TButton;
    SortAlphabeticallyButton: TButton;
    SortByLengthButton: TButton;
    ShuffleButton: TButton;
    ClearButton: TButton;
    SortedEnumeratorButton: TButton;
    procedure LoadButtonClick(Sender: TObject);
    procedure SortAlphabeticallyButtonClick(Sender: TObject);
    procedure SortByLengthButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure ShuffleButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SortedEnumeratorButtonClick(Sender: TObject);
  private
    procedure TrimAndSortMemoBox(const ASortCompare: TComparison<string>);
    procedure SortMemoBoxUsingReleaseAndReturn(const ASortCompare: TComparison<string>);
    procedure SortMemoBoxUsingSortedEnumerator(const ASortCompare: TComparison<string>);
  end;

var
  SortExampleForm: TSortExampleForm;

implementation

uses Math, TypInfo;

{$R *.dfm}

const
  VegetableList = 'Carrot,Pumpkin,Potato,Sweet Potato,Capsicum,Kale,Eggplant,' +
                  'Artichoke,Cabbage,Peas,Beans,Parsnip,Asparagus,Celery,' +
                  'Zucchini,Tomato,Okra,Broccoli,Lettuce,Bok Choy,Leeks,' +
                  'Mushrooms,Cauliflower,Brussel Sprouts,Spinach,Onions';

function CompareLength(const Left, Right: string): Integer;
begin
  Result := CompareValue(Left.Length, Right.Length);
end;

function RandomCompare(const Left, Right: string): Integer;
begin
  // This is enough to shuffle the list.
  // It will "randomly" return -1 or 1.
  Result := Random(2) * 2 - 1;
end;

{ TSortExampleForm }

// This is an example of sorting a TList<>
procedure TSortExampleForm.TrimAndSortMemoBox(const ASortCompare: TComparison<string>);
var
  StringList: TList<string>;
  Str: string;
begin
  StringList := TList<string>.Create;
  try
    for Str in MemoBox.Lines do
    begin
      if Trim(Str) <> '' then
        StringList.Add(Trim(Str));
    end;
    TStrataSort.Sort<string>(StringList, ASortCompare);
    MemoBox.Clear;
    for Str in StringList do
      MemoBox.Lines.Add(Str);
  finally
    StringList.Free;
  end;
end;

// This is an example of sorting without using a TList<>,
// by creating a TStrataSorter object, then using Release, RunSort and Return.
procedure TSortExampleForm.SortMemoBoxUsingReleaseAndReturn(const ASortCompare: TComparison<string>);
var
  Sorter: TStrataSorter<string>;
  Str: string;
begin
  Sorter := TStrataSorter<string>.Create(ASortCompare);
  try
    for Str in MemoBox.Lines do
    begin
      if Trim(Str) <> '' then
        Sorter.Release(Trim(Str));
    end;
    Sorter.RunSort;
    MemoBox.Clear;
    while not Sorter.EndOfSort do
      MemoBox.Lines.Add(Sorter.Return);
  finally
    Sorter.Free;
  end;
end;

// This is an example of sorting to an IEnumerable<T>
procedure TSortExampleForm.SortMemoBoxUsingSortedEnumerator(const ASortCompare: TComparison<string>);
var
  StringList: TList<string>;
  Str: string;
begin
  StringList := TList<string>.Create;
  try
    for Str in MemoBox.Lines do
    begin
      if Trim(Str) <> '' then
        StringList.Add(Trim(Str));
    end;

    MemoBox.Clear;
    for Str in TStrataSort.Sorted<string>(StringList, ASortCompare) do
      MemoBox.Lines.Add(Str);
  finally
    StringList.Free;
  end;
end;

{ Event Handlers }

procedure TSortExampleForm.FormCreate(Sender: TObject);
begin
  MemoBox.Lines.StrictDelimiter := True;
  MemoBox.Lines.CommaText := VegetableList;
end;

procedure TSortExampleForm.LoadButtonClick(Sender: TObject);
begin
  MemoBox.Lines.CommaText := VegetableList;
end;

procedure TSortExampleForm.SortAlphabeticallyButtonClick(Sender: TObject);
begin
  TrimAndSortMemoBox(CompareText);
end;

procedure TSortExampleForm.SortByLengthButtonClick(Sender: TObject);
begin
  SortMemoBoxUsingReleaseAndReturn(CompareLength);
end;

procedure TSortExampleForm.SortedEnumeratorButtonClick(Sender: TObject);
begin
  SortMemoBoxUsingSortedEnumerator(CompareText);
end;

procedure TSortExampleForm.ShuffleButtonClick(Sender: TObject);
begin
  // This will mix up the list.
  TrimAndSortMemoBox(RandomCompare);
end;

procedure TSortExampleForm.ClearButtonClick(Sender: TObject);
begin
  MemoBox.Clear;
end;

end.
