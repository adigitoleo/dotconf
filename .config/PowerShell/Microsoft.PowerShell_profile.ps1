# To visually check color mappings:
# $> [enum]::GetValues([System.ConsoleColor]) | ForEach-Object {Write-Host $_ -ForegroundColor $_}
# Color mapping for Mellow Dark scheme.
Set-PSReadlineOption -Colors @{
   Command = "DarkCyan"
   Comment = "DarkMagenta"
   ContinuationPrompt = "DarkGray"
   Default = "Gray"
   Emphasis = "Blue"
   Error = "Red"
   Keyword = "Cyan"
   Member = "Gray"
   Number = "Gray"
   Operator = "DarkCyan"
   Parameter = "Yellow"
   InlinePrediction = "DarkGray"
   String = "Gray"
   Type = "DarkYellow"
   Variable = "Yellow"
   # Selection (highlight) color already handled by powershell scheme.
}

Set-PSReadlineOption -EditMode Vi

# More Linux-ish shortcuts, note that Ctrl+<x> for some letter <x> must use the lowercase letter.
Set-PSReadlineKeyHandler -Key Ctrl+p -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key Ctrl+n -Function HistorySearchForward

# Use blue color for prompt, default at https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_prompts?view=powershell-7.2#the-default-prompt
function prompt {
   $color = [char]27
    "$color[34m" + $(if (Test-Path variable:/PSDebugContext) { '[DBG]: ' }
      else { '' }) + 'PS ' + $(Get-Location) +
        $(if ($NestedPromptLevel -ge 1) { '>>' }) + '>' + "$color[0m "
}