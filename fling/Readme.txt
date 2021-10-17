fling


	rules
		Les fonctions make_ball, ball_of, new_game, make_move,
get_balls, position_of_ball, servent à faire des conversions de type. 
		
		ball_of_position recherche un élément dans une liste.
		
		eq_ball est un test d'égalité sur le type ball.
		
		La fonction apply_move se décompose en plusieurs étapes:
			1) on crée une balle virtuelle ( virtuelle veut dire
que l'on ne déplace pas la balle "réelle" mais que l'on simule des
déplacements de la balle "réelle". La balle virtuelle et la balle réelle
associée ont le même identifiant. Pour cela j'ai écris une fonction ball_of
qui crée une balle avec une position et un int identifiant ). 
			2)Tant que la balle virtuelle n'est pas à
la même position qu'une balle réelle, on déplace la balle réelle à la place de
la balle virtuelle, on décale d'une case la balle virtuelle dans la direction
voulue. 
			3)Quand on rencontre une balle réelle, on ne déplace
pas la balle réelle associée à la balle virtuelle. On crée un balle virtuelle
associée à la nouvelle balle virtuelle et on recommence du début.
			4) Si on sort de l'espace de
jeu (calculé à l'aide de la fonction dimension) on supprime la balle. 
		
		La fonction move est la concaténation des move_dir appliquées
aux 4 directions. 

		La fonction move_dir est la concaténation de move_possible
appliqué à toutes les balles du jeu, en créant les mouvements associés à
chacune des balles pour une direction donnée

		La fonction move_possible se décompose en plusieurs étape:
			1) y a-t-il une balle dans la case juste à coté de la
balle testée ? Si oui -> move impossible
			2) Si non -> y a t-il une balle plus loin dans la
grille dans la direction où je me déplace ? ( ce test est réalisé avec le même
principe que dans les étapes  1) et 2) de apply_move, sauf que l'on ne déplace
pas la balle réelle ici) Si oui -> le move est valide. On ajoute (balle, dir)
au résultat.  
			3) Si non -> on sort de la grille et le move est
invalide  

		

	solver
		La fonction fusion permet de créer une liste qui est le
produit cartésien élément par élément de 2 listes. Le but est de pouvoir créer
dans le solver à proprement parler une liste dont les éléments sont de type
(move list * game). De pouvoir travailler séparément sur chaque élément d'un
couple puis fusionner les résultats

		J'ai seulement écrit la fonction add car je n'étais pas sûr de
comment utiliser un List.map avec le constructeur ::

		La fonction permet de remettre la liste des coups qui
résolvent la partie dans le bon ordre.
		Le solveur est un parcours en largeur de l'arbre des parties
atteignables avec les coups valides depuis un game initial (celui à la racine
donc). Puisque l'on veut renvoyer une liste de move qui permet de gagner, on
crée un type qui est une liste dont les élements sont de type (move list*
game). J'appelle un (move list * game) un état. La move list est la liste 
des mouvements à faire pour atteindre le game auquel elle est associée depuis
 le game initial. Le parcours de l'arbre :
			1)le [] -> failwith "weird" est là pour éviter un
warning de matching incomplet à la compilation
			2) Je prends le premier élément de ma liste d'états
puis je teste si la partie est gagnée. Si oui je renvoie la move list
associée.
			3) Je calcule l'ensemble des move valides pour le game associé à l'état.
			4) Je crée une liste de move list qui ajoute à la move
list de l'état sur lequel je travaille un move valide. 
			5) Je crée l'ensemble des game atteints par les move
valides
			6) Je fusionne ma move list list et ma game list. Les
deux vont bien correspondre puisque même si les opérations sont faites
séparément, elles sont faites dans le même ordre.
			7) Je concatene cette liste après la liste des états
			8) J'appelle parcours_profondeur sur cette liste
			9) Si la liste est vide le jeu n'a pas de solution.
			Un parcours en profondeur m'avait semblé dans un
premier temps  plus compliqué à implémenter pour ne pas se perdre dans la move
liste associée à un game quand on remonte dans l'arbre après arriver à une
configuration sans solution). Seulement l'utilisation d'une liste reste peu
adaptée en terme de complexité pour un parcours en profondeur, on aurait
préféré utiliser une file (notamment pour l'étape 7))

	game 
		loop 
			A chaque tour de boucle on teste si la partie est
gagnée.  

			
		
 
