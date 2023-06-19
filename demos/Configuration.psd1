# Configuration for PowerLine
# Expected location: $env:APPDATA\PowerShell\HuddledMasses.org\PowerLine\Configuration.psd1

@{
    EscapeSequences = @{
        Esc = '['
        Store = '[s'
        Recall = '[u'
        Clear = '[0m'
    }
    ExtendedCharacters = @{
        ColorSeparator = ''
        ReverseColorSeparator = ''
        Separator = ''
        ReverseSeparator = ''
        Branch = ''
        Lock = ''
        Gear = '⛯'
        Power = '⚡'
        HourGlass = '⌛'
    }
    PowerLineConfig = @{
        RestoreVirtualTerminal = $True
        SetCurrentDirectory = $True
        Colors = @((RgbColor 'Cyan'),(RgbColor 'DarkCyan'),(RgbColor 'Gray'),(RgbColor 'DarkGray'),(RgbColor 'Gray'))
        DefaultAddIndex = -1
        Prompt = @(
            (ScriptBlock ' if ($IsElevated) { New-PromptText "!" -BackgroundColor Red -ForegroundColor White }')
            (ScriptBlock ' New-PromptText "$([PoshCode.Pansies.Entities]::ExtendedCharacters["HourGlass"])" -BackgroundColor Black -ForegroundColor White ')
            (ScriptBlock ' $splat = Get-RemainingSessionTime -Session Ninja; New-PromptText @splat')
            (ScriptBlock ' if (Get-Module -Name TabExpansionPlusPlus) { New-PromptText "++" -BackgroundColor "#007FFF" -ForegroundColor White} ')
            (ScriptBlock ' New-PromptText { "$([PoshCode.Pansies.Entities]::ExtendedCharacters["Gear"])" * $NestedPromptLevel } -BackgroundColor Blue -ForegroundColor White ')
            (ScriptBlock ' if($pushd = (Get-Location -Stack).count) { New-PromptText { "$([char]187)" + $pushd } -BackgroundColor DarkGray -ForegroundColor White } ')
            (ScriptBlock ' New-PromptText { (Get-SegmentedPath) -join ([PoshCode.Pansies.Entities]::ExtendedCharacters["Separator"]) } -BackgroundColor DarkBlue -ForegroundColor White ')
            (ScriptBlock ' Reset-Background ')
        )
        PowerLineFont = $True
        FullColor = $True
    }
}
