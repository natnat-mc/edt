#!/bin/bash

installdir="$1"
bindir="$2"

# ask the user if locations aren't provided
if [ -z "$installdir" ]; then
	echo -n "Dans quel dossier installer ? [$HOME/opt/edt] "
	read installdir
	[ -z "$installdir" ] && installdir="$HOME/opt/edt"
fi
if [ -z "$bindir" ]; then
	echo -n "Dans quel dossier placer le point d'entrée ? [$HOME/bin] "
	read bindir
	[ -z "$bindir" ] && bindir="$HOME/bin"
fi

# create the directories recursively
mkdir -p "$installdir"
mkdir -p "$bindir"

# install the base code
for file in get.sh parse.sh forday.sh data; do
	cp -r "$file" "$installdir"
done

# install the entry point
cat <<EOF > "$bindir/edt"
#!/bin/bash

# set the installation directory
export installdir="$installdir"

EOF
cat entrypoint.sh >> "$bindir/edt"
chmod +x "$bindir/edt"

# make sure we're in the path
if [ ! "`which edt`" = "`realpath "$bindir/edt"`" ]; then
	answered=''
	while ! [ "$answered" = "y" ]; do
		echo -n "Le point d'entrée n'est pas dans le path, l'ajouter ? [Y/n] "
		read answered
		answered="`echo "$answered" | tr '[:upper:]' '[:lower:]'`"
		[ -z "$answered" ] && answered='y'
	done
	
	if [ "$answered" = 'y' ]; then
		cp "$HOME/.profile" profile_bak
		echo "PATH=$bindir:\$PATH" >> "$HOME/.profile"
		echo "Le PATH a été modifié, vous devriez recharger votre environement avec '. ~/.profile'"
	fi
fi
