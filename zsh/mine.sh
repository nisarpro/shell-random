# TODO:  rename this file.  Move it into lib.sh?

rmln() {
  # TODO:  Sanity checking
  rmln_target=`basename $1`
  echo $rmln_target
  \rm --interactive=once --recursive --verbose $rmln_target
  \ln --symbolic --verbose $1 .
}


# 1.tar.bz2 => tar.bz2 (good, but...)
#   it also does 1.test.test.tar.bz2 => test.test.tar.bz2 (bad idea!)
# EXT=${AUTOTEST_FILE#*.}
# 1.tar.bz2 => bz2 (better!)
# Is this problematic code for other shells?
#EXT=${AUTOTEST_FILE##*.}


# TODO - count the number of files in subdirectories.
# TODO - count the number of subdirectories.
# TODO - count the number of symlinks.
# TODO - count the number of hard links.
# TODO - Use printf and a fixed field width instead of using tabs?
#        Or can I set where the first tab stop is?
# FIXME - `du` fails when doing something like `c foo*` where one of the directories of foo* has a space in it.
c() {
  c_count() {
    local count=$( \ls -1 "$1" | \wc -l )
    local count=$( comma $count )
    \echo $count
  }
  c_size() {
    # The size of those files (and subdirectories - FIXME)
    local size="$( \du --bytes --summarize \"$1\" )"
    # Everything before the space.
    # I don't know why I can't make this ${ ${ and it must be ${${
    local size=${$( \echo "$size" )[1]}
    local size=$( comma $size )
    \echo $size
  }
  c_samecheck(){
    if [ $1 == $2 ]; then
      #\echo "  same"
    else
      \echo "  DIFFERENT"
    fi
  }

  if [ -z $1 ]; then
    local count=$(c_count ./)
    \echo "$count files."

    local size=$(c_size ./)
    \echo "$size bytes."
  elif [ -z $2 ]; then
    echo "For $1"

    local count=$(c_count "$1")
    \echo "$count files."

    local size=$(c_size $1)
    \echo "$size bytes."
  elif ! [ -z $2 ]; then
    local count_one=$(c_count "$1")
    local count_two=$(c_count "$2")
    \echo "Files:"
    \echo -e "  $1: \t $count_one"
    \echo -e "  $2: \t $count_two"
    c_samecheck $count_one $count_two

    \echo

    local size_one=$(c_size "$1")
    local size_two=$(c_size "$2")
    \echo "Size:"
    \echo -e "  $1: \t $size_one"
    \echo -e "  $2: \t $size_two"
    c_samecheck $size_one $size_two
  fi
}

edit() {
  # I'm in X, I'm at the raw console and X is launched.
  \geany --new-instance $@ > /dev/null 2>&1
  if [ "$?" != "0" ]; then
    # X is not launched at all.  It might be sitting at the login screen though.
    \mcedit --colors editnormal=lightgrey,black $@
  fi
}
alias mcedit="\mcedit --colors editnormal=lightgrey,black"


# TODO: implement 'global' with find
# or just do (zsh):
# For directories:  **/
# For files:  **
# This doesn't work..
#global() {
  #if [ x$1 = x ]; then return 0; fi
  #for i in *; do
    #$@
  #done
#}
global() {
  echo "use **"
}
globaldirs() {
  echo "use **/"
}
#globaldirs() {
  #EXEC="$@"
  #EXEC=(${=EXEC})
  #echo $EXEC
  #for globaldirs in **/; do
    #cd "$globaldirs"
    ##echo $EXEC
    #cd -
  #done
#}



# TODO: Change directory and don't bother requiring double-quotes in the string..
#cd() {
#  # This isn't working..
#  dir=${*:gs/~/\\\\~/}
#  builtin cd "$dir"
#}
# ccd() {
# a="$@"
# echo $a
# # b=${a:gs/ /\\\\ /}
# b=${(q)a}
# echo $b
#   \cd $b
# }

# Find and enter the highest numbered directory
# FIXME - this doesn't work to go to 0.0.99 instead of 0.0.1
cdv() {
  if [ ! "x$1" = "x" ]; then
    # TODO: Sanity-check on $1 (a directory, exists, whatever)
    \cd "$1"
  fi
  # Translation:  Only directories | only n.n.n format | remove trailing slash.| only the last entry
  \cd `\ls -1d */ | \grep '[0-9]*\.[0-9]*\.[0-9]' | \sed 's/\///' | \tail -n 1`
}

NOWAY-umount() {
  if [ "$#" = "0" ] || [ "$1" = "--help" ]; then
    /bin/umount "$@"
  else
    # TODO: Maybe there's a way for me to capture the output into a HEREDOC?  That would be far cleaner.
    # Run it, being hopeful.
    /usr/bin/umount-root "$@" >/dev/null 2>&1
    if [ ! "$?" = "0" ]; then
      # If it errored out, run it again but see the error this time.
      /usr/bin/umount-root "$@"
    fi
  fi
}

# Make and change into a directory:
mcd() { \mkdir "$1" && \cd "$1" ; }

# A proper dir command!
# dir() { /bin/ls --color -gGh "$@"|cut -d" " -f4-100 ; }
# dir() { \ls --color -gGh "$@" | \cut -b14- | \less -F -r ; }
# Challenges:
# 1) Don't display a size for directories.
# TODO: -R does funny things.  Catch if it's been sent (even with -AR) and deal with it specially?
# Note that $LESS will influence the display.
dir() {
  if [ "x$1" = "x-d" ] || [ "x$1" = "x-ad" ]; then
    ddir
    return $?
  fi
  file_sizes=
  file_sizes_commas=
  file_sizes_width=
  ls_options="-g --no-group -l --numeric-uid-gid -v --color --group-directories-first ${@}"
  # FIXME: Why is the first file size left-aligned?
  # IDEA: Only display files.  I'd have to adapt the `find` code from ddir.

  # This will sort dotfiles above regular files.  Lubuntu 10.10 .. at first I needed it and now I don't.  Hrm.
  # export LANG="C"
# FUCK, fixme - doesn't work with stuff with spaces in it, or with directories with a space in them?  Or maybe directories with not much stuff in them..
  file_sizes=$(
    \ls $ls_options \
      | \cut -b15- \
      | \cut -d"-" -f1 \
      | \rev \
      | \cut -b6- \
      | \sed -e 's/ //g' \
      | \rev
  )
  file_sizes_commas=comma($file_sizes)
  file_sizes_width=$(
    \ls $ls_options \
      | \cut -b15- \
      | \cut -d"-" -f1 \
      | \rev \
      | \cut -b6- \
      | \sed -e 's/ //g' \
      | \rev \
      | \sort -g \
      | \sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;ta' \
      | \tail -n 1
  )
  file_sizes_width=${#file_sizes_width}
read -d '' file_sizes <<EOF
$(
  # Intentionally not in quotes.
  for i in $file_sizes_commas; do
    printf "%${file_sizes_width}s\n" "$i"
  done
)
EOF

  file_names=$(
    \ls $ls_options \
      | \cut -b15- \
      | \cut -d":" -f2- \
      | \cut -b4- \
      | sed '1d'
  )
  # Yay for process substitution!  This puts the two columns side-by-side.
  \paste <( \printf '%s' "$file_sizes") <( \printf '%s' "$file_names") | \less --raw-control-chars --HILITE-UNREAD --QUIT-AT-EOF


#echo "$new_file_sizes"
}


# DOS-style `dir /ad`
ddir() {
  OLD_LANG="$LANG"
  export LANG="C"
  \ls -1d --indicator none --color $(
    find -maxdepth 1 -type d \
      ! -name .
  ) \
  | \sort \
  | \sed -e 's/\.\///' \
  | \less -r
  export LANG="$OLD_LANG"
  OLD_LANG=
}


# File/Directory-finding helpers.  Saves keystrokes.
# uses grep to colour.
findfile() {
  # TODO: parameter-sanity
  \find -type f -iname \*"$1"\* |\
  \sed 's/^/"/'|\
  \sed 's/$/"/' |\
  \grep --colour=always -i "$1"
}
# A more simple version of it, so that it can be used with pipes and such.  For example:
#   findfile2 "worry be happy"|xargs deadbeef -queue
findfile2() {
  # TODO: parameter-sanity
  \find -type f -iname \*"$1"\* |\
  \sed 's/^/"/'|\
  \sed 's/$/"/' |\
  \grep --colour=never -i "$1"
}
finddir()  {
  # TODO: parameter-sanity
  \find -type d -iname \*"$1"\* |\
  \sed 's/^/"/'|\
  \sed 's/$/"/' |\
  \grep --colour=always -i "$1"
}
findin() {
  # TODO: parameter-sanity
  if [ "x$1" = "x" ]; then
    \echo "Give a filename, or * to search through all files."
  elif [ "x$1" = "x*" ]; then
    \find -type f -iname \*"$1"\* -print0 |\
      \xargs -r0 \
      \grep --colour=always -Fi -e "$2"
  else
    # TODO
    \echo "TODO"
  fi
}
# TODO: parameter-sanity?
findinall() { findin '*' $1 ; }

findplay() {
  # TODO: parameter-sanity
  \findfile2 "$1" |\
  \head --lines 1 |\
  \xargs --no-run-if-empty deadbeef &
}
# This is seriously limited.
# \find -type f -iname \*"the gathering"\* | \sed 's/^/"/'| \sed 's/$/"/' | \tr -d '\n' | \sed 's/""/" "/g' | \xargs -P0 -s99999 deadbeef --queue
#  failed to add file or folder ëî
# There is some sort of limitation to the number of items which can be processed.  I thought xargs solved that.  I don't understand... deadbeef has no queue limitation, so there must be something else.
findqueue() {
  # TODO: parameter-sanity
  \findfile2 "$1" |\
  \xargs --no-run-if-empty deadbeef --queue &
}
#
# TODO: randomplay
# TODO: findqueue, but shuffled


# TODO: Do I actually use this anywhere?
# if a file exists, act on it.
# warning: Your command won't prompt!  (so rm will nuke files)
ifexists() {
  if [ -a "$2" ]; then
    "$1" "$2"
  fi
}

searchstring() {
  unset searchstring_success
  until [ "sky" = "falling" ]; do
  # 2 parameters, no blanks, first parameter  must be one character.
  if [ ! "$#" -eq 2 ] || [ "$1" = "" ] || [ "$2" = "" ] || [ `expr length $1` -gt 1 ]; then echo "Needs two parameters: a character, and a string"; break ; fi
  character="$1"
  string="$2"
  # Iterate through the string.
  for i in $(seq 0 $((${#string} - 1))); do
    # Checking that location in the string, see if the character matches.
    # I should convert this into an 'until' so it makes sense to me, and it halts on the first success.
    if [ "${string:$i:1}" = "$character" ]; then searchstring_success=$i ; fi
  done
  if [ ! "$searchstring_success" = "" ]; then echo $searchstring_success ; else echo "-1" ; fi
  break
  done
}

searchstring_right_l() {
  unset searchstring_success
  until [ "sky" = "falling" ]; do
  # 2 parameters, no blanks, first parameter  must be one character.
  if [ ! "$#" -eq 2 ] || [ "$1" = "" ] || [ "$2" = "" ] || [ `expr length $1` -gt 1 ]; then echo "Needs two parameters: a character, and a string"; break ; fi
  character="$1"
  string="$2"

  position=0
  length=${#string}
  until [ $length = -1 ]; do
    if [ "${string:$length:1}" = "$character" ]; then searchstring_success=$length ; fi
    ((position++))
    ((length--))
  done
  if [ ! "$searchstring_success" = "" ]; then echo $searchstring_success ; else echo "-1" ; fi
  break
  done
}

searchstring_right_r() {
  unset searchstring_success
  until [ "sky" = "falling" ]; do
  # 2 parameters, no blanks, first parameter  must be one character.
  if [ ! "$#" -eq 2 ] || [ "$1" = "" ] || [ "$2" = "" ] || [ `expr length $1` -gt 1 ]; then echo "Needs two parameters: a character, and a string"; break ; fi
  character="$1"
  string="$2"
  position=0
  length=${#string}
  until [ $length = -1 ]; do
    if [ "${string:$length:1}" = "$character" ]; then searchstring_success=$position ; fi
    ((position++))
    ((length--))
  done
  if [ ! "$searchstring_success" = "" ]; then echo $searchstring_success ; else echo "-1" ; fi
  break
  done
}

divide() {
  # Just simple for now.  Elsewhere I have more complex code that's more thorough
  isnumber() {
    if expr $1 + 1 &> /dev/null ; then
      echo "0"
    else
      echo "1"
    fi
  }

  # Since "exit" also exits xterm, I do this to allow "break" to end this procedure.
  until [ "sky" = "falling" ]; do
  if [ ! "$#" -eq 2 ] || [ "$1" = "" ] || [ "$2" = "" ] ; then echo "Needs two parameters"; break ; fi
  if [ ! `isnumber $1` -eq 0 ] || [ ! `isnumber $2` -eq 0 ] ; then echo "Needs two numbers"; break; fi

  left=$1
  right=$2
  answer_left=$(( $left / $right ))

  # TODO: Allow a third input to specify the number of places to give (the number of 0s)
  # TODO: Or, allow notation like divide 1 2.12345 and detect the number of places after the dot.
  #   With that, I'd have to convert the string into numbers and remove the decimal for bash to work with.  Too much math for me.  =)
  # The number of 0s is the number of places displayed after the decimal.
  left=$(( $left * 100 ))
  answer_right=$(( $left / $right ))
  # clean up $answer_left from the beginning of $answer_right
  answer_right=${answer_right#*$answer_left}

  # Add a dot.  Must be combined into a variable otherwise the final echo won't work.
  echo $answer_left"."$answer_right

break
done
}

position_from_right_to_left() {
  until [ "sky" = "falling" ]; do
  if [ ! "$#" -eq 2 ] || [ "$1" = "" ] || [ "$2" = "" ]; then echo "Needs two parameters: a string and a number"; break ; fi
  expr $2 + 1 &> /dev/null ; result=$?
  if [ $result -ne 0 ]; then echo $2 is not a number. ; break ; fi
  string=$1
  position=$2
  length=${#string}
  iteration=0
  until [ $length -eq $position ]; do
    ((iteration++))
    ((length--))
  done
  echo $iteration
  break
  done
}

insert_character() {
  unset searchstring_success
  until [ "sky" = "falling" ]; do
  # 2 parameters, no blanks, first parameter  must be one character.
  if [ ! "$#" -eq 3 ] || [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ] || [ `expr length $1` -gt 1 ]; then echo "Needs three parameters: a character, a string and a position"; break ; fi
  expr $3 + 1 &> /dev/null ; result=$?
  if [ $result -ne 0 ]; then echo $3 is not a number. ; break ; fi
  character="$1"
  string="$2"
  position="$3"
  length=${#string}
  i=0
  unset newstring
  until [ $i -eq $length ]; do
    newstring=$newstring${string:$i:1}
    ((i++))
    if [ $i -eq $position ]; then newstring=$newstring$character ; fi
  done
  echo $newstring

  break
  done
}

replace_character() {
  unset searchstring_success
  until [ "sky" = "falling" ]; do
  # 2 parameters, no blanks, first parameter  must be one character.
  if [ ! "$#" -eq 3 ] || [ "$1" = "" ] || [ "$2" = "" ] || [ "$3" = "" ] || [ `expr length $1` -gt 1 ]; then echo "Needs three parameters: a character, a string and a position"; break ; fi
  expr $3 + 1 &> /dev/null ; result=$?
  if [ $result -ne 0 ]; then echo $3 is not a number. ; break ; fi
  character="$1"
  string="$2"
  position="$3"
  length=${#string}
  i=0
  unset newstring
  until [ $i -eq $length ]; do
    if [ $i -eq $position ]; then
      newstring=$newstring$character
    else
      newstring=$newstring${string:$i:1}
    fi
    ((i++))
  done
  echo $newstring

  break
  done
}


multiply() {
  until [ "sky" = "falling" ]; do
    if [ ! "$#" -eq 2 ] || [ "$1" = "" ] || [ "$2" = "" ] ; then echo "Needs two parameters"; break ; fi
    if [ ! `isnumber $1` -eq 0 ] || [ ! `isnumber $2` -eq 0 ] ; then echo "Needs two numbers"; break; fi
    a=$1
    b=$2

    # remove the . from either.
    a_nodot=${a//./""}
    b_nodot=${b//./""}

    # Multiply the decimal-less numbers together:
    sum=$(( $a_nodot * $b_nodot ))

    # Learn the position of "." in each.
    a_dotloc=`searchstring_right_r "." $a`
    b_dotloc=`searchstring_right_r "." $b`

    # Add one to it, to get its position in human terms.
    # If there was no dot (-1) then make it 0.
    if [ $a_dotloc -gt "-1" ]; then ((a_dotloc--)) ; else a_dotloc=0 ; fi
    if [ $b_dotloc -gt "-1" ]; then ((b_dotloc--)) ; else b_dotloc=0 ; fi

    # add the two positions of "." together
    dotloc=$(( $a_dotloc + $b_dotloc ))

    # insert "." into $sum
    # But first I must learn the proper insertion location.  Convert from from-right to the standard from-left.
    dotloc=`position_from_right_to_left $sum $dotloc`

    # insert a "." into $sum, but not at the end
    if [ $dotloc -ne ${#sum} ]; then sum=`insert_character "." "$sum" $dotloc` ; fi

    echo $sum
  break
  done
}

# TODO:  Is this working?
# - rm should be smarter, and remove directories too.  Check if a directory and then just use rmdir.  =p
# -- Auto-remove empty directories (with no subdirectories)
rm() {
  # Be aware that if you alias rm, it'll muck this up.
#   echo "$#"
  if [ "$#" = "1" ] && [ -d "$1" ]; then
#     \rmdir --ignore-fail-on-non-empty "$1"
    \rmdir -v "$1"
  else
    /bin/rm -i "$@"
  fi
}