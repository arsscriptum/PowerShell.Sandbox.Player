# Basic example of using powershell for setting or querying the windows timer resolution value 
# using .NET functions by importing the ntdll.dll functions NtSetTimerResolution, NtQueryTimerResolution
#
# You can use this function to micro-increment timer resolution 
# See https://github.com/djdallmann/GamingPCSetup/blob/master/RESEARCH/FINDINGS/timermicroadjust.txt
#1


#Import the functions from dll
$Script:MethodDefinition = @"
[DllImport("ntdll.dll", SetLastError=true)]
public static extern NtStatus NtQueryTimerResolution(out uint MinimumResolution, out uint MaximumResolution, out uint ActualResolution);

[DllImport("ntdll.dll", SetLastError=true)]
public static extern int NtSetTimerResolution(int DesiredResolution, bool SetResolution, out int CurrentResolution );
"@



function Register-NtStatus{
    [CmdletBinding(SupportsShouldProcess)]
    param()
 
    if (!("Win32.NtStatus" -as [type])) {
        Write-Verbose "Registering Win32.NtStatus... " 
        $NtStatus = Add-Type -MemberDefinition $Script:MethodDefinition -Name 'NtStatus' -Namespace 'Win32' -PassThru
    }else{
        Write-Verbose "Win32.NtStatus already registered... " 
    }
}

function Set-DefaultNtTimerResolution{
    [CmdletBinding()]
    Param
    ()    
    Register-NtStatus
    #The resolution you want
    [long]$ntdesiredres = 6000
    [bool]$ntsetres = $true
    Write-Verbose "Set-DefaultNtTimerResolution DesiredResolution $ntdesiredres, SetResolution $ntsetres"
    Set-NtTimerResolution -DesiredResolution $ntdesiredres -SetResolution $ntsetres
}

function Set-NtTimerResolution{
    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0, Mandatory=$true, HelpMessage="Resolution to set. To receive minimum and maximum resolution values, call Get-NtTimerResolution")]
        [long]$DesiredResolution,
        [Parameter(Mandatory=$false, HelpMessage="If set, system Timer's resolution is set to DesiredResolution value. If no, parameter DesiredResolution is ignored.")]
        [bool]$SetResolution
    )    
    Register-NtStatus

    # Pointer to ULONG value receiving current timer's resolution, in 100-ns units
    [long]$ntcurrentres = $null
    #Set the timer resolution using the variables at the top
    $ret1 = [Win32.NtStatus]::NtSetTimerResolution($DesiredResolution,$SetResolution,[ref]$ntcurrentres)
    Write-Verbose "NtSetTimerResolution $DesiredResolution,$SetResolution ==> receiving current timer's resolution $ntcurrentres"
    $ntcurrentres
}

function Get-NtTimerResolution{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Register-NtStatus

    [long]$ntqtrmin = $null
    [long]$ntqtrmax = $null
    [long]$ntqtrcur = $null

    #Query the timer resolution and store them in the variables ntqtrmin, ntqtrmax and ntqtrcur
    [Win32.NtStatus]::NtQueryTimerResolution([ref]$ntqtrmin, [ref]$ntqtrmax, [ref]$ntqtrcur)

    $res = [PsCustomObject]@{
        MinimumResolution = $ntqtrmin
        MaximumResolution = $ntqtrmax
        CurrentResolution = $ntqtrcur
    }
    Write-Verbose "Current Timer Res: $ntqtrcur `r`nTimer Res Minimum: $ntqtrmin `r`nTimer Res Maximum: $ntqtrmax `r`n"
    $res
}