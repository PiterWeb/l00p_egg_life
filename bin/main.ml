open Raylib
open Game

type state = {
  player_state: Player.player_state;
  camera: Camera2D.t;
}

(* let change_model last_player_model form =
  unload_model last_player_model;
  let model_path = "./assets/" ^ (match form with
    | Egg -> "egg"
    | Chick -> "chick"
    | Hen -> "hen"
  ) ^ ".glb" in
  load_model model_path *)

let full_screen_handler () =
  if is_key_pressed Key.F11 then
    let display = get_current_monitor () in
    (match is_window_fullscreen () with
    | true -> set_window_size Window.width Window.height
    | false -> set_window_size (get_monitor_width display) (get_monitor_height display));
    toggle_fullscreen ()

let controls state =
  let player_state = state.player_state in
  let x = Vector2.x player_state.player_position in
  let y = Vector2.y player_state.player_position in
  let speed = match player_state.player_speed with
    | speed when speed <= Player.player_min_speed || speed >= Player.player_base_speed -> Player.player_base_speed
    | speed -> speed
  in
  let delta_time = get_frame_time() in
  let player_speed = speed +. Player.player_acceleration *. delta_time in
  player_state.player_speed <- player_speed;
  if is_key_down Key.A then (
    player_state.player_direction <- Left;
    Vector2.set_x player_state.player_position (x -. player_speed *. delta_time);
  );
  if is_key_down Key.D then (
    player_state.player_direction <- Right;
    Vector2.set_x state.player_state.player_position (x +. player_speed *. delta_time);
  );
  if is_key_down Key.S then (
    player_state.player_direction <- Front;
    Vector2.set_y player_state.player_position (y +. player_speed *. delta_time);
  );
  if is_key_down Key.W then (
    player_state.player_direction <- Back;
    Vector2.set_y player_state.player_position (y -. player_speed *. delta_time);
  );
  if not (is_key_down Key.W) && not (is_key_down Key.A) && not (is_key_down Key.S) && not (is_key_down Key.D) then (
    player_state.player_speed <- (speed -. Player.player_acceleration *. delta_time);
  ) else (
    Camera2D.set_target state.camera player_state.player_position;
    match Map.is_outside_map player_state.player_position with
      | true -> (
        Vector2.set_x player_state.player_position x;
        Vector2.set_y player_state.player_position y;
      )
      | false -> ()
  );
  state

let drawing (enviroment: Map.enviroment) (state: Player.player_state) =
  (* Start Canvas *)
  let (texture, position) = (state.player_texture, state.player_position) in
  let promise_touching_grass = Miou.async @@ fun () -> (match Map.touching_grass state.player_position enviroment with
    | (g_index, true) -> 
      Vector2.set_x enviroment.grass_positions.(g_index) 1_000.0;
      Vector2.set_y enviroment.grass_positions.(g_index) 1_000.0;
      enviroment.grass_eat_count <- enviroment.grass_eat_count + 1
    | (_, false) -> ()) in
  Map.draw_visible_terrain enviroment.map_texture position;
  let promise_draw_player = Miou.async @@ fun () -> (match state.player_form with
    | Egg -> Player.draw_egg texture position
    | Chick -> ()
    | Hen -> (
      match state.player_direction with
      | Left -> Player.draw_chicken_left texture position
      | Right -> Player.draw_chicken_right texture position
      | Front -> Player.draw_chicken_front texture position
      | Back -> Player.draw_chicken_back texture position
    )
  ) in
  Map.draw_visible_grass enviroment.map_texture enviroment.grass_positions position;
  ignore @@ Miou.await_all [promise_draw_player; promise_touching_grass]
  (* End Canvas *)
  
let rec loop font enviroment state =
  if window_should_close () then close_window ()
  else
    full_screen_handler ();
    let promise_state = Miou.async @@ fun () -> (match state.player_state.player_form with
      | Egg -> state
      | Chick -> state 
      | Hen -> controls state) in
    begin_drawing ();
    Camera2D.set_offset state.camera (Vector2.create (float_of_int @@ get_render_width () / 2) (float_of_int @@ get_render_height () / 2));
    begin_mode_2d state.camera;
    clear_background Color.white;

    drawing enviroment state.player_state;
    
    end_mode_2d ();
    Gui.draw_gui font enviroment state.player_state;
    end_drawing ();
    let state = Miou.await_exn promise_state in
    loop font enviroment state

let () = Miou.run @@ fun () ->
  Window.setup ();
  let promise_enviroment = Miou.async @@ Map.init_enviroment in
  let camera = Camera2D.create
    (Vector2.create (float_of_int @@ get_render_width () / 2) (float_of_int @@ get_render_height () / 2))
    (Vector2.create 0.0 0.0)
    0.0
    2.5 in
  let _ = Player.Egg in
  let _ = Player.Chick in
  let player_form = Player.Hen in
  let player_position = Vector2.create 0.0 0.0 in
  let player_speed = Player.player_base_speed in
  let player_direction = Player.Front in
  let font = load_font "./assets/open-sans.bold-italic.ttf" in
  let player_texture = Player.load_chicken_texture () in
  let player_state: Player.player_state = {player_position; player_speed; player_direction; player_form; player_texture} in
  let state = {camera; player_state} in
  let enviroment = Miou.await_exn promise_enviroment in
  loop font enviroment state