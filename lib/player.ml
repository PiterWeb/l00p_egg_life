open Raylib

type player_form =
  | Egg
  | Chick
  | Hen

type player_direction =
  | Front
  | Back
  | Left
  | Right

type player_state = {
  player_position: Vector2.t;
  mutable player_speed: float;
  player_texture: Texture2D.t;
  mutable player_direction: player_direction;
  mutable player_form: player_form;
}

let player_min_speed = 32.0
let player_base_speed = 72.0
let player_acceleration = -8.0

let load_hen_texture _ =
  load_texture "./assets/hen.png"

let draw_chicken_right texture position =
  draw_texture_rec texture (Rectangle.create 0.0 0.0 16.0 16.0) position Color.white

let draw_chicken_back texture position =
  draw_texture_rec texture (Rectangle.create 0.0 16.0 16.0 16.0) position Color.white

let draw_chicken_left texture position =
  draw_texture_rec texture (Rectangle.create 0.0 32.0 16.0 16.0) position Color.white

let draw_chicken_front texture position =
  draw_texture_rec texture (Rectangle.create 0.0 48.0 16.0 16.0) position Color.white

let load_egg_texture _ =
  load_texture "./assets/egg.png"

let draw_egg texture position =
  draw_texture_rec texture (Rectangle.create 0.0 0.0 32.0 32.0) position Color.white

let load_chick_texture _ =
  load_texture "./assets/chick.png"

let draw_chick_right texture position =
  draw_texture_rec texture (Rectangle.create 96.0 48.0 8.0 16.0) position Color.white

