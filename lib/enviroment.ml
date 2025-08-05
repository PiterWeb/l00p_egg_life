open Raylib

type enviroment = {
  grass_model: Model.t;
  grass_positions: Vector2.t array;
  grass_eat_count: int ref;
}

let touching_grass pos enviroment =
  match Array.find_index (fun g -> Vector2.distance pos g <= 2.0) enviroment.grass_positions with
    | Some(gi) -> (gi, true)
    | None -> (0, false)

let get_grass _ = 
  let grass_model = load_model "./assets/grass.glb" in
  let grass_marqued_max_num = 50 in
  let grass_marqued_positions = List.init grass_marqued_max_num (fun _ -> List.init grass_marqued_max_num (fun _ -> Random.int @@ 10 = 0)) in
  let grass_possible_pos_count = (List.length grass_marqued_positions / 2) - 1 in
  let grass_count = Utils.count_if (fun g -> g) grass_marqued_positions in 
  let grass_positions = Array.init grass_count (fun _ -> Vector2.create 0.0 0.0) in
  let index = ref 0 in
  for x_cord = 0 to grass_possible_pos_count * 2  do
    for y_cord = 0 to grass_possible_pos_count * 2 do
      if List.nth (List.nth grass_marqued_positions x_cord) y_cord then ( 
        let pos_x = (float_of_int @@ (x_cord - grass_possible_pos_count) * 5) in
        let pos_y = (float_of_int @@ (y_cord - grass_possible_pos_count) * 5) in
        Vector2.set_x grass_positions.(index.contents) pos_x;
        Vector2.set_y grass_positions.(index.contents) pos_y;
        index := index.contents + 1
      )
    done
  done;
  (* let text = Printf.sprintf "grass_count - %d\n" grass_count in
  trace_log 3 text;
  Array.iteri (fun i g->
    let text = Printf.sprintf "Grass %d x:%f - y:%f\n" i (Vector2.x g) (Vector2.y g) in
    trace_log 3 text
  ) grass_positions; *)
  let grass_eat_count = -10 in
  {grass_model; grass_positions; grass_eat_count = ref grass_eat_count} 