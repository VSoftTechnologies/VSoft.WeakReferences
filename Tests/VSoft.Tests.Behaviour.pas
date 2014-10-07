unit VSoft.Tests.Behaviour;

interface
uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TWeakReferencesBehaviourTest = class(TObject)
  public
    [Test]
    procedure TWeakReferencedObject_Is_WeakReferenceable;
    [Test]
    procedure TNoCountedWeakReferencedObject_Is_WeakReferenceable;
    [Test]
    procedure TInterfacedObject_Is_Not_WeakReferenceable;
  end;

implementation

uses
  VSoft.Tests.Classhelpers.Assert, VSoft.WeakReference, System.SysUtils;

{ TWeakReferencesBehaviourTest }

procedure TWeakReferencesBehaviourTest.TInterfacedObject_Is_Not_WeakReferenceable;
begin
  Assert.IsNotWeakReferenceable<IInterface>(TInterfacedObject.Create);
end;

procedure TWeakReferencesBehaviourTest.TNoCountedWeakReferencedObject_Is_WeakReferenceable;
var
  lNoCounted: TNoCountedWeakReferencedObject;
begin
  lNoCounted := TNoCountedWeakReferencedObject.Create;
  try
    Assert.IsWeakReferenceable<IInterface>(lNoCounted);
  finally
    FreeAndNil(lNoCounted);
  end;
end;

procedure TWeakReferencesBehaviourTest.TWeakReferencedObject_Is_WeakReferenceable;
begin
  Assert.IsWeakReferenceable<IInterface>(TWeakReferencedObject.Create);
end;

initialization
  TDUnitX.RegisterTestFixture(TWeakReferencesBehaviourTest);
end.
