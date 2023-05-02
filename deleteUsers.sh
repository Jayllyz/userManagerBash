#!/bin/bash

user_file="users.txt"

awk -F: -v login=1 '{
    system("userdel -r " $login);
}' $user_file