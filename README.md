
## Description

**Plugin pour afficher des images.**

Pour lancer le plugin dire '***montre-toi***': cela affichera une interface graphique dans le navigateur web.

Ensuite, pour afficher une image d'éléphant par exemple, dire '***montre-moi un éléphant***'. Jarvis effectuera une recherche sur Google ou Qwant et affichera la première image qui correspond à 'un éléphant'.

Vous pouvez continuer à utiliser Jarvis normalement, la conversation est retranscrite dans l'interface.

## Dépendences

Ce plugin utilise [Websocketd](http://websocketd.com/).
Le module sera téléchargé lors de l'installation (~7Mb).

## Captures

![Interface](/../media/jarvis-montre-moi/interface_sample_1.png?raw=true )

![Image](/../media/jarvis-montre-moi/media/interface_sample_2.png?raw=true )

## Usage

```
Vous: Montre-toi
Jarvis: 2 secondes, je me prépare...
Jarvis: Me voici

Vous: Montre-moi un éléphant
Jarvis: Je regarde les images disponibles...
Jarvis: Voici 'un éléphant'...
```

## Contribuer

Vous pouvez ajouter de nouvelles interactions graphiques en 2 étapes :
1) Côté Jarvis, appeler la fonction 
```
	jv_pg_mm_enqueue_event "action" "data"
```

2) Dans le fichier '**www/js/app.js**', ajouter un cas de traitement
```
var handleMessage = function (event) {
//...
	case "action" :
		myTreatment(detail); // detail contient "data"
	break;
//...
}
```

Vous pouvez utiliser des images GIF pour l'animation du robot.
Voir pour cela le paramètre de configuration '**jv_pg_mm_bot_face**'

Vous pouvez changer les animations CSS par defaut via le fichier '**www/css/bot.css**'. Pour vous aider, vous pouvez utiliser [ce CodePen](https://codepen.io/Lakadev/pen/RxbKdV/)

Si vous ajoutez de nouvelles expressions, pensez à les déclarer dans la variable 'validStatus' à la fin du fichier '**www/js/app.js**'.

## Auteur
[Lakadev](http://www.lakadev.com)

---


----------- English Version -----------


## Description
**Plugin to display images.**

To launch the plugin say '***show yourself***': this will display a graphical interface in the web browser.

To display the image of an elephant for example, say '***show me an elephant***'. Jarvis will search on Google or Qwant and display the first image corresponding to 'an elephant'.


You can continue to use Jarvis normally, the conversation is transcribed in the interface.

## Dependencies

This plugin uses [Websocketd](http://websocketd.com/).
It will be downloaded during install (~7Mb).

## Screenshots

![Interface]()

![Image]()

## Usage

```
You: Show yourself
Jarvis: One moment, I'm getting ready...
Jarvis: Here I am

You: Show me an elephant
Jarvis: Here's 'an elephant'...
```

## Contribute

You can add new graphical interactions in 2 steps:
1) Jarvis side, call the function
```
jv_pg_mm_enqueue_event "action" "data"
```

2) In the file '**www/js/app.js**', add the treatment 
```
var handleMessage = function (event) {
// ...
case "action":
	myTreatment(detail); // detail contains "data"
break;
// ...
}
```

You can use GIF images for the robot animation.
See the configuration parameter '**jv_pg_mm_bot_face**'.

You can add or edit the default CSS animation via the '**www/css/bot.css**' file. In order to help you, you can use [this CodePen](https://codepen.io/Lakadev/pen/RxbKdV/)

If you add new expressions, don't forget to declare them in the variable 'validStatus' at the end of the file '**www/js/app.js**'.

## Author
[Lakadev](http://www.lakadev.com)
 