//
//  I18n.swift
//  Centralize iOS
//
//  Created by Max Prudhomme on 06/04/2016.
//  Copyright © 2016 Centralize. All rights reserved.
//

import UIKit

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
        return available_languages[self.current_language]! as! NSDictionary
    }
    
    func locale_en() -> NSDictionary {
        return [
            // Global
            "CENTRALIZE": "Centralize",
            "USERNAME": "Username",
            "PASSWORD": "Password",
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
            "READ_MESSAGE": "Read message"
        ]
    }
    
    func locale_fr() -> NSDictionary {
        return [
            // Global
            "CENTRALIZE": "Centralize",
            "USERNAME": "Identifiants",
            "PASSWORD": "Mot de passe",
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
            "READ_MESSAGE": "Lecture d'un message"
        ]
    }
}
