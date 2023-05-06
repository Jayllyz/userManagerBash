#!/bin/bash

old="old_list.txt"
new="new_list.txt"


afficher_date_modification() {
    fichier="$1"
    date_modification=$(sudo stat -c %y "$fichier")
    if [ $? -eq 0 ]; then
        echo "Date de modification : $date_modification"
    else
        echo "Impossible de récupérer la date de modification du fichier"
    fi
}

sudo find /home -perm /6000 -type f 2>/dev/null > "$new"

if [ -f "$old" ]; then
    differences=$(diff "$old" "$new")
    if [ -n "$differences" ]; then
        echo "Avertissement : Les fichiers avec SUID et/ou SGID activés ont changé depuis le dernier appel du script."
        echo "Différences :"
        echo "$differences" | while IFS= read -r ligne_diff; do
            if [[ ! $ligne_diff =~ ^[0-9]+[acd][0-9]+$ ]]; then
                echo "$ligne_diff"
                fichier_diff=$(echo "$ligne_diff" | cut -d' ' -f2)
                afficher_date_modification "$fichier_diff"
            fi
        done
    else
        echo "Les fichiers avec SUID et/ou SGID activés sont identiques à la liste précédente."
    fi
else
    echo "La liste précédente n'existe pas. Une nouvelle liste a été créée."
fi


cp "$new" "$old"
