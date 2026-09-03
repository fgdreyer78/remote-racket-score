$p = "c:\src\Remote Racket Score - CODING\lib\features\score\landscape_score_layout.dart"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$c = [System.IO.File]::ReadAllText("c:\src\Remote Racket Score - CODING\lib\features\score\landscape_score_layout.dart")
Write-Host "Current length: $($c.Length)"
