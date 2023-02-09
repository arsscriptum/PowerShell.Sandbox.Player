<#
    public static Stopwatch sw;
    public static HashSet<DateTime> distinctValues;
    public static void Reset {
        distinctValues = new HashSet<DateTime>();
        sw = Stopwatch.StartNew();
    }
    public static long Stop {
        long res = sw.Elapsed.TotalMilliseconds / distinctValues.Count;
        return res;
    }

#>

#Import the functions from dll
$Script:HighResTimerDefinition = @"
using System;
using System.Diagnostics;
using System.Threading;
using System.Runtime.InteropServices;

public static class HighResolutionDateTimer
{
    public static DateTime UtcStart { get; private set; } 
    public static Stopwatch timePerParse  { get; private set; } 
    public static bool IsAvailable { get; private set; }


    [DllImport("Kernel32.dll", CallingConvention = CallingConvention.Winapi)]
    private static extern void GetSystemTimePreciseAsFileTime(out long filetime);

    public static void StartTimer()
    {
        UtcStart = DateTime.UtcNow;
    }
    public static double StopTimer()
    {
        TimeSpan diff = DateTime.UtcNow - UtcStart;
        return diff.TotalMilliseconds;
    }
    public static DateTime UtcNow
    {
        get
        {
            if (!IsAvailable)
            {
                throw new InvalidOperationException(
                    "High resolution clock isn't available.");
            }

            long filetime;
            GetSystemTimePreciseAsFileTime(out filetime);

            return DateTime.FromFileTimeUtc(filetime);
        }
    }

    static HighResolutionDateTimer()
    {
        try
        {
            long filetime;
            GetSystemTimePreciseAsFileTime(out filetime);
            IsAvailable = true;
        }
        catch (EntryPointNotFoundException)
        {
            // Not running Windows 8 or higher.
            IsAvailable = false;
        }
    }
}

"@



function Register-HighResTimer{
    [CmdletBinding(SupportsShouldProcess)]
    param()
 
    if (!("Win32.HighResolutionDateTimer" -as [type])) {
        Write-Verbose "Registering Win32.HighResolutionDateTimer... " 
        $HighResolutionDateTime = Add-Type -TypeDefinition "$Script:HighResTimerDefinition" -Passthru
    }else{
        Write-Verbose "Win32.HighResolutionDateTime already registered... " 
    }
}


