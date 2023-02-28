#This script is a dedicated to the creator of ebook-speaker
#Jos Lemmens / http://jlemmens.nl/ This Script takes no code
#from the original but intends to provide quick and easy way
#of outputing text to speach and saving the progress of a
#text file via a bookmark. it intends to be extreemly portable,
#only requring a shell, awk, seq, and espeak ideally you can
#replace espeak with any other tts which excepts pipe input.

#tested in bash, sh, yash, dash

#limitations, its not curses, or termcap so it cant accept
#keyboard interupts (yet), like going back, etc.

#count the lines / wc
#output lines, one by one to stdout awk
#pipe output to espeak awk | espeak
#print line numbers echo variable

#TODO: Converters, the object is to output to plain text file and read it.
#this would of course require the converter be installed.
PS2TXT="ps2txt"
PDF2TXT="FIXME"
EBPUB2TXT="epub2txt"
GZIP2TXT="gunzip -c"
#Variables
ESPEAKCOMMAND="/usr/bin/espeak" #you can add voices with -v <voice name>
if test -f $ESPEAKCOMMAND; then
    echo "DEBUG espeak exists"
else
    echo "DEBUG no espeak command, check your ESPEAK variable."
    echo "try whereis espeak, you may need to isntall (usually /usr/bin/espeak)"
    exit
fi

FILENAME=$1
BMEXT=".bookmark" #new file created with .bookmark appended to name
if [ $# -eq 1 ]; then
   if test -f $FILENAME$BMEXT; then
       echo "DEBUG: no args, but found bookmark"
       BOOKMARK=$(cat $FILENAME$BMEXT)
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
for i in $(seq $BOOKMARK $FILESIZE)
do
    #read -rsn1 -t 0.01 input  #nonfucntional
    #if [ "$input" = "h" ]; then
    #    $i=$i-1
    #fi
    echo $i $(awk -v BM=$i 'NR==BM' $FILENAME)
    awk -v BM=$i 'NR==BM' $FILENAME | $ESPEAKCOMMAND
    #debug creates a bookmark file which outputs the line number
    #last read.
    echo $i > $FILENAME".bookmark" #protect your files!
    #The above statement  uses a ">" very close to your filename
    #and if it somehow overwrites
    #your files dont blame me! I have tested it and it *shouldnt*
    #overwrite.
done
