open Raylib

type enviroment = {
  map_texture: Texture2D.t;
  grass_positions: Vector2.t array;
  grass_eat_count: int ref;
}

let map_max_limit = 1_000.0
let map_min_limit = -.map_max_limit

let grass_hitbox = 14.0

let is_outside_map pos =
  (match Vector2.x pos with
    | x when x >= map_max_limit -> true
    | x when x <= map_min_limit -> true
    | _ -> false
  ) || (match Vector2.y pos with
    | y when y >= map_max_limit -> true
    | y when y <= map_min_limit -> true 
    | _ -> false
  )

let touching_grass pos enviroment =
  match Array.find_index (fun g -> 
    let y_cord = Vector2.y g in
    (Vector2.distance pos g <= grass_hitbox)  && y_cord <> 0.0
  ) enviroment.grass_positions with
    | Some(gi) -> (gi, true)
    | None -> (0, false)

let load_map_texture _ =
  load_texture "./assets/map.png"

let draw_grass texture position =
  draw_texture_rec texture (Rectangle.create 16.0 (5.0 *. 16.0) 16.0 16.0) position Color.white

let get_grass_calc _ = 
  let grass_marqued_max_num = 550 in
  let grass_marqued_positions = List.init grass_marqued_max_num (fun _ -> List.init grass_marqued_max_num (fun _ -> Random.int @@ 15 = 0)) in
  let grass_possible_pos_count = (List.length grass_marqued_positions / 2) - 1 in
  let grass_count = Utils.count_if (fun g -> g) grass_marqued_positions in 
  let grass_positions = Array.init grass_count (fun _ -> Vector2.create 0.0 0.0) in
  let index = ref 0 in
  let separation_between_grass = 16 in
  for x_cord = 0 to grass_possible_pos_count * 2  do
    for y_cord = 0 to grass_possible_pos_count * 2 do
      if List.nth (List.nth grass_marqued_positions x_cord) y_cord then ( 
        let pos_x = (float_of_int @@ (x_cord - grass_possible_pos_count) * separation_between_grass) in
        let pos_y = (float_of_int @@ (y_cord - grass_possible_pos_count) * separation_between_grass) in
        if pos_y > 16.0 || pos_y < -16.0 then (
          Vector2.set_x grass_positions.(index.contents) pos_x;
          Vector2.set_y grass_positions.(index.contents) pos_y;
          index := index.contents + 1
        )
      )
    done
  done;
  (* let text = Printf.sprintf "grass_count - %d\n" grass_count in
  trace_log 3 text;
  Array.iteri (fun i g->
    let text = Printf.sprintf "Grass %d x:%f - y:%f\n" i (Vector2.x g) (Vector2.y g) in
    trace_log 3 text
  ) grass_positions; *)
  let grass_eat_count = 0 in
  (grass_positions, ref grass_eat_count) 

let init_enviroment _ =
  let map_texture = load_map_texture () in
  let (grass_positions, grass_eat_count) = get_grass_calc () in
  {map_texture; grass_positions; grass_eat_count}