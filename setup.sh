#!/bin/bash

# Run this script in a newly installed Linux (tested on Kali)

PKG_MANAGER_OPTIONS=("apt" "pacman")
PACKAGES=(
	"wget"
  "curl"
  "git"
	"pwncat"
	"npm"
  "golang"
	"neovim"
        "vlc"
        "gdb"
        "xclip"
        "tilix"
        "openvpn"
        "docker.io"
        "encfs"
        "libu2f-udev"
        "libnspr4"
        "libc++1"
)

# USER detect
USER="lucky"
HOME="/home/lucky"
if [ `id -u` == 0 ]; then
	USER="root";
	HOME="/root";
elif id "lucky" &>/dev/null; then
	echo '[!] user lucky already exists with uid' $(id -u lucky);
else
  echo '[+] adding user `lucky`';
	useradd lucky
	read -p "enter the password for lucky: " PASSWD
	echo "lucky:$PASSWD" | chpasswd
	echo "[!] user \`lucky\` added successfully"
fi

# Detect package manager
if [ -f "/etc/arch-release" ]; then
    PKG_MANAGER=${PKG_MANAGER_OPTIONS[1]}
else
    PKG_MANAGER=${PKG_MANAGER_OPTIONS[0]}
fi

# Initial package manager setup
$PKG_MANAGER update

# Install packages with apt/pacman
echo '[+] Installing packages, this may take some time ...'
if [ $PKG_MANAGER == "apt" ]; then
    $PKG_MANAGER install -y "${PACKAGES[@]}"
elif [ $PKG_MANAGER == "pacman" ]; then
    $PKG_MANAGER -S --noconfirm "${PACKAGES[@]}"
fi

# Download and install from sources
DISCORD=("https://discord.com/api/download?platform=linux&format=deb" "https://discord.com/api/download?platform=linux&format=tar.gz")
CUTTER="https://github.com/rizinorg/cutter/releases/download/v2.2.0/Cutter-v2.2.0-Linux-x86_64.AppImage"
CHROME=("https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" "https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm")

echo '[+] Installing Discord...';
#wget -O /tmp/Discord.tar.gz "${DISCORD[1]}";
#tar xvf /tmp/Discord.tar.gz -C /usr/share/;
echo '[!] Discord installed';

echo '[+] Installing Cutter';
mkdir -p ~/bin;
wget -O ~/bin/cutter "$CUTTER";
chmod +x ~/bin/cutter;
echo '[+] Cutter installed';

echo '[+] Installing Chrome...'
if [ $PKG_MANAGER == "apt" ]; then
    wget -O /tmp/chrome.deb "${CHROME[0]}";
    dpkg -i /tmp/chrome.deb;
elif [ $PKG_MANAGER == "pacman" ]; then
    wget -O /tmp/chrome.rpm "${CHROME[1]}";
    rpm -i /tmp/chrome.rpm;
fi
if [ $PKG_MANAGER == 'apt' ]; then
  $PKG_MANAGER --fix-broken install;
fi
  echo '[+] Chrome installed';

# Move bins/* to /usr/local/bin
echo '[+] Moving ~/bin/* to /usr/local/bin';
cp -r $(pwd)/bins/* /usr/local/bin/;

# Configure Terminal
cp -r ./terminal/tilix/* /usr/share/tilix/;
tar xvf ./terminal/tmux.tar -C ./terminal/
mkdir -p $HOME/.tmux;
cp -r ./terminal/tmux/{plugins,notify,resurrect} $HOME/.tmux/;
cp -r ./terminal/tmux/.tmux.conf $HOME/;

# Wallapaper & face icon (lightdm)
## will think about it in future.

# neovim NvChad
echo "[+] installing NvChad neovim...";
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1;
echo "[+] opening nvim, close it manually (:q!) once the installation is completed";
nvim 
echo "[!] NvChad installation completed";

# gdb-gef 
echo "[+] installing gef in gdb";
bash -c "$(curl -fsSL https://gef.blah.cat/sh)";
echo "[!] gef installation completed";

# batcat
echo '[+] installing batcat --> bat'
if [ $PKG_MANAGER == 'apt' ]; then
   $PKG_MANAGER install bat -y;
  mv /bin/batcat /bin/bat;
fi

# gnome session (vim and others) restore
read -p 'restore the gnome and others sessions(y/n) ' allow;
if [ "$allow" == 'yes' ] || [ "$allow" == 'y' ] || [ "$allow" == 'Y' ] || [ "$allow" == 'YES' ]; then
  cp -r ./local/* $HOME/.local/;
else 
  echo '[!] skipped...';
fi

# HTB
echo '[+] openvpn HTB Configure...'
cp ./htb/luckythandel.ovpn $HOME/Desktop/.luckythandel.ovpn
cp ./htb/luckythande-release.ovpn $HOME/Desktop/.luckythande-release.ovpn
cp ./htb/luckythandel-fortress.ovpn $HOME/Desktop/.luckythandel-fortress.ovpn
echo -e "#!/bin/bash\nopenvpn --config $HOME/Desktop/.luckythandel.ovpn" > /bin/htb; chmod +x /bin/htb
echo -e "#!/bin/bash\nopenvpn --config $HOME/Desktop/.luckythandel-release.ovpn" > /bin/htb-release; chmod +x /bin/htb-release
echo -e "#!/bin/bash\nopenvpn --config $HOME/Desktop/.luckythandel-fortress.ovpn" > /bin/htb-fortress; chmod +x /bin/htb-fortress
echo '[!] HTB configured successfully!!'

# LuckyThandel's tools from GitHub
echo "[+] LuckyThandel's Github tools downloading..."
URLS=(
  "https://github.com/luckythandel/Floki.git"
  "https://github.com/luckythandel/netx.git"
  "https://github.com/luckythandel/loki.git"
  "https://github.com/luckythandel/fn-login.git"
  "https://github.com/luckythandel/LUNA.git"
  "https://github.com/luckythandel/luckyporter.git"
  "https://github.com/luckythandel/villi.git"
  );
mkdir $HOME/LuckyRepo/
for url in URLS; do
  git clone $url $HOME/LuckyRepo;
done
echo "[!] Lucky\'s GitHub repo fetched successfully!!"; 
  
# Tomnomnom's tools from github
# mostly used in bug hunting....
echo "[+] Tomnomnom\'s GitHUb tools downloading...";
go install github.com/tomnomnom/httprobe@latest;
go install -v github.com/projectdiscovery/wappalyzergo/cmd/update-fingerprints@latest;
go install github.com/tomnomnom/waybackurls@latest;
go install github.com/tomnomnom/gf@latest;
go install github.com/tomnomnom/assetfinder@latest;
go install github.com/tomnomnom/fff@latest;
go install github.com/tomnomnom/meg@latest;
echo "[+] Tomnomnom\'s tools downloaded successfully!!";

# ohmybash
echo '[+] installing ohmybash';
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)";
chsh -s /usr/bin/bash;
echo '[+] ohmybash installed successfully';


