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
  $global:ompjob = Start-Job {Import-Module -Name Terminal-Icons; oh-my-posh --init --shell powershell --config $env:POSH_THEMES_PATH/kushal.omp.json};
  Write-Host "BC v1.5 Loading Profile in Background..."
  Write-Host -NoNewline "$($executionContext.SessionState.Path.CurrentLocation)".replace($pwd, '~');
  Write-Host -NoNewline " --->";
  return " ";
}
