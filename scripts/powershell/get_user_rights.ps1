clear
Import-Module 'PowerView.ps1'
function Colorize-Output {
    process {
        $_ | ForEach-Object {
            $originalString = $_

            # Define phrases and their colors
            $phrases = @{
                'AccessAllowed' = 'Green'
                'None'          = 'Red'
                'GenericAll'          = 'Blue'
            }

            $pattern = '(' + (($phrases.Keys | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')'
            $segments = [regex]::Split($originalString, $pattern)

            foreach ($segment in $segments) {
                if ($phrases.ContainsKey($segment)) {
                    Write-Host -NoNewline -ForegroundColor $phrases[$segment] $segment
                } else {
                    Write-Host -NoNewline $segment
                }
            }
            
            # Output a newline character for the next line
            Write-Host
        }
    }
}





$userName = Read-Host "Enter the username"
Get-ObjectAcl $userName | Out-String | Colorize-Output





