$PSScriptVersion = "0.9.1-testing";

<#
	Get-StringHash
	
	Returns a Hash from an input string of the specified algorithm.

	By: LupineDream
	Windows Powershell 5.0
#>
Function Get-StringHash([String] $String,$HashName = "MD5") 
{ 
	$StringBuilder = New-Object System.Text.StringBuilder 
	[System.Security.Cryptography.HashAlgorithm]::Create($HashName).ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))|%{ 
		[Void]$StringBuilder.Append($_.ToString("x2")) 
	} 
	$StringBuilder.ToString() 
}

<#
	Display-FromBytes
	
	Return a correctly formatted string representation of a byte number.
#>
Function Display-FromBytes($num) 
{
    $suffix = "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB";
    $index = 0;
	$num2 = $num;
    while ($num2 -gt 1024) 
    {
        $num2 = $num2 / 1024
        $index++
    } 

    "{0:N1} {1}" -f $num2, $suffix[$index]
}

<#
	SetConsoleColor
	
	Sets the Winodws PowerShell console window's background and foreground color.

	By:  LupineDream
	Windows PowerShell 5.0
#>
Function SetConsoleColor ($bc,$fc) {
	$a = (Get-Host).UI.RawUI
	$a.BackgroundColor = $bc
	$a.ForegroundColor = $fc ; cls}

<#
	List-ByLength

	Converts a string to a .NET list split by a specified number of characters
	Optimized for speyd (very large strings!)

	By:  LupineDream
	Windows PowerShell 5.0
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
	Clear-Host;
	SetConsoleColor "Black" "White";
	[console]::CursorVisible=$false;
	[console]::Title=$("YOFFHASHER {0}" -f $PSScriptVersion);
	Write-Host "                                     " -ForegroundColor White;
	Write-Host "                .-'''''-.            " -ForegroundColor White;
	Write-Host "              .'         ``.          " -ForegroundColor White;
	Write-Host "             :             :         " -ForegroundColor White;
	Write-Host "            :               :        " -ForegroundColor White;
	Write-Host "            :      _/|      :        " -ForegroundColor White;
	Write-Host "             :   =/_/      :         " -ForegroundColor White;
	Write-Host -NoNewline "              ``._/ |     .'         " -ForegroundColor White;
	Write-Host "YOFFHASHER" -ForegroundColor Cyan;
	Write-Host -NoNewline "           (   /  ,|...-'            by: " -ForegroundColor White;
	Write-Host "fur_user" -ForegroundColor Magenta;
	Write-Host "           `|\_/^\/||_               " -ForegroundColor White;
	Write-Host "         _/~  ```"`"~```"` \_         version:" -ForegroundColor White;
	Write-Host -NoNewLine "      __`/  -`'/  ``-._ ``\_`\__           " -ForegroundColor White;
	Write-Host $("{0}" -f $PSScriptVersion) -ForegroundColor Yellow;
	Write-Host "    /     /-`'``  ``\   \  \-.\         `n" -ForegroundColor White
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
	Write-Host "----- Hashing directory -----`n" -ForegroundColor Cyan;

	<# 1st pass, populate everything... #> 
	Write-Host "`tIndexing files`n" -ForegroundColor Yellow
	$hashTable = New-Object System.Collections.Generic.List[System.Object];
	Write-Host -NoNewLine "`r`t`tProcessing" -ForegroundColor White;
	Write-Host -NoNewLine " `| " -ForegroundColor White;
	Write-Host -NoNewLine "(Hashing...)          " -ForegroundColor Green;
	$recordCount = 0;
	$recordsSec = 0;
	$sT = Get-Date;
	Get-ChildItem "$($HashDirectory)\*" -Include $FileTypeFilter | Foreach-Object {
		$hashObject = New-Object -TypeName PSObject;
		$FObject = $_;
		$hashObject | Add-Member -Name 'Hash' -MemberType Noteproperty -Value (Get-FileHash -LiteralPath $FObject.FullName -Algorithm MD5).Hash;
		$hashObject | Add-Member -Name 'FullPath' -MemberType Noteproperty -Value $FObject.FullName;
		$hashTable.Add($hashObject);
		If ((($hashTable.Count) % 2048) -eq 0) {
			Write-Host -NoNewline "`r`t`tProcessing `| " -ForegroundColor White;
			Write-Host -NoNewline $("File: {0}" -f ($hashTable.Count)) -ForegroundColor Yellow;
			Write-Host -NoNewLine " `| " -ForegroundColor White;
			Write-Host -NoNewline $("Records`/sec: {0}" -f $recordsSec.ToString()) -ForegroundColor Blue;
			Write-Host -NoNewLine "                 " -ForegroundColor White;
		}
		$recordCount++;
		
		<# Update timer #>
		$cT = Get-Date;
		If ([system.Math]::Abs(([int]$cT.Second-[int]$sT.Second)) -Gt 1) {
			$sT = $cT;
			$recordsSec = $recordCount;
			$recordCount = 0;
		}
	}
	Write-Host -NoNewline "`r`t`tProcessing `| " -ForegroundColor White;
	Write-Host -NoNewline $("File: {0}" -f ($hashTable.Count)) -ForegroundColor Yellow;
	Write-Host -NoNewLine " `| " -ForegroundColor White;
	Write-Host -NoNewline $("Records`/sec: {0}" -f $recordsSec.ToString()) -ForegroundColor Blue;
	Write-Host -NoNewLine " `| " -ForegroundColor White;
	Write-Host -NoNewLine "(Operation Completed)                               " -ForegroundColor Green;

	<# Define worker ScriptBlocks #>
	$duplicateScriptBlock = {
	    param([System.Collections.Generic.List[System.Object]]$hTable) 
		# Write-Host "`n`t`tFinding duplicate files... (wait, could take a while if your directory contains a lot)" -ForegroundColor Yellow;
		$hTableResult = $hTable | Group -Property Hash | Where { $_.Count -gt 1 }
		$RunResult = New-Object PSObject -Property @{
			RunIdent = "JobDuplicates"
			Table = $hTableResult
		}
		Return $RunResult;
	}
	$uniqueScriptBlock = {
		param([System.Collections.Generic.List[System.Object]]$hTable)
		# Write-Host "`t`tFinding unique files... (wait, could take a while if your directory contains a lot)" -ForegroundColor Yellow;
		$hTableResult = $hTable | Group -Property Hash | Where { $_.Count -eq 1 }
		$RunResult = New-Object PSObject -Property @{
			RunIdent = "JobUnique"
			Table = $hTableResult
		}
		Return $RunResult;
	}
	
	<# Register jobs to the runspace pool. #>
	$RunspacePool = [RunspaceFactory]::CreateRunspacePool(1, 2);
	$RunspacePool.Open();
    $JobDuplicates = [powershell]::Create().AddScript($duplicateScriptBlock).AddArgument([System.Collections.Generic.List[System.Object]]$hashTable);
    $JobDuplicates.RunspacePool = $RunspacePool;
	$JobUniques = [powershell]::Create().AddScript($uniqueScriptBlock).AddArgument([System.Collections.Generic.List[System.Object]]$hashTable);
    $JobUniques.RunspacePool = $RunspacePool;
	
	<# Invoke parallel jobs #>
	Write-Host "`n`n`tGrouping items" -ForegroundColor Yellow;
	$Jobs = @()
	$Jobs += New-Object PSObject -Property @{
		RunID = "JobDuplicates"
		Pipe = $JobDuplicates
		Handle = $JobDuplicates.BeginInvoke()
    }
	$Jobs += New-Object PSObject -Property @{
		RunID = "JobUniques"
		Pipe = $JobUniques
		Handle = $JobUniques.BeginInvoke()
	}
	
	<# Wait loop #>
	Write-Host -NoNewLine "`n";
	$Timer = [System.Diagnostics.Stopwatch]::StartNew()
	do {
		Start-Sleep -Seconds 1;
		$RunningJobs = (@($Jobs | Where { $_.Handle.IsCompleted -Ne 'Completed'}).Count);
		$cT = $Timer.Elapsed;
		Write-Host -NoNewLine $("`r`t`t{0} Jobs running" -f $RunningJobs.ToString()) -ForegroundColor Cyan;
		Write-Host -NoNewLine " `| " -ForegroundColor White;
		Write-Host -NoNewLine $("Elapsed: {0:d1}h:{1:d2}m:{2:d2}s          " -f $cT.Hours,$cT.Minutes,$cT.Seconds) -ForegroundColor Blue;
	} While ( $Jobs.Handle.IsCompleted -Contains $false)
   
	<# Store Results #>
	$Results = @()
	ForEach ($Job in $Jobs) {
		$Results += $Job.Pipe.EndInvoke($Job.Handle);
		$Job.Pipe.Dispose();
	}
	ForEach ($Result in $Results) {
		If ($Result.RunIdent -Eq "JobDuplicates") {
			$hashGroupDuplicate = $Result.Table;
		}
		If ($Result.RunIdent -Eq "JobUnique") {
			$hashGroupUnique = $Result.Table;	
		}
	}

	$DuplicateFiles = ($hashGroupDuplicate.Count);
	$UniqueFiles = ($hashGroupUnique.Count);
	$RemovedFiles = 0;

	<# Delete Duplicates #>
	Write-Host "`n`n`tPerforming cleanup`n" -ForegroundColor Yellow
	ForEach ($Group in $hashGroupDuplicate) {
		$Group.group | Select Hash,FullPath -Skip 1 | %{
			Write-Host -NoNewline "`r`t`t" -ForegroundColor White;
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
	If ($RemovedFiles -Eq 0) {
		Write-Host "`t`tNo duplicates detected, nothing done" -ForegroundColor Red;
	}

	<# Rename items to unique names #>
	Write-Host "`n`tCorrecting file names`n" -ForegroundColor Yellow
	$RenamedFiles = 0;
	ForEach ($Group in $hashGroupUnique) {
		$Group.group | Select Hash,FullPath | %{
			Rename-Item -LiteralPath $_.FullPath -NewName $("w{0}{1}" -f $RenamedFiles.ToString("#########"), [IO.Path]::GetExtension($_.FullPath));
			Write-Host -NoNewline "`r`t`t" -ForegroundColor White
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
			Write-Host -NoNewline "`r`t`t" -ForegroundColor White
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
	Write-Host " --- Reseting directory file attributes ---`n" -ForegroundColor Cyan;
	Write-Host "`tListing files... (wait, could take a while if your directory contains a lot)" -ForegroundColor Yellow;
	$catalog = Get-ChildItem "$($ResetDirectory)\*" -Include $FileTypeFilter -Force;
	Write-Host $("`n`tCataloged {0} files.`n" -f (($catalog).Count).ToString("##,###,###,###"));

	Write-Host "`tResetting File Attributes" -ForegroundColor Yellow;
	
	$ToReset = @("ReadOnly", "Hidden", "Archive");
	
	ForEach ($ToResetThis in $ToReset) {
		$ROcatalog = $catalog | where { $_.Attributes -Match $ToResetThis}
		If (($ROcatalog.Count) -gt 0) {
			Write-Host $("`t`tFound {0} {1} files." -f (($ROcatalog).Count).ToString("##,###,###,###"),$ToResetThis);
			$fcount = 1;
			ForEach ($ROfile in $ROcatalog) {
				Write-Host -NoNewline $("`r`t`tReset {0} {1} files." -f $fcount.ToString("##,###,###,###"),$ToResetThis) -ForegroundColor Cyan;
				$ROfile.Attributes = "Normal"
				$fcount++;
			}
			Write-Host -NoNewLine "`n`r";
		} Else {
			Write-Host $("`t`tNo {0} files need reset." -f $ToResetThis) -ForegroundColor Red;
		}
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
	Write-Host " --- Flattening Cluster directory ---`n" -ForegroundColor Cyan;

	<# Scan the directory for existing clusters #>
	Write-Host "`tAttempting to detect current cluster culture" -ForegroundColor Yellow;
	$catalogFolders = Get-ChildItem "$($FlattenRootDirectory)\*" -Directory -Force -ErrorAction SilentlyContinue | Where-Object { $_.FullName -Like "$($FlattenRootDirectory)\cluster*" }
	$numClusters = $catalogFolders.Count;

	If ($numClusters) {
		Write-Host $("`tDetected {0} existing clusters --" -f $numClusters.ToString("##,###,###,###")) -ForegroundColor Cyan;

		<# Scan the directory and subdirectories below for files (this will include entires that are
		ONLY in a cluster, thus leaving other files unflattened you may have stored in other folders #>
		Write-Host "`n`tScanning files inside clusters" -ForegroundColor Yellow;
		$catalogFiles = Get-ChildItem "$($FlattenRootDirectory)\*" -Recurse -Include *.* -ErrorAction SilentlyContinue | Where-Object { $_.FullName -Like "$($FlattenRootDirectory)\cluster*\*" }
		$numFiles = $catalogFiles.Count;

		Write-Host $("`n`t`tDetected {0} files in {1} clusters --" -f $numFiles.ToString("##,###,###,###"), $numClusters.ToString("##,###,###,###")) -ForegroundColor Cyan;
		Write-Host "`n`tFlattening directory tree" -ForegroundColor Yellow;
		Write-Host "`t`tPlease wait, this is an active file-move operation which could take a while.`n" -ForegroundColor Green;

		<# copy files to root #>
		$numFilesDone = 1;
		ForEach ($catalogFile in $catalogFiles) {
			$theFile = $($catalogFile.Name);
			$theClusterB = $catalogFile.FullName;
			$SearchStart=[System.Text.RegularExpressions.Regex]::Escape("$($FlattenRootDirectory)\cluster");
			$SearchEnd=[System.Text.RegularExpressions.Regex]::Escape("\$($theFile)");
			If ($theClusterB -match "(?s)$SearchStart(?<content>.*)$SearchEnd") { $theCluster=[int]$matches['content']; }
			Write-Host -NoNewline $("`r`t`tMoving file {0} of {1} in cluster {2} to root - {3}       " -f $numFilesDone.ToString("##,###,###,###"), $numFiles.ToString("##,###,###,###"), $theCluster.ToString("##,###,###,###"), $theFile) -ForegroundColor Cyan;
			mi $catalogFile.FullName $FlattenRootDirectory;
			$numFilesDone++;
		}

		Write-Host -NoNewLine "`n";

		<# remove empty cluster folders #>
		$numClust = 1;
		If ($catalogFolders.Count -gt 0) {
			
			Write-Host "`n`tRemoving original cluster folders" -ForegroundColor Yellow;
			ForEach ($currentFolder in $catalogFolders)
			{
					$theFolderB = $currentFolder.FullName;
					$SearchStart=[System.Text.RegularExpressions.Regex]::Escape("$($FlattenRootDirectory)\cluster");
					if ($theFolderB -match "(?s)$SearchStart(?<content>.*)") { $theCluster=[int]$matches['content']; }
					Write-Host -NoNewLine $("`r`tSuccessfully cleaned cluster #{0}       " -f $theCluster.ToString("##,###,###,###")) -ForegroundColor Cyan;
					Remove-Item -Path $currentFolder.FullName -Force;
					$numClust++;
			}
			Write-Host -NoNewLine "`n`r"
		}
	} Else {
		Write-Host "`tNo Clusters found - No operation needed`!" -ForegroundColor Red;
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

	Write-Host "--- Generating Clusters ---`n" -ForegroundColor Cyan;

	<# Search for currently existing cluster folders #>
	Write-Host "`tAttempting to detect current cluster culture" -ForegroundColor Yellow;
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
		Write-Host $("`t`tDetected {0} existing clusters --`n" -f $numClusters) -ForegroundColor Yellow;
	} Else {
		Write-Host $("`t`tNo pre-existing folder clusters found`n" -f $numClusters) -ForegroundColor Red;
	}
	
	<# Detect how many clusters are needed to be created to complete the operation #>
	Write-Host "`tListing files... (wait, could take a while if your directory contains a lot)";
	$catalog = Get-ChildItem "$($ClusterRootDirectory)\*" -Include $FileTypeFilter -Force -ErrorAction SilentlyContinue;
	$numClustersNeeded = Get-Increment $(($catalog).Count / $ClusterSize);

	If ($numClustersNeeded -ne 0)
	{
		Write-Host $("`n`tDetected needed {0} clusters --`n" -f $numClustersNeeded) -ForegroundColor Yellow;

		<# Generate the folder structure #>
		For ($createCluster = $($numClusters + 1); $createCluster -le $($numClustersNeeded + $numClusters); $createCluster++)
		{
			$buildpath = $("{0}\cluster{1}" -f $ClusterRootDirectory, $createCluster.ToString());
			Write-Host -NoNewline $("`r`t`tCreating Cluster Directory `#{0} - {1}" -f $createCluster.ToString("##,###,###,###"), $buildpath) -ForegroundColor Cyan;
			$dummy = New-Item -ItemType directory -Path $buildpath;
		}
		Write-Host "`n`r";

		<# Move the files from the root into the newly generated clusters #>
		Write-Host "`tBeginning clustering process`n" -ForegroundColor Yellow;
		$currentCluster = $($numClusters + 1);
		$currentFile = 1;
		ForEach ($WorkFile in $catalog)
		{
			$buildpath = $("{0}\cluster{1}" -f $ClusterRootDirectory, $currentCluster.ToString());
			Write-Host -NoNewline $("`r`t`tWorking on Cluster {0} at index {1} / Clusters remaining: {2}" -f $currentCluster.ToString("##,###,###,###"), $currentFile.ToString(), $($($numClusters + $numClustersNeeded) - $currentCluster).ToString("##,###,###,###")) -ForegroundColor Cyan;
			mi $WorkFile.FullName $buildpath;
			$currentFile++;
			If ($currentFile -gt $ClusterSize) {
				$currentFile = 1;
				$currentCluster++;
			}
		}
	} Else {
		Write-Host "`tNo update operation is required" -ForegroundColor Red;
	}
	Write-Host "`n----- Operation Completed -----`n" -ForegroundColor Green;
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
		Write-Host " --- Migrating files ---`n" -ForegroundColor Cyan;
		If ($StubOriginals -Eq $True) {
			Write-Host "`tKeeping file stubs during operation" -ForegroundColor Green;
		} Else {
			Write-Host "`tMoving files only during operation" -ForegroundColor Yellow;
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
			
				Write-Host -NoNewLine "`tMigrating file: " -ForegroundColor White;
				Write-Host $("{0}" -f [System.IO.Path]::GetFileName($nextName)) -ForegroundColor Cyan;
				$NumMigrated++;
			}
		}
		If ($NumMigrated -Eq 0) {
			Write-Host "`tNothing new - No migration operation is required" -ForegroundColor Red;
		}
		Write-Host "`n----- Operation Completed -----`n" -ForegroundColor Green;
	} Else {
		Write-Host "`tFATAL:  Migration source directory does not exist" -ForegroundColor Red;
	}
}

#>

Display-Intro
$DirectoryPath = $(Get-Location);

<# Testbench #>
# Flatten-Directory -FlattenRootDirectory "E:\lupin\Pictures\sorted\hashed"
# Reset-Directory -ResetDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp
# Hash-Directory -HashDirectory "E:\lupin\Pictures\sorted\hashed_debug" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp
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
