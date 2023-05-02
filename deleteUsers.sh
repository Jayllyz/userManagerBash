#!/bin/bash

awk -F: -v login=1 '{
    system("userdel -r " $login);
}' users.txt