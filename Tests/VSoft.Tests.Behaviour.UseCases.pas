unit VSoft.Tests.Behaviour.UseCases;

interface

uses
  VSoft.WeakReference;

const
  TELLMYNAME = '%s';
  TELLMYNAMEANDCONTROLLER = TELLMYNAME + ' and my Controllers Name is: %s';
type
  IInterfaceToDelegate = interface
    ['{D542305A-824C-426C-8FFF-AD43DFAD6629}']
    function TellMeYourName: String;
    function RefCount: Integer;
  end;

  IInterfaceNotToDelegate = interface
    ['{7DFC703F-BB24-4D43-9E36-A8EB0C1B589E}']
    function TellMeYourName: String;
    function RefCount: Integer;
  end;

  TAggregatedObjectThatImplementsTheDelegatedInterface<T: IInterfaceNotToDelegate> = class(TAggregatedWeakReferencedObject<T>, IInterfaceToDelegate)
  public
    function TellMeYourName: String;
    function RefCount: Integer;
  end;

  TContainedObjectThatImplementsTheDelegatedInterface<T: IInterfaceNotToDelegate> = class(TContainedWeakReferencedObject<T>, IInterfaceToDelegate)
  public
    function TellMeYourName: String;
    function RefCount: Integer;
  end;

  TObjectThatDelegatesAnInterfaceToAggregatedObject = class(TWeakReferencedObject, IInterfaceToDelegate, IInterfaceNotToDelegate)
  strict protected
    FAggregatedObject: TAggregatedObjectThatImplementsTheDelegatedInterface<IInterfaceNotToDelegate>;
    function GetAggregatedObject: IInterfaceToDelegate;
    property AggregatedObjectThatDelegates: IInterfaceToDelegate read GetAggregatedObject implements IInterfaceToDelegate;
  public
    constructor Create;
    destructor Destroy; override;
    function TellMeYourName: String;
    function RefCount: Integer;
  end;

  TObjectThatDelegatesAnInterfaceToContainedObject = class(TWeakReferencedObject, IInterfaceToDelegate, IInterfaceNotToDelegate)
  strict protected
    FContainedObject: TContainedObjectThatImplementsTheDelegatedInterface<IInterfaceNotToDelegate>;
    function GetContainedObject: IInterfaceToDelegate;
    property ContainedObjectThatDelegates: IInterfaceToDelegate read GetContainedObject implements IInterfaceToDelegate;
  public
    constructor Create;
    destructor Destroy; override;
    function TellMeYourName: String;
    function RefCount: Integer;
  end;

  TSimpleAggregatedObject = class(TAggregatedObject, IInterface)
  end;

  TSimpleContainedObject = class(TContainedObject, IInterface)
  end;

  TSimpleObject = class(TObject, IInterface)
  public
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

implementation

uses
  System.SysUtils;

{ TClassThatDelegatesAnInterface }

constructor TObjectThatDelegatesAnInterfaceToAggregatedObject.Create;
begin
  FAggregatedObject := TAggregatedObjectThatImplementsTheDelegatedInterface<IInterfaceNotToDelegate>.Create(Self);
end;

destructor TObjectThatDelegatesAnInterfaceToAggregatedObject.Destroy;
begin
  FreeAndNil(FAggregatedObject);
  inherited;
end;

function TObjectThatDelegatesAnInterfaceToAggregatedObject.GetAggregatedObject: IInterfaceToDelegate;
begin
  Result := FAggregatedObject;
end;

function TObjectThatDelegatesAnInterfaceToAggregatedObject.RefCount: Integer;
begin
  Result := GetRefCount;
end;

function TObjectThatDelegatesAnInterfaceToAggregatedObject.TellMeYourName: String;
begin
  Result := Format(TELLMYNAME, [ClassName]);
end;

{ TClassThatImplementsTheDelegatedInterface<T> }

function TAggregatedObjectThatImplementsTheDelegatedInterface<T>.RefCount: Integer;
begin
  Result := GetRefCount;
end;

function TAggregatedObjectThatImplementsTheDelegatedInterface<T>.TellMeYourName: String;
begin
  Result := Format(TELLMYNAMEANDCONTROLLER, [ClassName, Controller.TellMeYourName]);
end;


{ TObjectThatDelegatesAnInterfaceToContainedObject }

constructor TObjectThatDelegatesAnInterfaceToContainedObject.Create;
begin
  FContainedObject := TContainedObjectThatImplementsTheDelegatedInterface<IInterfaceNotToDelegate>.Create(Self);
end;

destructor TObjectThatDelegatesAnInterfaceToContainedObject.Destroy;
begin
  FreeAndNil(FContainedObject);
  inherited;
end;

function TObjectThatDelegatesAnInterfaceToContainedObject.GetContainedObject: IInterfaceToDelegate;
begin
  Result := FContainedObject;
end;

function TObjectThatDelegatesAnInterfaceToContainedObject.RefCount: Integer;
begin
  Result := GetRefCount;
end;

function TObjectThatDelegatesAnInterfaceToContainedObject.TellMeYourName: String;
begin
  Result := Format(TELLMYNAME, [ClassName]);
end;

{ TContainedObjectThatImplementsTheDelegatedInterface<T> }

function TContainedObjectThatImplementsTheDelegatedInterface<T>.RefCount: Integer;
begin
  Result := GetRefCount;
end;

function TContainedObjectThatImplementsTheDelegatedInterface<T>.TellMeYourName: String;
begin
  Result := Format(TELLMYNAMEANDCONTROLLER, [ClassName, Controller.TellMeYourName]);
end;

{ TSimpleObject }

function TSimpleObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin

end;

function TSimpleObject._AddRef: Integer;
begin

end;

function TSimpleObject._Release: Integer;
begin

end;

end.
