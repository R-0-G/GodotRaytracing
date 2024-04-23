using Godot;
using System;

[Tool]
public partial class RogRT : RogPlugin
{
    protected override string RootName => "Add";

    public override void _EnterTree()
    {
        base._EnterTree();
               
        AddSpatialMenu("Collider/Cube", ColliderCube);
        AddSpatialMenu("Mesh/Cube", MeshCube);
        AddSpatialMenu("Rigidbody/Cube", RigidbodyCube);
        AddSpatialMenu("Collider/Sphere", ColliderSphere);
        AddSpatialMenu("Mesh/Sphere", MeshSphere);
        AddSpatialMenu("Rigidbody/Sphere", RigidbodySphere);
    }

    private void ColliderCube()
    {
        GD.Print("ColliderCube");
    }
    private void MeshCube()
    {
        AddMeshInstance( new BoxMesh(), "Cube");
    }
    private void RigidbodyCube()
    {
        GD.Print("RigidbodyCube");
    }
    private void ColliderSphere()
    {
        GD.Print("ColliderSphere");
    }
    private void MeshSphere()
    {
        AddMeshInstance( new SphereMesh(), "Sphere");
    }
    private void RigidbodySphere()
    {
        GD.Print("RigidbodySphere");
    }

    private MeshInstance3D AddMeshInstance(Mesh mesh, string name, Node parent = null)
    {
        if (parent==null)
        {
            parent = GetTree().EditedSceneRoot;
        }
        MeshInstance3D result = new MeshInstance3D();
        result.Name = name + parent.GetChildCount()+1;
        parent.AddChild(result);
        result.Owner=parent;
        result.Mesh = mesh;
        return result;
    }

    public override void _ExitTree()
    {
        base._ExitTree();
    }
}
