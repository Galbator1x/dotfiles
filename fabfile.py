import os
import socket

from fabric.api import cd, env, prefix, run, sudo

env.hosts = [socket.gethostname()]
env.password = os.getenv('PASSWORD')
env.base_dir = '/home/{}'.format(env.user)
env.ln_template = 'ln -s {} {}'
env.dotfiles_path = '{base_dir}/projects/dotfiles'.format(**env)
env.phantomjs = 'phantomjs-2.1.1-linux-x86_64'

# TODO node,
# TODO fix inserting sudo in terminal

def setup():
    update_system()
    install_useful_apps()
    add_repositories()
    install_system_libs()
    clone_dotfiles()
    symlink_configs()

    install_vim()
    install_chrome()
    install_phantomjs()
    install_mailcloud()
    install_torrent_client()
    install_tweaks()
    install_icons()
    install_libre()
    install_vlc()
    install_redshift()
    cleanup_system()


def update_system():
    sudo('apt-get update')
    sudo('apt-get -y upgrade')
    sudo('apt-get -y dist-upgrade')


def install_useful_apps():
    # for installing repo in terminal
    sudo('apt-get install -y software-properties-common')
    sudo('apt-get install -y git')
    sudo('apt install -y gconf2')


def add_repositories():
    sudo('add-apt-repository ppa:jonathonf/python-3.6 -y')
    sudo('apt-get update')


def install_system_libs():
    sudo('sudo apt-get -y install zlib1g-dev build-essential libssl-dev libffi-dev '
         'python3.6 python3.6-dev python3.6-venv language-pack-ru chrpath libxft-dev '
         'libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev '
         'exuberant-ctags python python-dev python3-dev python-pip ')


def clone_dotfiles():
    run('mkdir -p {base_dir}/projects'.format(**env))
    with cd('{base_dir}/projects'.format(**env)):
        run('git clone https://github.com/Galbator1x/dotfiles.git')


def symlink_configs():
    if os.path.exists(os.path.join(env.base_dir, '.bashrc')):
        sudo('rm {}'.format(os.path.join(env.base_dir, '.bashrc')))
    run(env.ln_template.format(os.path.join(env.dotfiles_path, '.bashrc'),
                               os.path.join(env.base_dir, '.bashrc')))
    run(env.ln_template.format(os.path.join(env.dotfiles_path, '.bash_aliases'),
                               os.path.join(env.base_dir, '.bash_aliases')))
    run(env.ln_template.format(os.path.join(env.dotfiles_path, '.tmux.conf'),
                               os.path.join(env.base_dir, '.tmux.conf')))


def install_vim():
    sudo('add-apt-repository ppa:jonathonf/vim -y')
    sudo('apt update')
    sudo('apt -y install vim vim-nox')
    run(env.ln_template.format(os.path.join(env.dotfiles_path, '.vim'),
                               os.path.join(env.base_dir, '.vim')))
    run(env.ln_template.format(os.path.join(env.dotfiles_path, '.vimrc'),
                               os.path.join(env.base_dir, '.vimrc')))
    run('mkdir -p {}'.format(os.path.join(env.dotfiles_path, '.vim/plugged')))
    with cd(os.path.join(env.dotfiles_path, '.vim/plugged')):
        run('git clone https://github.com/nanotech/jellybeans.vim.git')
    run('curl -fLo ~/.vim/autoload/plug.vim --create-dirs '
         'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim')
    run('vim -i NONE -c PlugUpdate -c quitall')


def install_chrome():
    run('wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -')
    sudo("""sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'""")
    sudo('apt-get update')
    sudo('apt-get install -y google-chrome-stable')
    sudo('gconftool-2 --set /apps/metacity/general/button_layout --type string ":minimize,maximize,close"')


def install_phantomjs():
    run('cd ~')
    run('wget https://bitbucket.org/ariya/phantomjs/downloads/{}.tar.bz2'
        .format(env.phantomjs))
    sudo('tar xvjf {}.tar.bz2'.format(env.phantomjs))
    sudo('mv {} /usr/local/share'.format(env.phantomjs))
    sudo('ln -sf /usr/local/share/{}/bin/phantomjs /usr/local/bin'.format(env.phantomjs))
    sudo('rm ~/{}.tar.bz2'.format(env.phantomjs))


def install_mailcloud():
    run('wget -O mail.ru-cloud.gpg https://linuxdesktopcloud.mail.ru/mail.ru-cloud.gpg')
    sudo('apt-key add mail.ru-cloud.gpg')
    run('rm ~/mail.ru-cloud.gpg')
    sudo('echo "deb https://linuxdesktopcloud.mail.ru/deb default free" > /etc/apt/sources.list.d/mail.ru-cloud.list')
    sudo('apt-get update')
    sudo('apt-get install -y mail.ru-cloud')


def install_torrent_client():
    sudo('apt-get install -y deluge')


def install_tweaks():
    sudo('add-apt-repository -y ppa:philip.scott/elementary-tweaks')
    sudo('apt-get update')
    sudo('apt-get install -y elementary-tweaks')


def install_icons():
    sudo('apt-add-repository -y ppa:numix/ppa')
    sudo('apt-get update')
    sudo('apt-get install -y numix-icon-theme-circle')


def install_libre():
    sudo('add-apt-repository -y ppa:libreoffice/ppa')
    sudo('apt-get update')
    sudo('apt-get install -y libreoffice')


def install_vlc():
    sudo('apt-get install -y vlc')


def install_redshift():
    sudo('apt-get install -y gtk-redshift')
    run('gtk-redshift -l 56:92 -t 5500:3400 & exit')


def cleanup_system():
    sudo('sudo apt-get -y remove epiphany-browser epiphany-browser-data epiphany-browser-data epiphany-extensions')
    sudo('apt-get -y autoremove')
    sudo('apt-get -y autoclean')
