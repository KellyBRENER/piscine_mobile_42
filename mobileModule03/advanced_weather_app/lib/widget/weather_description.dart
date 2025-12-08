import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

IconData getWeatherIcon(int weatherCode) {
  switch (weatherCode) {
    case 0: // Ciel clair
      return FontAwesomeIcons.solidSun;
    case 1: // Principalement clair
    case 2: // Partiellement nuageux
      return FontAwesomeIcons.cloudSun;
    case 3: // Couvert
      return FontAwesomeIcons.cloud;
    case 45: // Brouillard
    case 48: // Brouillard givrant
      return FontAwesomeIcons.smog;

    // Bruine
    case 51:
    case 53:
    case 55:
    case 56:
    case 57:
      return FontAwesomeIcons.cloudRain;

    // Pluie
    case 61: // Pluie légère
    case 63: // Pluie modérée
    case 65: // Pluie forte
    case 66: // Pluie verglaçante légère
    case 67: // Pluie verglaçante forte
      return FontAwesomeIcons.cloudShowersHeavy;

    // Neige
    case 71: // Neige légère
    case 73: // Neige modérée
    case 75: // Neige forte
    case 77: // Grains de neige
      return FontAwesomeIcons.snowflake;

    // Averses
    case 80: // Averses de pluie légère
    case 81: // Averses de pluie modérées
    case 82: // Averses de pluie fortes
      return FontAwesomeIcons.cloudShowersHeavy;

    // Averses de neige
    case 85:
    case 86:
      return FontAwesomeIcons.cloudMeatball; // Une icône de neige plus lourde

    // Orages
    case 95: // Orage
    case 96: // Orage avec grêle
    case 99: // Orage avec forte grêle
      return FontAwesomeIcons.cloudBolt;

    default:
      return FontAwesomeIcons.circleQuestion; // Icône par défaut
  }
}

final Map<int, String> weatherCodeMap = {
  0: "Ciel clair",
  1: "Principalement clair",
  2: "Partiellement nuageux",
  3: "Couvert",
  45: "Brouillard",
  48: "Brouillard givrant",
  51: "Pluie fine",
  53: "Pluie modérée",
  55: "Pluie forte",
  56: "Pluie verglaçante légère",
  57: "Pluie verglaçante forte",
  61: "Pluie faible",
  63: "Pluie modérée",
  65: "Pluie forte",
  66: "Pluie verglaçante faible",
  67: "Pluie verglaçante forte",
  71: "Neige faible",
  73: "Neige modérée",
  75: "Neige forte",
  77: "Grains de neige",
  80: "Averse de pluie faible",
  81: "Averse de pluie modérée",
  82: "Averse de pluie forte",
  85: "Averse de neige faible",
  86: "Averse de neige forte",
  95: "Orage",
  96: "Orage avec pluie faible",
  99: "Orage avec pluie forte"
};

String getWeatherDescription(int code) {
  return weatherCodeMap[code] ?? "Weather code aknown";
}