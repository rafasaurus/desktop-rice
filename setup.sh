#!/bin/sh

[ -z "$progsfile" ] && progsfile="https://raw.githubusercontent.com/rafasaurus/i3-rice/master/progs.csv"
[ -z "$aurhelper" ] && aurhelper="yay"

maininstall() { # Installs all needed programs from main repo.
	dialog --title "i3-rice Installation" --infobox "Installing \`$1\` ($n of $total). $1 $2" 5 70
	pacman --noconfirm --needed -S "$1" >/dev/null 2>&1
	}

gitmakeinstall() {
	dir=$(mktemp -d)
	dialog --title "i3-rice Installation" --infobox "Installing \`$(basename "$1")\` ($n of $total) via \`git\` and \`make\`. $(basename "$1") $2" 5 70
	git clone --depth 1 "$1" "$dir" >/dev/null 2>&1
	cd "$dir" || exit
	make >/dev/null 2>&1
	make install >/dev/null 2>&1
	cd /tmp || return ;}

aurinstall() { \
	dialog --title "i3-rice Installation" --infobox "Installing \`$1\` ($n of $total) from the AUR. $1 $2" 5 70
	echo "$aurinstalled" | grep "^$1$" >/dev/null 2>&1 && return
	sudo -u "$USER" $aurhelper -S --noconfirm "$1" > /dev/null 2>&1
	}

pipinstall() { \
	dialog --title "i3-rice Installation" --infobox "Installing the Python package \`$1\` ($n of $total). $1 $2" 5 70
	command -v pip || pacman -S --noconfirm --needed python-pip >/dev/null 2>&1
	yes | pip install "$1"
	}

installationloop() { \
	# ([ -f "$progsfile" ] && cp "$progsfile" /tmp/progs.csv) || curl -Ls "$progsfile" | sed '/^#/d' > /tmp/progs.csv
	total=$(wc -l < /tmp/progs.csv)
	aurinstalled=$(pacman -Qm | awk '{print $1}')
	while IFS=, read -r tag program comment; do
		n=$((n+1))
		echo "$comment" | grep "^\".*\"$" >/dev/null 2>&1 && comment="$(echo "$comment" | sed "s/\(^\"\|\"$\)//g")"
		case "$tag" in
			"") maininstall "$program" "$comment" ;;
			"A") aurinstall "$program" "$comment" ;;
			"G") gitmakeinstall "$program" "$comment" ;;
			"P") pipinstall "$program" "$comment" ;;
		esac
	done < /tmp/progs.csv ;}

resetpulse() {
	dialog --infobox "Reseting Pulseaudio..." 4 50
	killall pulseaudio
	sudo -n "$USER" pulseaudio --start ;
}

setupBetterLockScreenService() {
	dialog --title "i3-rice Installation" --infobox "Installing \`$1\` ($n of $total). $1 $2" 5 70
	sudo -n "$USER" systemctl enable betterlockscreen@$USER > .log.betterlockscreen

}
setupBetterLockScreenFolder() {
	dialog --title "i3-rice Installation" --infobox "Installing \`$1\` ($n of $total). $1 $2" 5 70
	betterlockscreen -u /home/$USER/github/dotfiles/wallpaper > .log.betterlockscreen
}
	
# The command that does all the installing. Reads the progs.csv file and
# installs each needed program the way required. Be sure to run this only after
# the user has been created and has priviledges to run sudo without a password
# and all build dependencies are installed.
installationloop

# Pulseaudio, if/when initially installed, often needs a restart to work immediately.
[ -f /usr/bin/pulseaudio ] && resetpulse
setupBetterLockScreenService
setupBetterLockScreenFolder
