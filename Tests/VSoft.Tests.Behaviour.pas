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
    procedure TAggregatedObject_Is_Not_WeakReferenceable;
    [Test]
    procedure TContainedObject_Is_Not_WeakReferenceable;
    [Test]
    procedure TObject_Is_Not_WeakReferenceable;
    [Test]
    procedure TAggregatedWeakReferencedObject_Is_WeakReferenceable;
    [Test]
    procedure TAggregatedWeakReferencedObject_Delegate_Works;
    [Test]
    procedure TAggregatedWeakReferencedObject_QueryInterface_Works;
    [Test]
    procedure TAggregatedWeakReferencedObject_ReferenceCounting_Works;
    [Test]
    procedure TContainedWeakReferencedObject_Is_WeakReferenceable;
    [Test]
    procedure TContainedWeakReferencedObject_Delegate_Works;
    [Test]
    procedure TContainedWeakReferencedObject_QueryInterface_Works;
    [Test]
    procedure TContainedWeakReferencedObject_ReferenceCounting_Works;
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

procedure TWeakReferencesBehaviourTest.TAggregatedWeakReferencedObject_QueryInterface_Works;
var
  lInterfaceNotToDelegateRef: IInterfaceNotToDelegate;
  lInterfaceToDelegateRef: IInterfaceToDelegate;
begin
  // This Interface is implemented by TClassThatDelegatesAnInterface
  lInterfaceNotToDelegateRef := TObjectThatDelegatesAnInterfaceToAggregatedObject.Create;
  Assert.AreEqual(1, lInterfaceNotToDelegateRef.RefCount);

  // This Interfaces is implemented by TClassThatDelegatesAnInterface, but has been delegated to TClassThatImplementsTheDelegatedInterface
  Assert.IsTrue(Supports(lInterfaceNotToDelegateRef, IInterfaceToDelegate, lInterfaceToDelegateRef));
  // So as TAggregatedWeakReferencedObjects route QueryInterface (IInterface) to its Controller, the other way round must work, too
  Assert.IsTrue(Supports(lInterfaceToDelegateRef, IInterfaceNotToDelegate));
end;

procedure TWeakReferencesBehaviourTest.TAggregatedWeakReferencedObject_ReferenceCounting_Works;
var
  lInterfaceNotToDelegateRef: IInterfaceNotToDelegate;
  lInterfaceToDelegateRef: IInterfaceToDelegate;
begin
  // This Interface is implemented by TClassThatDelegatesAnInterface
  lInterfaceNotToDelegateRef := TObjectThatDelegatesAnInterfaceToAggregatedObject.Create;
  Assert.AreEqual(1, lInterfaceNotToDelegateRef.RefCount);

  // This Interfaces is implemented by TClassThatDelegatesAnInterface, but has been delegated to TClassThatImplementsTheDelegatedInterface
  Assert.IsTrue(Supports(lInterfaceNotToDelegateRef, IInterfaceToDelegate, lInterfaceToDelegateRef));
  Assert.AreEqual(2, lInterfaceNotToDelegateRef.RefCount);
  // As the AggregatedObject only routes the reference counting to its controller, the Refcount call must be equal
  Assert.AreEqual(2, lInterfaceToDelegateRef.RefCount);
end;

procedure TWeakReferencesBehaviourTest.TContainedObject_Is_Not_WeakReferenceable;
var
  lContainedObj: TSimpleContainedObject;
  lController: IInterface;
begin
  lController := TInterfacedObject.Create;
  lContainedObj := TSimpleContainedObject.Create(lController);
  try
    Assert.IsNotWeakReferenceable<IInterface>(lContainedObj);
  finally
    FreeAndNil(lContainedObj);
  end;
end;

procedure TWeakReferencesBehaviourTest.TContainedWeakReferencedObject_Delegate_Works;
var
  lInterfaceNotToDelegateRef: IInterfaceNotToDelegate;
  lInterfaceToDelegateRef: IInterfaceToDelegate;
  lExpectedNameOf_IInterfaceNotToDelegate_Implementer: String;
  lExpectedNameOf_IInterfaceToDelegate_Implementer: String;
begin
  // This Interface is implemented by TClassThatDelegatesAnInterface
  lInterfaceNotToDelegateRef := TObjectThatDelegatesAnInterfaceToContainedObject.Create;
  // This Interfaces is implemented by TClassThatDelegatesAnInterface, but has been delegated to TClassThatImplementsTheDelegatedInterface
  Assert.IsTrue(Supports(lInterfaceNotToDelegateRef, IInterfaceToDelegate, lInterfaceToDelegateRef));

  lExpectedNameOf_IInterfaceNotToDelegate_Implementer := Format(TELLMYNAME, [TObjectThatDelegatesAnInterfaceToContainedObject.ClassName]);
  lExpectedNameOf_IInterfaceToDelegate_Implementer := Format(TELLMYNAMEANDCONTROLLER, [TContainedObjectThatImplementsTheDelegatedInterface<IInterfaceNotToDelegate>.ClassName, TObjectThatDelegatesAnInterfaceToContainedObject.ClassName]);

  Assert.AreEqual(lInterfaceNotToDelegateRef.TellMeYourName, lExpectedNameOf_IInterfaceNotToDelegate_Implementer);
  Assert.AreEqual(lInterfaceToDelegateRef.TellMeYourName, lExpectedNameOf_IInterfaceToDelegate_Implementer);
end;

procedure TWeakReferencesBehaviourTest.TContainedWeakReferencedObject_Is_WeakReferenceable;
var
  lController: IWeakReferenceableObject;
  lContainedObj: TContainedWeakReferencedObject<IWeakReferenceableObject>;
begin
  // note that this creation of an ContainedObject is not the way its meant to be used. Creating an ContainedObject
  // outside its Controller is not recommended and only used for this special testcase
  lController := TWeakReferencedObject.Create;
  lContainedObj := TContainedWeakReferencedObject<IWeakReferenceableObject>.Create(lController);
  try
    Assert.IsWeakReferenceable<IWeakReferenceableObject>(lContainedObj);
  finally
    FreeAndNil(lContainedObj);
  end;
end;

procedure TWeakReferencesBehaviourTest.TContainedWeakReferencedObject_QueryInterface_Works;
var
  lInterfaceNotToDelegateRef: IInterfaceNotToDelegate;
  lInterfaceToDelegateRef: IInterfaceToDelegate;
begin
  // This Interface is implemented by TClassThatDelegatesAnInterface
  lInterfaceNotToDelegateRef := TObjectThatDelegatesAnInterfaceToContainedObject.Create;
  Assert.AreEqual(1, lInterfaceNotToDelegateRef.RefCount);

  // This Interfaces is implemented by TClassThatDelegatesAnInterface, but has been delegated to TClassThatImplementsTheDelegatedInterface
  Assert.IsTrue(Supports(lInterfaceNotToDelegateRef, IInterfaceToDelegate, lInterfaceToDelegateRef));
  // So as TContainedWeakReferencedObjects does not route QueryInterface (IInterface) to its Controller, the other way round will not work
  Assert.IsFalse(Supports(lInterfaceToDelegateRef, IInterfaceNotToDelegate));
end;

procedure TWeakReferencesBehaviourTest.TContainedWeakReferencedObject_ReferenceCounting_Works;
var
  lInterfaceNotToDelegateRef: IInterfaceNotToDelegate;
  lInterfaceToDelegateRef: IInterfaceToDelegate;
begin
  // This Interface is implemented by TClassThatDelegatesAnInterface
  lInterfaceNotToDelegateRef := TObjectThatDelegatesAnInterfaceToContainedObject.Create;
  Assert.AreEqual(1, lInterfaceNotToDelegateRef.RefCount);

  // This Interfaces is implemented by TClassThatDelegatesAnInterface, but has been delegated to TClassThatImplementsTheDelegatedInterface
  Assert.IsTrue(Supports(lInterfaceNotToDelegateRef, IInterfaceToDelegate, lInterfaceToDelegateRef));
  Assert.AreEqual(2, lInterfaceNotToDelegateRef.RefCount);
  // As the ContainedObject only routes the reference counting to its controller, the Refcount call must be equal
  Assert.AreEqual(2, lInterfaceToDelegateRef.RefCount);
end;

procedure TWeakReferencesBehaviourTest.TAggregatedObject_Is_Not_WeakReferenceable;
var
  lAggregatedObj: TSimpleAggregatedObject;
  lController: IInterface;
begin
  lController := TInterfacedObject.Create;
  lAggregatedObj := TSimpleAggregatedObject.Create(lController);
  try
    Assert.IsNotWeakReferenceable<IInterface>(lAggregatedObj);
  finally
    FreeAndNil(lAggregatedObj);
  end;
end;

procedure TWeakReferencesBehaviourTest.TAggregatedWeakReferencedObject_Delegate_Works;
var
  lInterfaceNotToDelegateRef: IInterfaceNotToDelegate;
  lInterfaceToDelegateRef: IInterfaceToDelegate;
  lExpectedNameOf_IInterfaceNotToDelegate_Implementer: String;
  lExpectedNameOf_IInterfaceToDelegate_Implementer: String;
begin
  // This Interface is implemented by TClassThatDelegatesAnInterface
  lInterfaceNotToDelegateRef := TObjectThatDelegatesAnInterfaceToAggregatedObject.Create;
  // This Interfaces is implemented by TClassThatDelegatesAnInterface, but has been delegated to TClassThatImplementsTheDelegatedInterface
  Assert.IsTrue(Supports(lInterfaceNotToDelegateRef, IInterfaceToDelegate, lInterfaceToDelegateRef));

  lExpectedNameOf_IInterfaceNotToDelegate_Implementer := Format(TELLMYNAME, [TObjectThatDelegatesAnInterfaceToAggregatedObject.ClassName]);
  lExpectedNameOf_IInterfaceToDelegate_Implementer := Format(TELLMYNAMEANDCONTROLLER, [TAggregatedObjectThatImplementsTheDelegatedInterface<IInterfaceNotToDelegate>.ClassName, TObjectThatDelegatesAnInterfaceToAggregatedObject.ClassName]);

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

procedure TWeakReferencesBehaviourTest.TObject_Is_Not_WeakReferenceable;
var
  lObj: TSimpleObject;
begin
  lObj := TSimpleObject.Create;
  try
    Assert.IsNotWeakReferenceable<IInterface>(lObj);
  finally
    FreeAndNil(lObj);
  end;
end;

procedure TWeakReferencesBehaviourTest.TWeakReferencedObject_Is_WeakReferenceable;
begin
  Assert.IsWeakReferenceable<IInterface>(TWeakReferencedObject.Create);
end;

initialization
  TDUnitX.RegisterTestFixture(TWeakReferencesBehaviourTest);

end.
