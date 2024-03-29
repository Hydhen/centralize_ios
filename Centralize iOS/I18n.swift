//
//  I18n.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 06/04/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

var currentLanguage = ""

class I18n {
    var current_language: String = "en"
    init () {
        var cLanguage = "en"
        let hasLanguage = NSUserDefaults.standardUserDefaults().objectForKey("language")
        
        if hasLanguage == nil {
            NSUserDefaults.standardUserDefaults().setObject("en", forKey: "language")
        } else {
            cLanguage = hasLanguage as! String
        }
        
        self.current_language = cLanguage
    }
    
    func load_locales() -> NSDictionary {
        let available_languages: NSDictionary = [
            "en": { self.locale_en() }(),
            "fr": { self.locale_fr() }()
        ]
        currentLanguage = self.current_language
        return available_languages[self.current_language]! as! NSDictionary
    }
    
    func locale_en() -> NSDictionary {
        return [
            // Global
            "CENTRALIZE": "Centralize",
            "USERNAME": "Username",
            "PASSWORD": "Password",
            "BACK": "Back",
            // Menu
            "HOME": "Home",
            "ACCOUNT": "Account",
            "HELP": "Help",
            "LANGUAGES": "Languages",
            "PROFILE": "Profile",
            "DASHBOARDS": "Dashboards",
            "SERVICES": "Services",
            "EDIT_PASSWORD": "Edit your password",
            "FAQ": "FAQ",
            "ASSISTANCE": "Assistance",
            "CONTACT": "Contact",
            "SIGN_OUT": "Sign out",
            // Buttons
            "SAVE": "Save",
            "SIGN_IN": "Sign in",
            "OK": "Ok",
            "CANCEL": "Cancel",
            // Profile
            "YOUR_PROFILE": "Your profile",
            "PASSWORD_MISSING": "Password missing",
            "PASSWORD_MISSING_DESC": "Please enter a password",
            "USERNAME_MISSING": "Username missing",
            "USERNAME_MISSING_DESC": "Please enter a username",
            "EDIT_YOUR_PROFILE": "Edit your profil",
            "FIRST_NAME": "First name",
            "LAST_NAME": "Last name",
            "CITY": "City",
            "COUNTRY": "Country",
            "BIOGRAPHY": "Biography",
            "FIRSTNAME_MISSING": "First name missing",
            "FIRSTNAME_MISSING_DESC": "Please enter your first name",
            "LASTNAME_MISSING": "Last name missing",
            "LASTNAME_MISSING_DESC": "Please enter your last name",
            "PROFILE_SAVED": "Profile saved",
            "PROFILE_SAVED_DESC": "Your profile has been saved",
            // Languages
            "LANGUAGE_SAVED": "Language saved",
            "LANGUAGE_SAVED_DESC": "The language of the app is now English\nPlease restart the app to conplete changes",
            // Errors
            "ERROR": "An error occured",
            "ERROR_DESC": "Something gone wrong, please try again",
            "CEN_NOT_REACHABLE": "Centralize is not reachable",
            "CEN_NOT_REACHABLE_DESC": "The website is currently not reachable, check your connection and try again",
            "ACCOUNT_UNKNOWN": "Account unknown",
            "ACCOUNT_UNKNOWN_DESC": "No account found with these credentials",
            "CONNECTION_ERROR": "Connection error",
            "CONNECTION_ERROR_DESC": "The connection to the website is currently not possible, please try later",
            "CEN_NO_DATA_RECEIVED": "No data received",
            "CEN_NO_DATA_RECEIVED_DESC": "The data received are empty, please try again",
            // Gmail
            "THREADS": "Threads",
            "NO_THREADS": "No threads unread",
            "MESSAGES": "Messages",
            "READ_MESSAGE": "Read message",
            "SEARCH_LOAD_MORE": "Load more",
            "SEARCH_EMPTY": "Search field is empty",
            "SEARCH_EMPTY_DESC": "Search cannot be empty, please enter keywords",
            "SEARCH_KEYWORD": "Enter any keyword in the search bar",
            "SEARCH_NOT_FOUND": "No result found",
            "SEARCH_NO_MORE": "No more results",
            "SEARCH_NO_MORE_DESC": "No more results has been found for this keywords",
            //----------------------//
            //  GOOGLE CALENDAR     //
            //----------------------//
            "CALENDAR_LIST_TITLE": "Calendars",
            "CALENDAR_NO_CALENDARS": "No calendars found",
            "CALENDAR_SUMMARY_EMPTY": "Summary is empty",
            "CALENDAR_SUMMARY_EMPTY_DESC": "Summary cannot be empty",
            "CALENDAR_LIST_EVENT_TITLE": "Events",
            "CALENDAR_LIST_EVENT_NO_EVENT": "No event found",
            "CALENDAR_LIST_REMINDER_TITLE": "Events",
            "CALENDAR_LIST_REMINDER_NO_REMINDER": "No event found",
            "CALENDAR_EVENT_DELETE": "Deleting event",
            "CALENDAR_EVENT_DELETE_DESC": "You're about to delete this event, are you sure?",
            "CALENDAR_EVENT_UNNAMED": "(Unnamed event)",
            "CALENDAR_EVENT_START": "Start",
            "CALENDAR_EVENT_END": "End",
            "CALENDAR_EVENT_START_LATER_THAN_END": "Start later than end",
            "CALENDAR_EVENT_START_LATER_THAN_END_DESC": "Start cannot be later than end",
            "CALENDAR_TIME_ALLDAY": "All-day",
            "CALENDAR_DETAILS_DESCRIPTION": "Description",
            "CALENDAR_DETAILS_NO_DESCRIPTION": "(This event has no description)",
            "CALENDAR_DETAILS_NO_LOCATION": "(This event has no location)",
            //----------------------//
            //  GOOGLE DRIVE        //
            //----------------------//
            "DRIVE": "Drive",
            "DRIVE_NO_FILE": "No file found",
            "DRIVE_ROOT": "Root",
            "DRIVE_BACK": "Back",
            "DRIVE_DETAILS": "Details",
            "DRIVE_SIZE": "Size of file",
            "DRIVE_CREATION": "Created on",
            "DRIVE_MODIFICATION": "Last modified on",
            "DRIVE_OPEN": "Open",
            "DRIVE_DOWNLOAD": "Download",
            "DRIVE_SHARE": "Share",
            "DRIVE_SIZE_NULL": "Unknown",
            "DRIVE_DATE_UNKNOWN": "Unknwon date",
            "DRIVE_DOWNLOAD": "Download",
            "DRIVE_OPEN_IN_BROWSER": "Open",
            "DRIVE_SHARE_RECEIVER": "Email",
            "DRIVE_SHARE_NOTIFICATION": "Send notification?",
            "DRIVE_RIGHT_READER": "Reader",
            "DRIVE_RIGHT_WRITER": "Writer",
            "DRIVE_RIGHT_COMMENTER": "Commenter",
            "DRIVE_WRONG_EMAIL_TITLE": "Invalid email",
            "DRIVE_WRONG_EMAIL_MESSAGE": "You entered an invalid email, please try again",
            //----------------------//
            //  SLACK               //
            //----------------------//
            "SLACK_EMPTY_MESSAGE_SHORT": "Message empty",
            "SLACK_EMPTY_MESSAGE_LONG": "Your message cannot be empty",
        ]
    }
    
    func locale_fr() -> NSDictionary {
        return [
            // Global
            "CENTRALIZE": "Centralize",
            "USERNAME": "Identifiants",
            "PASSWORD": "Mot de passe",
            "BACK": "Retour",
            // Menu
            "HOME": "Accueil",
            "ACCOUNT": "Compte",
            "HELP": "Aide",
            "PROFILE": "Profil",
            "LANGUAGES": "Langues",
            "DASHBOARDS": "Tableaux de bords",
            "SERVICES": "Services",
            "EDIT_PASSWORD": "Changer le mot de passe",
            "FAQ": "FAQ",
            "ASSISTANCE": "Assistance",
            "CONTACT": "Contact",
            "SIGN_OUT": "Déconnexion",
            // Buttons
            "SAVE": "Enregistrer",
            "SIGN_IN": "Connexion",
            "OK": "Ok",
            "CANCEL": "Annuler",
            // Profile
            "YOUR_PROFILE": "Votre profil",
            "PASSWORD_MISSING": "Mot de passe manquant",
            "PASSWORD_MISSING_DESC": "Veuillez indiquer un mot de passe",
            "USERNAME_MISSING": "Identifiant manquant",
            "USERNAME_MISSING_DESC": "Veuillez indiquer un identifiant",
            "EDIT_YOUR_PROFILE": "Modifier votre profil",
            "FIRST_NAME": "Prénom",
            "LAST_NAME": "Nom",
            "CITY": "Ville",
            "COUNTRY": "Pays",
            "BIOGRAPHY": "Biographie",
            "FIRSTNAME_MISSING": "Prénom manquant",
            "FIRSTNAME_MISSING_DESC": "Veuillez indiquer votre prénom",
            "LASTNAME_MISSING": "Nom manquant",
            "LASTNAME_MISSING_DESC": "Veuillez indiquer votre nom",
            "PROFILE_SAVED": "Profil sauvegardé",
            "PROFILE_SAVED_DESC": "Votre profil a bien été sauvegardé",
            // Languages
            "LANGUAGE_SAVED": "Langue enregistrée",
            "LANGUAGE_SAVED_DESC": "La langue de l'application est maintenant Français\nRedémarrez l'application pour appliquer le changement",
            // Errors
            "ERROR": "Une erreur est survenue",
            "ERROR_DESC": "Quelque chose s'est mal passé, veuillez réessayer",
            "CEN_NOT_REACHABLE": "Centralize n'est pas joignable",
            "CEN_NOT_REACHABLE_DESC": "Impossible de joindre le site internet, vérifiez votre connexion et réessayez",
            "ACCOUNT_UNKNOWN": "Compte non trouvé",
            "ACCOUNT_UNKNOWN_DESC": "Aucun compte trouvé avec ces identifiants",
            "CONNECTION_ERROR": "Erreur de connexion",
            "CONNECTION_ERROR_DESC": "La connexion au site est temporairement indisponible, veuillez réessayer",
            "CEN_NO_DATA_RECEIVED": "Aucune données reçues",
            "CEN_NO_DATA_RECEIVED_DESC": "Les données reçues sont vides, merci de réessayer",
            // Gmail
            "THREADS": "Fils de discussion",
            "NO_THREADS": "Aucun fil de discussion non-lu trouvé",
            "MESSAGES": "Messages",
            "READ_MESSAGE": "Lecture d'un message",
            "SEARCH_LOAD_MORE": "Charger plus",
            "SEARCH_EMPTY": "Champ de recherche vide",
            "SEARCH_EMPTY_DESC": "Le champ de recherche est vide, veuillez saisir des mots clés",
            "SEARCH_KEYWORD": "Entrer vos mots clés dans la barre de recherche",
            "SEARCH_NOT_FOUND": "Aucun résultat trouvé",
            "SEARCH_NO_MORE": "Plus de résultat",
            "SEARCH_NO_MORE_DESC": "Aucun résultat supplémentaire n'as été trouvé avec ces mots-clés",
            //----------------------//
            //  GOOGLE CALENDAR     //
            //----------------------//
            "CALENDAR_LIST_TITLE": "Calendriers",
            "CALENDAR_NO_CALENDARS": "Aucun calendriers trouvés",
            "CALENDAR_SUMMARY_EMPTY": "Le résumé est vide",
            "CALENDAR_SUMMARY_EMPTY_DESC": "Le résumé ne peut pas être vide",
            "CALENDAR_LIST_EVENT_TITLE": "Évènements",
            "CALENDAR_LIST_EVENT_NO_EVENT": "Aucun élément trouvé",
            "CALENDAR_EVENT_DELETE": "Suppression d'évènement",
            "CALENDAR_EVENT_DELETE_DESC": "Vous allez supprimer un évènement, êtes-vous sur ?",
            "CALENDAR_EVENT_UNNAMED": "(Évènement anonyme)",
            "CALENDAR_EVENT_START": "Début",
            "CALENDAR_EVENT_END": "Fin",
            "CALENDAR_EVENT_START_LATER_THAN_END": "Début plus tard que la fin",
            "CALENDAR_EVENT_START_LATER_THAN_END_DESC": "Le début de l'évènement ne peut pas être plus tard que la fin",
            "CALENDAR_TIME_ALLDAY": "Toute la journée",
            "CALENDAR_DETAILS_DESCRIPTION": "Description",
            "CALENDAR_DETAILS_NO_DESCRIPTION": "(Cet évènement n'a pas de description)",
            "CALENDAR_DETAILS_NO_LOCATION": "(Cet évènement n'a pas de localisation)",
            //----------------------//
            //  GOOGLE DRIVE        //
            //----------------------//
            "DRIVE": "Drive",
            "DRIVE_NO_FILE": "Aucun fichier trouvé",
            "DRIVE_ROOT": "Racine",
            "DRIVE_BACK": "Retour",
            "DRIVE_DETAILS": "Détails",
            "DRIVE_SIZE": "Taille du fichier",
            "DRIVE_CREATION": "Créé le",
            "DRIVE_MODIFICATION": "Dernière modification le",
            "DRIVE_OPEN": "Ouvrir",
            "DRIVE_DOWNLOAD": "Télécharger",
            "DRIVE_SHARE": "Partager",
            "DRIVE_SIZE_NULL": "Inconnue",
            "DRIVE_DATE_UNKNOWN": "Date inconnue",
            "DRIVE_DOWNLOAD": "Télécharger",
            "DRIVE_OPEN_IN_BROWSER": "Ouvrir",
            "DRIVE_SHARE_RECEIVER": "Email",
            "DRIVE_SHARE_NOTIFICATION": "Notifier par email ?",
            "DRIVE_RIGHT_READER": "Lecture",
            "DRIVE_RIGHT_WRITER": "Ecriture",
            "DRIVE_RIGHT_COMMENTER": "Commenter",
            "DRIVE_WRONG_EMAIL_TITLE": "Email invalide",
            "DRIVE_WRONG_EMAIL_MESSAGE": "Vous avez rentré une adresse email invalide, veuillez réessayer",
            //----------------------//
            //  SLACK               //
            //----------------------//
            "SLACK_EMPTY_MESSAGE_SHORT": "Message vide",
            "SLACK_EMPTY_MESSAGE_LONG": "Votre message ne peut pas être vide",
        ]
    }
}
