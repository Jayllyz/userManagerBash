# userManagerBash

Pour éxécuter chaque script, il faut utiliser la commande suivante :

```bash
chmod +x nomDuScript.sh
sudo ./nomDuScript.sh
```

## Script 1 : createUsers.sh

Ce script permet de créer tout les utilisateurs à partir d'un fichier texte.

La syntaxe du fichier texte est la suivante :

```
login:firtname:lastname:group1,group2,group3:password
```

Pour chaque utilisateur un nombre aléatoire de fichiers est créé dans son répertoire personnel, avec une taille aléatoire comprise entre 5 et 50 Mo.

## Script 2 : usage.sh

Ce script permet de calculer l'espace disque utilisé par chaque utilisateur, et de l'afficher d'une manière lisible.

Il ajoute une régle dans le .bashrc de chaque utilisateur pour afficher l'espace disque utilisé à chaque connexion, avec une alerte si l'espace disque utilisé dépasse 100Mo.

De plus, le top 5 des utilisateurs les plus gourmands en espace disque est affiché grâce à un trie avec l'algorithme du tri pair-impair.

## Script 3 : checkPerms.sh

Ce script permet de vérifier les fichiers avec les permissions SUID & GUID d'activées dans le système.
Il faut créer au préalable le fichier `old_list.txt` dans le même répertoire que le script.
