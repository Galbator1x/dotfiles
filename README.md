# dotfiles

Setup your Elementary OS loki and Vim.

## Installation

Install pip3 and fabric3
```
$ sudo apt-get install -y --install-recommends python3-pip
$ sudo pip3 install fabric3
```
Put your password in environment variable
```
export PASSWORD=yourpassword
```
Download fabfile and run it
```
$ wget https://raw.githubusercontent.com/Galbator1x/dotfiles/master/fabfile.py
$ fab setup
```
