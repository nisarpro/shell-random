# Tested 2016-01-30 on Windows 10, updated recently
# git version 2.7.0.windows.1
# GNU bash, version 4.3.42(5)-release (x86_64-pc-msys)


alias  ls='\ls  -1  --all  --classify  --color=auto  --show-control-chars  -X'

# World of Warcraft
alias  addons='\cd  /d/live/World_of_Warcraft/_dotfiles/Interface/AddOns'
alias     wow='\cd  /d/live/World_of_Warcraft'



# --
# --  Windows console applications
# --


# Nano, text editor
# https://coderwall.com/p/ee-law/use-nano-from-git-bash-on-windows-d
# http://vijayparsi.wordpress.com/2012/03/07/nano-with-mingw32-for-msysgit/
#   \curl -L -O http://www.nano-editor.org/dist/v2.2/NT/nano-2.2.6.zip
# It doesn't work on this present 64-bit setup
#alias  nano="${GIT_DIRECTORY}/bin/nano/nano.exe  --autoindent  --nowrap  --tabsize=2  --tabstospaces"

# Fdupes, duplicate file checker/deleter
# TODO
alias  fdupes="${GIT_DIRECTORY}/bin/fdupes.exe"

# Tortoise, thingy TODO
# http://tortoisesvn.net/downloads.html
alias  svn="${PF}/TortoiseSVN/bin/svn.exe"

# Mercurial, version control
# http://mercurial.selenic.com/wiki/Download
alias  hg="${PF}/\TortoiseHg/hg.exe"

# Midnight Commander, file thingy
# http://www.midnight-commander.org/
# http://sourceforge.net/projects/mcwin32/
alias  mc="${PFx}/Midnight Commander/mc.exe"

# 7zip compression, filename.7z
# http://www.7-zip.org/
alias  7z="${PF}/7-Zip/7z.exe"

alias  rename='${shell_random}/live/rename.pl'

alias  rsync='${GIT_DIRECTORY}/bin/cwRsync/rsync.exe'



# --
# --  Windows GUI applications
# --

geany() {
  "${PFx}/Geany/bin/geany.exe"  $* &
}
