using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using Godot;

public class runbat : Node
{
	private Process process;

	[DllImport("user32.dll")]
	private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

	public void _run()
	{
		process = new Process();
		process.StartInfo.WindowStyle = ProcessWindowStyle.Normal;
		process.StartInfo.FileName = "temp.bat";
		process.StartInfo.WorkingDirectory = OS.GetUserDataDir();
		process.EnableRaisingEvents = true;
		process.Start();
	}
}
