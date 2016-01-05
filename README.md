
# stdnbr-to-loc-callnumber

A quick and dirty shell script that takes an OCLC standard number (one per line) and outputs a tab delimited file of standard number, call number and title based on what was avialable at the OCLC classify API.

## requirements

+ Bash
+ xpath (installed usually with Perl and the XML modules)
+ cut
+ curl


## Process

Get the excel file with all the data. Make sure the column with the has the number you want to send to OCLC
is not hidden. Copy the column into its own spreadsheet and save as a tab delimited file. When Excel on a Mac
save the data as a tab delimited (or CSV) file it will do so with the wrong type of line endings. These script
expect the traditional Unix LF (line feed) for line endings not charage returns or charage returns plus line feed.
You can use emacs or Atom editor (or most programmer's text editors) to convert the line feeds.

Since the file is large I recommend using the Unix split command to break it into smaller chunks. E.g.

```
    split original-data-file.txt data-out.
```

Then for each split of the the data-out files you would run the bash script to build up data-out-final.txt.

```
    bash stdnbr-to-callnumber.sh data-out.aa
    bash stdnbr-to-callnumber.sh data-out.ab
    bash stdnbr-to-callnumber.sh data-out.ac
```

And so forth.

