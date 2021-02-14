StrataSort
----------
StrataSort is an open source stable sort implemented in Delphi.<br>
As it is a stable sort, it will preserve the order of items with equal keys.

The sort algorithm supplied with Delphi, QuickSort, is not stable, so the order of items with equal keys sorted by QuickSort is arbitrary.

StrataSort and QuickSort have similar speeds. StrataSort is generally a little faster than QuickSort when sorting objects in 32 bit programs, and a little slower when sorting in 64 bit programs or when sorting reference counted items.

StrataSort uses more memory than QuickSort. The extra memory used by StrataSort is between one and two times the amount of memory used by the list. This is usually much less than the memory used by the objects in the list.

Usage
-----
To use StrataSort, include StrataSort in the uses clause.<br>
You will usually also need Generics.Defaults and Generics.Collections in the uses clause.

In the following examples, CompareWidgets, Widget and WidgetList are declared as follows:
```
function CompareWidgets(const Left, Right: TWidget): Integer;

var
  Widget: TWidget;
  WidgetList: TList<TWidget>;
  //  or 
  //  WidgetList: TObjectList<TWidget>
```

The compare function is a `TComparison<T>`, defined in Generics.Defaults as a<br>
`reference to function(const Left, Right: T): Integer;`<br>
You can use anonymous methods as the compare function.

TWidget can be anything that can be stored in a generic TList; a class, record, interface, Integer, string, etc.

To sort WidgetList, call:<br>
`TStrataSort.Sort<TWidget>(WidgetList, CompareWidgets);`<br>

If SourceList and DestinationList are declared as follows
```
var
  SourceList: TList<TWidget>;
  DestinationList: TList<TWidget>;
```

You can sort items from one list to another:<br>
`TStrataSort.Sort<TWidget>(SourceList, DestinationList, CompareWidgets);`<br>
If the destination list is not empty, the sorted records are added to the end of the list.


You can interate through the items in sorted order without actually sorting the list.
To do this, use a for ... in statement:
```
var
  Widget: TWidget;
...
  for Widget in TStrataSort.Sorted<TWidget>(WidgetList, CompareWidgets) do
    ....
```
This works by creating a sorted `IEnumerable<T>` from the list.


StrataSort can sort items that are not in a list. This can be used to easily extend the functionality to other collection types.
There is an example of this in the SortExample program, the `SortMemoBoxUsingReleaseAndReturn` method.

Supplied Example and Test programs
----------------------------------
The supplied program group includes
- a sample program with a couple of simple examples,
- a unit test program that
  - tests sorting of object, interfaces, records, integers, bytes, and strings,
  - tests sorting all different sequences of items up to 9 items long,
  - tests TStrataSort's public methods.
- a speed test program to test its performance when sorting different size lists, different types, and different initial sequences.

Unit tests will raise and catch ESortError and ETriggeredException. This is to test error handling and error recovery.<br>
You can safely tell the IDE to "Ignore this exception type" for ETriggeredException. It is only raised in the unit tests.<br>
You might not want to do that for ESortError. It is raised when StrataSort methods are called incorrectly.

The unit test "TestSequences" will take a while, maybe 30 sec, because it is running 7,685,706 different sorts.

StrataSort has been tested with billions of different starting sequences.

Delphi Version Compatibility
----------------------------
StrataSort works with recent versions of Delphi; XE6 and later. It may work with some versions before that, but it is dependent on the `List` property of `TList<T>`, which was introduced in a version after Delphi XE2.

StrataSort works fine in Delphi 10.3.3 (Rio), but SortUnitTests and SortSpeedTest will not compile in Delphi 10.3.3 (Rio).
Something was broken in the Delphi 10.3 compiler and was fixed in 10.4.<br>
(SortUnitTests and SortSpeedTest work ok in Delphi 10.2 and are working again in Delphi 10.4.1 (Sydney) ). 

Compiling StrataSort in Delphi XE6 shows an incorrect warning on the line:<br>
`  Create(MakeTComparison(ASortComparer));`<br>
in the constructor<br>
`  constructor TStrataSort<T>.Create(const ASortComparer: IComparer<T>);`
