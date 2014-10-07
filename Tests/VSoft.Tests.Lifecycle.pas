unit VSoft.Tests.Lifecycle;

interface
uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TWeakReferencesLifecycleTest = class(TObject)
  public
    [Test]
    procedure TWeakReferencedObject_Is_ReferenceCounted;
    [Test]
    procedure TNoCountedWeakReferencedObject_Is_Not_ReferenceCounted;
  end;

implementation

uses
  VSoft.Tests.Classhelpers.Assert, VSoft.WeakReference;


{ TWeakReferencesLifecycleTest }

procedure TWeakReferencesLifecycleTest.TNoCountedWeakReferencedObject_Is_Not_ReferenceCounted;
var
  lNoCounted: TNoCountedWeakReferencedObject;
begin
  lNoCounted := TNoCountedWeakReferencedObject.Create;
  Assert.IsNotReferenceCounted<IWeakReferenceableObject>(lNoCounted, lNoCounted);
end;

procedure TWeakReferencesLifecycleTest.TWeakReferencedObject_Is_ReferenceCounted;
begin
  Assert.IsReferenceCounted<IWeakReferenceableObject>(TWeakReferencedObject.Create);
end;

initialization
  TDUnitX.RegisterTestFixture(TWeakReferencesLifecycleTest);
end.
