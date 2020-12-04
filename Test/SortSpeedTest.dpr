program SortSpeedTest;

uses
  Vcl.Forms,
  StrataSort in '..\StrataSort.pas',
  uSortTestTypes in 'uSortTestTypes.pas',
  uCompareCounter in 'uCompareCounter.pas',
  uSortSpeedTest in 'uSortSpeedTest.pas' {SortSpeedTestForm};

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSortSpeedTestForm, SortSpeedTestForm);
  Application.Run;
end.
