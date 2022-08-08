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
Set-PSReadlineKeyHandler -Key Ctrl+p -Function PreviousHistory
Set-PSReadlineKeyHandler -Key Ctrl+n -Function NextHistory