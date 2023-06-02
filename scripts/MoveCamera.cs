using Godot;
using System;

public partial class MoveCamera : Node3D
{
	[Export] private float timer = 0f;
	[Export] private float resetTime = 4f;
	[Export] private bool rota;
	[Export] private bool mv;
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		timer += (float) delta;

		if (rota)
		RotationDegrees = new Vector3(0f,Mathf.Lerp(0,180,timer/resetTime), 0f);

		if (mv)
		Position = new Vector3(0f, 0f, Mathf.Lerp(-1.2f, 1.2f, timer/resetTime));
		if (timer > resetTime)
		{
			timer =0f;
		}
	}
}
