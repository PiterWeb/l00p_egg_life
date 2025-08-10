open Raylib

type enviroment = {
  map_texture: Texture2D.t;
  grass_positions: Vector2.t array;
  mutable grass_eat_count: int;
}

let map_max_limit = 1_000.0
let map_min_limit = -.map_max_limit

let max_map_visible = lazy (float_of_int @@ get_render_width () )
let max_player_distance = lazy(Lazy.force max_map_visible /. 2.0)

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
    (Vector2.distance pos g <= grass_hitbox) && y_cord <> 0.0
  ) enviroment.grass_positions with
    | Some(gi) -> (gi, true)
    | None -> (0, false)

let load_map_texture _ =
  load_texture "./assets/map.png"

let draw_grass texture position =
  draw_texture_rec texture (Rectangle.create 16.0 (5.0 *. 16.0) 16.0 16.0) position Color.white

let draw_terrain texture position =
  draw_texture_rec texture (Rectangle.create 80.0 (5.0 *. 16.0) 16.0 16.0) position Color.white

let draw_visible_grass texture grass_positions player_position =
  let max_player_distance = Lazy.force max_player_distance in
  (* trace_log 3 (Printf.sprintf "Max_player_distance: %f" max_player_distance); *)
  Array.iter (fun g_pos ->
    let y_cord = Vector2.y g_pos in  
    if y_cord < -24.0 || y_cord > 24.0 then (
      let distance = Vector2.distance g_pos player_position in
      if distance <= max_player_distance then draw_grass texture g_pos
    )
  ) grass_positions

let draw_visible_terrain texture player_position =
  let max_player_distance = Lazy.force max_player_distance in
  let max_x = int_of_float @@ Vector2.x player_position +. max_player_distance in 
  let min_x = int_of_float @@ Vector2.x player_position -. max_player_distance in
  let max_y = int_of_float @@ Vector2.y player_position +. max_player_distance in
  let min_y = int_of_float @@ Vector2.y player_position -. max_player_distance in
  for x =  min_x to max_x do
    let x_divisible_by_16 = (x mod 16) = 0 in
    if x_divisible_by_16 then (
      for y = min_y to max_y do
        let y_divisible_by_16 = (y mod 16) = 0 in
        if y_divisible_by_16 then (
          draw_terrain texture (Vector2.create (float_of_int x) (float_of_int y)) 
        )
      done
    )
  done


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
  grass_positions

let init_enviroment _ =
  let map_texture = load_map_texture () in
  let grass_positions = get_grass_calc () in
  let grass_eat_count = 0 in
  {map_texture; grass_positions; grass_eat_count}