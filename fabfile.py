import os

from fabric.api import cd, env, prefix, run, sudo

env.hosts = ['testing']
env.password = 'd47f17d82b7eaaeb9510d420'
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

    install_phantomjs()
    install_vim()
    cleanup_system()


def update_system():
    sudo('apt-get update')
    sudo('apt-get -y upgrade')
    sudo('apt-get -y dist-upgrade')


def install_useful_apps():
    # for installing repo in terminal
    sudo('apt-get install -y software-properties-common')


def install_system_libs():
    sudo('sudo apt-get -y install zlib1g-dev build-essential libssl-dev libffi-dev '
         'python3.6 python3.6-dev python3.6-venv language-pack-ru chrpath libxft-dev '
         'libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev '
         'exuberant-ctags python python-dev python3-dev python-pip')


def add_repositories():
    sudo('add-apt-repository ppa:jonathonf/python-3.6 -y')
    sudo('apt-get update')


def clone_dotfiles():
    run('mkdir -p {base_dir}/projects'.format(**env))
    with cd('{base_dir}/projects'.format(**env)):
        run('git clone https://github.com/Galbator1x/dotfiles.git')


def symlink_configs():
    sudo('rm {}'.format(os.path.join(env.base_dir, '.bashrc')))
    run(env.ln_template.format(os.path.join(env.dotfiles_path, '.bashrc'),
                               os.path.join(env.base_dir, '.bashrc')))
    run(env.ln_template.format(os.path.join(env.dotfiles_path, '.bash_aliases'),
                               os.path.join(env.base_dir, '.bash_aliases')))
    run(env.ln_template.format(os.path.join(env.dotfiles_path, '.tmux.conf'),
                               os.path.join(env.base_dir, '.tmux.conf')))


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


def cleanup_system():
    sudo('apt-get purge midori-granite')
    sudo('apt-get autoremove')
    sudo('apt-get autoclean')
