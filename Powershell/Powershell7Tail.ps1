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
  $ohmyposhluncher = & ([ScriptBlock]::Create((oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\kushal.omp.json" --print) -join "`n"))
  $global:ompjob = Start-Job {$ohmyposhluncher};
  write-host -ForegroundColor Blue "BC v1.6 Loading `$profile in the background..."
  Write-Host '            _________________' -ForegroundColor Red
Write-Host '         < Welcome' $Env:UserName'!! >' -ForegroundColor Green
Write-Host '            -----------------' -ForegroundColor Red
Write-Host '             \' -ForegroundColor Red
Write-Host '              \' -ForegroundColor Red
Write-Host '                                            .::!!!!!!!:.' -ForegroundColor Red
Write-Host '           .!!!!!:.                        .:!!!!!!!!!!!!' -ForegroundColor Red
Write-Host '           ~~~~!!!!!!.                 .:!!!!!!!!!UWWW$$$' -ForegroundColor Red
Write-Host '               :$$NWX!!:           .:!!!!!!XUWW$$$$$$$$$P' -ForegroundColor Red
Write-Host '               $$$$$##WX!:      .<!!!!UW$$$$"  $$$$$$$$#' -ForegroundColor Red
Write-Host '               $$$$$  $$$UX   :!!UW$$$$$$$$$   4$$$$$*' -ForegroundColor Red
Write-Host '               ^$$$B  $$$$\     $$$$$$$$$$$$   d$$R"' -ForegroundColor Red
Write-Host '                 "*$bd$$$$       "#$$$$$$$$$$bd$P' -ForegroundColor Red
Write-Host '                      """"          """"""""""" ' -ForegroundColor Red
Write-Host ' '
Write-Host ' '
  Write-Host -ForegroundColor Green -NoNewline "  $($executionContext.SessionState.Path.CurrentLocation) ".replace($HOME, '~');
  Write-Host -ForegroundColor Red -NoNewline "ᓚᘏᗢ"
  return " ";
}
