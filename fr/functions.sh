#!/bin/bash
# Here you can define translations to be used in the plugin functions file
# the below code is an sample to be reused:
# 1) uncomment to function below
# 2) replace XXX by your plugin name (short)
# 3) remove and add your own translations
# 4) you can the arguments $2, $3 passed to this function
# 5) in your plugin functions.sh file, use it like this:
#      say "$(pv_myplugin_lang the_answer_is "oui")"
#      => Jarvis: La réponse est oui

pg_show_me_lang () {
   case "$1" in
   	mm_preparing_phrase) echo "2 secondes, je me prépare...";;
	mm_here_i_am) echo "Me voici";;

    mm_order_regex) echo ".*montre-moi (.*)";;
	mm_not_understood) echo "Je n'ai pas compris ce qu'il faut montrer.";;
	mm_not_found) echo "Désolé, je n'ai pas trouvé d'images.";;
	mm_thinking_phrase) echo "Je regarde les images disponibles...";;
	mm_textual_response) echo "Voici '$2'...";;
	mm_not_ready) echo "Je ne peux pas tout de suite...";;

   esac
} 
