# myebookshellread - a command line ebook reader shell script and now, a C version too

An very lightweight (just a shell script — and now optionally C!) ebook reader that can
use either espeak, espeak-ng, or flite TTS.

## What's New

We now include a **C implementation**: `myebookreader.c` — for those who demand speed, simplicity, and full control over their binaries.  
No interpreters. No dependencies. No excuses.

The original `ebookreader.sh` is still included for shell lovers, tinkerers, and graybeards running Plan 9 or busybox on a toaster.

## requirements:
	espeak  - for reading out loud, however could also use flite by changing the variable at the top of the script
	awk     - most shells/distros have this
	a shell - tested in bash, sh, yash, dash

## optional depends:
The script and C version both rely on common *external* tools to convert ebook formats to plain text.
All are standard in most package managers:

	groff       - for roff/man files
	Latex       - only for detex'ing documents
	odt2txt     - read OpenOffice files
	ghostscript - for ps2ascii
	pdf2txt     - Python-based, requires pdfminer
	epub2txt2   - for .epub (https://github.com/kevinboone/epub2txt2)
	html2text   - for .html/.htm
	gunzip, bunzip2, unxz - for compressed .gz/.bz2/.xz files
	man         - if you want to read manpages aloud

## Supported Formats
	.txt           - plain text (fallback if unknown)
	.gz, .bz2, .xz - compressed text
	.html          - saved web pages
	.epub          - ebook format
	.ps/.pdf       - ghostscript (or pdf2txt fallback)
	.odt           - OpenOffice documents
	.tex           - LaTeX files (via detex)
	.1/.2/.ms/.me  - Groff/Troff (via groff -ms/-me)
	manpages       - readable via the "man" arg

## Usage (Bash):
	ebookreader.sh FILENAME BOOKMARK man/noconv
	"man"     → reads the manpage version of the file
	"noconv"  → skips conversion, reads raw

Examples:
	ebookreader.sh ls 1 man
	ebookreader.sh war_and_peace.txt 5000


 

## Usage (C):
The new C version has the same interface, minus shellisms:

```sh
./myebookreader FILE [BOOKMARK] [man|noconv]

```

## Changing your TTS in C. 

Look for the following code and change it accordingly, then recompile (the suckless way).  Note, that you can also chagne espeak's voice if you need to do so.

```
#define ESPEAK_COMMAND "/usr/bin/espeak -v f4 -p85"

/*
#ESPEAKCOMMAND="/usr/bin/flite"
#ESPEAKCOMMAND="/usr/bin/espeak-ng" #the new one.
#ESPEAKCOMMAND="/data/data/com.termux/files/usr/bin/espeak"
*/
```

This project is dedicated to Jos Lemmens, creator of ebook-speaker.
While this script shares no code with the original, it shares the same spirit — a quick, minimal, and accessible way to read text aloud and save your place via a bookmark.

Designed for extreme portability, it requires only a shell, awk, seq, and espeak — though you can swap in any TTS engine that accepts piped input.
