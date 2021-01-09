StrataSort
----------
StrataSort is an open source stable sort implemented in Delphi.
A stable sort will preserve the order of items with equal keys.
The sort algorithm supplied with Delphi, QuickSort, is not stable, so the order of items with equal keys sorted by QuickSort is arbitrary.

StrataSort and QuickSort have similar speeds. StrataSort is generally a little faster than QuickSort when sorting objects in 32 bit programs, and a little slower when sorting in 64 bit programs or when sorting reference counted items.

StrataSort uses more memory that QuickSort. QuickSort is an in-place sort, so if the data is already in a list, it uses very little extra memory. The extra memory used by StrataSort is between one and two times the amount of memory used by the list. This is usually much less than the memory used by the objects in the list.

The code required to sort a TList of Widgets is:
  TStrataSort.Sort<TWidget>(WidgetList, CompareWidgets);

The compare function is a TComparison<T>, defined in Generics.Defaults as a
    reference to function(const Left, Right: T): Integer;

This will sort items in a TList<T> or a TObjectList<T>. The items can be anything that can be stored in a generic TList.

It can sort items from one list to another:
  TStrataSort.Sort<TWidget>(SourceList, DestinationList, CompareWidgets);
If the destination list is not empty, the sorted records are added to the end of the list.

It can sort items that are not in a list. There is an example of this in the SortExample program - SortMemoBoxUsingReleaseAndReturn.

The supplied program group includes
- a sample program with a couple of simple examples,
- a unit test program that
  - tests sorting of object, interfaces, records, integers, bytes, and strings,
  - tests all different sequences of items up to 9 items long,
  - tests TStrataSort's public methods.
- a speed test program to test its performance when sorting different size lists, different types, and different initial sequences.

The sort class works with recent versions of Delphi. I don't know the earliest version that it will work with, but it is dependent on the List property of TList<T>, which was introduced some time after Delphi XE2.

The SortUnitTest program and SortSpeedTest program do not compile in Delphi 10.3.3. Something was broken in Delphi 10.3 and was fixed in 10.4.
