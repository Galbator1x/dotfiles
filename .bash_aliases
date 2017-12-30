alias p='sudo sh pycharm.sh'
alias i='sudo sh idea.sh'

alias sorti='isort -rc .'
alias y='yandex-disk'

alias va='source ../activate'
alias pm='python manage.py'
alias pmr='python manage.py runserver'
alias pmm='python manage.py migrate'
alias pmmk='python manage.py makemigrations'
alias pmu='python manage.py upgrade'
alias pmuser='python manage.py createsuperuser'

alias dm='docker-machine'

alias kkpdbreset='rm db.sqlite3 && rm -rf problem_solver/migrations/ && pmm && pmmk problem_solver && pmm'

alias cd1='cd ..'
alias cd2='cd ../../'
alias cd3='cd ../../../'
alias cdp='cd ~/projects/'
alias cdd='cd ~/projects/devman/'
alias cddot='cd ~/projects/dotfiles/'
alias cdmkv='cd ~/Videos/mkv/'
alias cdkkp='cd ~/projects/kkp/ && workon kkp'
alias cdrun='cd ~/projects/running_delivery/running/ && workon running'
alias cded='cd ~/projects/edstein/'
alias cdg='cd ~/projects/thegame/'

alias pstart='sudo /etc/init.d/postgresql start'
alias pstop='sudo /etc/init.d/postgresql stop'
alias prestart='sudo /etc/init.d/postgresql restart'
alias pstatus='sudo /etc/init.d/postgresql status'
alias pshell='sudo -u postgres psql'

alias cl='clear'
alias gs='git status'
alias ga='git add'
alias gb='git branch'
alias gc='git commit -m'
alias gp='git push'
alias gpu='git push --set-upstream origin'
alias gph='git push heroku master'
alias gd='git diff'
alias go='git checkout'
alias gk='gitk --all&'
alias gx='gitx --all'
alias gh='git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'

