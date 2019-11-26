$path_to_folder = 'C:\' #should be replaced with path to folder
$pattern = 'pattern'    

Get-ChildItem $path_to_folder *.dtsx -recurse | Select-String -pattern $pattern | group path | select name

