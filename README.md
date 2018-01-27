# YIFFHASHER
---------------------
## Autonimous backup management script
# PowerShell script for backup management
By: loopyd / fur_user

Oogled at by:  yucked  ;3

---

### What is this?

An automagical backup organization script with a lot of extendability and optimization for Windows PowerShell 5.0 and above.
It can be installed as a background service and run automagically at intervals, or run a few times and left sadly...to cry
alone and forgotten about.  (please, no - animal abuse is not okay).

---

### Installation
# For the diligant bold-hearted tester:

1.  Clone it  (currently **testing** branch only due to beta-ness)
2.  Place the modules to run at the bottom of the script ( a few examples have been provided with ther appropriate arguments )
3.  Run, hash, YOFF!

---

### Configuration
Explanations of argument options

# Flatten-Directory options:
```
-FlattenRootDirectory [string]
     The path to flatten the cluster folders to.  It is the folder that contains all of the cluster directories.
```

# Reset-Directory options:
```
-ResetDirectory [string]
     The path which contains files that need their attribute flags reset.
-FileTypeFilter [string,string,...]
     Glob expressions filtering files by extension (or potentially name!)  Add as many as you'd like.
```

# Hash-Directory options:
```
-ResetDirectory [string]
     The path which contains files that need their attribute flags reset.
-FileTypeFilter [string,string,...]
     Glob expressions filtering files by extension (or potentially name!)  Add as many as you'd like.
```

# Generate-FolderClusters options:
```
-ClusterRootDirectory [string]
     The path which contains files that need organized.  It is recommended you run Flatten-Directory and 
     Reset-Directory on the same directory first, as the operation does not recurse subfolders !
-FileTypeFilter [string,string,...]
     Glob expressions filtering files by extension (or potentially name!)  Add as many as you'd like.
-ClusterSize [int]
     Each cluster folder will take the number of files in you specify here.  You should set this higher
     (50-100) for larger directories, or (25-50) for smaller directories.
```

# Migrate-All options:
```
-MigrateRootDirectory [string]
     The path which contains files that need migrated.
-FileTypeFilter [string,string,...]
     Glob expressions filtering files by extension (or potentially name!)  Add as many as you'd like.
-DestinationDirectory [string]
     The path to place the migrated files (flat).
-StubOriginals [bool]
	Wether or not to leave an empty stub behind in the copy operation which retains the original file's
	creation and modification dates.  Useful to preserve tree structures in the original directory, but
	save storage space.
```

# Stub-Move options:
```
-FilePath [string]
     The File to move and create a stub of
-DestinationDirectory [string]
     The destination path/filename (usually the same, could be different to avoid duplicates)
```

# Add-Resource options:
```
  CURRENTLY IN TESTING STATE, DON'T USE THIS JUST YET.  IT'S A JSON RESOURCE PACKER I HAVEN'T
  IMPLEMENTED YET.
```

---

### Example usage

Samples are provided at the bottom of the powershell in testing.  But here they are run in the proper order:

```
Flatten-Directory -FlattenRootDirectory "E:\lupin\Pictures\sorted\hashed"
Reset-Directory -ResetDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp
Hash-Directory -HashDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp
Generate-FolderClusters -ClusterRootDirectory "E:\lupin\Pictures\sorted\hashed" -FileTypeFilter *.gif,*.jpg,*.png,*.jpeg,*.bmp -ClusterSize 100
```

### LICENSE

See ``license.md`` for licensing details.
