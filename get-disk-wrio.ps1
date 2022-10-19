#Powered by kimakrus, kimkarus.ru, info@kimkarus.ru
clear
#Get-Counter -ListSet * | Where-Object CounterSetName -eq "Логический диск" | Select -ExpandProperty Paths
function getContentByPath([string]$path) {

    $content = Get-Content -Path $PSScriptRoot\$path -TotalCount 1
    return $content
}
function getDiskSpeedContent([string]$content){

    $content_array1 = $content -split ","
    $disk_speed = 0
    $content_array2 = $content_array1[1] -split "="
    $disk_speed = [decimal]$content_array2[1]
    return $disk_speed
}
function getExitStatus([decimal]$disk_speed, [int]$critical, [int]$warning){
    if($disk_speed -gt $critical){
        return(2)
    }
    if($disk_speed -gt $warning){
        return(1)
    }
    return(0)
}

$disk = $args[0]
$counter_type = $args[1]
$warning = [int]$args[2]
$critical = [int]$args[3]

$path_source = "output_"+$counter_type+"_"+$disk+".txt"

$content = (getContentByPath -path $path_source)
$disk_speed = getDiskSpeedContent -content $content

$exit_status = (getExitStatus -disk_speed $disk_speed -critical $critical -warning $warning)
if($exit_status -eq 0){
    $content = "OK: "+$content
}
if($exit_status -eq 1){
    $content = "WARNING: "+$content
}
if($exit_status -eq 2){
    $content = "CRITICAL: "+$content
}
Write-Host $content
exit $exit_status