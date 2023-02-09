
. "$PSScriptRoot\HighResolutionTimer.ps1"

Register-HighResTimer

    $handlerLoadCompleted = [System.ComponentModel.AsyncCompletedEventHandler] {
            param($SenderObject,$handlerLoadCompletedEventArgs) 

        function HandleLoadException([System.Exception]$ex){
            
            $formatstring = "{0}`n{1}"
            $fields = $ex.Source,$ex.Message
            $ExceptMsg=($formatstring -f $fields)
            
            Write-Host "`n[ERROR] -> " -NoNewLine -ForegroundColor DarkRed; 
            Write-Host "$ExceptMsg`n`n" -ForegroundColor DarkYellow
        }  

        [System.Exception]$eventError = $handlerLoadCompletedEventArgs.error
        [bool]$loadCancelled = $handlerLoadCompletedEventArgs.cancelled
        [System.Object]$eventUserState = $handlerLoadCompletedEventArgs.userState

        if($loadCancelled -eq $True){
            Write-Host "[Load Event] " -n -f DarkRed
            Write-Host "Load was cancelled by the user" -f DarkYellow
        }else{
            $delay = [HighResolutionDateTimer]::StopTimer()
            Write-Host "[Load Event] " -n -f DarkRed
            Write-Host "Load was completed in $delay ms" -f DarkYellow
        }
        if($eventError -ne $Null){
            HandleLoadException($eventError)
        }
        if($eventUserState -ne $Null){
            $s = $eventUserState.ToString()
            Write-Host "eventUserState $s" -f Green 
        }
    };

    [Media.SoundPlayer]$Script:Player = [Media.SoundPlayer]::new()
    [Media.SoundPlayer]$Script:Player2 = [Media.SoundPlayer]::new()


    $Script:Player.add_LoadCompleted($handlerLoadCompleted)
    $Script:Player2.add_LoadCompleted($handlerLoadCompleted)



function New-Player1{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Path = "$PSScriptRoot\sounds\PinkPanther60.wav"
    )
    if(-not(Test-Path -Path $Path -PathType Leaf)){ throw "[New-Player1] invalid path $Path" }
    
    $KBytes = [math]::Round((gi $Path).Length /1024)
    Write-Host "Loading file $Path ($KBytes KBytes)"
    $Player.SoundLocation = $Path
    # Load the .wav file.
    Write-Host "Player 1 is loading sound" -f DarkYellow
    [HighResolutionDateTimer]::StartTimer()
    $Script:Player.LoadAsync()
}
            


function New-Player2{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Path = "$PSScriptRoot\sounds\ImperialMarch60.wav" 
    )
    if(-not(Test-Path -Path $Path -PathType Leaf)){ throw "[New-Player2] invalid path $Path" }
    
    $KBytes = [math]::Round((gi $Path).Length /1024)
    Write-Host "Loading file $Path ($KBytes KBytes)"
    $Player.SoundLocation = $Path
    # Load the .wav file.
    Write-Host "Player 2 is loading sound" -f DarkYellow
    [HighResolutionDateTimer]::StartTimer()
    $Script:Player2.LoadAsync()
}
            

function LoadSound{
    # Load the .wav file.
    $Script:Player.Load()
}
            

function PlaySoundAsync{
    # Load the .wav file.
    $Script:Player.Play()
}
            
function PlaySoundAsync2{
    # Load the .wav file.
    $Script:Player2.Play()
}

function PlaySoundBlocking{
    # Load the .wav file.
    $Script:Player.PlaySync()
}