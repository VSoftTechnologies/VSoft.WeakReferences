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
    [Test]
    procedure TAggregatedWeakReferencedObject_Is_Not_ReferenceCounted;
    [Test]
    procedure TContainedWeakReferencedObject_Is_Not_ReferenceCounted;
  end;

implementation

uses
  VSoft.Tests.Classhelpers.Assert,
  VSoft.WeakReference,
  System.SysUtils;


{ TWeakReferencesLifecycleTest }

procedure TWeakReferencesLifecycleTest.TAggregatedWeakReferencedObject_Is_Not_ReferenceCounted;
var
  lWeakReference: IWeakReference<IWeakReferenceableObject>;
  lControllerRef: IWeakReferenceableObject;
  lAggregatedObj: TAggregatedWeakReferencedObject<IWeakReferenceableObject>;
begin
  // note that this creation of an AggregatedObject is not the way its meant to be used. Creating an AggregatedObject
  // outside its Controller is not recommended and only used for this special testcase
  lControllerRef := TWeakReferencedObject.Create;
  lAggregatedObj := TAggregatedWeakReferencedObject<IWeakReferenceableObject>.Create(lControllerRef);

  lWeakReference := TWeakReference<IWeakReferenceableObject>.Create(lControllerRef);
  Assert.IsTrue(lWeakReference.IsAlive, 'controller instance should be still alive');
  Assert.IsNotNull(lAggregatedObj);
  Assert.AreEqual(1, lControllerRef.GetRefCount);

  lControllerRef := nil;
  Assert.IsFalse(lWeakReference.IsAlive, 'after freeing the controller instance, the aggregated object should remain alive');
  Assert.IsNotNull(lAggregatedObj);

  FreeAndNil(lAggregatedObj);
  Assert.IsNull(lAggregatedObj);
end;

procedure TWeakReferencesLifecycleTest.TContainedWeakReferencedObject_Is_Not_ReferenceCounted;
var
  lWeakReference: IWeakReference<IWeakReferenceableObject>;
  lControllerRef: IWeakReferenceableObject;
  lContainedObj: TContainedWeakReferencedObject<IWeakReferenceableObject>;
begin
  // note that this creation of an ContainedObject is not the way its meant to be used. Creating an ContainedObject
  // outside its Controller is not recommended and only used for this special testcase
  lControllerRef := TWeakReferencedObject.Create;
  lContainedObj := TContainedWeakReferencedObject<IWeakReferenceableObject>.Create(lControllerRef);

  lWeakReference := TWeakReference<IWeakReferenceableObject>.Create(lControllerRef);
  Assert.IsTrue(lWeakReference.IsAlive, 'controller instance should be still alive');
  Assert.IsNotNull(lContainedObj);
  Assert.AreEqual(1, lControllerRef.GetRefCount);

  lControllerRef := nil;
  Assert.IsFalse(lWeakReference.IsAlive, 'after freeing the controller instance, the Contained object should remain alive');
  Assert.IsNotNull(lContainedObj);

  FreeAndNil(lContainedObj);
  Assert.IsNull(lContainedObj);
end;

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
