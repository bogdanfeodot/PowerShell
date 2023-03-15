$SqlServer1Name = "VBUHDWH2016CL.RORETAIL.ROINTRANET"
$SqlServer2Name = "BUHSQLDWHST07.rouat.rotest\dwh2016"

$SqlServer1 = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServer1Name)
$SqlServer2 = New-Object Microsoft.SqlServer.Management.Smo.Server($SqlServer2Name)

$SqlServer1JobListing = $SqlServer1.JobServer.Jobs | 
    Select-Object -ExpandProperty Name

$SqlServer2JobListing = $SqlServer2.JobServer.Jobs |
    Select-Object -ExpandProperty Name

Write-Host 'Comparing Jobs Names...' $SqlServer1Name ' vs ' $SqlServer2Name

Compare-Object -ReferenceObject $SqlServer1JobListing -DifferenceObject $SqlServer2JobListing |
    Where-Object {$SqlServer1JobListing -NotLike '_*' -or $SqlServer2JobListing -NotLike '_*'} #|
    Select-Object -ExpandProperty InputObject
