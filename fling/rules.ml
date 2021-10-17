type direction = Up | Right | Down | Left

type ball = Position.t * int

type move = ball * direction

type game = ball list

let nb_boules = ref 0

let make_ball p = 
        nb_boules:= !nb_boules+1; (p,!nb_boules-1)

(** [ball_of p n] takes a position p and an int n and returns a ball. Its purpose is mainly to create virtual balls to test wether a move is possible or not, without modifying the reference nb_boules *)
let ball_of p n = (p,n)        
        
let new_game ps = ps

let position_of_ball b = fst b  

(** [same_position p p'] takes 2 positions p and p' and returns true iff they're the same, else false. It tests cordinates by coordinates *) 
let same_position p p' = 
        if Position.proj_x p = Position.proj_x p'
        then if Position.proj_y p = Position.proj_y p' then true else false
        else false

(** [is ball g p] takes a game g and a position p, returns true iff there's a ball in g at position p. It does it recursively by testing the position of the first ball of g *)
let rec is_ball g p = match g with 
        |hd::tl -> if same_position (position_of_ball hd) p then true else is_ball tl p
        |[] -> false
           

  
let eq_ball b b' = 
        if snd b = snd b' then true else false

(** [dir_to_move dir] takes a direction and returns a (int*int) . Its purpose is to "vectorize" a direction to virtualy move  ball when testing if a move in a given direction is possible or not *)
let dir_to_move dir = match dir with
|Up -> (0,1)
|Right ->(1,0)
|Down ->(0,-1)
|Left -> (-1,0)


let make_move b d = 
        (b,d)

(** [dimension g pos] takes a game and a projector (from position.ml) , and returns the maximum coordinate of a ball in g towards this projector. Its purpose is to know when to suppress a ball after a valid move, or when a move is invalid if there's no other ball in the wanted direction. *)
let dimension g pos = 
        let rec max_list m game posi = match game with
        |hd::tl -> if posi (position_of_ball hd) > m then max_list ( posi (position_of_ball hd)) tl posi else max_list  m tl posi
        
        |[] -> m 
        in max_list 0 g pos
(** [step move] takes a move  and returns a move new_move, with the same direction and a virtual ball that has the same indentifier as the ball in move but that has moved from 1 square in the given direction. It's purpose is to : test if there's a ball just right next to the one I want to move, or if I can keep going in the same direction *) 
let step move = 
       let b = fst move in 
       let dir = snd move in
       let pos = position_of_ball b in
       let n = snd b in 
       let small_step = dir_to_move dir in 
       let new_pos = Position.from_int (Position.proj_x pos + fst small_step) (Position.proj_y pos + snd small_step)in 
       let new_ball = (new_pos, n) in 
       let new_move = (new_ball, dir) in
       new_move

(** [actualize b g] takes a ball b and a game g and modify in g the position of the ball that has the same identifier as b  *)      
let rec actualize b g = match g with
|hd::tl -> if eq_ball hd b then b::tl else hd::(actualize b tl)
|[] -> failwith "A game must have at list 1 ball - actualize"

(** [suppress b g] takes a ball b and a game g and suppress in g the ball that has the same identifier as b *)
let rec suppress b g = match g with
|hd::tl -> if eq_ball hd b then tl else hd::(suppress b tl)
|[] -> failwith "A game must have at list 1 ball - suppress"

(** [is_in_the_box b g] takes a (usually virtual, i.e that is not in the game g) ball b and a game g, and returns true iff the position of b is inside the box delimited by (0,0) and the max coordinates given by the function [dimension]. Combined with the function [step] it tells when a bell has to be suppressed after a move, or if a move is imposssible if the ball in move gets out of the box without hitinh anyone on its path *)
let is_in_the_box b g = 
        let x = dimension g Position.proj_x in 
        let y = dimension g Position.proj_y in
        let pos_b = position_of_ball b in    
        if( Position.proj_x pos_b > -1 && Position.proj_x pos_b < x+1) 
        then if Position.proj_y pos_b > -1 && Position.proj_y pos_b < y+1 then true else false
        else false

let get_balls g = g


let rec ball_of_position game p = let g = get_balls game in  match g with
|[] -> failwith "None"
|hd::tl -> let pos_hd = position_of_ball hd in  if same_position pos_hd p then hd else ball_of_position tl p

	  
(** [apply_move g move] takes a game g and a move g and returns a game new_g where move has been applied to g. The move move is supposed valid. The game g is actualized after each step, to gain in complexity it could only be actualized when the ball in move hits an other ball, but I would have had to memorize or re-calculate the previous position of the virtual ball.  *)        
let rec apply_move g move = 
        let small_step = step move in (** virtual movement of the ball *)
        let pos = position_of_ball ( fst small_step) in 
        if is_ball g pos 
        then let b = ball_of_position g pos in let new_move = make_move b (snd move) in apply_move g new_move (** if there's a real ball in the position of the virtual ball, the ball contained in 'move' is not moved. I get the real ball, creat a new move with this ball, and the same direction as before, and apply the function 'apply_move' to this new move *)
        else if is_in_the_box (fst small_step) g then let new_g = actualize (fst small_step) g in apply_move new_g small_step (** s'il n'y a pas de balle à l'emplacement de la balle virtuelle, on teste si la balle virtuelle est encore dans les limites du plateau, si oui, on déplace la balle réelle à la place de la balle virtuelle, si non on supprime la balle *)
        else suppress (fst small_step) g   

(** [move_possible move g] takes a move move and a game g and returns true iff move is a valid move in g *)
let move_possible move g = 
        let small_step = step move in
        let pos = position_of_ball ( fst small_step ) in 
        if is_ball g pos then false  (* if there's a ball right next to the ball in move in the given direction then the move is not valid. This test has to be done only once, that's why move_possible can't be recursive *)
        else let rec is_possible mov game = 
                let second_step = step mov in 
                if is_in_the_box (fst second_step) game (* if the virtual ball is still in the box and didn't hit an other ball , then keep going *) 
                then if is_ball game (position_of_ball (fst second_step)) then true else is_possible second_step game (* if the ball hits an other ball the the move is valid *)
                else false (* if the virtual ball gets out of the box then the move is invalid *)
		in is_possible move g
                
(* [moves_dir dir g] takes a direction dir and tries for every ball b in g if the move (b,dir) is a valid move in g. It returns the list of the valid moves in g for the given direction *)                
let moves_dir dir g = 
        let rec aux direction game ball_list = match ball_list with
        |[] -> []
        |hd::tl -> let move = make_move hd direction in let result = aux direction game tl in if move_possible move game then move::result else result
        in let g' = get_balls g in aux dir g g'
                
(* [moves g] takes a game g and returns the list of the valid moves for g. Just a concatenatiion of moves_dir with the diferent directions. *) 
let moves g = (moves_dir Up g)@(moves_dir Down g)@(moves_dir Left g)@(moves_dir Right g)


        


