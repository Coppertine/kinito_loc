// KinitoPET, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// AppActiveCheck
using System.Diagnostics;
using Godot;

public class AppActiveCheck : Node
{
	private bool ProcessExists(int iProcessID)
	{
		Process[] processes = Process.GetProcesses();
		for (int i = 0; i < processes.Length; i++)
		{
			if (processes[i].Id == iProcessID)
			{
				return true;
			}
		}
		return false;
	}

	public override void _Process(float delta)
	{
		if ((int)GetNode("/root/App").Get("_pid") != 0 && !ProcessExists((int)GetNode("/root/App").Get("_pid")))
		{
			GD.Print("Closing by listner PID:", GetNode("/root/App").Get("_pid"), "  (Steam Force Close)");
			GetNode("/root/App").Call("_allClose");
		}
	}
}
