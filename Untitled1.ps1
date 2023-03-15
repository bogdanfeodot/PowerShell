#Load the SQL Server SMO Assemly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

$srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" 'VBUHDWHCL.RORETAIL.ROINTRANET'

$script =  $srv.JobServer.Jobs[0].Script()

$schedule = $srv.JobServer.Jobs[0].JobSchedules.Count
write-output $schedule

#$scheduleID = $schedule.ScheduleUid
#
#$a = ', 
#		@schedule_uid=N''' + $scheduleID + ''''
#
#$script = $script -replace $a, ''
#
#Write-Output $script
#
#
#Write-Output $a