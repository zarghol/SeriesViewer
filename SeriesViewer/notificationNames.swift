//
//  notificationNames.swift
//  SeriesViewer
//
//  Created by Clément NONN on 27/12/2014.
//  Copyright (c) 2014 Clément NONN. All rights reserved.
//

import Foundation

/// Les noms des notifications envoyées ainsi que leurs significations
enum NotificationsNames: String {
    /// On veut récupérer le token de ce membre
    //case recuperationToken = "recuperationToken"
    /// Le mot de passe / identifiant n'est pas valide pour se connecter
    //case mauvaisPassword = "mauvaisPassword"
    /// Le token actuel est bien actif
    //case tokenActive = "tokenActive"
    /// On récupère toutes les infos du membre (c'est à dire ces séries mais aussi ses stats)
    //case resultatMembre = "resultatMembre"
    /// On a récupéré la totalité d'une série (avec épisode et bannière)
    //case serieComplete = "serieComplete"
    /// On a récupéré les premières infos des séries : on a pas encore les épisodes ni les bannières -> pas indispensable pour l'affichage de la liste de séries
    //case recuperationSeries = "recuperationSeries"
    /// Toutes les séries sont complètes, avec les épisodes et les bannières
    //case seriesCompletes = "seriesCompletes"
    /// La bannière est récupérée, on peut l'afficher si besoin est
    case banniereRecupere = "banniereRecupere"
    /// Les épisodes sont récupéré, on peut mettre à jour la liste
    case episodesRecupere = "episodesRecupere"
    /// On vient de dragger un fichier dans la fenetre => on le passe au scraper, et on ajoute le lien à l'episode correspondant
    case fichierRecupere = "fichierRecupere"
    
    /// Les résultats de la recherche de séries par le champ de recherche
    //case resultatRecherche = "resultatRecherche"
    
    /// Affiche la demande de connexion à l'utilisateur
    //case afficheDemandeMembre = "afficheDemandeMembre"
    
    /// Fin du différentiel des séries locales et des séries web
    //case finDifferentiel = "finDifferentiel"
}

