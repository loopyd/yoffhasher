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

    [cmdletbinding()]
    param(
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
[console]::Title="YIFFHASHER 1.1.2";
Write-Host "                                     "
Write-Host "                .-'''''-.            "
Write-Host "              .'         ``.          "
Write-Host "             :             :         "
Write-Host "            :               :        "
Write-Host "            :      _/|      :        "
Write-Host "             :   =/_/      :         "
Write-Host "              ``._/ |     .'         YIFFHASHER "
Write-Host "           (   /  ,|...-'            by fur_user"
Write-Host "            \_/^\/||__               "
Write-Host "         _/~  ```"`"~```"` \_         Am an M$ faggot      "
Write-Host "      __/  -'/  ``-._ ``\_\__           js   "
Write-Host "    /     /-'``  ``\   \  \-.\         `n"
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
  Write-Host " --- Hashing directory ---`n" -ForegroundColor Yellow;
  Write-Host "-- Welcome to THE YIFFERHASHER.  Leave your hat at the door.  This takes a while!  Here's an explanation" -ForegroundColor Cyan;
  Write-Host "   of whats happening:`n" -ForegroundColor Cyan;
  Write-Host "   Phase 1 (Population Phase)" -ForegroundColor Green;
  Write-Host "      Your directory will be non-destructively MD5 hashed.  The performance impact here is dependent on" -ForegroundColor Magenta;
  Write-Host "      how large each file is, how many you've to scan, and of course the speed of your storage media." -ForegroundColor Magenta;
  Write-Host "   Phase 2 (Adjustment Phase)" -ForegroundColor Green;
  Write-Host "      The table in memory will be removed of duplicates and stored into a different table for deletion." -ForegroundColor Magenta;
  Write-Host "      You will NOT experience heavy disk activity during this time.  It is highly recomended on a large" -ForegroundColor Magenta;
  Write-Host "      dataset, that you hold at least 8 GB of RAM in your system.  Performance impact in this phase is" -ForegroundColor Magenta;
  Write-Host "      dependant on wether or not you have enough RAM to remain in RAM and not on your pagefile, the" -ForegroundColor Magenta;
  Write-Host "      clockspeed of your RAM, and how many entries need to be searched.`n" -ForegroundColor Magenta;
  Write-Host -NoNewLine "-- Initializing... (wait, could take a while if your directory contains a lot)" -ForegroundColor Yellow;
  
  <# Allocate memory for the lists #>
  $hashTable = New-Object System.Collections.Generic.List[System.Object];
  $duplicateHashFiles = New-Object System.Collections.Generic.List[System.Object];
 
  <# 1st pass, populate everything... #>
  Get-ChildItem "$($HashDirectory)\*" -Include $FileTypeFilter | Foreach-Object {
	$f_path = $_.Path;
    $f_name = $_.FullName;
	$f_ext = $_.Extension;
	$f_hashed = $("{0}" -f $(Get-FileHash -LiteralPath $f_name -Algorithm MD5).Hash );
    $hashObject = New-Object -TypeName PSObject;
	$hashObject | Add-Member -Name 'Hash' -MemberType Noteproperty -Value $f_hashed;
	$hashObject | Add-Member -Name 'FullPath' -MemberType Noteproperty -Value $f_name;
	$hashTable.Add($hashObject);
	Write-Host -NoNewline "`r-- Processing Hashtable:  " -ForegroundColor White
	Write-Host -NoNewline "U: N/`A" -ForegroundColor Cyan;
	Write-Host -NoNewLine " `| " -ForegroundColor White
	Write-Host -NoNewline "D: N`/A" -ForegroundColor Red;
    Write-Host -NoNewLine " `| " -ForegroundColor White
    Write-Host -NoNewline $("F: {0}" -f ($hashTable.Count).ToString()) -ForegroundColor Yellow;
	Write-Host -NoNewLine " `| " -ForegroundColor White
	Write-Host -NoNewLine "Phase: 1 (Population Phase)" -ForegroundColor Green
	Write-Host -NoNewline "                      " -ForegroundColor Yellow
  }
  
  <# Sort the hashtable #>
  $hashTableTemp = New-Object System.Collections.Generic.List[System.Object];
  [System.Collections.Generic.List[System.Object]]$hashTableTemp = $($hashTable | Sort-Object -Property Hash );
  [System.Collections.Generic.List[System.Object]]$hashTable = $hashTableTemp;
  
  <# Second Pass, Recursively go for duplicate hashes #>
  $currentItem = 0;
  $maxItems = ($hashTable.Count);
  while ($currentItem -Lt $maxItems) {
  
    <# Due to ascending sort order - this always works #>
	<# It only "always worked" after 6 hours of debugging, thats lyfe #>
    $dupResult = New-Object System.Collections.Generic.List[System.Object];
    $dupFound = $True;
	$ci = 1;
	do {
	   If ($hashTable[$currentItem].Hash -Eq $hashTable[$currentItem+$ci].Hash) {
		    $duplicateHashFiles.Add($HashTable[$currentItem+$ci]);
			$hashTable.RemoveAt($currentItem+$ci) | out-null;
			$maxItems--;
		    $ci++;
       } Else {
            $dupFound = $False;
       }
	   if (($currentItem+$ci) -Ge ($maxItems)) { $dupFound = $False; }
	} until (!$dupFound)
	$currentItem++;

    Write-Host -NoNewline "`r-- Processing Hashtable:  " -ForegroundColor White;
	Write-Host -NoNewline $("U: {0}" -f ($hashTable.Count).ToString()) -ForegroundColor Cyan;
	Write-Host -NoNewLine " `| " -ForegroundColor White;
	Write-Host -NoNewline $("D: {0}" -f ($duplicateHashFiles.Count).ToString()) -ForegroundColor Red;
    Write-Host -NoNewLine " `| " -ForegroundColor White;
    Write-Host -NoNewline $("F: {0}" -f ($currentItem).ToString()) -ForegroundColor Yellow;
	Write-Host -NoNewLine " `| " -ForegroundColor White;
	Write-Host -NoNewLine "Phase: 2 (Adjustment Phase)" -ForegroundColor Green;
	Write-Host -NoNewline "                   " -ForegroundColor Yellow;
  }

  <# Delete the duplicate files #>
  if (($duplicateHashFiles.Count) -Gt 0) {
    Write-Host "`n`n`r-- Deleting duplicate files" -ForegroundColor White;
    $f_count = 0;
    while ($f_count -Lt ($duplicateHashFiles.Count)) {
        $f_name = (Split-Path -Path $duplicateHashFiles[$f_count].FullPath -Leaf).Split(".")[0];
        $f_ext = (Split-Path -Path $duplicateHashFiles[$f_count].FullPath -Leaf).Split(".")[1];
	    $f_fname = $("{0}.{1}" -f $f_name, $f_ext);
        Write-Host -NoNewline $("`r---- Cleaning duplicate:  {0} | `#{1}" -f $f_fname, ($f_count+1).ToString("#,###,###,###")) -ForegroundColor Cyan	
	    Remove-Item -Path $duplicateHashFiles[$f_count].FullPath -Force;
	    $f_count++;
      }
  }
  
  <# Rename the files uniquely to avoid filename colissions #>
  Write-Host "`n`n`r-- Renaming files to avoid collisions..." -ForegroundColor White;
  $f_count = 0;
  while ($f_count -Lt ($hashTable.Count)) {
    <# The split in here to different variables is for status output purposes only... #>
    $f_name = (Split-Path -Path $hashTable[$f_count].FullPath -Leaf).Split(".")[0];
    $f_ext = (Split-Path -Path $hashTable[$f_count].FullPath -Leaf).Split(".")[1];
    $f_oldname = $("{0}.{1}" -f $f_name, $f_ext);
	$f_newname = $("{0}.{1}" -f $f_count.ToString("##########"), $f_ext);
	Write-Host -NoNewline $("`r---- Working on file:  {0} | `#{1}          " -f $f_oldname, ($f_count+1).ToString("#,###,###,###")) -ForegroundColor Cyan
	Rename-Item -LiteralPath $("{0}\{1}" -f $HashDirectory, $f_oldname) -NewName $f_newname
    $f_count++;
  }  
  
  <# Rename the uniquely named files #>
  Write-Host "`n`n`r-- Renaming files to proper hashnames..." -ForegroundColor White;
  $f_count = 0;
  while ($f_count -Lt ($hashTable.Count)) {
    <# The split in here to different variables is for status output purposes only... #>
    $f_name = $("{0}" -f $f_count.ToString("##########"));
    $f_ext = (Split-Path -Path $hashTable[$f_count].FullPath -Leaf).Split(".")[1];
	$f_oldname = $("{0}.{1}" -f $f_name, $f_ext);
	$f_newname = $("{0}.{1}" -f $hashTable[$f_count].Hash, $f_ext);
	Write-Host -NoNewline $("`r---- Working on file:  {0} | `#{1}          " -f $f_oldname, ($f_count+1).ToString("#,###,###,###")) -ForegroundColor Cyan
	Rename-Item -LiteralPath $("{0}\{1}" -f $HashDirectory, $f_oldname) -NewName $f_newname
    $f_count++;
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
	Foreach ($ROfile in $ROcatalog) {
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
  if (($ARcatalog.Count) -gt 0) {
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
  
  if ($numClusters) {
	Write-Host $("-- Detected {0} existing clusters --" -f $numClusters.ToString("##,###,###,###")) -ForegroundColor Cyan;
  
	<# Scan the directory and subdirectories below for files (this will include entires that are
       ONLY in a cluster, thus leaving other files unflattened you may have stored in other folders #>
	Write-Host $("`n-- Scanning files inside clusters" -f $numClusters) -ForegroundColor Yellow;
	Write-Host "-- Please wait, this may take a long time if your cluster database is very large.";
	Write-Host "     On a z270 platform with an i7 6700k on a mechanical 7200rpm drive on a SATA 3gb/s bus," -ForegroundColor Magenta;
	Write-Host "     iterating through 200,000 image files, the process took approximately 45 seconds to" -ForegroundColor Magenta;
	Write-Host "     finish scanning.  Be patient`!  This step does not provide progress`/status output for" -ForegroundColor Magenta;
	Write-Host "     performance reasons." -ForegroundColor Magenta;
	$catalogFiles = Get-ChildItem "$($FlattenRootDirectory)\*" -Recurse -Include *.* -ErrorAction SilentlyContinue | Where-Object { $_.FullName -Like "$($FlattenRootDirectory)\cluster*\*" }
	$numFiles = $catalogFiles.Count;

	Write-Host $("-- Detected {0} files in {1} clusters --" -f $numFiles.ToString("##,###,###,###"), $numClusters.ToString("##,###,###,###")) -ForegroundColor Cyan;
  
	Write-Host $("`n-- Flattening directory tree" -f $numClusters) -ForegroundColor Yellow;
	Write-Host "-- Please wait, this is an active file-move operation which could take a while.`n";
  
	<# copy files to root #>
	$numFilesDone = 1;
	foreach ($catalogFile in $catalogFiles) {
		$theFile = $($catalogFile.Name);
		$theClusterB = $catalogFile.FullName;
		$SearchStart=[System.Text.RegularExpressions.Regex]::Escape("$($FlattenRootDirectory)\cluster");
		$SearchEnd=[System.Text.RegularExpressions.Regex]::Escape("\$($theFile)");
		if ($theClusterB -match "(?s)$SearchStart(?<content>.*)$SearchEnd") { $theCluster=[int]$matches['content']; }
		Write-Host -NoNewline $("`r-- Moving file {0} of {1} in cluster {2} to root - {3}       " -f $numFilesDone.ToString("##,###,###,###"), $numFiles.ToString("##,###,###,###"), $theCluster.ToString("##,###,###,###"), $theFile) -ForegroundColor Cyan;
		mi $catalogFile.FullName $FlattenRootDirectory;
		$numFilesDone++;
	}
  
	Write-Host -NoNewLine "`n";
  
	<# remove empty cluster folders #>
	$numClust = 1;
	If ($catalogFolders.Count -gt 0) {
		foreach ($currentFolder in $catalogFolders)
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
  if ($(($catalogFolders).Count) -gt 0) {
	foreach ($currentFolder in $catalogFolders)
	{
		$buildname = $("{0}\cluster{1}" -f $ClusterRootDirectory, $($numClusters + 1).ToString());
		if (Test-Path $buildname)
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
  
  if ($numClustersNeeded -ne 0)
  {
	Write-Host $("`n-- Detected needed {0} clusters --`n" -f $numClustersNeeded) -ForegroundColor Yellow;
  
	<# Generate the folder structure #>
	for ($createCluster = $($numClusters + 1); $createCluster -le $($numClustersNeeded + $numClusters); $createCluster++)
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
	foreach ($WorkFile in $catalog)
	{
	  $buildpath = $("{0}\cluster{1}" -f $ClusterRootDirectory, $currentCluster.ToString());
	  Write-Host -NoNewline $("`r-- Working on Cluster {0} at index {1} / Clusters remaining: {2}" -f $currentCluster.ToString("##,###,###,###"), $currentFile.ToString(), $($($numClusters + $numClustersNeeded) - $currentCluster).ToString("##,###,###,###")) -ForegroundColor Cyan;
	  mi $WorkFile.FullName $buildpath;
	  $currentFile++;
	  if ($currentFile -gt $ClusterSize) {
	    $currentFile = 1;
		$currentCluster++;
	  }
	}
  } else
  {
      Write-Host "-- No update operation is required" -ForegroundColor Red;
  }
}

Display-Intro
$DirectoryPath = $(Get-Location);

<# Testbench #>
# Flatten-Directory -FlattenRootDirectory "E:\lupin\Pictures\sorted\hashed"
# Reset-Directory -ResetDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp
Hash-Directory -HashDirectory "E:\lupin\Pictures\sorted\hashed_debug" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp
# Generate-FolderClusters -ClusterRootDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp -ClusterSize 100
# Reset-Directory -ResetDirectory "E:\lupin\Videos\nice stuff" -FileTypeFilter *.mov,*.avi,*.flv,*.wmv,*.mp4,*.m4v,*.mkv,*.divx,*.rm,*.mpg,*.mpeg,*.mpeg4,*.3gp,*.webm,*.vob
# Hash-Directory -HashDirectory "E:\lupin\Videos\nice stuff" -FileTypeFilter *.mov,*.avi,*.flv,*.wmv,*.mp4,*.m4v,*.mkv,*.divx,*.rm,*.mpg,*.mpeg,*.mpeg4,*.3gp,*.webm,*.vob
# Generate-FolderClusters -ClusterRootDirectory "E:\lupin\Videos\nice stuff" -FileTypeFilter *.mov,*.avi,*.flv,*.wmv,*.mp4,*.m4v,*.mkv,*.divx,*.rm,*.mpg,*.mpeg,*.mpeg4,*.3gp,*.webm,*.vob -ClusterSize 10
#Add-Resource "$($DirectoryPath)\test.txt" "$($DirectoryPath)\test.rsrc"
#Add-Resource "$($DirectoryPath)\test2.txt" "$($DirectoryPath)\test.rsrc"
