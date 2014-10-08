unit VSoft.Tests.WeakReference.UseCases;

interface

uses
  VSoft.WeakReference;

type
  ISimpleInterface = interface
    ['{1A84030F-EEC5-447F-981D-94C4339D8800}']
    function GetName : string;
  end;

  TSimpleInterfacedObject = class(TWeakReferencedObject, ISimpleInterface)
    function GetName : string;
  end;

  IInternalUseInterface = interface
    ['{B2A2406D-C17D-478C-A194-59AACF40D279}']
    function GetName : string;
    function GetInternalUseOnly : string;
    property Name : string read GetName;
    property InternalUseOnly : string read GetInternalUseOnly;
  end;

  IExternalUseInterface = interface
    ['{907365C0-2A20-41D0-927B-8B36FB4CB0FD}']
    function GetName : string;
    property Name : string read GetName;
  end;

  TExposedObject = class(TWeakReferencedObject, IInternalUseInterface, IExternalUseInterface)
  private
    FName : string;
  protected
    function GetName : string;
    function GetInternalUseOnly : string;
  public
    property Name : string read GetName;
    constructor Create(const ANewName: string);
  end;

implementation

{ TExposedObject }

function TExposedObject.GetName: string;
begin
  Result := FName;
end;

constructor TExposedObject.Create(const ANewName: string);
begin
  inherited Create;
  FName := ANewName;
end;

function TExposedObject.GetInternalUseOnly: string;
begin
  Result := 'Only here for completeness!';
end;

{ TSimpleInterfacedObject }

function TSimpleInterfacedObject.GetName: string;
begin
  Result := Self.ClassName;
end;

end.
