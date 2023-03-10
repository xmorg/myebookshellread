#This script is a dedicated to the creator of ebook-speaker

#This script will only read 1 line, of text then exit.
#it has no loop, it does create abookmark i may be better
#for other apps to handle

#TODO: bookmarking more than one "converted" book
#will probably overwrite teh previous bookmark.

PS2TXT="/usr/bin/ps2txt" #ghostscript
PDF2TXT="/usr/bin/pdf2txt" #python pdf miner
PS2ASCII="/usr/bin/ps2ascii" #fallback if you have ghostscript.
EBPUB2TXT="/usr/bin/epub2txt" #https://github.com/kevinboone/epub2txt2
HTML2TXT="/usr/bin/html2text" #https://linux.die.net/man/1/html2text ? a package?
#http://userpage.fu-berlin.de/~mbayer/tools/html2text.html
GZIP2TXT="/bin/gunzip -c" #needs gunzip, part of most linux os distros
BZIP2TXT="/usr/bin/bunzip2 -c"
XZ2TXT="/usr/bin/unxz -c"
DETEX="/usr/bin/detex" #install Latex suite
ODT2TXT="/usr/bin/odt2txt" #install odt2txt, check your package manager?
RANDOMTMPFILE="234rqwer2342qrwer423tmp.txt"
#Variables
#ESPEAKCOMMAND="/usr/bin/flite"
ESPEAKCOMMAND="/usr/bin/espeak" #you can add voices with -v <voice name>

if test -f $ESPEAKCOMMAND; then
    ESPEAKFOUND=1 #found espeak!
else
    echo "DEBUG no espeak command, check your ESPEAK variable."
    echo "try whereis espeak, you may need to isntall (usually /usr/bin/espeak)"
    exit
fi


FILEARG=$1 #$2=bookmark $3man? man page


echo $FILEARG " " $(head -c 4 $FILEARG)

if [[ $# > 2 ]]; then #if [ $# -lt 3 ]; then #did you say man?
    if [ $3 = "man" ]; then
	#man page out, requires man!
	man -Tascii $FILEARG > $RANDOMTMPFILE
	FILENAME=$RANDOMTMPFILE
	trap 'rm $RANDOMTMPFILE; exit' INT
    fi
elif [[ $FILEARG =~ ".gz" ]]; then # || [ $FILEARG = *\.tgz ]; then
    echo "found a gzip file"
    $GZIP2TXT $FILEARG > $RANDOMTMPFILE
    FILENAME=$RANDOMTMPFILE
    trap 'rm $RANDOMTMPFILE; exit' INT
elif [[ $FILEARG =~ ".1" ]] || [[ $FILEARG =~ ".2" ]] || [[ $FILEARG =~ ".ms" ]]; then # || [ $FILEARG = *\.tgz ]; then
    echo "found a groff/troff (groff_ms) file"
    #$BZIP2TXT $FILEARG > $RANDOMTMPFILE
    #test for groff
    /usr/bin/groff -Tascii -ms  $FILEARG > $RANDOMTMPFILE
    FILENAME=$RANDOMTMPFILE
    trap 'rm $RANDOMTMPFILE; exit' INT
elif [[ $FILEARG =~ ".tex" ]]; then
    #TEST for detex
    echo "Found LaTex file"
    $DETEX $FILEARG > $RANDOMTMPFILE
    FILENAME=$RANDOMTMPFILE
    trap 'rm $RANDOMTMPFILE; exit' INT
elif [[ $FILEARG =~ ".bz2" ]]; then # || [ $FILEARG = *\.tgz ]; then
    echo "found a bzip2 file"
    $BZIP2TXT $FILEARG > $RANDOMTMPFILE
    FILENAME=$RANDOMTMPFILE
    trap 'rm $RANDOMTMPFILE; exit' INT
elif [[ $FILEARG =~ ".xz" ]]; then # || [ $FILEARG = *\.tgz ]; then
    echo "found a xz file"
    $XZ2TXT $FILEARG > $RANDOMTMPFILE
    FILENAME=$RANDOMTMPFILE
    trap 'rm $RANDOMTMPFILE; exit' INT
elif [ $(head -c 4 $FILEARG) = "%!PS" ] ; then
    echo "found a ps file"
    if test -f $PS2ASCII; then #PS2ASCII or PS2TXT
	$PS2ASCII $FILEARG > $RANDOMTMPFILE
        FILENAME=$RANDOMTMPFILE
        trap 'rm $RANDOMTMPFILE; exit' INT
    elif test -f $PS2TXT; then
	#FOUNDPS=1
	$PS2TXT $FILEARG > $RANDOMTMPFILE
	FILENAME=$RANDOMTMPFILE
	trap 'rm $RANDOMTMPFILE; exit' INT
    else
	echo "error no ps converter! exiting"
	exit
    fi
elif [[ $FILEARG =~ ".epub" ]]; then
    echo "found an epub file"
    if test -f $EBPUB2TXT; then
        FOUNDPS=1
        $EBPUB2TXT $FILEARG > $RANDOMTMPFILE
        FILENAME=$RANDOMTMPFILE
        trap 'rm $RANDOMTMPFILE; exit' INT
    else
        echo "error no epub converter! exiting"
	echo "try : https://github.com/kevinboone/epub2txt2"
        exit
    fi
    # test me vv
elif [[ $FILEARG =~ ".odt" ]]; then
    echo "found an odt file"                                                                                                                                                                
    if test -f $ODT2TXT; then
        FOUNDODT=1
        $ODT2TXT $FILEARG > $RANDOMTMPFILE
        FILENAME=$RANDOMTMPFILE
        trap 'rm $RANDOMTMPFILE; exit' INT                                                                                                                                                   
    else
        echo "error no epub converter! exiting"
        echo "try : https://github.com/kevinboone/epub2txt2"
        exit
    fi
elif [[ $FILEARG =~ ".htm" ]] || [[ $FILEARG =~ ".html" ]]; then
    echo "found an html file"
    if test -f $HTML2TXT; then
        FOUNDPS=1
        $HTML2TXT $FILEARG > $RANDOMTMPFILE
        FILENAME=$RANDOMTMPFILE
        trap 'rm $RANDOMTMPFILE; exit' INT
    else
        echo "error no html converter! exiting"
        echo "your distro might have a package for " $HTML2TXT
        exit
    fi
elif [ $(head -c 4 "$FILEARG") = "%PDF" ]; then
    echo "found a PDF file"
    if test -f $PS2ASCII; then #PS2ASCII or PS2TXT
        FOUNDPS=1
        $PS2ASCII $FILEARG > $RANDOMTMPFILE
        FILENAME=$RANDOMTMPFILE
        trap 'rm $RANDOMTMPFILE; exit' INT
    elif test -f $PDF2TXT; then
	FOUNDPS=1
        $PDF2TXT $FILEARG > $RANDOMTMPFILE
        FILENAME=$RANDOMTMPFILE
        trap 'rm $RANDOMTMPFILE; exit' INT
    else
        echo "error no pdf converter! exiting"
        echo "try installing python-pdfminer, or bring your own converter"
        exit
    fi
else
    echo "DEBUG: assuming plain text file"
    FILENAME=$1
fi

BMEXT=".bookmark" #new file created with .bookmark appended to name
if [ $# -eq 0 ]; then
    echo "Usage: " $0 ": FILE line-number"
    exit
fi

if [ $# -eq 1 ]; then #new code, trying to solve multi-converted
   if test -f $FILEARG$BMEXT; then #bookmarks
       echo "DEBUG: no args, but found bookmark"
       BOOKMARK=$(cat $FILEARG$BMEXT)
   else
       echo "DEBUG: no args or bookmark, starting form beginning"
       BOOKMARK=1
   fi
else
    echo "DEBUG: starting from arg bookmark"
    BOOKMARK=$2
fi
FILESIZE=$(wc -l $FILENAME | awk '{print $1;}')

echo "bookmark line:"$BOOKMARK"    Exit with C-c"
echo "file lines:"$FILESIZE

#for i in {$a..$z..1} #{(($BOOKMARK))..(($FILESIZE))}
#seq $BOOKMARK $FILESIZE
#OUTMARK=$BOOKMARK
#for i in $(seq $BOOKMARK $FILESIZE)
#do
echo $i $(awk -v BM=$BOOKMARK 'NR==BM' $FILENAME)
awk -v BM=$BOOKMARK 'NR==BM' $FILENAME | $ESPEAKCOMMAND
echo $i > $FILEARG".bookmark" #protect your files!

#dont remove the temp file? or dont keep creating teh file every line?
#rm $RANDOMTMPFILE # warning i hope you have no tmp.txt in this dir :)
