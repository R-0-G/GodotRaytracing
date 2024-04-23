using Godot;
using System;

[Tool]
public partial class RogRT : RogPlugin
{
    protected override string RootName => "TestEditor";

    public override void _EnterTree()
    {
        base._EnterTree();
               
        AddSpatialMenu("Test", Test);
        AddSpatialMenu("Zest", Zest);
        AddSpatialMenu("Best/Crest", Crest);
        AddSpatialMenu("Best/Vest", Vest);
        AddSpatialMenu("Best/Dorp/Worp", Worp);
        AddSpatialMenu("Morp/Dorp/Worp", Worp);
    }

    public void Test()
    {
        GD.Print("Test");
    }

    public void Zest()
    {
        GD.Print("Zest");
    }

    public void Crest()
    {
        GD.Print("Crest");
    }

    public void Vest()
    {
        GD.Print("Vest");
    }
    public void Worp()
    {
        GD.Print("Worp");
    }

    public override void _ExitTree()
    {
        base._ExitTree();
    }
}
