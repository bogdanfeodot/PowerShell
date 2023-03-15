$fso = Get-ChildItem -Recurse -path 'C:\Users\pu92wl\PU92WL\PowerShell\Script Jobs\20200423_Prod_Jobs\VBUHDWH2016CL.RORETAIL.ROINTRANET\_Jobs\Weekly' | 
    Where-Object {$_.Extension -eq ".sql"} 

$fsoBU = Get-ChildItem -Recurse -path 'C:\Users\pu92wl\Repos\VBUHDWH2016CL.RORETAIL.ROINTRANET\_Jobs\Weekly' | 
    Where-Object {$_.Extension -eq ".sql"} 

Compare-Object -ReferenceObject $fso -DifferenceObject $fsoBU