program SortUnitTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  StrataSort in '..\StrataSort.pas',
  uSortTestTypes in 'uSortTestTypes.pas',
  uSequenceGenerator in 'uSequenceGenerator.pas',
  uSortUnitTests in 'uSortUnitTests.pas',
  uSortEnumeratorUnitTests in 'uSortEnumeratorUnitTests.pas';

{$R *.RES}

begin
  ReportMemoryLeaksOnShutdown := True;
  DUnitTestRunner.RunRegisteredTests;
end.

