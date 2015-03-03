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

Function Generate-Results {
    $SimpChar = $Args[0]
    $Pinyin = $Args[1]
    $Definition = $Args[2]
    
    $Results = @()
    $Results += Generate-SimpToDef $SimpChar $Pinyin $Definition
    $Results += Generate-PinyinToDef $SimpChar $Pinyin $Definition
    $Results += Generate-PinyinToPronunc $SimpChar $Pinyin $Definition
    return $Results
}

Function Generate-SimpToDef {
    $SimpChar = $Args[0]
    $Pinyin = $Args[1]
    $Definition = $Args[2]
    
    return "$SimpChar`t$Pinyin - $Definition"
}

Function Generate-PinyinToDef {
    $SimpChar = $Args[0]
    $Pinyin = $Args[1]
    $Definition = $Args[2]
    
    return "$Pinyin`t$SimpChar - $Definition"
}

# https://chinese.stackexchange.com/questions/480/where-can-i-find-audio-recordings-of-every-word
# https://stackoverflow.com/questions/9163988/download-mp3-from-google-translate-text-to-speech/13823866#13823866

# http://ankisrs.net/docs/manual.html#importing-media
# C:\Users\User\Documents\Anki\User 1\collection.media
Function Generate-PinyinToPronunc {
    $SimpChar = $Args[0]
    $Pinyin = $Args[1]
    $Definition = $Args[2]
    
    $Letters = [char[]]([char]'a'..[char]'z')
    
    $ToneString = ""
    foreach($Letter in $Pinyin.toCharArray()) {
        if($Letters -contains $Letter) {
            $ToneString += $Letter
        } else {
            $ToneString += '_'
        }
    }
    
    return "$ToneString - $SimpChar`t$Pinyin"
}

# @TODO: Make one char pinyin appear before two char. E.g. 中 before 中国。
$File = $Args[0]
if(-not $File) {
    Write-Error "$Args[0] must be the location of the file."
} else {
    $FileContents = get-content -encoding utf8 $File
    foreach($Line in $FileContents) {
        $Splat = $Line.Split("`t")
        $SimpChar = $Splat[0]
        $Pinyin = $Splat[2]
        $Definition = Tidy-Definition $Splat[3]
        
        $Results = Generate-Results $SimpChar $Pinyin $Definition
        
        foreach($Result in $Results) {
            Write-Output $Result
        }
    }
}
