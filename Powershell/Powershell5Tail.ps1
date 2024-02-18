$nficon=[PSCustomObject]@{
'/\/'=[char]0xf489
}
$nfcleanicon = $nficon.'/\/'

$nficon2=[PSCustomObject]@{
'/\/\'=[char]0xe7a2
}
$nfcleanicon2 = $nficon2.'/\/\'
function prompt {
  if (Test-Path variable:global:ompjob) {
    Receive-Job -Wait -AutoRemoveJob -Job $global:ompjob | Invoke-Expression;
    Remove-Variable ompjob -Scope Global;
    Enable-PoshTransientPrompt
    Enable-PoshLineError

    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle InlineView

    [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
    return prompt;
  }
  $ohmyposhluncher = & ([ScriptBlock]::Create((oh-my-posh init powershell --config "$env:POSH_THEMES_PATH\kushal.omp.json" --print) -join "`n")); Import-Module Terminal-Icons
  $global:ompjob = Start-Job {$ohmyposhluncher};
  Receive-Job 'CheckFBCUpdate','CheckFEPUpdate' -Wait -AutoRemoveJob -ErrorAction SilentlyContinue >$null | Out-Null;
  Write-Host 'Loading `$profile in Background...' -ForegroundColor "Blue";
    Write-Host '            _________________' -ForegroundColor "Red";
Write-Host '         < Welcome' $Env:UserName'!! >' -ForegroundColor "Green";
Write-Host '            -----------------' -ForegroundColor "Red";
Write-Host '             \' -ForegroundColor "Red";
Write-Host '              \' -ForegroundColor "Red";
Write-Host '                                            .::!!!!!!!:.' -ForegroundColor "Red";
Write-Host '           .!!!!!:.                        .:!!!!!!!!!!!!' -ForegroundColor "Red";
Write-Host '           ~~~~!!!!!!.                 .:!!!!!!!!!UWWW$$$' -ForegroundColor "Red";
Write-Host '               :$$NWX!!:           .:!!!!!!XUWW$$$$$$$$$P' -ForegroundColor "Red";
Write-Host '               $$$$$##WX!:      .<!!!!UW$$$$"  $$$$$$$$#' -ForegroundColor "Red";
Write-Host '               $$$$$  $$$UX   :!!UW$$$$$$$$$   4$$$$$*' -ForegroundColor "Red";
Write-Host '               ^$$$B  $$$$\     $$$$$$$$$$$$   d$$R"' -ForegroundColor "Red";
Write-Host '                 "*$bd$$$$       "#$$$$$$$$$$bd$P' -ForegroundColor "Red";
Write-Host '                      """"          """"""""""" ' -ForegroundColor "Red";
Write-Host ' ';
Write-Host ' ';
  Write-Host -NoNewline $nfcleanicon "$($executionContext.SessionState.Path.CurrentLocation)".replace($pwd, '~') -foregroundcolor "Green";
  Write-Host -NoNewline " $nfcleanicon2" -foregroundcolor "red";
  return " ";
}
