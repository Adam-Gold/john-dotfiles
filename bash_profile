function yalla {
        perl -i -n -e "print unless (\$. == $1)" ~/.ssh/known_hosts;
}

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
#alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

function whatismyip () {
    curl http://ipv4.icanhazip.com
}

function google () {
    u=`perl -MURI::Escape -wle 'print "http://google.com/search?q=".
    uri_escape(join " ",  @ARGV)' $@`
    w3m -no-mouse -F $u
}

function scpan () {
    u=`perl -MURI::Escape -wle 'print "http://search.cpan.org/search?query=".
        uri_escape(join " ",  @ARGV) ."&mode=module&n=100"' $@`

    w3m -no-mouse -F $u
}

function hostip () {
    grep $1 /etc/hosts | awk '{print $1}'
}

function cp_p() {
    pv < $1 > $2;
}

#function scp(){ if [[ "$@" =~ : ]];then /usr/bin/scp $@ ; else echo 'stupid colon...'; fi;} # Catch a common scp mistake.

function phplog() {
    perl -nle'$_=~ s/\\n/\n/g; $_=~ s/\\t/\t/g; print $_'
}

function calc() {
    awk "BEGIN{ print $* }"
}

complete -C perldoc-complete -o nospace -o default pod

function maxmem() {
    TR=`free|grep Mem:|awk '{print $2}'`
    /bin/ps axo rss,comm,pid|awk -v tr=$TR '{proc_list[$2]+=$1;} END {for (proc in proc_list) {proc_pct=(proc_list[proc]/tr)*100; printf("%d\t%-16s\t%0.2f%\n",proc_list[proc],proc,proc_pct);}}'|sort -n |tail -n 20|tac
}

function conns() {
    netstat -an | grep ESTABLISHED | awk '{print $5}' | awk -F: '{print $1}' | sort | uniq -c | awk '{ printf("%s\t%s\t",$2,$1); for (i = 0; i < $1; i++) {printf("*")}; print ""}' | sort -nk 2
}

function strace_read() {
    strace -ff -e write=1,2 -s 1024 -p $1  2>&1 | grep "^ |" | cut -c11-60 | sed -e 's/ //g' | xxd -r -p
}

function screencast() {
    ffmpeg -f alsa -ac 2 -i hw:0,0 -f x11grab -r 30 -s $(xwininfo -root | grep 'geometry' | awk '{print $2;}') -i :0.0 -acodec pcm_s16le -vcodec libx264 -vpre lossless_ultrafast -threads 0 -y $1
}

function noproxy() { unset http_proxy https_proxy ftp_proxy all_proxy no_proxy; }

function isproxy() {
    echo Test if sap proxy defined in env:
    env | grep -i proxy | sed 's/^/  /'
}

function tail_timestamp() { tail -f $* | while read line; do echo -n $(date -u -Ins); echo -e "\t$line"; done;  }

function fstrace() { strace -ff -e trace=file $1 2>&1 | perl -ne 's/^[^"]+"(([^\\"]|\\[\\"nt])*)".*/$1/ && print'; }

function makepass32() { 
    python -c "from random import choice; print ''.join([choice('abcdefghijklmnopqrstuvwxyz0123456789%^*(-_=+)') for i in range(32)])"
}

function makepass16() { 
    python -c "from random import choice; print ''.join([choice('abcdefghijklmnopqrstuvwxyz0123456789%^*(-_=+)') for i in range(16)])"
}

function makepass8() { 
    python -c "from random import choice; print ''.join([choice('abcdefghijklmnopqrstuvwxyz0123456789%^*(-_=+)') for i in range(8)])"
}
# Easily extract all compressed file types
extract () {
   if [ -f "$1" ] ; then
       case $1 in
           *.tar.bz2)   tar xvjf -- "$1"    ;;
           *.tar.gz)    tar xvzf -- "$1"    ;;
           *.bz2)       bunzip2 -- "$1"     ;;
           *.rar)       unrar x -- "$1"     ;;
           *.gz)        gunzip -- "$1"      ;;
           *.tar)       tar xvf -- "$1"     ;;
           *.tbz2)      tar xvjf -- "$1"    ;;
           *.tgz)       tar xvzf -- "$1"    ;;
           *.zip)       unzip -- "$1"       ;;
           *.Z)         uncompress -- "$1"  ;;
           *.7z)        7z x -- "$1"        ;;
           *)           echo "don't know how to extract '$1'..." ;;
       esac
   else
       echo "'$1' is not a valid file"
   fi
}

# Get weather data for Bristol
# You need to register at
# http://www.wunderground.com/weather/api/d/login.html
# to get an API key
weather() {
    key=
    echo Tel Aviv:
    echo ''
    data=$(curl -s "http://api.wunderground.com/api/$key/forecast/q/israel/Tel_Aviv.json" | jq -r ['.forecast.txt_forecast.forecastday[] | [.title], [.fcttext], ["break"] | .[]'])
    echo $data | sed -e 's/[,]/\n/g' -e 's/[]"]/''/g' -e 's/[[]/''/g' -e 's/break/\n/g'
}

# Define a word using collinsdictionary.com
define() {
  curl -s "http://www.collinsdictionary.com/dictionary/english/$*" | sed -n '/class="def"/p' | awk '{gsub(/.*<span class="def">|<\/span>.*/,"");print}' | sed "s/<[^>]\+>//g";
}

# Epoch time conversion
epoch() {
  TESTREG="[\d{10}]"
  if [[ "$1" =~ $TESTREG ]]; then
    # is epoch
    date -d @$*
  else
    # is date
    if [ $# -gt 0 ]; then
      date +%s --date="$*"
    else
      date +%s
    fi
  fi
}

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

if [ -f /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh ]; then
    . /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh
fi

if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

[ -f /usr/local/lib/node_modules/yo/node_modules/tabtab/.completions/yo.bash ] && . /usr/local/lib/node_modules/yo/node_modules/tabtab/.completions/yo.bash

[[ -x "$(which aws_completer)" ]] && complete -C "$(which aws_completer)" aws

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export GREP_OPTIONS='--color=auto'
export JAVA_HOME="$(/usr/libexec/java_home)"
export GROOVY_HOME=/usr/local/opt/groovysdk/libexec
#export GOPATH=/opt/golang
#export GOROOT=/usr/local/opt/go/libexec

. ~/.git_term
. ~/.aliases
. ~/.openrc
#source <(kubectl completion bash)
#source <(minikube completion bash)
#/usr/local/bin/archey -c
#eval $(thefuck --alias)
eval $(keychain --eval --agents ssh -Q /Users/adam/.ssh/id_rsa)

source ~/.profile
export PATH="/usr/local/opt/openssl/bin:$PATH"
