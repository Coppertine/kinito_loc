using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using Godot;

public class LoopCMD : Node
{
	private struct RECT
	{
		public int Left;

		public int Top;

		public int Right;

		public int Bottom;
	}

	private const uint SWP_NOSIZE = 1u;

	private const uint TOPMOST = 8u;

	public bool closeable;

	public bool cmdOpened;

	private Process process;

	public int wid = 800;

	public int hig = 500;

	[DllImport("user32.dll")]
	private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

	[DllImport("user32.dll", SetLastError = true)]
	private static extern bool GetWindowRect(IntPtr hwnd, out RECT lpRect);

	[DllImport("user32.dll")]
	[return: MarshalAs(UnmanagedType.Bool)]
	private static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

	private void OnProcessExited(object sender, EventArgs e)
	{
		if (!closeable)
		{
			GetParent().Call("playerCloseCMD");
			RunBatFile();
		}
	}

	public void CloseCommandPrompts()
	{
		Process[] processesByName = Process.GetProcessesByName("cmd");
		foreach (Process process in processesByName)
		{
			if (process.Id != Process.GetCurrentProcess().Id)
			{
				process.CloseMainWindow();
				if (!process.WaitForExit(2000))
				{
					process.Kill();
				}
				RunBatFile();
				cmdOpened = true;
			}
		}
	}

	public async void RunBatFile()
	{
		process = new Process();
		process.StartInfo.WindowStyle = ProcessWindowStyle.Normal;
		process.StartInfo.FileName = "temp.bat";
		process.StartInfo.WorkingDirectory = OS.GetUserDataDir() + "/.bat";
		process.EnableRaisingEvents = true;
		process.Exited += OnProcessExited;
		process.Start();
		GetParent().Call("openedCMD");
	}

	private void _on_Funny_timeout()
{	
		IntPtr hwnd = FindWindow(null, "KinitoPET.exe - Compiling (Administrator)");
		if (hwnd != IntPtr.Zero)
		{
			if (GetWindowRect(hwnd, out var rect))
			{
				SetWindowPos(hwnd, IntPtr.Zero, rect.Left, rect.Top, wid, hig, 8u);
			}
			return;
		}
		IntPtr hwnd2 = FindWindow(null, "Select KinitoPET.exe - Compiling (Administrator)");
		if (hwnd2 != IntPtr.Zero && GetWindowRect(hwnd2, out var rect2))
		{
			SetWindowPos(hwnd2, IntPtr.Zero, rect2.Left, rect2.Top, wid, hig, 8u);
		}
	}
}
