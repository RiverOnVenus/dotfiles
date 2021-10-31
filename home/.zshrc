eval "$(starship init zsh)"

##在命令前插入 sudo {{{
#定义功能
sudo-command-line() {
[[ -z $BUFFER ]] && zle up-history
[[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
zle end-of-line                 #光标移动到行末
}
zle -N sudo-command-line
#定义快捷键为： [Esc] [Esc]
bindkey "\e\e" sudo-command-line
#}}}

man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}
#命令别名 {{{
  #alias vim='nvim'
  alias diff= 'diff --color=auto'
  alias kill='kill -9'
  alias ls='ls -F --color=auto'
  alias Syu='sudo pacman -Syu'
  alias Syyu='sudo pacman -Syyu'
#}}}

#关于历史纪录的配置 {{{
#历史纪录条目数量
export HISTSIZE=1000
#注销后保存的历史纪录条目数量
export SAVEHIST=1000
#历史纪录文件
export HISTFILE=~/.zhistory
#以附加的方式写入历史纪录
setopt INC_APPEND_HISTORY
#如果连续输入的命令相同，历史纪录中只保留一个
setopt HIST_IGNORE_DUPS
#为历史纪录中的命令添加时间戳
setopt EXTENDED_HISTORY      

#启用 cd 命令的历史纪录，cd -[TAB]进入历史路径
setopt AUTO_PUSHD
#相同的历史路径只保留一个
setopt PUSHD_IGNORE_DUPS

#在命令前添加空格，不将此命令添加到纪录文件中
#setopt HIST_IGNORE_SPACE
#}}}


#每个目录使用独立的历史纪录{{{
cd() {
builtin cd "$@"                             # do actual cd
fc -W                                       # write current history  file
local HISTDIR="$HOME/.zsh_history$PWD"      # use nested folders for history
if  [ ! -d "$HISTDIR" ] ; then          # create folder if needed
mkdir -p "$HISTDIR"
fi
export HISTFILE="$HISTDIR/zhistory"     # set new history file
touch $HISTFILE
local ohistsize=$HISTSIZE
HISTSIZE=0                              # Discard previous dir's history
HISTSIZE=$ohistsize                     # Prepare for new dir's history
fc -R                                       #read from current histfile
}
mkdir -p $HOME/.zsh_history$PWD
export HISTFILE="$HOME/.zsh_history$PWD/zhistory"

function allhistory { cat $(find $HOME/.zsh_history -name zhistory) }
function convhistory {
sort $1 | uniq |
sed 's/^:\([ 0-9]*\):[0-9]*;\(.*\)/\1::::::\2/' |
awk -F"::::::" '{ $1=strftime("%Y-%m-%d %T",$1) "|"; print }'
}
#使用 histall 命令查看全部历史纪录
function histall { convhistory =(allhistory) |
sed '/^.\{20\} *cd/i\\' }
#使用 hist 查看当前目录历史纪录
function hist { convhistory $HISTFILE }

#全部历史纪录 top50
function top50 { allhistory | awk -F':[ 0-9]*:[0-9]*;' '{ $1="" ; print }' | sed 's/ /\n/g' | sed '/^$/d' | sort | uniq -c | sort -nr | head -n 50 }

#}}}

#命令高亮界面
# setopt extended_glob
#  TOKENS_FOLLOWED_BY_COMMANDS=('|' '||' ';' '&' '&&' 'sudo' 'do' 'time' 'strace')
# 
#  recolor-cmd() {
#      region_highlight=()
#      colorize=true
#      start_pos=0
#      for arg in ${(z)BUFFER}; do
#          ((start_pos+=${#BUFFER[$start_pos+1,-1]}-${#${BUFFER[$start_pos+1,-1]## #}}))
#          ((end_pos=$start_pos+${#arg}))
#          if $colorize; then
#              colorize=false
#              res=$(LC_ALL=C builtin type $arg 2>/dev/null)
#              case $res in
#                  *'reserved word'*)   style="fg=magenta,bold";;
#                  *'alias for'*)       style="fg=cyan,bold";;
#                  *'shell builtin'*)   style="fg=yellow,bold";;
#                  *'shell function'*)  style='fg=green,bold';;
#                  *"$arg is"*)
#                      [[ $arg = 'sudo' ]] && style="fg=red,bold" || style="fg=blue,bold";;
#                  *)                   style='none,bold';;
#              esac
#              region_highlight+=("$start_pos $end_pos $style")
#          fi
#          [[ ${${TOKENS_FOLLOWED_BY_COMMANDS[(r)${arg//|/\|}]}:+yes} = 'yes' ]] && colorize=true
#          start_pos=$end_pos
#      done
#  }
#  check-cmd-self-insert() { zle .self-insert && recolor-cmd }
#  check-cmd-backward-delete-char() { zle .backward-delete-char && recolor-cmd }
# 
#  zle -N self-insert check-cmd-self-insert
#  zle -N backward-delete-char check-cmd-backward-delete-char

 # git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# git clone git://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
