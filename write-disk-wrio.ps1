#Powered by kimakrus, kimkarus.ru, info@kimkarus.ru
clear
#Get-Counter -ListSet * | Where-Object CounterSetName -eq "Логический диск" | Select -ExpandProperty Paths
function getDiskCurrentSpeed([string]$str_disk_performance) {
       
    $disk_speed = ((((get-counter -counter $str_disk_performance -ea 0).countersamples) | select cookedvalue).cookedvalue)/1024/1024

    return $disk_speed
}
function getCounterString([string]$disk,[string]$counter_type){
    $str_disk_performance_io = "\Логический диск("+$disk+":)\Скорость обмена с диском (байт/с)"
    $str_disk_performance_read = "\Логический диск("+$disk+":)\Скорость чтения с диска (байт/с)"
    $str_disk_performance_write = "\Логический диск("+$disk+":)\Скорость записи на диск (байт/с)"

    $str_disk_performance = $str_disk_performance_write

    if($counter_type -eq "read")
    {
        $str_disk_performance = $str_disk_performance_read
    }
    if($counter_type -eq "write")
    {
        $str_disk_performance = $str_disk_performance_write
    }
    if($counter_type -eq "io")
    {
        $str_disk_performance = $str_disk_performance_io
    }
    return $str_disk_performance
}
function getDiskSpeed([string]$disk,[int]$need_counts,[string]$counter_type) {
    $counts = 0
    $speed_sum = 0
    $str_disk_performance = (getCounterString -disk $disk -counter_type $counter_type)
    Write-Host $str_disk_performance
    while ($need_counts -ge $counts){
        $speed = (getDiskCurrentSpeed -str_disk_performance $str_disk_performance)
        $speed_sum = $speed_sum + $speed
        $counts += 1
        start-sleep 0.5
    }

    $speed_calc = $speed_sum / $need_counts
    return $speed_calc
}

$disk = $args[0]
$need_counts = $args[1]
$need_counts = 60
$counter_type = $args[2]

$end_speed = (getDiskSpeed -disk $disk -need_counts $need_counts -counter_type $counter_type)
$content = "disk="+$disk+",speed="+$end_speed+",MB/s"+",type="+$counter_type
$path_output = "output_"+$counter_type+"_"+$disk+".txt"
Write-Output $content | Set-Content $PSScriptRoot\$path_output