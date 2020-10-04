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
  TSortTestForm = class(TForm)
    MemoBox: TMemo;
    ButtonPanel: TPanel;
    LoadButton: TButton;
    SortAlphabeticallyButton: TButton;
    SortByLengthButton: TButton;
    ShuffleButton: TButton;
    ClearButton: TButton;
    procedure LoadButtonClick(Sender: TObject);
    procedure SortAlphabeticallyButtonClick(Sender: TObject);
    procedure SortByLengthButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure ShuffleButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure TrimAndSortMemoBox(const ASortCompare: TComparison<string>);
    procedure SortMemoBoxUsingReleaseAndReturn(const ASortCompare: TComparison<string>);
  end;

var
  SortTestForm: TSortTestForm;

implementation

uses Math, TypInfo;

{$R *.dfm}

const
  VegetableList = 'Carrot,Pumpkin,Potato,Sweet Potato,Capsicum,Kale,Eggplant,' +
                  'Artichoke,Cabbage,Peas,Beans,Parsnip,Asparagus,Celery,' +
                  'Zucchini,Tomato,Okra,Broccoli,Lettuce,Bok Choy,Leeks,' +
                  'Mushrooms,Cauliflower,Brussel Sprouts,Spinach,Onions';

{ TSortTestForm }

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

// This is an example of sorting a TList<>
procedure TSortTestForm.TrimAndSortMemoBox(const ASortCompare: TComparison<string>);
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
    TStrataSort<string>.Sort(StringList, ASortCompare);
    MemoBox.Clear;
    for Str in StringList do
      MemoBox.Lines.Add(Str);
  finally
    StringList.Free;
  end;
end;

// This is an examle of sorting without using a TList<>,
// by creating a StrataSort object, then using Release, RunSort and Return.
procedure TSortTestForm.SortMemoBoxUsingReleaseAndReturn(const ASortCompare: TComparison<string>);
var
  Sorter: TStrataSort<string>;
  Str: string;
begin
  Sorter := TStrataSort<string>.Create(ASortCompare);
  try
    for Str in MemoBox.Lines do
    begin
      if Trim(Str) <> '' then
        Sorter.Release(Trim(Str));
    end;
    Sorter.RunSort;
    MemoBox.Clear;
    while not Sorter.Eof do
      MemoBox.Lines.Add(Sorter.Return);
  finally
    Sorter.Free;
  end;
end;

{ Event Handlers }

procedure TSortTestForm.FormCreate(Sender: TObject);
begin
  MemoBox.Lines.StrictDelimiter := True;
  MemoBox.Lines.CommaText := VegetableList;
end;

procedure TSortTestForm.LoadButtonClick(Sender: TObject);
begin
  MemoBox.Lines.CommaText := VegetableList;
end;

procedure TSortTestForm.SortAlphabeticallyButtonClick(Sender: TObject);
begin
  TrimAndSortMemoBox(CompareText);
end;

procedure TSortTestForm.SortByLengthButtonClick(Sender: TObject);
begin
  SortMemoBoxUsingReleaseAndReturn(CompareLength);
end;

procedure TSortTestForm.ShuffleButtonClick(Sender: TObject);
begin
  // This will mix up the list.
  TrimAndSortMemoBox(RandomCompare);
end;

procedure TSortTestForm.ClearButtonClick(Sender: TObject);
begin
  MemoBox.Clear;
end;

end.
