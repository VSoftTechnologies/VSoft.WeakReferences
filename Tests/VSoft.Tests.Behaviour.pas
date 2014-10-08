unit VSoft.Tests.Behaviour;

interface
uses
  DUnitX.TestFramework,
  VSoft.WeakReference;

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
    [Test]
    procedure TAggregatedWeakReferencedObject_Is_WeakReferenceable;
    [Test]
    procedure TAggregatedWeakReferencedObject_Delegate_Works;
    [Test]
    procedure TAggregatedWeakReferencedObject_ReferenceCounting_Works;
  end;

implementation

uses
  VSoft.Tests.Classhelpers.Assert,
  System.SysUtils,
  VSoft.Tests.Behaviour.UseCases;

{ TWeakReferencesBehaviourTest }

procedure TWeakReferencesBehaviourTest.TAggregatedWeakReferencedObject_Is_WeakReferenceable;
var
  lController: IWeakReferenceableObject;
  lAggregatedObj: TAggregatedWeakReferencedObject<IWeakReferenceableObject>;
begin
  // note that this creation of an AggregatedObject is not the way its meant to be used. Creating an AggregatedObject
  // outside its Controller is not recommended and only used for this special testcase
  lController := TWeakReferencedObject.Create;
  lAggregatedObj := TAggregatedWeakReferencedObject<IWeakReferenceableObject>.Create(lController);
  try
    Assert.IsWeakReferenceable<IWeakReferenceableObject>(lAggregatedObj);
  finally
    FreeAndNil(lAggregatedObj);
  end;
end;

procedure TWeakReferencesBehaviourTest.TAggregatedWeakReferencedObject_ReferenceCounting_Works;
var
  lInterfaceNotToDelegateRef: IInterfaceNotToDelegate;
  lInterfaceToDelegateRef: IInterfaceToDelegate;
begin
  // This Interface is implemented by TClassThatDelegatesAnInterface
  lInterfaceNotToDelegateRef := TClassThatDelegatesAnInterface.Create;
  Assert.AreEqual(1, lInterfaceNotToDelegateRef.RefCount);

  // This Interfaces is implemented by TClassThatDelegatesAnInterface, but has been delegated to TClassThatImplementsTheDelegatedInterface
  Assert.IsTrue(Supports(lInterfaceNotToDelegateRef, IInterfaceToDelegate, lInterfaceToDelegateRef));
  Assert.AreEqual(2, lInterfaceNotToDelegateRef.RefCount);
  // As the AggregatedObject only routes the reference counting to its controller, the Refcount call must be equal
  Assert.AreEqual(2, lInterfaceToDelegateRef.RefCount);
end;

procedure TWeakReferencesBehaviourTest.TAggregatedWeakReferencedObject_Delegate_Works;
var
  lInterfaceNotToDelegateRef: IInterfaceNotToDelegate;
  lInterfaceToDelegateRef: IInterfaceToDelegate;
  lExpectedNameOf_IInterfaceNotToDelegate_Implementer: String;
  lExpectedNameOf_IInterfaceToDelegate_Implementer: String;
begin
  // This Interface is implemented by TClassThatDelegatesAnInterface
  lInterfaceNotToDelegateRef := TClassThatDelegatesAnInterface.Create;
  // This Interfaces is implemented by TClassThatDelegatesAnInterface, but has been delegated to TClassThatImplementsTheDelegatedInterface
  Assert.IsTrue(Supports(lInterfaceNotToDelegateRef, IInterfaceToDelegate, lInterfaceToDelegateRef));

  lExpectedNameOf_IInterfaceNotToDelegate_Implementer := Format(TELLMYNAME, [TClassThatDelegatesAnInterface.ClassName]);
  lExpectedNameOf_IInterfaceToDelegate_Implementer := Format(TELLMYNAMEANDCONTROLLER, [TClassThatImplementsTheDelegatedInterface<IInterfaceNotToDelegate>.ClassName, TClassThatDelegatesAnInterface.ClassName]);

  Assert.AreEqual(lInterfaceNotToDelegateRef.TellMeYourName, lExpectedNameOf_IInterfaceNotToDelegate_Implementer);
  Assert.AreEqual(lInterfaceToDelegateRef.TellMeYourName, lExpectedNameOf_IInterfaceToDelegate_Implementer);
end;

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
