program SortExample;

uses
  Vcl.Forms,
  uSortExampleForm in 'uSortExampleForm.pas' {SortTestForm},
  StrataSort in '..\StrataSort.pas';

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSortTestForm, SortTestForm);
  Application.Run;
end.
