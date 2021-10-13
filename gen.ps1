Param(
    [Parameter(Position=1)]
    [int]
    $Generate = 100
)

$INPUT_FILE = "./in/genres.txt"
$OUT0="out/output_0_markov.txt"
$OUT1="out/output_1_clean.txt"
$OUT2="out/output_2_regex.txt"
$OUT3="out/output_3_final.txt"

"Generating $Generate genres..."
Get-Content $INPUT_FILE | ./quick-markov/markov.exe $Generate | Out-File $OUT0

[System.Collections.ArrayList]$InputFile = Get-Content $INPUT_FILE

$Content = Get-Content $OUT0 | Sort | Get-Unique
$Lines = [System.Collections.ArrayList]@()
$Content | % {
    [System.Collections.ArrayList]$Clean = @()
    $_.Split(" ") | % {
        if ($_ -in $Clean) {
            $Clean.Remove($_)
        }
       $i = $Clean.Add($_)
    }
    [String]$Line = $Clean -Join " "
    $Line = $Line.Trim()
    if ($Line -notin $InputFile) {
        $i = $Lines.Add($Line)
    }
}
"Cleaned down to $($Content.Count) lines..."
$Content = $Lines
Set-Content $OUT1 $Content

function Regex-Pass {
    param($In)

    foreach ($_ in Get-Content "./in/contractions.csv") {
        $Parts = $_.Split(',')
        if ($Parts.length -eq 2) {
            $Match = $Parts[0];
            $Replace = $Parts[1].Replace('\', '$');
            $In = $In -creplace "$Match", "$Replace"
        }
    }

    Write-Output $In
}

$Content = Regex-Pass($Content)
$Content = Regex-Pass($Content)

Set-Content $OUT2 $Content
$Content = $Content | Sort | Get-Unique
"Regex pass down to $($Content.Count) lines."
Set-Content $OUT3 $Content