$path_to_folder = 'C:\' #should be replaced with path to folder
$searchedString = 'oldValue'    
$replacementValue = 'newValue'

Get-ChildItem $path_to_folder *.sql -recurse |
     Foreach-Object {
         $c = ($_ | Get-Content)
         $c = $c -replace $searchedString ,$replacementValue
         [IO.File]::WriteAllText($_.FullName, ($c -join "`r`n"))
     }