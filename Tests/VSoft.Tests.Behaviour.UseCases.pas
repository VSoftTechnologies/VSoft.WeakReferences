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

  TClassThatImplementsTheDelegatedInterface<T: IInterfaceNotToDelegate> = class(TAggregatedWeakReferencedObject<T>, IInterfaceToDelegate)
  public
    function TellMeYourName: String;
    function RefCount: Integer;
  end;

  TClassThatDelegatesAnInterface = class(TWeakReferencedObject, IInterfaceToDelegate, IInterfaceNotToDelegate)
  strict protected
    FAggregatedObject: TClassThatImplementsTheDelegatedInterface<IInterfaceNotToDelegate>;
    function GetAggregatedObject: IInterfaceToDelegate;
    property AggregatedObjectThatDelegates: IInterfaceToDelegate read GetAggregatedObject implements IInterfaceToDelegate;
  public
    constructor Create;
    destructor Destroy; override;
    function TellMeYourName: String;
    function RefCount: Integer;
  end;


implementation

uses
  System.SysUtils;

{ TClassThatDelegatesAnInterface }

constructor TClassThatDelegatesAnInterface.Create;
begin
  FAggregatedObject := TClassThatImplementsTheDelegatedInterface<IInterfaceNotToDelegate>.Create(Self);
end;

destructor TClassThatDelegatesAnInterface.Destroy;
begin
  FreeAndNil(FAggregatedObject);
  inherited;
end;

function TClassThatDelegatesAnInterface.GetAggregatedObject: IInterfaceToDelegate;
begin
  Result := FAggregatedObject;
end;

function TClassThatDelegatesAnInterface.RefCount: Integer;
begin
  Result := GetRefCount;
end;

function TClassThatDelegatesAnInterface.TellMeYourName: String;
begin
  Result := Format(TELLMYNAME, [ClassName]);
end;

{ TClassThatImplementsTheDelegatedInterface<T> }

function TClassThatImplementsTheDelegatedInterface<T>.RefCount: Integer;
begin
  Result := GetRefCount;
end;

function TClassThatImplementsTheDelegatedInterface<T>.TellMeYourName: String;
begin
  Result := Format(TELLMYNAMEANDCONTROLLER, [ClassName, Controller.TellMeYourName]);
end;

end.
