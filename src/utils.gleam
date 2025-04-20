import gleam/string

pub fn right_pad_trim(value: String, length: Int, dots: Bool) -> String {
  let char = case dots {
    False -> " "
    True -> "."
  }
  case { value |> string.length } > length {
    False ->
      [value, string.repeat(char, { length - { value |> string.length } })]
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
