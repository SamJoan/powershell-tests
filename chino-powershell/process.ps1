Param(
    [parameter(Mandatory=$true)]
    [alias("i")]
    $InFile,
    [parameter(Mandatory=$false)]
    [alias("o")]
    $OutFile
)

$ErrorActionPreference = "Stop"
$OutputEncoding = New-Object -typename System.Text.UTF8Encoding

$ScriptPath = $MyInvocation.MyCommand.Path
$PWD = Split-Path $ScriptPath
Set-Location $PWD

Function Tidy-Definition {
    $Definition = $Args[0]
    $Splat = $Definition.Split(';')[0..3]
    $Result = $Splat -join ';'
    return $Result
}

Function New-Card($Property) {
    return New-Object -Type PSObject -Property $Property
}

Function Generate-Results($Word) {
    $Results = @()
    $Results += New-Card (Generate-SimpToDef $Word)
    $Results += New-Card (Generate-PinyinToDef $Word)
    $Results += New-Card (Generate-PinyinToPronunc $Word)
    return $Results
}

Function Generate-Back($Word) {
    return "{0} - {1} - {2}" -f $Word.Simpchar,$Word.Pinyin,$Word.Definition
}

Function Generate-SimpToDef($Word) {
    return @{
        Front = $Word.SimpChar
        Back = Generate-Back $Word
    }
}

Function Generate-PinyinToDef($Word) {
    return @{
        Front = $Word.Pinyin
        Back = Generate-Back $Word
    }
    
}

Function Generate-PinyinToPronunc($Word) {
    return @{
        Front = "{0} ({1})" -f $Word.ToneString,$Word.SimpChar
        Back = Generate-Back $Word
    }
}

Function Get-Word($Line) {
    $Splat = $Line.Split("`t")
    $Letters = [char[]]([char]'a'..[char]'z') + " "
    $Pinyin = $Splat[2]
    
    $ToneString = ""
    foreach($Letter in $Pinyin.toCharArray()) {
        if($Letters -contains $Letter) {
            $ToneString += $Letter
        } else {
            $ToneString += '_'
        }
    }
    
    $ToneString = ""
    foreach($Letter in $Pinyin.toCharArray()) {
        if($Letters -contains $Letter) {
            $ToneString += $Letter
        } else {
            $ToneString += '_'
        }
    }
    
    $Prop = @{
        SimpChar = $Splat[0]
        Pinyin = $Pinyin
        Definition = Tidy-Definition $Splat[3]
        ToneString = $ToneString
        length = $Splat[0].length
    }
    
    return New-Object -TypeName PSObject -Property $Prop
}

$FileContents = Get-Content -Encoding utf8 $InFile
$Words = @()
foreach($Line in $FileContents) {
    $Words += Get-Word $Line
}

$Results = @()
$Words = $Words | Sort-Object length
foreach($Word in $Words) { 
    $Results += Generate-Results $Word
}

if($OutFile) {
    Write-Output $Results | ConvertTo-CSV -Delimiter "`t" -NoTypeInformation | % {$_ -replace '"',''} | Select -Skip 1 | Out-File -Encoding utf8 $OutFile
    Write-Host ("Wrote to '{0}'" -f $OutFile)
} else {
    Write-Output $Results
}