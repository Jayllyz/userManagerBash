#!/bin/bash

format_size() {
    local size=$1
    local go=$((size / 1024 / 1024))
    local mo=$((size / 1024))
    local ko=$((size))
    local octets=$((size* 1024))
    
    echo "$go Go, $mo Mo, $ko ko et $octets octets"
}

odd_even_sort() {
    local arr=("$@")
    local len=${#arr[@]}
    
    for ((i = 0; i < len - 1; i++)); do
        for ((j = 0; j < len - i - 1; j++)); do
            if ((arr[j] < arr[j + 1])); then
                temp=${arr[j]}
                arr[j]=${arr[j + 1]}
                arr[j + 1]=$temp
            fi
        done
    done
    
    echo "${arr[@]}"
}


users=$(awk -F: '{print $1}' users.txt)

sizes_users=()
for user in $users; do
    
    dir_size=$(du -s "/home/$user" | awk '{print $1}')
    sizes_users+=("$dir_size")
    
    formatted_size=$(format_size "$dir_size")
    
    echo "Taille du répertoire personnel de $user : $formatted_size"
    
    echo >> "/home/$user/.bashrc"
    echo "# Affichage de la taille du répertoire personnel" >> "/home/$user/.bashrc"
    echo 'dir_size=$(du -s "$HOME" | awk "{print $1}")' >> "/home/$user/.bashrc"
    echo 'formatted_size=$(format_size "$dir_size")' >> "/home/$user/.bashrc"
    echo 'echo "Taille de votre répertoire personnel : $formatted_size"' >> "/home/$user/.bashrc"
    echo 'if ((dir_size > 102400)); then' >> "/home/$user/.bashrc"
    echo '    echo "Attention : votre répertoire personnel occupe plus de 100Mo!"' >> "/home/$user/.bashrc"
    echo 'fi' >> "/home/$user/.bashrc"
done

sorted_sizes=($(odd_even_sort "${sizes_users[@]}"))

prev_size=0
printed=0
echo "Les 5 plus gros consommateurs d'espace disque :"
for ((i = 0; i < 5; i++)); do
    index=$i
    dir_size=${sorted_sizes[index]}
    if ((dir_size == prev_size)); then
        continue
    fi
    printed=$((printed + 1))
    formatted_size=$(format_size "$dir_size")
    user=$(du -s "/home/"* | awk -v size="$dir_size" -v field="$index" 'BEGIN{FS="\t"} $1 == size {print $2}')
    echo "$((printed)). Utilisateur: $user | Taille: $formatted_size"
    prev_size=$dir_size
done
