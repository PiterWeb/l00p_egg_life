open Raylib
open Hello_world

type player_form =
  | Egg
  | Chick
  | Hen

type player_state = {
  player_position: Vector2.t;
  player_speed: float ref;
  player_model: Model.t;
  player_angle: float ref;
  player_form: player_form ref;
}

type state = {
  player_state: player_state;
  camera: Camera3D.t;
}

(* let change_model state form =
  unload_model state.player_model;
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

let draw_speed_bar player_speed =
  (* Draw the background of the progress bar *)
  let width = 400 in
  let height = 20 in
  let position_x = 20 in
  let position_y = 10 in
  draw_rectangle position_x position_y width height Color.gray;
  (* Draw the progress *)
  let progress_width = int_of_float @@ float_of_int width *. player_speed /. Player.player_base_speed in
  draw_rectangle position_x position_y progress_width height Color.green;
  (* Draw the border *)
  draw_rectangle_lines position_x position_y width height Color.black

let draw_objective font form =
  let objective_text = match form with
  | Egg -> "Start jour journey"
  | Chick -> "Grow up and become a hen"
  | Hen -> "Lay your own egg" in
  let position_x = 20.0 in
  let position_y = 40.0 in
  draw_text_ex font ("Objective: " ^ objective_text) (Vector2.create position_x position_y) 24.0 0.0 Color.black

let draw_grass_count font count =
  let count_text = "Grass: " ^ Int.to_string count in
  let position_x = 20.0 in
  let position_y = 70.0 in
  draw_text_ex font count_text (Vector2.create position_x position_y) 24.0 0.0 Color.black

let gui font (enviroment: Enviroment.enviroment) state =
  (* Start Gui *)
  draw_speed_bar state.player_state.player_speed.contents;
  draw_objective font state.player_state.player_form.contents;
  draw_grass_count font enviroment.grass_eat_count.contents
  (* End Gui *)

let controls state =
  let player_state = state.player_state in
  let x = Vector2.x player_state.player_position in
  let y = Vector2.y player_state.player_position in
  let speed = match player_state.player_speed.contents with
    | speed when speed <= Player.player_min_speed || speed >= Player.player_base_speed -> Player.player_base_speed
    | speed -> speed
  in
  let delta_time = get_frame_time() in
  let player_speed = speed +. Player.player_acceleration *. delta_time in
  player_state.player_speed := player_speed;
  if is_key_down Key.A then (
    player_state.player_angle := 90.0;
    Vector2.set_x player_state.player_position (x +. player_speed *. delta_time);
  );
  if is_key_down Key.D then (
    player_state.player_angle := 270.0;
    Vector2.set_x state.player_state.player_position (x -. player_speed *. delta_time);
  );
  if is_key_down Key.S then (
    player_state.player_angle := 180.0;
    Vector2.set_y player_state.player_position (y -. player_speed *. delta_time);
  );
  if is_key_down Key.W then (
    player_state.player_angle := 0.0;
    Vector2.set_y player_state.player_position (y +. player_speed *. delta_time);
  );
  if not (is_key_down Key.W) && not (is_key_down Key.A) && not (is_key_down Key.S) && not (is_key_down Key.D) then (
    player_state.player_speed := (speed -. Player.player_acceleration *. delta_time);
  ) else (
    Camera3D.set_target state.camera (Vector3.create (Vector2.x player_state.player_position) 0.0 (Vector2.y player_state.player_position));
    Camera3D.set_position state.camera (Vector3.create (Vector2.x player_state.player_position) 10.0 (Vector2.y player_state.player_position));
    match Map.is_outside_map player_state.player_position with
      | true -> (
        Vector2.set_x player_state.player_position x;
        Vector2.set_y player_state.player_position y;
      )
      | false -> ()
    (* let camera_position_text = Printf.sprintf "camera position - x:%f y:%f z:%f\n" (Vector3.x @@ Camera3D.position state.camera) (Vector3.y @@ Camera3D.position state.camera) (Vector3.z @@ Camera3D.position state.camera) in
    trace_log 3 camera_position_text; *)
  );
  state

let drawing (enviroment: Enviroment.enviroment) state =
  (* Start Canvas *)
  let x = Vector2.x state.player_position in
  let y = Vector2.y state.player_position in
  draw_model_ex state.player_model (Vector3.create x 0.0 y) (Vector3.create 0.0 1.0 0.0) state.player_angle.contents (Vector3.create 0.06 0.06 0.06) Color.white;
  draw_plane (Vector3.create 0.0 0.0 0.0) (Vector2.create 250.0 250.0) Color.brown;
  let grass_scale = 35.0 in
  match Enviroment.touching_grass state.player_position enviroment with
    | (g_index, true) -> 
      Vector2.set_x enviroment.grass_positions.(g_index) 260.0;
      Vector2.set_y enviroment.grass_positions.(g_index) 260.0;
      enviroment.grass_eat_count := enviroment.grass_eat_count.contents + 1
    | _ -> ();
  Array.iter (fun g -> 
    draw_model enviroment.grass_model (Vector3.create (Vector2.x g) 0.0 (Vector2.y g)) grass_scale Color.white
  ) enviroment.grass_positions
  
  (* End Canvas *)

let rec loop font enviroment state =
  if window_should_close () then close_window ()
  else
    full_screen_handler ();
    begin_drawing ();
    clear_background Color.raywhite;
    begin_mode_3d state.camera;
    let state = controls state in
    drawing enviroment state.player_state;
    end_mode_3d ();
    gui font enviroment state;
    end_drawing ();
    loop font enviroment state

let () =
  Window.setup ();
  let camera = Camera3D.create
    (Vector3.create 0.0 10.0 0.0)
    (Vector3.create 0.0 0.0 0.0)
    (Vector3.create 0.0 0.0 1.0)
    27.5
    CameraProjection.Orthographic in
  let _ = Egg in
  let _ = Chick in
  let player_form = Hen in
  let player_position = Vector2.create 0.0 0.0 in
  let player_speed = Player.player_base_speed in
  let player_angle = 0.0 in
  let player_model = load_model "./assets/hen.glb" in
  let font = load_font "./assets/open-sans.bold-italic.ttf" in
  let player_state = {player_position; player_model; player_speed = ref player_speed; player_angle = ref player_angle; player_form = ref player_form} in
  let state = {camera; player_state} in
  let enviroment: Enviroment.enviroment = Enviroment.get_grass () in
  loop font enviroment state
