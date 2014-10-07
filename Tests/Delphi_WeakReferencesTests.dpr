program Delphi_WeakReferencesTests;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  DUnitX.Loggers.XML.NUnit,
  DUnitX.Windows.Console,
  VSoft.WeakReference in '..\VSoft.WeakReference.pas',
  VSoft.Tests.WeakReference in 'VSoft.Tests.WeakReference.pas',
  VSoft.Tests.Lifecycle in 'VSoft.Tests.Lifecycle.pas',
  VSoft.Tests.Classhelpers.Assert in 'VSoft.Tests.Classhelpers.Assert.pas';

{$R *.RES}

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
  try
    //Create the runner
    runner := TDUnitX.CreateRunner;
    runner.UseRTTI := True;
    //tell the runner how we will log things
    logger := TDUnitXConsoleLogger.Create;
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create;
    runner.AddLogger(logger);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;

    System.Writeln('Done.. press any key to quit.');
    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

