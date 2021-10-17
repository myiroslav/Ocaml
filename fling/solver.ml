let rec fusion l1 l2 = match(l1,l2) with
|([],[]) ->[]
|(hd1::tl1,hd2::tl2) -> (hd1,hd2)::(fusion tl1 tl2)
|_ -> failwith "Lists don't have the same length" 

let add l a = a::l

let reverse l = let rec aux l1 l2 = match l1 with
|[] -> l2
|hd::tl -> aux tl (hd::l2)
in aux l []

(** The idea here is to perform a breadth-first search of the tree of the possible states of the game from a givenintial position. THe configurations of the game are stocked in a list, as well as the list of moves required to reach this state. I don't define a new type but I call a path the liste of moves that transform the initial configuration into the current configuration. A state is now a (path*game). *)
let solve game = 
        let rec bfsearch state_list = match state_list with
        |[] -> failwith "No warning"
        |state::tl-> begin  match Rules.get_balls(snd state) with
                        |hd::[] ->Some (reverse (fst state))
                        |[] -> None
                        |_  -> let g = snd state in let valid_moves = Rules.moves g in 
	                       let new_games = List.map (Rules.apply_move g ) valid_moves in
                               let new_paths = List.map (add (fst state)) valid_moves in 
                               let new_states = fusion new_paths new_games in
                               bfsearch (tl@new_states) end  in bfsearch [([], game)]  
