#! /bin/bash


APP_PATH=/var/containers/Bundle/Application
function list_app()
{
    for bid_path in ${APP_PATH}/*;
    do 
	app=${bid_path}/*.app
        echo ${app}
    done
}


function decrypt_app()
{
    path=$1
    app=$(basename "$path")
    mkdir -p "dump/$app"
    cp -rf "$path" "dump"
    
    # read manifest file
    echo "process sinf manifest file"
    manifest=$path/SC_Info/Manifest.plist
    if [ -f "$manifest" ];
    then
        plistutil -i "$manifest" -f xml | grep "<string.*.sinf</string>$" | cut -d'>' -f2 | cut -d '<' -f1 | sort | uniq | while read -r sinf;
        do
            #echo "processing $sinf"
	    macho=$(basename "$sinf" | sed -E s/.sinf//g)
	    rpath=$(dirname $(dirname "$sinf"))
	    echo "decrypting file @$rpath/$macho"

	    src="$path/$rpath/$macho"
	    dst="dump/$app/$rpath/$macho"

	    flexdecrypt file "$src" --output "$dst"
	done
    fi
    
}

if [ "$1" = "list" ];
then
    list_app
elif [ "$1" = "decrypt" ];
then
    decrypt_app "$2"
else
    echo -e "usage : list/decrypt"
fi

