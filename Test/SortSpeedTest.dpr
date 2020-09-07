program SortSpeedTest;

uses
  Vcl.Forms,
  uSortSpeedTest in 'uSortSpeedTest.pas' {SortSpeedTestForm},
  StrataSort in '..\StrataSort.pas',
  uSortTestTypes in 'uSortTestTypes.pas';

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSortSpeedTestForm, SortSpeedTestForm);
  Application.Run;
end.
