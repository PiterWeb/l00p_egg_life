open Raylib

let draw_speed_bar ~player_speed =
  (* Draw the background of the progress bar *)
  let width = 400 in
  let height = 20 in
  let position_x = 20 in
  let position_y = 10 in
  draw_rectangle position_x position_y width height Color.gray;
  (* Draw the progress *)
  let progress_width = int_of_float @@ float_of_int width *. (player_speed -. Player.player_min_speed) /. (Player.player_base_speed -. Player.player_min_speed) in
  draw_rectangle position_x position_y progress_width height Color.green;
  (* Draw the border *)
  draw_rectangle_lines position_x position_y width height Color.gray

let draw_objective font (form: Player.player_form) =
  let objective_text = match form with
  | Egg -> "Start jour journey"
  | Chick -> "Grow up and become a hen"
  | Hen -> "Lay your own egg" in
  let position_x = 20.0 in
  let position_y = 40.0 in
  draw_text_ex font ("Objective: " ^ objective_text) (Vector2.create position_x position_y) 24.0 0.0 Color.white

let draw_grass_count font count =
  let count_text = "Grass: " ^ Int.to_string count in
  let position_x = 20.0 in
  let position_y = 70.0 in
  draw_text_ex font count_text (Vector2.create position_x position_y) 24.0 0.0 Color.white

let draw_gui font (enviroment: Map.enviroment) (state: Player.player_state) =
  (* Start Gui *)
  draw_speed_bar ~player_speed:state.player_speed;
  draw_objective font state.player_form;
  draw_grass_count font enviroment.grass_eat_count;
  draw_fps 20 100
  (* End Gui *)