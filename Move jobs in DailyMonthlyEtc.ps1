
$source = "C:\Users\pu92wl\PU92WL\PowerShell\Script Jobs\20200423_Prod_Jobs\VBUHDWHCL.RORETAIL.ROINTRANET"

## Daily

$target = $source + "\_Jobs\Daily"

get-childitem -Recurse -path $source | 
    where {($_.extension -eq '.sql' -and $_ -like '*daily*')} | 
    move-item -Destination $target

#Monthly

$target = $source + "\_Jobs\Monthly"

get-childitem -Recurse -path $source | 
    where {($_.extension -eq '.sql' -and $_ -like '*Monthly*')} | 
    move-item -Destination $target

#Twice

$target = $source + "\_Jobs\Twice"

get-childitem -Recurse -path $source | 
    where {($_.extension -eq '.sql' -and $_ -like '*Twice*')} | 
    move-item -Destination $target

#Weekly

$target = $source + "\_Jobs\Weekly"

get-childitem -Recurse -path $source | 
    where {($_.extension -eq '.sql' -and $_ -like '*Weekly*')} | 
    move-item -Destination $target
