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
    
    for ((i = 1; i < len - 1; i += 1)); do
        # Comparaisons impaires-paires
        for ((x = 1; x < len - 1; x += 2)); do
            if ((arr[x] < arr[x + 1])); then
                temp=${arr[x]}
                arr[x]=${arr[x + 1]}
                arr[x + 1]=$temp
            fi
        done
        
        # Comparaisons paires-impaires
        for ((x = 0; x < len - 1; x += 2)); do
            if ((arr[x] < arr[x + 1])); then
                temp=${arr[x]}
                arr[x]=${arr[x + 1]}
                arr[x + 1]=$temp
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
    
    
    if ! grep -q "# Affichage de la taille du répertoire personnel" ".bashrc"; then
        printf "\n" >> ".bashrc"
        printf 'format_size() {\n' >> ".bashrc"
        printf '    local size=$1\n' >> ".bashrc"
        printf '    local go=$((size / 1024 / 1024))\n' >> ".bashrc"
        printf '    local mo=$((size / 1024))\n' >> ".bashrc"
        printf '    local ko=$((size))\n' >> ".bashrc"
        printf '    local octets=$((size * 1024))\n' >> ".bashrc"
        printf '    echo "$go Go, $mo Mo, $ko ko et $octets octets"\n' >> ".bashrc"
        printf '}\n' >> ".bashrc"
        printf "\n" >> ".bashrc"
        printf "# Affichage de la taille du répertoire personnel\n" >> ".bashrc"
        printf 'dir_size=$(du -s "$HOME" | awk "{print \$1}")\n' >> ".bashrc"
        printf 'formatted_size=$(format_size "$dir_size")\n' >> ".bashrc"
        printf 'echo "Taille de votre répertoire personnel : $formatted_size."\n' >> ".bashrc"
        printf 'if ((dir_size > 102400)); then\n' >> ".bashrc"
        printf '    echo "Attention : votre répertoire personnel occupe plus de 100Mo!"\n' >> ".bashrc"
        printf 'fi\n' >> ".bashrc"
    fi
    
    
done

sorted_sizes=($(odd_even_sort "${sizes_users[@]}"))

prev_size=0
printed=0
index=-1
echo "Les 5 plus gros consommateurs d'espace disque :"
for ((i = 0; i < 5; i++)); do
    index=$((index + 1))
    dir_size=${sorted_sizes[index]}
    if ((dir_size == prev_size)); then
        i=$((i - 1))
        continue
    fi
    printed=$((printed + 1))
    formatted_size=$(format_size "$dir_size")
    user=$(du -s "/home/"* | awk -v size="$dir_size" -v field="$index" 'BEGIN{FS="\t"} $1 == size {users[$2]=1} END{for (user in users) {usersList = (usersList == "" ? user : usersList ", " user)} print usersList}')
    echo "$((printed)). Utilisateur: $user | Taille: $formatted_size"
    prev_size=$dir_size
done

