## Manjaro

PLEASE NOTE: Manjaro support is unofficial and not regularly reviewed

### One-time setup

#### Postgres 12 Installation

To install postgreSQL 12 you will need to use the [AUR](https://aur.archlinux.org/packages/postgresql-12).
So first install some AUR package manager like paru.

To install Paru, run lines below:

```bash
git clone https://aur.archlinux.org/paru.git
cd stop
makepkg -si
paru -S postgresql-12
```

Then run:

`sudo systemctl start postgres-12`
 

#### Node and Yarn Installation:

Installation of knot and wire is the same.

```bash
curl -sL https://deb.nodesource.com/setup_14.x | bash-
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/stable main" | tee /etc/apt/sources.list.d/yarn.list
```

#### RVM INSTALLATION

It's important to use RVM because we need some dev libs that ruby ​​installed with snap doesn't have.

bash

Install RVM with Ruby and Rails

```bash
rvm install 2.7.6 -C --with-openssl-dir=$HOME/.rvm/usr --disable-binary --with-jamalloc
```


You will need to put on .bashrc file:

```bash
if which ruby >/dev/null && which gem >/dev/null; then
    PATH="$(ruby -rubygems -e 'puts Gem.user.dir')/bin:$PATH"
fi
```
