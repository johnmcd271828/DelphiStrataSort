program SortExample;

uses
  Vcl.Forms,
  uSortExampleForm in 'uSortExampleForm.pas' {SortExampleForm},
  StrataSort in '..\StrataSort.pas';

{$R *.res}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TSortExampleForm, SortExampleForm);
  Application.Run;
end.
