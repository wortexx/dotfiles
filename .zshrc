# -*- mode: sh; mode: fold -*-
# zsh configuration (c) 2003-2005 piranha
# thanx to smax, "XAKEP" journal and google.com

export LANG=ru_RU.koi8r
export LC_TIME=C
export LC_NUMERIC=C

stty pass8

unlimit 
limit stack 8192
limit core 0
limit -s

umask 026

export EDITOR="vim"
export PAGER="most"
export PATH=~/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:/opt/kde/bin
export LESS="-R"
export PERL5LIB=${PERL5LIB:+$PERL5LIB:}$HOME/perl
#export MANPATH=/usr/local/man:$HOME/man

# Prompt setup (c) smax 2002, adapted for zsh (c) piranha 2004
# 0-black, 1-red, 2-green, 3-yellow, 4-blue, 5-magenta 6-cyan, 7-white
C() { echo '%{\033[3'$1'm%}'; }
hc=`C 6`; wc=`C 3`; tc=`C 7`; w=`C 7`; n=`C 9`
[ $UID = 0 ] && at=`C 1`%B'#'%b || at=$w'@'
PS1="$at$hc%m $wc%~$w>$n"
unset n b C uc hc wc tc tty at

typeset -U path cdpath fpath manpath

# History
HISTFILE=~/.zhistory
HISTSIZE=1000
SAVEHIST=1000
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt autocd

# Клава
bindkey -e
bindkey "[2~" transpose-words
bindkey "[3~" delete-char
bindkey "[1~" beginning-of-line
bindkey "[4~" end-of-line
bindkey "[A" up-line-or-history
bindkey "[B" down-line-or-history

# Заголовок xterm
case $TERM in
xterm*)
  precmd () {
    print -Pn "\033]0;%n@%M (%y) - %/\a"
    print -Pn "\033]1;%n@%m (tty%l)\a"
  }
  preexec () {
    print -Pn "\033]0;%n@%M (%y) - %/ - ($1)\a"
    print -Pn "\033]1;%n@%m (tty%l)\a"
  }
;;
esac

######## Completition #######
hostsmy=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*})
#???#zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z} r:|[._-]=* r:|=*' 'm:{a-zA-Z}={A-Za-z} r:|[._-]=* r:|=*' 'm:{a-zA-Z}={A-Za-z} r:|[._-]=* r:|=*' 'm:{a-zA-Z}={A-Za-z} r:|[._-]=* r:|=*'
zstyle ':completion:*' max-errors 2
zstyle :compinstall filename '.zshrc'

compctl -o wget make man rpm iptables
compctl -k hostsmy ssh telnet ping mtr traceroute
compctl -j -P "%" kill
compctl -g '*.gz' + -g '*(-/)' gunzip gzcat
compctl -g '*.rar' + -g '*(-/)' rar unrar
compctl -g '*(-*)' + -g '*(-/)' strip
compctl -g '*.ps *.eps' + -g '*(-/)' gs ghostview psnup psduplex ps2ascii
compctl -g '*.dvi' + -g '*(-/)' xdvi dvips
compctl -g '*.xpm *.xpm.gz' + -g '*(-/)' xpmroot sxpm pixmap xpmtoppm
compctl -g '*.fig' + -g '*(-/)' xfig
compctl -g '*(-/) .*(-/)' cd
compctl -g '(^(*.o|*.class|*.jar|*.gz|*.gif|*.a|*.Z|*.bz2))' + -g '.*' less vim
compctl -g '*.pkg.tar.gz' pacman
#compctl -g '*' + -g '.*' vim
#compctl -g '*.html' + -g '*(-/)' appletviewer

autoload -U compinit
compinit
# End of lines added by compinstall

# archieved mail
#arch=( $(ls ~archiver/Mail/)  )
#ma() { mutt -f ~archiver/Mail/$1 }
#compctl -k arch ma

# Поиск файла по шаблону:
function ff() { find . -type f -iname '*'$*'*' -ls ; }

# поиск строки по файлам:
function fstr()
{
    OPTIND=1
    local case=""
    local usage="fstr: поиск строки в файлах.
Порядок использования: fstr [-i] \"шаблон\" [\"шаблон_имени_файла\"] "
    while getopts :it opt
    do
        case "$opt" in
        i) case="-i " ;;
        *) echo "$usage"; return;;
        esac
    done
    shift $(( $OPTIND - 1 ))
    if [ "$#" -lt 1 ]; then
        echo "$usage"
        return;
    fi
    local SMSO=$(tput smso)
    local RMSO=$(tput rmso)
    find . -type f -name "${2:-*}" -print0 | xargs -0 grep -sn ${case} "$1" 2>&- | \
#    sed "s/$1/${SMSO}\0${RMSO}/gI" | more
sed "s/$1/${SMSO}\0${RMSO}/g" | more
}

# перевести имя файла в нижний регистр
function lowercase()
{
    for file ; do
        filename=${file##*/}
        case "$filename" in
		*/*) dirname==${file%/*} ;;
		*) dirname=.;;
        esac
        nf=$(echo $filename | tr A-Z a-z)
        newname="${dirname}/${nf}"
        if [ "$nf" != "$filename" ]; then
            mv "$file" "$newname"
            echo "lowercase: $file --> $newname"
        else
            echo "lowercase: имя файла $file не было изменено."
        fi
    done
}

isomake()
{
	if [ -z "$1" ]; then
		echo "isomake: первый параметр - имя выходного iso-файла"
		echo "isomake: второй параметр - имя входной диры/файла"
	else
		mkisofs -v -J -r -o $1 $2
	fi
}

#############        ALIASES         ###############
# Nocorrect
#alias mv="nocorrect mv"
#alias cp="nocorrect cp"
alias mkdir="nocorrect mkdir"

# Recode aliases
alias w2k="iconv -c -f cp1251 -t koi8-r"
alias k2w="iconv -c -f koi8-r -t cp1251"
alias u2k="iconv -c -f utf-8 -t koi8-r"
alias k2u="iconv -c -f koi8-r -t utf-8"
alias U2k="iconv -c -f utf-16 -t koi8-r"
alias k2U="iconv -c -f koi8-r -t utf-16"

# Misc
alias grep="egrep"
alias m="mutt"
alias nroff="nroff -Tlatin1"
alias mc="mc -acx"
alias ss="sudo -s"
alias ftp="lftp"
alias sr="screen -D -r"
alias ls="/bin/ls --color"
alias ll="/bin/ls --color -lh"
alias la="/bin/ls --color -lA"
alias lsd="/bin/ls --color -ld *(-/DN)"
alias lsa="/bin/ls --color -ld .*"
alias l="most"
alias g="egrep"
alias c="cat"
alias h="head"
alias t="tail"
alias p="ping"
alias tt="/usr/sbin/traceroute"
alias df="df -h"
alias bc="bc -l"
alias w="w|sort"
alias cad="ssh -l door -p 2222 gw.cad"
alias rtin="~/bin/rtin -qd"
alias e="jed"
