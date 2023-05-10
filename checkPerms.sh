#!/bin/bash

old="old_list.txt"
new="new_list.txt"

edit_date() {
    file="$1"
    if date=$(sudo stat -c %y "$file"); then
        echo "Date de modification : $date"
    else
        echo "Impossible de récupérer la date de modification du fichier"
    fi
}

sudo find / -perm /6000 -type f 2>/dev/null > "$new"

if [ -f "$old" ]; then
    diff=$(diff "$old" "$new")
    if [ -n "$diff" ]; then
        echo "Avertissement : Les fichiers avec SUID et/ou SGID activés ont changé depuis le dernier appel du script."
        echo "Différences :"
        echo "$diff" | while IFS= read -r line_diff; do
            if [[ ! $line_diff =~ ^[0-9]+[acd][0-9]+$ ]]; then # rm la ligne de différence renvoyée par diff
                echo "$line_diff"
                file_diff=$(echo "$line_diff" | cut -d' ' -f2)
                edit_date "$file_diff"
            fi
        done
    else
        echo "Les fichiers avec SUID et/ou SGID activés sont identiques à la liste précédente."
    fi
else
    echo "La liste précédente n'existe pas. Une nouvelle liste a été créée."
fi

cp "$new" "$old"
