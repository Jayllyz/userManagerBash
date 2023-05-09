#!/bin/bash

user_file="users.txt"
min_size=5;    # 5 Mo
max_size=10;   # 50 Mo

if [ ! -f "$user_file" ]; then
    echo "Le fichier source '$user_file' n'existe pas."
    exit 1
fi

awk -F: -v login=1 -v firstname=2 -v lastname=3 -v groups=4 -v password=5 -v min_size=$min_size -v max_size=$max_size '{
    print "Création de " $login "..."

    if (system("id -u " $login " >/dev/null 2>&1") == 0) {
        print "Utilisateur " $login " existe déjà."
        next
    }

    if( $groups == "" ) {
        primary_group = $login
    } else {
        split($groups, group_list, ",")
        primary_group=group_list[1]
        for (i in group_list) {
            group_name = group_list[i]
            if (system("getent group " group_name " >/dev/null 2>&1") != 0) {
                print "Creating group " group_name "..."
                system("sudo groupadd " group_name)
            }
        }
    }

    system("useradd -c \"" $firstname " " $lastname "\" -g \"" primary_group "\" -G \"" $groups "\" -m \"" $login "\"");
    cmd="echo \"" $login ":" $password "\" | sudo chpasswd"
    system(cmd);
    system("chage -d 0 " $login);

    srand();
    files = int(rand() * (10 - 5 + 1)) + 5;
    file_count = 0;

    for (i = 1; i <= files; i++) {
        file_size = int(rand() * (max_size - min_size + 1)) + min_size;
        file_path = "/home/" $login "/file" i;
        system("dd if=/dev/urandom of=\"" file_path "\" bs=" file_size "M count=1 >/dev/null 2>&1");
        file_count++;
    }

    print "Création de " file_count " fichiers pour " $login ".";

}' $user_file