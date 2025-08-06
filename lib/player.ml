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

let player_min_speed = 16.0
let player_base_speed = 75.0
let player_acceleration = -9.0

let load_chicken_texture _ =
  load_texture "./assets/chicken_white.png"

let draw_chicken_right texture position =
  draw_texture_rec texture (Rectangle.create 0.0 0.0 16.0 16.0) position Color.white

let draw_chicken_back texture position =
  draw_texture_rec texture (Rectangle.create 0.0 16.0 16.0 16.0) position Color.white

let draw_chicken_left texture position =
  draw_texture_rec texture (Rectangle.create 0.0 32.0 16.0 16.0) position Color.white

let draw_chicken_front texture position =
  draw_texture_rec texture (Rectangle.create 0.0 48.0 16.0 16.0) position Color.white