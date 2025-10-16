# calculator_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

en reprenant l'exercice précédent, je dois :
- être capable d'afficher le calcul et calculer et afficher le résultat pour:
les soustractions / additions / multiplications et divisions
- gérer de multiples opérations en une expression
- gérer les nombres négatifs
- gérer les décimales
- effacer le dernier caractère d'une expression (C)
- effacer toute l'expression (AC)
- !!! attention aux nombres infini et division par 0!!!

Pour cela je vais :
- créer un widget qui gère l'affichage du calcul dans calculationText
- créer un widget qui gère le calcul et l'affichage du résultat dans resultText
au fur et à mesure que l'on tape le calcul
- créer un widget qui gère l'affichage du résultat EN GROS quand on tape sur '='
