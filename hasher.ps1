Function Get-StringHash([String] $String,$HashName = "MD5") 
{ 
	$StringBuilder = New-Object System.Text.StringBuilder 
	[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{ 
		[Void]$StringBuilder.Append($_.ToString("x2")) 
	} 
	$StringBuilder.ToString() 
}

Function SetConsoleColor ($bc,$fc) {
	$a = (Get-Host).UI.RawUI
	$a.BackgroundColor = $bc
	$a.ForegroundColor = $fc ; cls}

<#
List-ByLength

Converts a string to a .NET list split by a specified number of characters
Optimized for speyd (very large strings!)

By:  LupineDream
Original:  http://stackoverflow.com/questions/17171531/powershell-string-to-array/17173367#17173367
#>
function List-ByLength{
	[cmdletbinding()]param(
		[string]$InputObject,
		[int]$Split=10,
		[System.Collections.Generic.List[System.String]]$OutList
	)
	begin{}
	process{
		foreach($string in $InputObject){
			$len = $string.Length;
			$repeat=[Math]::Floor($len/$Split);
			for($i=0;$i-lt$repeat;$i++){
				[void]$OutList.Add($("{0}" -f $string.Substring($i*$Split,$Split)));
			}
			if($remainder=$len%$split){
				[void]$OutList.Add($("{0}" -f $string.Substring($len-$remainder)));
			}
		}
	}
	end{
	}
}

<#
Get-Increment
Part of Lupy's libmath.ps1
		
		Gives you a number rounded up to the nearest incrimental value.
		
		Windows PowerShell 5.0
		By:  LupineDream
#>
Function Get-Increment([single] $value, [int] $increment=1){    
	if($value -gt 1)
	{
		[Math]::Ceiling($value / $increment) * $increment;
	}
	else
	{
		[math]::Ceiling($value)    
	}    
}

<#
	Add-Resource
	Part of Lupy's psResources.ps1

	Base64 a file into a json database resource file.
	Think of WinZip - Only running in PowerShell and json formatted!

	Windows PowerShell 5.0
	By:  LupineDream
#>
Function Add-Resource ([String] $FileToEncode, [String] $ResourceFile) {
	Write-Host " --- Encoding binary data ---`n" -ForegroundColor Yellow;
	
	<# First we'll store the db in memory #>
	If (Test-Path $FileToEncode) {
	<# Stuff the file into a base 64 string, then split it to a .NET list #>
	Write-Host "-- Encoding:  $($FileToEncode)... (please wait)" -ForegroundColor Cyan;
	$base64list =  New-Object -TypeName "System.Collections.Generic.List[System.String]";
	$base64string = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FileToEncode));
	List-ByLength -InputObject $base64string -OutList $base64list -Split 1024;
	} Else {
	Write-Host "-- The file specified: $($FileToEncode) does not exist";
	}
	
	$theFile = $(Split-Path -Path $FileToEncode -Leaf);
	
	If (Test-Path $ResourceFile) {
		Write-Host "-- Querying resource file for: $($theFile)" -ForegroundColor Cyan;
		$jsondata = @()
		$jsondata = Get-Content -Path $ResourceFile -Raw | ConvertFrom-Json;
		$fMatches = 0;
		$fMatchesAtIndex = 0;
		$fCurrentIndex = 0;
		foreach ($jsonfile in $jsondata) 
		{
			$linematches = 0;
			$fIndex = 0;
			foreach ($listdata in $jsonfile.file.data) 
			{
				If ($base64list[$fIndex] -Match $listdata) {
					$linematches++;
				}
				If ($fIndex -lt $($base64list.Count) - 1) {
					$fIndex++
				}
			}
			If ($linematches -eq $($base64list.Count)) {
				$fMatchesAtIndex = $fCurrentIndex;
				$fMatches++
			}
			$fCurrentIndex++
		}
	
		If ($fMatches -eq 1) {
			Write-Host $("-- The destination resource file already contains this entry at index {0}.  Nothing written." -f $fMatchesAtIndex) -ForegroundColor Red
		} ElseIf ($fMatches -gt 1) {
			Write-Host "-- The destination resource file contains more than one entry for this file.  Corruption" -ForegroundColor Red
		} Else {
			Write-Host $("-- Writing: {0} to resource database: {1}" -f $theFile, $ResourceFile) -ForegroundColor Cyan;
			Write-Host $("--   at index {0}...`n" -f $fCurrentIndex) -ForegroundColor Cyan;
			Write-Host "-- This could take a while if you have a large resource database" -ForegroundColor Yellow;
			$entry = @{"index" = $($fCurrentIndex.ToString); "filename" = $theFile; "data"=$base64List}
			$FileEntry = @{"file" = $entry}
			$jsondata += $FileEntry;
			$jsondata = $jsondata | ConvertTo-Json;
			[System.IO.FileInfo]$ResourceF = $ResourceFile;
			Remove-Item -Path $ResourceF -Force;
			$dummy = New-Item -Path $ResourceFile;
			$jsondata | Add-Content -LiteralPath $ResourceFile	
		}

	} Else {
		<# Creating the resource directory is SO much simpler than the last bit #>
		Write-Host "-- The destination resource file: $($ResourceFile) does not exist." -ForegroundColor Yellow
		Write-Host "-- Generating new resource file..." -ForegroundColor Yellow
		$dummyEntry = @{"index" = 0; "filename" = "dummy"; "data"="null"}
		$entry = @{"index" = 0; "filename" = $theFile; "data"=$base64List}
		$newDB = @()
		$newDB += @{"file" = $dummyEntry}
		$newDB += @{"file" = $entry}
		$newDB = $newDB | ConvertTo-Json;
		$dummy = New-Item -Path $ResourceFile;
		$newDB | Add-Content -Path $ResourceFile
	}
}	

Function Display-Intro()
{
	Clear-Host
	SetConsoleColor "Black" "White"
	[console]::CursorVisible=$false
	[console]::Title="YOFFHASHER 0.9.0-testing";
	Write-Host "                                     "
	Write-Host "                .-'''''-.            "
	Write-Host "              .'         ``.          "
	Write-Host "             :             :         "
	Write-Host "            :               :        "
	Write-Host "            :      _/|      :        "
	Write-Host "             :   =/_/      :         "
	Write-Host "              ``._/ |     .'         YOFFHASHER "
	Write-Host "           (   /  ,|...-'            by fur_user"
	Write-Host "           `|\_/^\/||_               "
	Write-Host "         _/~  ```"`"~```"` \_         version:"
	Write-Host "      __`/  -`'/  ``-._ ``\_`\__           0.9.0-testing"
	Write-Host "    /     /-`'``  ``\   \  \-.\         `n"
}

<#
	Hash-Directory

	Renames files with an indexed hashing algorithm (MD5-based)
	Duplicate-safe for data integrity, NOT space-optimization !

	Windows PowerShell 5.0
	By:  LupineDream
#>
Function Hash-Directory(
	[Parameter(Position = 0)]
	[String] $HashDirectory, 
	[string[]]$FileTypeFilter)
{
	Write-Host "----- Hashing directory -----`n" -ForegroundColor Yellow;

	<# 1st pass, populate everything... #> 
	Write-Host "-- Indexing files --`n" -ForegroundColor Cyan
	$hashTable = New-Object System.Collections.Generic.List[System.Object];
	Write-Host -NoNewLine "`r-- Processing" -ForegroundColor White;
	Write-Host -NoNewLine " `| " -ForegroundColor White;
	Write-Host -NoNewLine "(Hashing...)          " -ForegroundColor Green;
	Get-ChildItem "$($HashDirectory)\*" -Include $FileTypeFilter | Foreach-Object {
		$hashObject = New-Object -TypeName PSObject;
		$FObject = $_;
		$hashObject | Add-Member -Name 'Hash' -MemberType Noteproperty -Value (Get-FileHash -LiteralPath $FObject.FullName -Algorithm MD5).Hash;
		$hashObject | Add-Member -Name 'FullPath' -MemberType Noteproperty -Value $FObject.FullName;
		$hashTable.Add($hashObject);
		If ((($hashTable.Count) % 32768) -eq 0) {
			Write-Host -NoNewline "`r-- Processing `| " -ForegroundColor White;
			Write-Host -NoNewline $("F: {0}" -f ($hashTable.Count)) -ForegroundColor Yellow;
			Write-Host -NoNewLine " `| " -ForegroundColor White;
			Write-Host -NoNewLine "(Wow, you have a lot, this will take some time...)     " -ForegroundColor Green;
		}
	}
	Write-Host -NoNewline "`r-- Processing `| " -ForegroundColor White;
	Write-Host -NoNewline $("F: {0}" -f ($hashTable.Count)) -ForegroundColor Yellow;
	Write-Host -NoNewLine " `| " -ForegroundColor White;
	Write-Host -NoNewLine "(Operation Completed)                               " -ForegroundColor Green;

	<# Group Objects, Select groups greater than 1, and equal to 1. #>
	Write-Host "`n`n`n-- Grouping items --" -ForegroundColor Cyan;
	Write-Host "`n-- Finding duplicate files... (wait, could take a while if your directory contains a lot)" -ForegroundColor Yellow;
	$hashGroupDuplicate = $hashTable | Group -Property Hash | Where { $_.Count -gt 1 }
	Write-Host $("-- Found {0} duplicates`n" -f ($hashGroupDuplicate.Count)) -ForegroundColor Cyan;
	Write-Host "-- Finding unique files... (wait, could take a while if your directory contains a lot)" -ForegroundColor Yellow;
	$hashGroupUnique = $hashTable | Group -Property Hash | Where { $_.Count -eq 1 }
	Write-Host $("-- Found {0} unique files`n" -f ($hashGroupDuplicate.Count)) -ForegroundColor Cyan;

	$DuplicateFiles = ($hashGroupDuplicate.Count);
	$UniqueFiles = ($hashGroupUnique.Count);
	$RemovedFiles = 0;

	<# Delete Duplicates #>
	Write-Host "`n-- Performing cleanup --`n" -ForegroundColor Cyan
	ForEach ($Group in $hashGroupDuplicate) {
		$Group.group | Select Hash,FullPath -Skip 1 | %{
			Write-Host -NoNewline "`r-- " -ForegroundColor White;
			Write-Host -NoNewline $("U: {0}" -f $UniqueFiles.ToString()) -ForegroundColor Cyan;
			Write-Host -NoNewLine " `| " -ForegroundColor White;
			Write-Host -NoNewline $("D: {0}" -f  $RemovedFiles.ToString()) -ForegroundColor Red;
			Write-Host -NoNewLine " `| " -ForegroundColor White;
			Write-Host -NoNewline $("F: {0}" -f ($hashTable.Count).ToString()) -ForegroundColor Yellow;
			Write-Host -NoNewLine " `| " -ForegroundColor White;
			Write-Host -NoNewLine "Phase: 2 (Deletion Phase)" -ForegroundColor Green;
			Write-Host -NoNewline "                              " -ForegroundColor Yellow;
			del $_.FullPath;
			$RemovedFiles++;
		}
	}	

	<# Rename items to unique names #>
	Write-Host "`n-- Correcting file names --`n" -ForegroundColor Cyan
	$RenamedFiles = 0;
	ForEach ($Group in $hashGroupUnique) {
		$Group.group | Select Hash,FullPath | %{
			Rename-Item -LiteralPath $_.FullPath -NewName $("w{0}{1}" -f $RenamedFiles.ToString("#########"), [IO.Path]::GetExtension($_.FullPath));
			Write-Host -NoNewline "`r-- " -ForegroundColor White
			Write-Host -NoNewline $("U: {0}" -f $UniqueFiles.ToString()) -ForegroundColor Cyan;
			Write-Host -NoNewLine " `| " -ForegroundColor White
			Write-Host -NoNewline $("D: {0}" -f  $RemovedFiles.ToString()) -ForegroundColor Red;
			Write-Host -NoNewLine " `| " -ForegroundColor White;
			Write-Host -NoNewline $("R(I): {0}" -f $RenamedFiles.ToString()) -ForegroundColor Yellow;
			Write-Host -NoNewLine " `| " -ForegroundColor White
			Write-Host -NoNewLine "Phase: 3 (Rename Phase - Pass I)" -ForegroundColor Green
			Write-Host -NoNewline "                      " -ForegroundColor Yellow
			$RenamedFiles++;
		}
	}  

	<# Rename the uniquely named files #>
	$RenamedFiles = 0;
	ForEach ($Group in $hashGroupUnique) {
		$Group.group | Select Hash,FullPath | %{
			Rename-Item -LiteralPath $("{0}\w{1}{2}" -f $HashDirectory, $RenamedFiles.ToString("#########"), [IO.Path]::GetExtension($_.FullPath)) -NewName $("{0}{1}" -f $_.Hash, [IO.Path]::GetExtension($_.FullPath));
			Write-Host -NoNewline "`r-- " -ForegroundColor White
			Write-Host -NoNewline $("U: {0}" -f $UniqueFiles.ToString()) -ForegroundColor Cyan;
			Write-Host -NoNewLine " `| " -ForegroundColor White
			Write-Host -NoNewline $("D: {0}" -f  $RemovedFiles.ToString()) -ForegroundColor Red;
			Write-Host -NoNewLine " `| " -ForegroundColor White;
			Write-Host -NoNewline $("R(II): {0}" -f $RenamedFiles.ToString()) -ForegroundColor Yellow;
			Write-Host -NoNewLine " `| " -ForegroundColor White
			Write-Host -NoNewline $("F: {0}" -f ($hashTable.Count).ToString()) -ForegroundColor Yellow;
			Write-Host -NoNewLine " `| " -ForegroundColor White;
			Write-Host -NoNewLine "Phase: 3 (Rename Phase - Pass II)" -ForegroundColor Green
			Write-Host -NoNewline "                      " -ForegroundColor Yellow
			$RenamedFiles++;
		}
	}  

	Write-Host "`n`r"

	Write-Host "----- Operation Completed -----`n" -ForegroundColor Green
}

<#
	Reset-Directory

	Resets all files attributes in the ROOT of a directory to NORMAL.
	May require elevated PowerShell prompt to reset ReadOnly and Hidden items!

	Wether or not you will require elevation when using this function is entirely
	dependent on your user access rights.

	Windows PowerShell 5.0
	By:  LupineDream
#>
Function Reset-Directory(
		[Parameter(Position = 0)]
		[String] $ResetDirectory, 
		[string[]]$FileTypeFilter)
{
	Write-Host " --- Reseting directory file attributes ---`n" -ForegroundColor Yellow;
	Write-Host "--- Listing files... (wait, could take a while if your directory contains a lot)";
	$catalog = Get-ChildItem "$($ResetDirectory)\*" -Include $FileTypeFilter -Force;
	Write-Host $("`n -- Catalogged {0} files.`n" -f (($catalog).Count).ToString("##,###,###,###"));

	<# Act on ReadOnly items FIRST #>
	$ROcatalog = $catalog | where { $_.Attributes -Match "ReadOnly"}
	If (($ROcatalog.Count) -gt 0) {
		Write-Host $(" -- Found {0} Read Only files." -f (($ROcatalog).Count).ToString("##,###,###,###"));
		$fcount = 1;
		ForEach ($ROfile in $ROcatalog) {
			Write-Host -NoNewline $("`r -- Reset {0} Read Only files." -f $fcount.ToString("##,###,###,###")) -ForegroundColor Cyan;
			$ROfile.Attributes = "Normal"
			$fcount++;
		}
		Write-Host -NoNewLine "`n`r";
	} Else {
		Write-Host "-- No ReadOnly files need resetting." -ForegroundColor Green;
	}

	<# Act on Hidden items #>
	$HScatalog = $catalog | where { $_.Attributes -Match "Hidden"}
	If (($HScatalog.Count) -gt 0) {
		Write-Host $(" -- Found {0} Hidden files." -f (($HScatalog).Count).ToString("##,###,###,###"));
		$fcount = 1;
		Foreach ($HSfile in $HScatalog) {
			Write-Host -NoNewline $("`r -- Reset {0} Hidden files." -f $fcount.ToString("##,###,###,###")) -ForegroundColor Cyan;
			$HSfile.Attributes = "Normal"
			$fcount++;
		}
		Write-Host -NoNewLine "`n`r";
	} Else {
		Write-Host "-- No Hidden files need resetting." -ForegroundColor Green;
	}

	<# Act on Archive items (most typical attribute set) #>
	$ARcatalog = $catalog | where { $_.Attributes -Match "Archive"}
	If (($ARcatalog.Count) -gt 0) {
		Write-Host $(" -- Found {0} Archive files." -f (($ARcatalog).Count).ToString("##,###,###,###"));
		$fcount = 1;
		Foreach ($ARfile in $ARcatalog) {
			Write-Host -NoNewline $("`r -- Reset {0} Archive files." -f $fcount.ToString("##,###,###,###")) -ForegroundColor Cyan;
			$ARfile.Attributes = "Normal"
			$fcount++;
		}
		Write-Host -NoNewLine "`n`r";
	} Else {
		Write-Host "-- No Archive files need resetting." -ForegroundColor Green;
	}

	Write-Host "`n----- Operation Completed -----`n" -ForegroundColor Green;

}

<#
	Flatten-Directory

	Pushes all files back to the root of the directory specified, and removes
	the existing Cluster structure.  This functionality is generally used for
	correcting misaligned Cluster structures, and re-hashing by index starting
	from the first file in the first Cluster to the last file in the last.

	Windows PowerShell 5.0
	By:  LupineDream
#>
Function Flatten-Directory (
		[Parameter(Position = 0)]
		[String] $FlattenRootDirectory)
{
	Write-Host " --- Flattening Cluster directory ---`n" -ForegroundColor Yellow;

	<# Scan the directory for existing clusters #>
	Write-Host "-- Attempting to detect current cluster culture" -ForegroundColor Yellow;
	Write-Host "-- Please wait, this doesn't take too long.";
	$catalogFolders = Get-ChildItem "$($FlattenRootDirectory)\*" -Directory -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName -Like "$($FlattenRootDirectory)\cluster*" }
	$numClusters = $catalogFolders.Count;

	If ($numClusters) {
		Write-Host $("-- Detected {0} existing clusters --" -f $numClusters.ToString("##,###,###,###")) -ForegroundColor Cyan;

		<# Scan the directory and subdirectories below for files (this will include entires that are
		ONLY in a cluster, thus leaving other files unflattened you may have stored in other folders #>
		Write-Host $("`n-- Scanning files inside clusters" -f $numClusters) -ForegroundColor Yellow;
		$catalogFiles = Get-ChildItem "$($FlattenRootDirectory)\*" -Recurse -Include *.* -ErrorAction SilentlyContinue | Where-Object { $_.FullName -Like "$($FlattenRootDirectory)\cluster*\*" }
		$numFiles = $catalogFiles.Count;

		Write-Host $("-- Detected {0} files in {1} clusters --" -f $numFiles.ToString("##,###,###,###"), $numClusters.ToString("##,###,###,###")) -ForegroundColor Cyan;
		Write-Host $("`n-- Flattening directory tree" -f $numClusters) -ForegroundColor Yellow;
		Write-Host "-- Please wait, this is an active file-move operation which could take a while.`n";

		<# copy files to root #>
		$numFilesDone = 1;
		ForEach ($catalogFile in $catalogFiles) {
			$theFile = $($catalogFile.Name);
			$theClusterB = $catalogFile.FullName;
			$SearchStart=[System.Text.RegularExpressions.Regex]::Escape("$($FlattenRootDirectory)\cluster");
			$SearchEnd=[System.Text.RegularExpressions.Regex]::Escape("\$($theFile)");
			If ($theClusterB -match "(?s)$SearchStart(?<content>.*)$SearchEnd") { $theCluster=[int]$matches['content']; }
			Write-Host -NoNewline $("`r-- Moving file {0} of {1} in cluster {2} to root - {3}       " -f $numFilesDone.ToString("##,###,###,###"), $numFiles.ToString("##,###,###,###"), $theCluster.ToString("##,###,###,###"), $theFile) -ForegroundColor Cyan;
			mi $catalogFile.FullName $FlattenRootDirectory;
			$numFilesDone++;
		}

	Write-Host -NoNewLine "`n";

	<# remove empty cluster folders #>
	$numClust = 1;
	If ($catalogFolders.Count -gt 0) {
		ForEach ($currentFolder in $catalogFolders)
		{
				$theFolderB = $currentFolder.FullName;
				$SearchStart=[System.Text.RegularExpressions.Regex]::Escape("$($FlattenRootDirectory)\cluster");
				if ($theFolderB -match "(?s)$SearchStart(?<content>.*)") { $theCluster=[int]$matches['content']; }
				Write-Host -NoNewLine $("`r-- Successfully cleaned cluster #{0}       " -f $theCluster.ToString("##,###,###,###")) -ForegroundColor Cyan;
				Remove-Item -Path $currentFolder.FullName -Force;
				$numClust++;
		}
		Write-Host -NoNewLine "`n`r"
	}
	} Else {
		Write-Host "-- No Clusters found - cannot flatten non-existant things`!" -ForegroundColor Red;
	}

	Write-Host "`n----- Operation Completed -----`n" -ForegroundColor Green;
}

		
<# 

	Generate-FolderClusters

	Auto-appends and creates a clustered folder structure.

	Each cluster is auto-numbered and contains a set number of files.

	This function can be re-used to 'append' more files by dropping them in the rot of the cluster
	data directory.

	Windows PowerShell 5.0
	By:  LupineDream

#>

Function Generate-FolderClusters(
	[Parameter(Position = 0)]
	[string]$ClusterRootDirectory,
	[string[]]$FileTypeFilter,
	[int]$ClusterSize)
{

	Write-Host " --- Generating payload clusters ---`n" -ForegroundColor Yellow;

	<# Search for currently existing cluster folders #>
	Write-Host "-- Attempting to detect current cluster culture";
	$catalogFolders = Get-ChildItem "$($ClusterRootDirectory)\*" -Directory -Force -ErrorAction SilentlyContinue;
	$numClusters = 0;
	If ($(($catalogFolders).Count) -gt 0) {
		ForEach ($currentFolder in $catalogFolders)
		{
			$buildname = $("{0}\cluster{1}" -f $ClusterRootDirectory, $($numClusters + 1).ToString());
			If (Test-Path $buildname)
			{
				$numClusters++;
			}
		}
	}
	Write-Host $("`n-- Detected {0} existing clusters --`n" -f $numClusters) -ForegroundColor Yellow;

	<# Detect how many clusters are needed to be created to complete the operation #>
	Write-Host "-- Listing files... (wait, could take a while if your directory contains a lot)";
	$catalog = Get-ChildItem "$($ClusterRootDirectory)\*" -Include $FileTypeFilter -Force -ErrorAction SilentlyContinue;
	$numClustersNeeded = Get-Increment $(($catalog).Count / $ClusterSize);

	If ($numClustersNeeded -ne 0)
	{
		Write-Host $("`n-- Detected needed {0} clusters --`n" -f $numClustersNeeded) -ForegroundColor Yellow;

		<# Generate the folder structure #>
		For ($createCluster = $($numClusters + 1); $createCluster -le $($numClustersNeeded + $numClusters); $createCluster++)
		{
			$buildpath = $("{0}\cluster{1}" -f $ClusterRootDirectory, $createCluster.ToString());
			Write-Host -NoNewline $("`r-- Creating Cluster Directory `#{0} - {1}" -f $createCluster.ToString("##,###,###,###"), $buildpath) -ForegroundColor Cyan;
			$dummy = New-Item -ItemType directory -Path $buildpath;
		}
		Write-Host "`n`r";

		<# Move the files from the root into the newly generated clusters #>
		Write-Host "-- Begining clustering process --`n" -ForegroundColor Yellow;
		$currentCluster = $($numClusters + 1);
		$currentFile = 1;
		ForEach ($WorkFile in $catalog)
		{
			$buildpath = $("{0}\cluster{1}" -f $ClusterRootDirectory, $currentCluster.ToString());
			Write-Host -NoNewline $("`r-- Working on Cluster {0} at index {1} / Clusters remaining: {2}" -f $currentCluster.ToString("##,###,###,###"), $currentFile.ToString(), $($($numClusters + $numClustersNeeded) - $currentCluster).ToString("##,###,###,###")) -ForegroundColor Cyan;
			mi $WorkFile.FullName $buildpath;
			$currentFile++;
			If ($currentFile -gt $ClusterSize) {
				$currentFile = 1;
				$currentCluster++;
			}
		}
	} Else {
		Write-Host "-- No update operation is required" -ForegroundColor Red;
	}
}

<#

	Stub-Move

	Copies a file, leaving an empty stub behind that holds the same creation/modification timestamps.
	
	This function is designed to preserve an original directory tree while saving HDD space.
	The stub assumes the exact same properties as the original file, without its contents.
	
	Windows PowerShell 5.0
	By:  LupineDream
	
#>
Function Stub-Move (
	[Parameter(Position = 0)]
	[string]$FilePath,
	[string]$DestinationDirectory)
{
	<# Store info on the original file #>
	$File = ( Get-Item -LiteralPath $FilePath );
	$FileName = $File.Name;
	$FileFullName = $File.FullName;
	$FileCreateDate = $File.CreationTime;
	$FileLastModify = $File.LastWriteTime;
	$FileLastAccess = $File.LastAccessTime;
	$FileNewFullName = $DestinationDirectory;
		
	<# Copy the file from the old location and delete the original, replacing it with an empty file #>
	Copy-Item -LiteralPath $FileFullName -Destination $DestinationDirectory;
	Remove-Item -LiteralPath $FileFullName;
	New-Item $FileFullName -ItemType file | Out-Null;
		
	<# Update the stub's timestamps to match the old. #>
	(Get-Item -LiteralPath $FileFullName).LastWriteTime=($FileLastModify);
	(Get-Item -LiteralPath $FileFullName).CreationTime=($FileCreateDate);
	(Get-Item -LiteralPath $FileFullName).LastAccessTime=($FileLastAccess);
		
	<# Preserve the moved file's timestamps #>
	(Get-Item -LiteralPath $FileNewFullName).LastWriteTime=($FileLastModify);
	(Get-Item -LiteralPath $FileNewFullName).CreationTime=($FileCreateDate);
	(Get-Item -LiteralPath $FileNewFullName).LastAccessTime=($FileLastAccess);
}

<#

	Migrate-All

	Migrate a directory recursively to a flat directory tree for preperation for merger into
	the dataset.
	
	Duplicate filenames are renamed atuomatically.
	
	Pass in -StubOriginals True to stub the original file while preserving its creation/modification
	dates instead of directly moving it.
	
#>
Function Migrate-All(
	[Parameter(Position = 0)]
	[string]$MigrateRootDirectory,
	[string]$DestinationDirectory,
	[string[]]$FileTypeFilter,
	[bool]$StubOriginals = $False)
{
	If ((Test-Path -LiteralPath $MigrateRootDirectory)) {
		Write-Host " --- Migrating files ---`n" -ForegroundColor Yellow;
		If ($StubOriginals -Eq $True) {
			Write-Host "-- Keeping file stubs during operation`n" -ForegroundColor Green;
		} Else {
			Write-Host "-- Moving files only during operation`n" -ForegroundColor Yellow;
		}
		$NumMigrated = 0;
		Get-ChildItem "$($MigrateRootDirectory)\" -Include $FileTypeFilter -Recurse | Foreach-Object {
			
			$TheFile = $_;
			If ((Get-Item -LiteralPath $TheFile.FullName).length -gt 1Kb) {
				<# Determine a new filename that doesn't collide with one at the destination #>
				$nextName = Join-Path -Path $DestinationDirectory -ChildPath $TheFile.Name
				$num=1;
				while(Test-Path -LiteralPath $nextName)
				{
					$nextName = Join-Path $DestinationDirectory ($TheFile.BaseName + "_$num" + $TheFile.Extension);
					$num+=1;   
				}

				<# Move the file #>
				if ($StubOriginals -Eq $True) {
					Stub-Move -FilePath $TheFile.FullName -DestinationDirectory $nextName; 
				} Else {
					mi $TheFile.FullName $nextName;
				}
			
				Write-Host -NoNewLine "-- Migrating file: " -ForegroundColor White;
				Write-Host $("{0}" -f [System.IO.Path]::GetFileName($nextName)) -ForegroundColor Cyan;
				$NumMigrated++;
			}
		}
		Write-Host "`n----- Operation Completed -----`n" -ForegroundColor Green;
	}
}

#>

Display-Intro
$DirectoryPath = $(Get-Location);

<# Testbench #>
# Flatten-Directory -FlattenRootDirectory "E:\lupin\Pictures\sorted\hashed"
# Reset-Directory -ResetDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp
# Hash-Directory -HashDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp
# Generate-FolderClusters -ClusterRootDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp -ClusterSize 100
# Flatten-Directory -FlattenRootDirectory "E:\lupin\Videos\nice stuff"
# Reset-Directory -ResetDirectory "E:\lupin\Videos\nice stuff" -FileTypeFilter *.mov,*.avi,*.flv,*.wmv,*.mp4,*.m4v,*.mkv,*.divx,*.rm,*.mpg,*.mpeg,*.mpeg4,*.3gp,*.webm,*.vob
# Hash-Directory -HashDirectory "E:\lupin\Videos\nice stuff" -FileTypeFilter *.mov,*.avi,*.flv,*.wmv,*.mp4,*.m4v,*.mkv,*.divx,*.rm,*.mpg,*.mpeg,*.mpeg4,*.3gp,*.webm,*.vob
# Generate-FolderClusters -ClusterRootDirectory "E:\lupin\Videos\nice stuff" -FileTypeFilter *.mov,*.avi,*.flv,*.wmv,*.mp4,*.m4v,*.mkv,*.divx,*.rm,*.mpg,*.mpeg,*.mpeg4,*.3gp,*.webm,*.vob -ClusterSize 10
# Add-Resource "$($DirectoryPath)\test.txt" "$($DirectoryPath)\test.rsrc"
# Add-Resource "$($DirectoryPath)\test2.txt" "$($DirectoryPath)\test.rsrc"

# Stub-Move Function test
# Stub-Move -FilePath "$($DirectoryPath)\test.txt" -DestinationDirectory "$($DirectoryPath)\stub_debug"

# Picture migration test chain
Flatten-Directory -FlattenRootDirectory "E:\lupin\Pictures\sorted\hashed"
Migrate-All -MigrateRootDirectory "E:\lupin\Videos\nice stuff proofed" -DestinationDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp -StubOriginals $True;
Migrate-All -MigrateRootDirectory "E:\lupin\Videos\sorted" -DestinationDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp -StubOriginals $True;
Reset-Directory -ResetDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp
Hash-Directory -HashDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp
Generate-FolderClusters -ClusterRootDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp -ClusterSize 100

# Video migration test chain
Flatten-Directory -FlattenRootDirectory "E:\lupin\Videos\nice stuff"
Migrate-All -MigrateRootDirectory "E:\lupin\Videos\nice stuff proofed" -DestinationDirectory "E:\lupin\Videos\nice stuff" -FileTypeFilter *.mov,*.avi,*.flv,*.wmv,*.mp4,*.m4v,*.mkv,*.divx,*.rm,*.mpg,*.mpeg,*.mpeg4,*.3gp,*.webm,*.vob -StubOriginals $True;
Migrate-All -MigrateRootDirectory "E:\lupin\Videos\sorted" -DestinationDirectory "E:\lupin\Videos\nice stuff" -FileTypeFilter *.mov,*.avi,*.flv,*.wmv,*.mp4,*.m4v,*.mkv,*.divx,*.rm,*.mpg,*.mpeg,*.mpeg4,*.3gp,*.webm,*.vob -StubOriginals $True;
Reset-Directory -ResetDirectory "E:\lupin\Videos\nice stuff" -FileTypeFilter *.mov,*.avi,*.flv,*.wmv,*.mp4,*.m4v,*.mkv,*.divx,*.rm,*.mpg,*.mpeg,*.mpeg4,*.3gp,*.webm,*.vob
Hash-Directory -HashDirectory "E:\lupin\Videos\nice stuff" -FileTypeFilter *.mov,*.avi,*.flv,*.wmv,*.mp4,*.m4v,*.mkv,*.divx,*.rm,*.mpg,*.mpeg,*.mpeg4,*.3gp,*.webm,*.vob
Generate-FolderClusters -ClusterRootDirectory "E:\lupin\Videos\nice stuff" -FileTypeFilter *.mov,*.avi,*.flv,*.wmv,*.mp4,*.m4v,*.mkv,*.divx,*.rm,*.mpg,*.mpeg,*.mpeg4,*.3gp,*.webm,*.vob -ClusterSize 10
