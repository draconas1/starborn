$languages = @{"braz_por" = "l_braz_por"; "french" = "l_french"; "german" = "l_german"; "japanese" = "l_japanese"; "korean" = "l_korean"; "polish" = "l_polish"; "russian" = "l_russian"; "simp_chinese" = "l_simp_chinese"; "spanish" = "l_spanish" }
$language = ""
$loc = Get-Location
$modpath = $args[0]
$path2 = "$modpath\localisation\english"

$sourceDirectory = Convert-Path $path2
if ($?) {
    write-host "Found $sourceDirectory to copy from"
} else {
    write-host "The Source Directory '$sourceDirectory' does not exist.  Exiting"
    Exit 1
}

foreach($folderName in $($languages.keys)){
    $language = $languages[$folderName]
    $targetDirectory = $sourceDirectory.Replace("english", $folderName)

    #Delete Existing Language Files
    Remove-Item -Recurse -Force $targetDirectory

    #Copy English Files
    Copy-Item $sourceDirectory $targetDirectory -recurse

    #Change to the directory
    Set-Location $targetDirectory
    if ($?) {
    } else {
        # put a bail clause to avoid renaming the english localisation file!
        write-host "Unable to Change Directory to '$targetDirectory'.  Exiting"
        Exit 1
    }

    #Rename Files
    Get-ChildItem  -Recurse -file | 
         ForEach-Object{
             Rename-Item -Path $_.Fullname -NewName $_.Name.Replace("l_english",$language)  
         }

    #Replace in Files
    $configFiles = Get-ChildItem . *.yml -Recurse
    foreach ($file in $configFiles)
    {
        (Get-Content $file.PSPath) |
        Foreach-Object { $_ -replace "l_english", "$language" } |
        Set-Content $file.PSPath -encoding UTF8
    }
}
Set-Location $loc