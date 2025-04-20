import gleam/string
import types.{type Color}

pub fn get_bg_class(color: Color) -> String {
  "bg-[" <> color <> "]"
}

pub fn get_text_class(color: Color) -> String {
  "text-[" <> color <> "]"
}

pub fn get_border_class(color: Color) -> String {
  "border-[" <> color <> "]"
}

pub fn right_pad_trim(value: String, length: Int) -> String {
  case { value |> string.length } > length {
    False ->
      [value, string.repeat(".", { length - { value |> string.length } })]
      |> string.join("")
    True ->
      case length > 3 {
        False -> value |> string.slice(0, length)
        True ->
          [value |> string.slice(0, length - 3), "..."]
          |> string.join("")
      }
  }
}
