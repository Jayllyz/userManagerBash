#!/bin/bash

passwd_file="/etc/passwd"
group_file="/etc/group"
user_file="users.txt"
min_size=5000;    # 5 Mo
max_size=50000;   # 50 Mo

if [ ! -f "$user_file" ]; then
    echo "Le fichier source '$user_file' n'existe pas."
    exit 1
fi

awk -F: -v login=1 -v firstname=2 -v lastname=3 -v groups=4 -v password=5 -v min_size=$min_size -v max_size=$max_size '{
    print "Working on user " $login "..."

    if (system("id -u " $login " >/dev/null 2>&1") == 0) {
        print "User " $login " already exists."
        next
    }

    if( $groups == "" ) {
        print "User " $login " has no group."
        $primary_group = $login
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
    system("echo "$login":"$password "| chpasswd -e");
    system("chage -d 0 "$login);

    srand();
    files = int(rand() * (10 - 5 + 1)) + 5;
    for (i = 1; i <= files; i++) {
        file_size = int(rand() * (max_size - min_size + 1)) + min_size;
        system("dd if=/dev/urandom of=\"/home/" $login "/file" i "\" bs=" file_size " count=1");
    }

}' $user_file


