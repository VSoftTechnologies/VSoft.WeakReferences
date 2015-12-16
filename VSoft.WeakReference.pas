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


{$I WeakRef.inc}

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
  TWeakReferencedObject = class(TObject, IInterface, IWeakReferenceableObject)
  protected
    FWeakReferences : Array of Pointer;
    FRefCount: Integer;
    function QueryInterface(const IID: TGUID; out Obj): HResult; virtual; stdcall;
    function _AddRef: Integer; virtual; stdcall;
    function _Release: Integer; virtual; stdcall;
    procedure AddWeakRef(value : Pointer); virtual;
    procedure RemoveWeakRef(value : Pointer); virtual;
    function GetRefCount : integer; virtual;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    {$IFDEF NEXTGEN}[Result: Unsafe]{$ENDIF} class function NewInstance: TObject; override;
    property RefCount: Integer read FRefCount;
  end;
  {$ENDREGION}

  {$REGION 'TNoCountedWeakReferencedObject'}
  /// This class acts like a normal TObject but with the WeakReferenceable funcionality
  /// from TWeakReferencedObject.
  TNoCountedWeakReferencedObject = class(TWeakReferencedObject, IInterface)
  public
    function _Release: Integer; override; stdcall;
  end;
  {$ENDREGION}

  {$REGION 'IWeakReference'}
  // This is our generic WeakReference interface
  IWeakReference<T : IInterface> = interface//FI:W524
    ['{A6B88944-15A2-4FFD-B755-1B17960401BE}']
    function IsAlive : boolean;
    function Data : T;
    function DataImplementer: TWeakReferencedObject;
  end;
  {$ENDREGION}

<<<<<<< .merge_file_a04720
  //The actual WeakReference implementation.
  TWeakReference<T: IInterface> = class(TInterfacedObject, IWeakReference<T>)
=======
  {$REGION 'TWeakReference'}
  //The aatual WeakReference implementation.
  TWeakReference<T: IInterface> = class(TInterfacedObject,IWeakReference<T>)
>>>>>>> .merge_file_a10084
  private
    FData : TWeakReferencedObject;
  protected
    function IsAlive : boolean;
    function Data : T;
    function DataImplementer: TWeakReferencedObject;
  public
    constructor Create(const data : T);
    destructor Destroy;override;
  end;
  {$ENDREGION}

  {$REGION 'TAggregatedWeakReferencedObject'}
  /// This class adds the weakreferenceable functionality to an aggregated object.
  /// It behaves like the known TAggregatedObject from System.pas extended by an interface constraint
  /// to declare its controller.
  TAggregatedWeakReferencedObject<T: IInterface> = class(TWeakReferencedObject, IInterface)
  strict private
    FController: IWeakReference<T>;
  strict protected
    function Controller: T;
    function ControllerImplementer: TWeakReferencedObject;
  public
    constructor Create(const AController: T);

    function QueryInterface(const IID: TGUID; out Obj): HResult; override; stdcall;
    function _AddRef: Integer; override; stdcall;
    function _Release: Integer; override; stdcall;

    procedure AddWeakRef(value : Pointer); override;
    procedure RemoveWeakRef(value : Pointer); override;
    function GetRefCount : integer; override;
  end;
  {$ENDREGION}

  {$REGION 'TContainedWeakReferencedObject'}
  /// This class adds the weakreferenceable functionality to an contained object.
  /// It behaves like the known TContainedObject from System.pas extended by an interface constraint
  /// to declare its controller.
  TContainedWeakReferencedObject<T: IInterface> = class(TAggregatedWeakReferencedObject<T>, IInterface)
  public
    function QueryInterface(const IID: TGUID; out Obj): HResult; override; stdcall;
  end;
  {$ENDREGION}

  procedure RaiseWeakReferenceNotSupportedError;

resourcestring
  SWeakReferenceError = 'TWeakReference can only be used with objects derived from TWeakReferencedObject';

implementation

uses
<<<<<<< .merge_file_a04720
  {$IFDEF USE_NS}
  System.TypInfo,
  System.Classes,
  System.Sysutils,
  System.SyncObjs;
  {$ELSE}
  TypInfo,
  classes,
  SysUtils,
  SyncObjs;
  {$ENDIF}

{$IFNDEF DELPHI_XE2_UP}
type
  TInterlocked = class
  public
    class function Increment(var Target: Integer): Integer; static; inline;
    class function Decrement(var Target: Integer): Integer; static; inline;
    class function Add(var Target: Integer; Increment: Integer): Integer;static;
  end;
=======
  TypInfo,
  classes;

procedure RaiseWeakReferenceNotSupportedError;
begin
  raise EWeakReferenceNotSupportedError.Create('TWeakReference can only be used with objects derived from TWeakReferencedObject');
end;
>>>>>>> .merge_file_a10084

class function TInterlocked.Decrement(var Target: Integer): Integer;
begin
    result := Add(Target,-1);
end;

class function TInterlocked.Increment(var Target: Integer): Integer;
begin
  result := Add(Target,1);
end;

class function TInterlocked.Add(var Target: Integer; Increment: Integer): Integer;
{$IFNDEF CPUX86}
asm
  .NOFRAME
  MOV  EAX,EDX
  LOCK XADD [RCX].Integer,EAX
  ADD  EAX,EDX
end;
{$ELSE CPUX86}
asm
  MOV  ECX,EDX
  XCHG EAX,EDX
  LOCK XADD [EDX],EAX
  ADD  EAX,ECX
end;
{$ENDIF}
{$ENDIF DELPHI_XE2_UPE2}


{$REGION 'TWeakReference'}
constructor TWeakReference<T>.Create(const data: T);
var
  weakRef : IWeakReferenceableObject;
  d : IInterface;
begin
  d := IInterface(data);
  if Supports(d,IWeakReferenceableObject,weakRef) then
  begin
    FData := d as TWeakReferencedObject;
    weakRef.AddWeakRef(@FData);
  end
  else
<<<<<<< .merge_file_a04720
    raise Exception.Create(SWeakReferenceError);
=======
    RaiseWeakReferenceNotSupportedError;
>>>>>>> .merge_file_a10084
end;

function TWeakReference<T>.Data: T;
begin
  result := Default(T); /// can't assign nil to T
  if FData <> nil then
  begin
    //Make sure that the object supports the interface which is our generic type if we
    //simply pass in the interface base type, the method table doesn't work correctly
    if Supports(FData, GetTypeData(TypeInfo(T))^.Guid, result) then
<<<<<<< .merge_file_a04720
    //if Supports(FData, IInterface, result) then
=======
>>>>>>> .merge_file_a10084
      result := T(result);
  end;
end;

function TWeakReference<T>.DataImplementer: TWeakReferencedObject;
begin
  Result := FData;
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
  TInterlocked.Decrement(FRefCount);
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
  Result := TInterlocked.Increment(FRefCount);
end;

function TWeakReferencedObject._Release: Integer;
begin
  Result := TInterlocked.Decrement(FRefCount);
  if Result = 0  then
    Destroy;
end;
{$ENDREGION}

{$REGION 'TNoCountedWeakReferencedObject'}
{ TNoCountedWeakReferencedObject }

function TNoCountedWeakReferencedObject._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
end;
{$ENDREGION}

{$REGION 'TAggregatedWeakReferencedObject'}
{ TAggregatedWeakReferencedObject }

procedure TAggregatedWeakReferencedObject<T>.AddWeakRef(value: Pointer);
begin
  ControllerImplementer.AddWeakRef(value);
end;

function TAggregatedWeakReferencedObject<T>.Controller: T;
begin
  Result := FController.Data;
end;

function TAggregatedWeakReferencedObject<T>.ControllerImplementer: TWeakReferencedObject;
begin
  Result := FController.DataImplementer;
end;

constructor TAggregatedWeakReferencedObject<T>.Create(const AController: T);
begin
  FController := TWeakReference<T>.Create(AController);
end;

function TAggregatedWeakReferencedObject<T>.GetRefCount: integer;
begin
  Result := ControllerImplementer.GetRefCount;
end;

function TAggregatedWeakReferencedObject<T>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  Result := Controller.QueryInterface(IID, Obj);
end;

procedure TAggregatedWeakReferencedObject<T>.RemoveWeakRef(value: Pointer);
begin
  ControllerImplementer.RemoveWeakRef(value);
end;

function TAggregatedWeakReferencedObject<T>._AddRef: Integer;
begin
  Result := Controller._AddRef;
end;

function TAggregatedWeakReferencedObject<T>._Release: Integer;
begin
  Result := Controller._Release;
end;
{$ENDREGION}

{$REGION 'TContainedWeakReferencedObject'}
{ TContainedWeakReferencedObject<T> }

function TContainedWeakReferencedObject<T>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;
{$ENDREGION}

end.
