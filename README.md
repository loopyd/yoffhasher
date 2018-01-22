YIFFHASHER
---------------------
### Autonimous backup management script
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

PARTICIPATION AGREEMENT:
YOU AGREE TO SHARE BUG REPORTS/PROBLEMS/ISSUES WITH ME IN THE ISSUES SECTION
OF THIS REPOSITORY.

RELEASE OF LIABILITY AGREEMENT:
YOU WILL NOT HOLD THE AUTHOR RESPONSIBLE FOR DAMAGES AS A RESULT OF USING THIS
PRODUCT.  THE PRODUCT CAN POTENTIALLY WORK WITH LARGE AMOUNTS OF DATA AT THE
SAME TIME.  THE AUTHOR ASSUMES NO LEGAL, MONETARY, PERSONAL, OR FINANCIAL RISK
FOR YOUR USE OF THE PRODUCT (ESPECIALLY IN REGARDS TO THE 'TESTING' BRANCH)

COMMERCIAL USE POLICY:
THIS PRODUCT MAY NOT BE USED FOR COMMERCIAL USE WITHOUT LOYALTY TO ITS AUTHOR
IN THE AMOUNT OF 4 CENTS PER SUCCESSFUL EXECUTION - TO ITS AUTHOR AND NO OTHER

YOU MUST INSTALL THIS SCRIPT WITH A RUNNING TRACKER OF SUCCESSFUL EXECUTIONS
TO COMMIT ROYALTIES TO ITS AUTHOR IN A COMMERCIAL ENVIRONMENT.

YOU MUST REPORT YOUR RUNS TO THE AUTHOR LISTED AT THE TOP OF THE REPOSITORY
IN A TIMELY MANNER.

YOU MUST PAY THE ROYALTIES WHEN ASKED AND IN A TIMELY MANNER OF TO THE MAXIMUM
TIME OF 30 DAYS, NO EXCEPTIONS.

YOU WILL BE HELD TO THE MAXIMUM EXTENT OF THE LAW IF YOU ARE FOUND CIRCUMVENTING
APPLICABLE ROYALTY GUIDELINES.

MODIFICATIONS IN COMMERCIAL ENVIRONMENTS:
YOU MAY SURPRESS THE OUTPUT OF THIS SCRIPT BY PIPING STDOUT TO NULL IN AN
UNATTENDED SERVER ENVIRONMENT.

YOU MAY MODIFY OUTPUT YOU CONSIDER TO BE UNPROFESSIONAL, BUT YOU WILL NOT
REMOVE THE AUTHOR'S NAME AND CONTACT INFORMATION, AND REFERENCE TO THIS
REPOSITORY.

YOU WILL NOT CHANGE THE SCRIPTS FILENAME FROM: "hasher.ps1" TO ANYTHING ELSE.

YOU MAY ADD LOGGING FEATURES TO THE SCRIPT FOR DEBUGGING PERPOUSES, BUT YOU MAY
NOT MODIFY ITS CORE FUNCTIONALITY.

IF SAID FEATURES BREAK THE INTERNAL FUNCTIONALITY OF THIS SCRIPT, SUCCESSFUL
EXECUTION POLICY ALWAYS COINTS.

SUCCESSFUL EXECUTION:  DEFINES ANY RUN OF THE SCRIPT WHERE ITS FUNCTIONS ARE BEING
USED (ONE OR MANY), FROM INITIATION TO SCRIPT EXIT.  EXECUTIONS DURING LOSS OF
POWER DO NOT COUNT, INTENTIONAL EARLY TERMINATION OF THE SCRIPT TO CIRCUMVENT
THIS POLICY DOES COUNT.

PERSONAL USE POLICY:
YOU MAY USE THIS SCRIPT FOR PERSONAL USE AS MANY TIMES AS YOU WOULD LIKE.  AS
LONG AS THE RESULTS ARE NOT GENERATING ANY SORT OF INCOME, THIS COUNTS UNDERNEATH
THE PERSONAL USE POLICY.

DONATIONS ARE ALSO WELCOME, SINCE THIS HAS BEEN A PRIVATELY RUNNING PROJECT FOR
GOING ON 2 MONTHS (ESPECIALLY THE RESEARCH TO OPTIMIZE SCANS):

MONERO WALLET:

4AUHhC44dyDTb2JMfvvBxPVvXa5qnLTitW4CuS5gVQW97h9w5AbGMpaFzFnRUj7n7DBUDepczn53KU9LzzD79tM5Tiv4TXX

MODIFICATIONS IN PERSONAL USE ENVIRONMENT:
YOU MAY SURPRESS THE OUTPUT OF THIS SCRIPT BY PIPING STDOUT TO NULL IN AN
UNATTENDED SERVER ENVIRONMENT.

YOU MAY ADD LOGGING FEATURES TO THE SCRIPT FOR DEBUGGING PERPOUSES, BUT YOU MAY
NOT MODIFY ITS CORE FUNCTIONALITY.

IF SAID FEATURES BREAK THE INTERNAL FUNCTIONALITY OF THIS SCRIPT, THE AUTHOR
SHALL NOT RECIEVE ISSUE TICKETS FOR YOUR MODIFICATIONS.

