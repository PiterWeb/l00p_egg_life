open Raylib

let width = 800
let height = 450

let setup () =
  init_window width height "lOOp Egg life";
  set_target_fps 70;
  toggle_fullscreen () |> hide_cursor