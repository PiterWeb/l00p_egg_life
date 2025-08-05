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
  player_speed: float ref;
  player_texture: Texture2D.t;
  player_direction: player_direction ref;
  player_form: player_form ref;
}

let player_min_speed = 1.0
let player_base_speed = 25.0
let player_acceleration = -3.0

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