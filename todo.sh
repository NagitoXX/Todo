#!/bin/bash

# Fichier pour stocker les tâches
FICHIER_TACHES="taches.txt"

# S'assurer que le fichier de tâches existe
touch $FICHIER_TACHES

# Fonction pour valider la date et l'heure
valider_datetime() {
    date -d "$1" +"%Y-%m-%d %H:%M:%S" > /dev/null 2>&1
    return $?
}

# Fonction pour valider le statut de complétion
valider_completion() {
    [[ "$1" == "true" || "$1" == "false" ]]
}

# Fonction pour vérifier si une chaîne n'est pas vide
valider_string_non_vide() {
    [[ -n "$1" ]]
}

# Fonction pour lister les tâches d'aujourd'hui lorsqu'aucun argument n'est fourni
lister_taches_aujourdhui() {
    date=$(date +"%Y-%m-%d")
    echo "Tâches complétées aujourd'hui :"
    grep "|$date|" $FICHIER_TACHES | grep "|true$" | while IFS='|' read -r id titre date_heure_echeance description localisation completion; do
        echo "- $titre (ID : $id)"
    done

    echo "Tâches non complétées aujourd'hui :"
    grep "|$date|" $FICHIER_TACHES | grep "|false$" | while IFS='|' read -r id titre date_heure_echeance description localisation completion; do
        echo "- $titre (ID : $id)"
    done
}

if [ $# -eq 0 ]; then
    lister_taches_aujourdhui
    exit 0
fi

# Interface d'introduction
echo "Bienvenue dans le script Todo"
echo "-----------------------------"
echo "Ce script vous aide à gérer vos tâches à faire. Vous pouvez créer, mettre à jour, supprimer et voir des tâches. Chaque tâche a un identifiant unique, un titre, une description, une localisation, une date et heure d'échéance, et un marqueur de complétion. Le titre et la date d'échéance sont des champs obligatoires ; les autres sont facultatifs. Veuillez suivre les invites pour entrer les informations requises.
echo "-----------------------------------------------------------"
echo

# Boucle du menu principal
while true; do
    echo "Menu Todo"
    echo "---------"
    echo "1. Créer une tâche"
    echo "2. Mettre à jour une tâche"
    echo "3. Supprimer une tâche"
    echo "4. Afficher toutes les informations d'une tâche"
    echo "5. Lister les tâches d'un jour donné"
    echo "6. Rechercher une tâche par titre"
    echo "7. Quitter"
    read -p "Choisissez une option : " option

    case $option in
        1)
            while true; do
                read -p "Titre : " titre
                if valider_string_non_vide "$titre"; then
                    break
                else
                    echo "Erreur : Le titre ne peut pas être vide." >&2
                fi
            done
            
            while true; do
                read -p "Date et heure d'échéance (YYYY-MM-DD HH:MM:SS) : " date_heure_echeance
                if valider_datetime "$date_heure_echeance"; then
                    break
                else
                    echo "Erreur : Format de date et heure invalide. Veuillez entrer au format YYYY-MM-DD HH:MM:SS." >&2
                fi
            done

            read -p "Description (facultatif) : " description
            read -p "Localisation (facultatif) : " localisation
            
            while true; do
                read -p "Complétion (true/false) : " completion
                if valider_completion "$completion"; then
                    break
                else
                    echo "Erreur : La complétion doit être 'true' ou 'false'." >&2
                fi
            done

            id=$(uuidgen)
            echo "$id|$titre|$date_heure_echeance|$description|$localisation|$completion" >> $FICHIER_TACHES
            echo "Tâche créée avec succès."
            ;;

        2)
            while true; do
                read -p "Entrez l'ID de la tâche à mettre à jour : " id
                if grep -q "^$id|" $FICHIER_TACHES; then
                    break
                else
                    echo "Erreur : Tâche non trouvée." >&2
                fi
            done

            while true; do
                read -p "Titre : " titre
                if valider_string_non_vide "$titre"; then
                    break
                else
                    echo "Erreur : Le titre ne peut pas être vide." >&2
                fi
            done
            
            while true; do
                read -p "Date et heure d'échéance (YYYY-MM-DD HH:MM:SS) : " date_heure_echeance
                if valider_datetime "$date_heure_echeance"; then
                    break
                else
                    echo "Erreur : Format de date et heure invalide. Veuillez entrer au format YYYY-MM-DD HH:MM:SS." >&2
                fi
            done

            read -p "Description (facultatif) : " description
            read -p "Localisation (facultatif) : " localisation
            
            while true; do
                read -p "Complétion (true/false) : " completion
                if valider_completion "$completion"; then
                    break
                else
                    echo "Erreur : La complétion doit être 'true' ou 'false'." >&2
                fi
            done

            sed -i "/^$id|/d" $FICHIER_TACHES
            echo "$id|$titre|$date_heure_echeance|$description|$localisation|$completion" >> $FICHIER_TACHES
            echo "Tâche mise à jour avec succès."
            ;;

        3)
            while true; do
                read -p "Entrez l'ID de la tâche à supprimer : " id
                if grep -q "^$id|" $FICHIER_TACHES; then
                    break
                else
                    echo "Erreur : Tâche non trouvée." >&2
                fi
            done

            sed -i "/^$id|/d" $FICHIER_TACHES
            echo "Tâche supprimée avec succès."
            ;;

        4)
            while true; do
                read -p "Entrez l'ID de la tâche à afficher : " id
                tache=$(grep "^$id|" $FICHIER_TACHES)
                if [ -n "$tache" ]; then
                    break
                else
                    echo "Erreur : Tâche non trouvée." >&2
                fi
            done

            IFS='|' read -r id titre date_heure_echeance description localisation completion <<< "$tache"
            echo "ID : $id"
            echo "Titre : $titre"
            echo "Date et heure d'échéance : $date_heure_echeance"
            echo "Description : $description"
            echo "Localisation : $localisation"
            echo "Complétion : $completion"
            ;;

        5)
            while true; do
                read -p "Entrez la date (YYYY-MM-DD) pour lister les tâches : " date
                if valider_datetime "$date 00:00:00"; then
                    break
                else
                    echo "Erreur : Format de date invalide. Veuillez entrer au format YYYY-MM-DD." >&2
                fi
            done

            echo "Tâches complétées pour $date :"
            grep "|$date|" $FICHIER_TACHES | grep "|true$" | while IFS='|' read -r id titre date_heure_echeance description localisation completion; do
                echo "- $titre (ID : $id)"
            done

            echo "Tâches non complétées pour $date :"
            grep "|$date|" $FICHIER_TACHES | grep "|false$" | while IFS='|' read -r id titre date_heure_echeance description localisation completion; do
                echo "- $titre (ID : $id)"
            done
            ;;

        6)
            read -p "Entrez le titre pour rechercher : " titre
            resultats=$(grep "|$titre|" $FICHIER_TACHES)
            if [ -z "$resultats" ]; then
                echo "Aucune tâche trouvée avec un titre contenant '$titre'." >&2
                continue
            fi

            echo "Tâches correspondantes :"
            echo "$resultats" | while IFS='|' read -r id titre date_heure_echeance description localisation completion; do
                echo "ID : $id"
                echo "Titre : $titre"
                echo "Date et heure d'échéance : $date_heure_echeance"
                echo "Description : $description"
                echo "Localisation : $localisation"
                echo "Complétion : $completion"
                echo
            done
            ;;

        7)
            exit 0
            ;;

        *)
            echo "Option invalide. Veuillez réessayer."
            ;;
    esac
done
