



$PlaySoundScript = {
      param($Path)

      try{
        if(-not(Test-Path $Path -PathType Leaf)){ throw "invalid sound file $Path" }

        Write-Output "Creating Sound Player for file $Path"
        [Media.SoundPlayer]$Player = [Media.SoundPlayer]::new()
        [Media.SoundPlayer]$Player.SoundLocation = $Path
        [Media.SoundPlayer]$Player.Play()

      }catch{
        Write-Error "$_"
      }
      
}.GetNewClosure()

[scriptblock]$PlaySoundScriptBlock = [scriptblock]::create($PlaySoundScript) 



function Start-PlaySoundJobs{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [switch]$Asynchronous    
    )

    try{
        $TheSoundFile = "F:\Scripts\Sandbox\Sounds\sounds\ImperialMarch60.wav"  

        $JobName = "PlaySound"
        Write-LogEntry "Start job `"$JobName`" Asynchronous $Asynchronous"
        $jobby = Start-Job -Name $JobName -ScriptBlock $PlaySoundScriptBlock -ArgumentList ($TheSoundFile)
       
        if($Asynchronous -eq $False){
            Receive-Job $JobName
        }else{
            Write-Host "Asynchronous mode. To get progress, call `"Receive-HttpJob $JobName`""
        }
        

    }catch{
        Write-Error "$_"
    }
}



