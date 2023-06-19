#region $profile.CurrentUserCurrentHost
using namespace System.Management.Automation.Language
Import-Module PSReadline
$psReadLine = [Microsoft.PowerShell.PSConsoleReadLine]
Set-PSReadlineKeyHandler -Chord CTRL+Spacebar -ScriptBlock { Invoke-GuiCompletion }
Import-Module -Name PowerLine -RequiredVersion 3.0.3
Import-Module posh-git
Import-Module PSGit

$gitAliases = 
    (git config --global -l).Where{ 
            $_ -match '^alias\.'
        }.ForEach{
            $_ -replace '^alias\.(\w+).*', '$1'
        }

$ExecutionContext.InvokeCommand.CommandNotFoundAction = { 
    param ($name, $eventArgs) 
    if ($name -in $gitAliases) { 
        $alias = $name
    } elseif ($aliases = $gitAliases -match [regex]::Escape($name)) { 
        $alias = $aliases | 
            Sort-Object -Property Length  | 
            Select-Object -First 1 
    } elseif (Test-Path -LiteralPath $name) {
        $eventArgs.CommandScriptBlock = { Push-Location -LiteralPath $name }.GetNewClosure()
    }

    if ($alias) { 
        $eventArgs.CommandScriptBlock = { git $alias @args }.GetNewClosure()
    } 
}

Set-PSReadlineKeyHandler -Chord Spacebar -ScriptBlock {
    param ($key, $arg)
    $convert = @{
        'njuvm' = 'New-OPServer -Virtual -Pullserver Prod -HostName '
        'slcm' = 'Set-DscLocalConfigurationManager -Path \\dsc-pull.ams.optiver.com\meta -Verbose -CimSession '
        'sacfg' = 'Start-DscConfiguration -UseExisting -Wait -Verbose -CimSession '
        'upcfg' = 'Update-DscConfiguration -Wait -Verbose -CimSession '
        'tcfg' = 'Test-DscConfiguration -Detailed -Verbose -CimSession '
        'pu' = 'git push '
        'me' = 'git merge '
        'rmb' = 'git push --delete origin '
        'catc' = 'Get-Content -Path F:\Scripts\Windows\dsc\ConfigurationData\'
        'grepc' = 'Select-String -Path F:\Scripts\Windows\dsc\ConfigurationData '
        'pity' = 'putty bartoszbielawski@'
        'wpcon' = 'putty app_bartosz@'
        '11' = 'Show-Slide -Slide $topics.Profile.Why'
        '12' = 'Show-Slide -Slide $topics.Profile.Types'
        '13' = 'Show-Slide -Slide $topics.Profile.Modular'
        '21' = 'Show-Slide -Slide $topics.Modules.Shine'
        '22' = 'Show-Slide -Slide $topics.Modules.Complete'
        '23' = 'Show-Slide -Slide $topics.Modules.History'
        '31' = 'Show-Slide -Slide $topics.Tricks.Fake'
        '32' = 'Show-Slide -Slide $topics.Tricks.Vars'
        '33' = 'Show-Slide -Slide $topics.Tricks.Pipeline'
    }
    $line = $null
    $cursor = $null
    $psReadLine::GetBufferState(
        [ref]$line, [ref]$cursor
    )
    if ($convert.ContainsKey($line)) {
        $psReadLine::Replace(
            0,
            $line.Length,
            $convert.$line
        )
        $psReadLine::SetCursorPosition($convert.$line.Length)
    } else {
        $psReadLine::Insert(' ')
    }
}

# Version with expanding aliases...

Set-PSReadlineKeyHandler -Chord Spacebar -ScriptBlock {
    param ($key, $arg)
    $convert = @{
        'patch' = "git commit -p -m '"
        '11' = 'Show-Slide -Slide $topics.Profile.Why'
        '12' = 'Show-Slide -Slide $topics.Profile.Types'
        '13' = 'Show-Slide -Slide $topics.Profile.Modular'
        '21' = 'Show-Slide -Slide $topics.Modules.Shine'
        '22' = 'Show-Slide -Slide $topics.Modules.Complete'
        '23' = 'Show-Slide -Slide $topics.Modules.History'
        '31' = 'Show-Slide -Slide $topics.Tricks.Fake'
        '32' = 'Show-Slide -Slide $topics.Tricks.Vars'
        '33' = 'Show-Slide -Slide $topics.Tricks.Predict'
    }
    $line = $null
    $cursor = $null
    $psReadLine::GetBufferState(
        [ref]$line, [ref]$cursor
    )
    if ($convert.ContainsKey($line)) {
        $psReadLine::Replace(
            0,
            $line.Length,
            $convert.$line
        )
        $psReadLine::SetCursorPosition($convert.$line.Length)
    } else {
        $ast = [Parser]::ParseInput($line, [ref]$null, [ref]$null)
        $currentToken = @(
            $ast.Find(
                {
                    $args[0].Extent.EndOffset -eq $cursor -and
                    $args[0] -is [CommandAst]
                },
                $true
            )
        )[0]
        if ($currentToken) {
            $potentialAlias = $currentToken.Extent.Text
            $replace = if ($alias = Get-Alias -Name $potentialAlias | Where { $_.Name -eq $potentialAlias}) {
                $alias.Definition
            }
        }
        if ($replace) {
            $psReadLine::Replace(
                $currentToken.Extent.StartOffset,
                ($currentToken.Extent.EndOffset - $currentToken.Extent.StartOffset),
                $replace
            )
        }
        $psReadLine::Insert(' ')
    }
}

#endregion

#region $profile.CurrentUserAllHosts

Import-Module HistoryPx
function Get-RemainingSessionTime {
    param (
      [ValidateSet('Ninja', 'Predictors', 'Test')]
      [String]$Session = 'Ninja',
  
      [String]$Format = 'm\m\ s\s'
    )
    $end = switch ($Session) {
          Ninja {
              '2023-06-19 14:45'
          }
          Predictors {
              '2023-06-21 16:45'
          }
          Test {
              $sec = (0..2400) | Get-Random
              (Get-Date).AddSeconds($sec)
          }
      }
  
      $left = New-TimeSpan -End $end
      
      $color = if ($Left.Minutes -lt 5) {
          'DarkRed'
      } elseif ($Left.Minutes -lt 15) {
          'DarkYellow'
      } else {
          'DarkGreen'
      }
      @{
          InputObject = $left.ToString($Format)
          BackgroundColor = $color
          ForegroundColor = 'White'
      }
  }


#endregion