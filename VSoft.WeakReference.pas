{***************************************************************************}
{                                                                           }
{           VSoft.WeakReference                                             }
{                                                                           }
{           Copyright (C) 2011 Vincent Parrett                              }
{                                                                           }
{           http://www.finalbuilder.com                                     }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

(*

The idea behind this unit is provide a similar lifecycle to reference counted objects
in delphi as WeakReference does in .NET.

Reference counted objects in delphi have some limitations when it comes to circular references,
where for example TParent references it's children (via IChild), and TChild references it's parent
(via IParent). I we remove any external references to our IParent and IChild instances without first
getting the child to remove it's reference to IParent, we would end up with orphaned objects. This
is because our IChild and IParent instances are holding references to each other, and thus they never
get releaseds.

*)



unit VSoft.WeakReference;


interface

uses
  System.SysUtils;

type
  EWeakReferenceNotSupportedError = class(Exception);

  {$REGION 'IWeakReferenceableObject'}
  /// Implemented by our weak referenced object base class
  IWeakReferenceableObject = interface
    ['{3D7F9CB5-27F2-41BF-8C5F-F6195C578755}']
    procedure AddWeakRef(value : Pointer);
    procedure RemoveWeakRef(value : Pointer);
    function GetRefCount : integer;
  end;
  {$ENDREGION}

  {$REGION 'TWeakReferencedObject'}
  ///  This is our base class for any object that can have a weak reference to
  ///  it. It implements IInterface so the object can also be used just like
  ///  any normal reference counted objects in Delphi.
  TWeakReferencedObject = class(TObject,IInterface,IWeakReferenceableObject)
  protected
    FWeakReferences : Array of Pointer;
    FRefCount: Integer;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure AddWeakRef(value : Pointer);
    procedure RemoveWeakRef(value : Pointer);
    function GetRefCount : integer;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    class function NewInstance: TObject; override;
    property RefCount: Integer read FRefCount;
  end;
  {$ENDREGION}

  {$REGION 'IWeakReference'}
  // This is our generic WeakReference interface
  IWeakReference<T : IInterface> = interface
    ['{A6B88944-15A2-4FFD-B755-1B17960401BE}']
    function IsAlive : boolean;
    function Data : T;
  end;
  {$ENDREGION}

  {$REGION 'TWeakReference'}
  //The aatual WeakReference implementation.
  TWeakReference<T: IInterface> = class(TInterfacedObject,IWeakReference<T>)
  private
    FData : TObject;
  protected
    function IsAlive : boolean;
    function Data : T;
  public
    constructor Create(const data : T);
    destructor Destroy;override;
  end;
  {$ENDREGION}

  procedure RaiseWeakReferenceNotSupportedError;

implementation

uses
  TypInfo,
  classes;

procedure RaiseWeakReferenceNotSupportedError;
begin
  raise EWeakReferenceNotSupportedError.Create('TWeakReference can only be used with objects derived from TWeakReferencedObject');
end;

//copied from system since they are not exposed for us to use.s
function InterlockedIncrement(var Addend: Integer): Integer;
asm
      MOV   EDX,1
      XCHG  EAX,EDX
 LOCK XADD  [EDX],EAX
      INC   EAX
end;

function InterlockedDecrement(var Addend: Integer): Integer;
asm
      MOV   EDX,-1
      XCHG  EAX,EDX
 LOCK XADD  [EDX],EAX
      DEC   EAX
end;

{$REGION 'TWeakReference'}
constructor TWeakReference<T>.Create(const data: T);
var
  weakRef : IWeakReferenceableObject;
  d : IInterface;
begin
  d := IInterface(data);
  if Supports(d,IWeakReferenceableObject,weakRef) then
  begin
    FData := d as TObject;
    weakRef.AddWeakRef(@FData);
  end
  else
    RaiseWeakReferenceNotSupportedError;
end;

function TWeakReference<T>.Data: T;
begin
  result := Default(T); /// can't assign nil to T
  if FData <> nil then
  begin
    //Make sure that the object supports the interface which is our generic type if we
    //simply pass in the interface base type, the method table doesn't work correctly
    if Supports(FData, GetTypeData(TypeInfo(T))^.Guid, result) then
      result := T(result);
  end;
end;

destructor TWeakReference<T>.Destroy;
var
  weakRef : IWeakReferenceableObject;
begin
  if IsAlive then
  begin
    if Supports(FData,IWeakReferenceableObject,weakRef) then
    begin
      weakRef.RemoveWeakRef(@FData);
      weakRef := nil;
    end;
  end;
  FData := nil;
  inherited;
end;

function TWeakReference<T>.IsAlive: boolean;
begin
  result := FData <> nil;
end;
{$ENDREGION}

{$REGION 'TWeakReferencedObject'}
{ TWeakReferencedObject }

procedure TWeakReferencedObject.AddWeakRef(value: Pointer);
var
  l : integer;
begin
  MonitorEnter(Self);
  try
    l := Length(FWeakReferences);
    Inc(l);
    SetLength(FWeakReferences,l);
    FWeakReferences[l-1] := Value;
  finally
    MonitorExit(Self);
  end;
end;

procedure TWeakReferencedObject.RemoveWeakRef(value: Pointer);
var
  l : integer;
  i : integer;
  idx : integer;
begin
  MonitorEnter(Self);
  try
    l := Length(FWeakReferences);
    if l > 0 then
    begin
      idx := -1;
      for i := 0 to l - 1 do
      begin
        if idx <> -1 then
        begin
          FWeakReferences[i -1] := FWeakReferences[i];
        end;
        if FWeakReferences[i] = Value then
        begin
          FWeakReferences[i] := nil;
          idx := i;
        end;
      end;
      Dec(l);
      SetLength(FWeakReferences,l);
    end;
  finally
    MonitorExit(Self);
  end;
end;


procedure TWeakReferencedObject.AfterConstruction;
begin
// Release the constructor's implicit refcount
  InterlockedDecrement(FRefCount);
end;

procedure TWeakReferencedObject.BeforeDestruction;
var
  i: Integer;
begin
  if RefCount <> 0 then
    System.Error(reInvalidPtr);
  MonitorEnter(Self);
  try
    for i := 0 to Length(FWeakReferences) - 1 do
       TObject(FWeakReferences[i]^) := nil;
    SetLength(FWeakReferences,0);
  finally
    MonitorExit(Self);
  end;
end;

function TWeakReferencedObject.GetRefCount: integer;
begin
  result := FRefCount;
end;

class function TWeakReferencedObject.NewInstance: TObject;
begin
// Set an implicit refcount so that refcounting
// during construction won't destroy the object.
  Result := inherited NewInstance;
  TWeakReferencedObject(Result).FRefCount := 1;
end;

function TWeakReferencedObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TWeakReferencedObject._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

function TWeakReferencedObject._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0  then
    Destroy;
end;
{$ENDREGION}

end.
