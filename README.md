# VSoft.WeakReference

The idea behind this unit is provide a similar lifecycle to reference counted objects
in delphi as WeakReference does in .NET.

Reference counted objects in delphi have some limitations when it comes to circular references,
where for example TParent references it's children (via IChild), and TChild references it's parent
(via IParent). If we remove any external references to our IParent and IChild instances without first
getting the child to remove it's reference to IParent, we would end up with orphaned objects. This
is because our IChild and IParent instances are holding references to each other, and thus they never
get releaseds.


## Usage

Classes that can be weak referenced need to descend from ``TWeakReferencedObject``. 



````
type
    TParent = class(TWeakReferencedObject, IParent)
    ...
    end;

    TChild = class(TInterfacedObject, IChild)
    private
        FParent : IWeakReference<IParent>;
    protected
        procedure SetParent(const parent : IParent);
        function GetParent : IParent;
    public
        property Parent : IParent read GetParent write SetParent;
    end;

implementation

procedure TChild.SetParent(const parent : IParent);
begin
    if parent <> nil then
      FParent := TWeakReference<IParent>.Create(parent)
    else
      FParent := nil;

end;

function TChild.GetParent : IParent;
begin
    result := nil
    if (FParent <> nil) and FParent.IsAlive then
        result := FParent.Data;
end;
````

In the above example, if the Parent object is destroyed before the child, the weak reference to it in the child object will be marked as nil (so .IsAlive returns false). 
