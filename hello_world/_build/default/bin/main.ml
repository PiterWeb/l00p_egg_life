let setup () =
  Raylib.init_window 1024 720 "lOOp RedCube";
  Raylib.set_target_fps 60

type state = {
  player_position: Raylib.Vector3.t;
  player_speed: Raylib.Vector3.t;
  player_model: Raylib.Model.t;
  camera: Raylib.Camera3D.t;
}

let player_min_speed = 1.0
let player_base_speed = 50.0
let player_acceleration = -5.0

let controls state =
  let open Raylib in
    let x = Vector3.x state.player_position in
    let z = Vector3.z state.player_position in
    let x_speed = match Vector3.x state.player_speed with
      | speed when speed <= player_min_speed || speed >= player_base_speed -> player_base_speed
      | speed -> speed
    in
    let z_speed = match Vector3.z state.player_speed with
        | speed when speed <= player_min_speed || speed >= player_base_speed -> player_base_speed
        | speed -> speed
    in
    let delta_time = get_frame_time() in
    let player_speed_x = x_speed +. player_acceleration *. delta_time in
    let player_speed_z = z_speed +. player_acceleration *. delta_time in
    Vector3.set_x state.player_speed player_speed_x;
    Vector3.set_z state.player_speed player_speed_z;
      if is_key_down Key.D then
        Vector3.set_x state.player_position (x +. player_speed_x *. delta_time)
      else if is_key_down Key.A then
        Vector3.set_x state.player_position (x -. player_speed_x *. delta_time)
      else if is_key_down Key.W then
        Vector3.set_z state.player_position (z -. player_speed_z *. delta_time)
      else if is_key_down Key.S then
        Vector3.set_z state.player_position (z +. player_speed_z *. delta_time)
      else (
        Vector3.set_x state.player_speed (x_speed -. player_acceleration *. delta_time);
        Vector3.set_z state.player_speed (z_speed -. player_acceleration *. delta_time);
      );
      state

let drawing state =
  let open Raylib in
    (* Start Canvas *)
    draw_model state.player_model state.player_position 1.0 Color.black;
    draw_grid 20 10.0
    (* End Canvas *)

let rec loop state =
  if Raylib.window_should_close () then Raylib.close_window ()
  else
    let open Raylib in
      begin_drawing ();
      clear_background Color.raywhite;
      begin_mode_3d state.camera;
      let state = controls state in
      drawing state;
      end_mode_3d ();
      end_drawing ();
      loop state

let () =
  let player_model = Raylib.load_model "/assets/Chicken/Chicken_01.obj" in
  let camera = Raylib.Camera3D.create
      (Raylib.Vector3.create 10.0 100.0 10.0)
      (Raylib.Vector3.create 4.0 0.0 2.0)
      (Raylib.Vector3.create 0.0 1.0 0.0)
      45.0
      Raylib.CameraProjection.Perspective in
    let player_position = Raylib.Vector3.create 4.0 0.0 2.0 in
    let player_speed = Raylib.Vector3.create player_base_speed 0.0 player_base_speed in
      setup ();
      loop {camera; player_position; player_model; player_speed}
