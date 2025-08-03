open Raylib

let width = 800
let height = 450

let setup () =
  init_window width height "lOOp RedCube";
  set_target_fps 60;
  toggle_fullscreen () |> hide_cursor