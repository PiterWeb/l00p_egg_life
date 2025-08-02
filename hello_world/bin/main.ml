let window_width = 800
let window_height = 450

let window_setup () =
  Raylib.init_window window_width window_height "lOOp RedCube";
  Raylib.set_target_fps 60;
  Raylib.toggle_fullscreen ()

type state = {
  player_position: Raylib.Vector2.t;
  player_speed: float ref;
  player_model: Raylib.Model.t;
  player_angle: float ref;
  camera: Raylib.Camera3D.t;
}

let player_min_speed = 1.0
let player_base_speed = 25.0
let player_acceleration = -3.0

let full_screen_handler () =
  let open Raylib in
  if is_key_pressed Key.F11 then
    let display = get_current_monitor () in
    (match is_window_fullscreen () with
    | true -> set_window_size window_width window_height
    | false -> set_window_size (get_monitor_width display) (get_monitor_height display));
    toggle_fullscreen ()

let controls state =
  let open Raylib in
    let x = Vector2.x state.player_position in
    let y = Vector2.y state.player_position in
    let speed = match state.player_speed.contents with
      | speed when speed <= player_min_speed || speed >= player_base_speed -> (
        player_base_speed
      )
      | speed -> speed
    in
    let delta_time = get_frame_time() in
    let player_speed = speed +. player_acceleration *. delta_time in
    state.player_speed := player_speed;
    if is_key_down Key.A then (
      state.player_angle := 90.0;
      Vector2.set_x state.player_position (x +. player_speed *. delta_time)
    );
    if is_key_down Key.D then (
      state.player_angle := 270.0;
      Vector2.set_x state.player_position (x -. player_speed *. delta_time)
    );
    if is_key_down Key.S then (
      state.player_angle := 180.0;
      Vector2.set_y state.player_position (y -. player_speed *. delta_time)
    );
    if is_key_down Key.W then (
      state.player_angle := 0.0;
      Vector2.set_y state.player_position (y +. player_speed *. delta_time)
    );
    if not (is_key_down Key.W) && not (is_key_down Key.A) && not (is_key_down Key.S) && not (is_key_down Key.D) then (
      state.player_speed := (1.5 *. speed -. player_acceleration *. delta_time);
      state.player_speed := (1.5 *. speed -. player_acceleration *. delta_time);
    );
    state

let drawing state =
  let open Raylib in
    (* Start Canvas *)
    let x = Vector2.x state.player_position in
    let y = Vector2.y state.player_position in
    let _ = state.player_angle in
    draw_model_ex state.player_model (Vector3.create x 0.0 y) (Vector3.create 0.0 1.0 0.0) state.player_angle.contents (Vector3.create 0.06 0.06 0.06) Color.white;
    draw_grid 20 10.0
    (* End Canvas *)

let rec loop state =
  if Raylib.window_should_close () then Raylib.close_window ()
  else
    let open Raylib in
      full_screen_handler ();
      begin_drawing ();
      clear_background Color.raywhite;
      begin_mode_3d state.camera;
      let state = controls state in
      drawing state;
      end_mode_3d ();
      end_drawing ();
      loop state

let () =
  window_setup ();
  let camera = Raylib.Camera3D.create
    (Raylib.Vector3.create 0.0 10.0 0.0)
    (Raylib.Vector3.create 0.0 0.0 0.0)
    (Raylib.Vector3.create 0.0 0.5 1.0)
    27.5
    Raylib.CameraProjection.Orthographic in
  let player_position = Raylib.Vector2.create 0.0 0.0 in
  let player_speed = player_base_speed in
  let player_angle = 0.0 in
  let player_model = Raylib.load_model "./assets/hen.glb" in
  loop {camera; player_position; player_model; player_speed = ref player_speed; player_angle = ref player_angle}
