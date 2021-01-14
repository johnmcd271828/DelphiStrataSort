StrataSort
----------
StrataSort is an open source stable sort implemented in Delphi.<br>
A stable sort will preserve the order of items with equal keys.

The sort algorithm supplied with Delphi, QuickSort, is not stable, so the order of items with equal keys sorted by QuickSort is arbitrary.

StrataSort and QuickSort have similar speeds. StrataSort is generally a little faster than QuickSort when sorting objects in 32 bit programs, and a little slower when sorting in 64 bit programs or when sorting reference counted items.

StrataSort uses more memory than QuickSort. The extra memory used by StrataSort is between one and two times the amount of memory used by the list. This is usually much less than the memory used by the objects in the list.

The code required to sort a TList of Widgets is:<br>
`TStrataSort.Sort<TWidget>(WidgetList, CompareWidgets);`

This will sort items in a TList<T> or a TObjectList<T>. The items can be anything that can be stored in a generic TList.

It can sort items from one list to another:<br>
`TStrataSort.Sort<TWidget>(SourceList, DestinationList, CompareWidgets);`<br>
If the destination list is not empty, the sorted records are added to the end of the list.

It can create a sorted IEnumerable<T> from a list, so that you can use code like:
```
var
  Widget: TWidget;
...
  for Widget in TStrataSort.Sorted<TWidget>(WidgetList, CompareWidgets) do
    ....
```

It can sort items that are not in a list. There is an example of this in the SortExample program, the `SortMemoBoxUsingReleaseAndReturn` method.

The compare function is a TComparison<T>, defined in Generics.Defaults as a<br>
`reference to function(const Left, Right: T): Integer;`

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

StrataSort works with recent versions of Delphi; XE6 and later. It may work with some versions before that, but it is dependent on the List property of TList<T>, which was introduced in a version after Delphi XE2.

It works ok in Delphi 10.3.3 (Rio), but SortUnitTests and SortSpeedTest will not compile.
Something was broken in Delphi 10.3 and was fixed in 10.4. (SortUnitTests and SortSpeedTest work ok in Delphi 10.2 and are working again in Delphi 10.4.1 (Sydney) ). 

Compiling StrataSort in Delphi XE6 shows an incorrect warning on the line:<br>
  Create(MakeTComparison(ASortComparer));<br>
in the constructor<br>
  constructor TStrataSort<T>.Create(const ASortComparer: IComparer<T>);

