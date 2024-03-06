// KinitoPET, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// CmdTerminal
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using Godot;

public class CmdTerminal : Node
{
	private struct RECT
	{
		public int Left;

		public int Top;

		public int Right;

		public int Bottom;
	}

	private Timer positionCheckTimer;

	public int windowX;

	public int windowY;

	private Process process;

	private bool cmdCheck;

	private Timer shakeTimer;

	private Timer timeOut;

	public bool cmdOpened;

	public int shake;

	public int timeouter;

	public int randomValueX;

	public int randomValueY;

	public int lastX;

	public int lastY;

	public int setX;

	public int setY;

	private Random random = new Random();

	public bool closeable;

	[DllImport("user32.dll", SetLastError = true)]
	private static extern bool GetWindowRect(IntPtr hwnd, out RECT lpRect);

	[DllImport("user32.dll")]
	private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

	[DllImport("user32.dll")]
	private static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

	[DllImport("user32.dll", SetLastError = true)]
	internal static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

	public void _start()
	{
		timeOut = new Timer();
		timeOut.WaitTime = 10f;
		timeOut.OneShot = false;
		timeOut.Connect("timeout", this, "cmd_timout");
		AddChild(timeOut);
		timeOut.Start();
		cmdCheck = true;
	}

	private void cmd_timout()
	{
		if (System.Environment.OSVersion.Version.Build >= 22000)
		{
			if (!cmdOpened)
			{
				CloseOtherCommandPromptInstances();
				RunBatFile();
				cmdOpened = true;
			}
			timeouter = 5;
		}
		timeouter++;
		if (timeouter == 2)
		{
			GetParent().Call("waitCMD");
		}
		if (timeouter == 4)
		{
			GetParent().Call("timeoutCMD");
		}
		if (timeouter == 5 && !cmdOpened)
		{
			CloseOtherCommandPromptInstances();
			RunBatFile();
			cmdOpened = true;
		}
	}

	public override void _Process(float delta)
	{
		if (cmdCheck && !cmdOpened)
		{
			CloseCommandPrompts();
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

	public void RunBatFile()
	{
		process = new Process();
		process.StartInfo.WindowStyle = ProcessWindowStyle.Normal;
		process.StartInfo.FileName = "temp.bat";
		process.StartInfo.WorkingDirectory = OS.GetUserDataDir() + "/.bat";
		process.EnableRaisingEvents = true;
		process.Exited += OnProcessExited;
		process.Start();
		GetParent().Call("openedCMD");
		positionCheckTimer = new Timer();
		positionCheckTimer.WaitTime = 1f;
		positionCheckTimer.OneShot = false;
		positionCheckTimer.Connect("timeout", this, "windowsPos");
		AddChild(positionCheckTimer);
		positionCheckTimer.Start();
		shakeTimer = new Timer();
		shakeTimer.WaitTime = 0.05f;
		shakeTimer.OneShot = false;
		shakeTimer.Connect("timeout", this, "shakeOut");
		AddChild(shakeTimer);
		shakeTimer.Start();
	}

	private void CloseOtherCommandPromptInstances()
	{
		Process[] processesByName = Process.GetProcessesByName("cmd");
		foreach (Process p in processesByName)
		{
			if (p.Id != Process.GetCurrentProcess().Id)
			{
				p.CloseMainWindow();
				p.WaitForExit();
				p.Close();
			}
		}
	}

	private void shakeOut()
	{
		if (shake <= 0)
		{
			return;
		}
		// thanks to lang stuff, this will be the german title instead..	
		IntPtr hwnd = FindWindow(null, "Eingabeaufforderung");
		if (hwnd != IntPtr.Zero && GetWindowRect(hwnd, out var rect))
		{
			if (randomValueX == 0)
			{
				randomValueX = random.Next(-shake, shake);
			}
			else
			{
				randomValueX = 0;
			}
			if (randomValueY == 0)
			{
				randomValueY = random.Next(-shake, shake);
			}
			else
			{
				randomValueY = 0;
			}
			if ((randomValueX != 0) | (randomValueY != 0))
			{
				lastX = rect.Left;
				lastY = rect.Top;
				setX = rect.Left + randomValueX;
				setY = rect.Top + randomValueY;
			}
			else
			{
				setX = lastX;
				setY = lastY;
			}
			SetWindowPos(hwnd, IntPtr.Zero, setX, setY, rect.Right - rect.Left, rect.Bottom - rect.Top, 64u);
		}
	}

	private void windowsPos()
	{
		IntPtr hwnd = FindWindow(null, "Command Prompt");
		if (hwnd != IntPtr.Zero && GetWindowRect(hwnd, out var rect))
		{
			GD.Print("Window Position Updated: " + rect.Left + ", " + rect.Top);
			windowX = rect.Left;
			windowY = rect.Top;
			GetParent().Call("windowX", windowX);
			GetParent().Call("windowY", windowY);
		}
	}

	private void OnProcessExited(object sender, EventArgs e)
	{
		if (closeable)
		{
			positionCheckTimer.Stop();
			return;
		}
		GetParent().Call("playerCloseCMD");
		RunBatFile();
	}
}
