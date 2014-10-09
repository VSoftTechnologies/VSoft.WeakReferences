unit VSoft.Tests.Classhelpers.Assert;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  VSoft.WeakReference;

type
  EAssertHelperError = class(Exception);

  TAssertHelper = class helper for Assert
    class procedure IsReferenceCounted<T: IWeakReferenceableObject>(AInstance: T);
    class procedure IsNotReferenceCounted<T: IWeakReferenceableObject>(AInstance: T; AImplementingClass: TObject);
    class procedure IsWeakReferenceable<T: IInterface>(const AInstance: T);
    class procedure IsNotWeakReferenceable<T: IInterface>(const AInstance: T);
  end;

implementation

{ TAssertHelper }

class procedure TAssertHelper.IsNotReferenceCounted<T>(AInstance: T; AImplementingClass: TObject);
var
  lWeakReference: IWeakReference<T>;
begin
  if IWeakReferenceableObject(AInstance).GetRefcount > 1 then
    raise EAssertHelperError.Create('');

  lWeakReference := TWeakReference<T>.Create(AInstance);
  IsTrue(lWeakReference.IsAlive, 'tested instance should be alive');

  AInstance := nil;
  IsTrue(lWeakReference.IsAlive, 'even after freeing the interface reference, the instance should remain alive');

  FreeAndNil(AImplementingClass);
  IsFalse(lWeakReference.IsAlive, 'after manually freeing the implementing class, the instance should have died');
  IsNull(lWeakReference.Data);
end;

class procedure TAssertHelper.IsNotWeakReferenceable<T>(const AInstance: T);
var
  lWeakReference: IWeakReference<T>;
begin
  WillRaise(
  procedure
  begin
    lWeakReference := TWeakReference<T>.Create(AInstance);
  end,
  EWeakReferenceNotSupportedError
  );
end;

class procedure TAssertHelper.IsReferenceCounted<T>(AInstance: T);
var
  lWeakReference: IWeakReference<T>;
begin
  if IWeakReferenceableObject(AInstance).GetRefcount > 1 then
    raise EAssertHelperError.Create('');

  lWeakReference := TWeakReference<T>.Create(AInstance);
  IsTrue(lWeakReference.IsAlive, 'tested instance should be alive');

  AInstance := nil;
  IsFalse(lWeakReference.IsAlive, 'after freeing the interface reference, the instance should have died');
  IsNull(lWeakReference.Data);
end;

class procedure TAssertHelper.IsWeakReferenceable<T>(const AInstance: T);
var
  lWeakReference: IWeakReference<T>;
begin
  WillNotRaise(
  procedure
  begin
    lWeakReference := TWeakReference<T>.Create(AInstance);
  end,
  EWeakReferenceNotSupportedError
  );
end;

end.
