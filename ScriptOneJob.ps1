# Date:     16/02/14
# Author:   John Sansom
# Description:  PS script to generate all SQL Server Agent jobs on the given instance.
#       The script accepts an input file of server names.
# Version:  1.1
#
#Date:      07/04/20
#Author:    Bogdan Feodot
#Description:   Modified script to generate SQL Server Agent jobs scripts with the following improvments:
#           - Removed ScheduleUID, so the script cand be run from one instance to another
#           - Added sysjobhistory retention, script cand be executed multiple times without losing job's history (prepare for CI/CD)
# Version:  1.2
#
#
#Date:      21/07/20
#Author:    Bogdan Feodot
#Description:   Modified scriptSQLServerAgentJobs to be applied for a specific job
# Version:  1.2
#
#
# Example Execution: .\scriptOneJob.ps1 .\ServerNameList.txt 'Monthly FastLane'

 
param([String]$ServerListPath, [String]$JobName)

 
#Load the input file into an Object array
$ServerNameList = get-content -path $ServerListPath
 
#Load the SQL Server SMO Assemly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
 
#Create a new SqlConnection object
$objSQLConnection = New-Object System.Data.SqlClient.SqlConnection
 
#For each server in the array do the following..
foreach($ServerName in $ServerNameList)
{
    Try
    {
        $objSQLConnection.ConnectionString = "Server=$ServerName;Integrated Security=SSPI;"
            Write-Host "Trying to connect to SQL Server instance on $ServerName..." -NoNewline
            $objSQLConnection.Open() | Out-Null
            Write-Host "Success."
        $objSQLConnection.Close()
    }
    Catch
    {
        Write-Host -BackgroundColor Red -ForegroundColor White "Fail"
        $errText =  $Error[0].ToString()
            if ($errText.Contains("network-related"))
        {Write-Host "Connection Error. Check server name, port, firewall."}
 
        Write-Host $errText
        continue
    }
 
#IF the output folder does not exist then create it
$OutputFolder = ".\$ServerName"
$DoesFolderExist = Test-Path $OutputFolder
$null = if (!$DoesFolderExist){MKDIR "$OutputFolder"}

#Create a new SMO instance for this $ServerName
$srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $ServerName

 
$srv.JobServer.Jobs | foreach-object -process { 

    IF ($_.name -eq $JobName) {
        
$script = '
USE [msdb]
GO
declare @var_jobId UNIQUEIDENTIFIER

SELECT @var_jobId = job_id from msdb.dbo.sysjobs WHERE name = '''+ $_.Name +'''

DROP TABLE IF EXISTS #jobHistory

select *
into #jobHistory
from msdb.dbo.sysjobhistory
where job_id = @var_jobId

IF @var_jobId IS NOT NULL
    BEGIN
    EXEC msdb.dbo.sp_delete_job @job_id=@var_jobId, @delete_unused_schedule=1
    END

' + $_.Script() + '

select @var_jobId = job_id from msdb.dbo.sysjobs WHERE name = '''+ $_.Name +'''

SET IDENTITY_INSERT msdb.dbo.sysjobhistory ON
INSERT INTO msdb.dbo.sysjobhistory 
(instance_id
,job_id
,step_id
,step_name
,sql_message_id
,sql_severity
,message
,run_status
,run_date
,run_time
,run_duration
,operator_id_emailed
,operator_id_netsent
,operator_id_paged
,retries_attempted
,server)
select instance_id
,@var_jobId
,step_id
,step_name
,sql_message_id
,sql_severity
,message
,run_status
,run_date
,run_time
,run_duration
,operator_id_emailed
,operator_id_netsent
,operator_id_paged
,retries_attempted
,server
from #jobHistory
SET IDENTITY_INSERT msdb.dbo.sysjobhistory OFF
'

if ($_.JobSchedules.Count -gt 0)
    {
    $schedule = $_.JobSchedules.Item(0)
    $scheduleUid = $schedule.ScheduleUid

    $a = ', 
		@schedule_uid=N''' + $scheduleUid + ''''

    $script = $script -replace $a, ''
    }

if ($_.JobSchedules.Count -gt 1)
    {
    $schedule = $_.JobSchedules.Item(1)
    $scheduleUid = $schedule.ScheduleUid

    $a = ', 
		@schedule_uid=N''' + $scheduleUid + ''''

    $script = $script -replace $a, ''
    }

out-file -filepath $(".\$OutputFolder\" + $((($_.Name -replace '\\', '') -replace '/','') -replace ' ','_') + ".sql") -inputobject $script

        }
    
    }

}