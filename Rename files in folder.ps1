$path_to_folder = 'C:\' #should be replaced with path to folder
$searchedString = 'oldValue'    
$replacementValue = 'newValue'

cd $path_to_folder 


Dir | Rename-Item -NewName {$_.name -replace $searchedString,$replacementValue }