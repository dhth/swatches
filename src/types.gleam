import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import gleam/string

const fallback_color = "#ffffff"

pub type Color =
  String

pub type Layout {
  Simple
}

pub type Msg {
  ColorChanged2(Component, Color)
  ResetColor2(String)
  InputSubmitted
}

pub type Component {
  Bg
  H1
  H2
  P
  TableBorder
  TableHeading
  TableCell
  LabelText
  InputBg
  InputText
  ButtonBg
  ButtonText
}

pub type Colors =
  dict.Dict(Component, Color)

pub type Model {
  Model(layout: Layout, colors: Colors, debug: Bool)
}

fn components() -> List(Component) {
  [
    Bg,
    H1,
    H2,
    P,
    TableBorder,
    TableHeading,
    TableCell,
    LabelText,
    InputBg,
    InputText,
    ButtonBg,
    ButtonText,
  ]
}

pub fn get_color_for_component(colors: Colors, component: Component) -> Color {
  colors
  |> dict.get(component)
  |> result.unwrap(fallback_color)
}

pub fn component_to_string(component: Component) -> String {
  case component {
    Bg -> "background"
    H1 -> "h1"
    H2 -> "h2"
    P -> "paragraph"
    TableBorder -> "table-border"
    TableHeading -> "table-heading"
    TableCell -> "table-cell"
    LabelText -> "label-text"
    InputBg -> "input-bg"
    InputText -> "input-text"
    ButtonBg -> "button-bg"
    ButtonText -> "button-text"
  }
}

pub fn component_to_string_padded(component: Component) -> String {
  component |> component_to_string |> string.pad_end(10, " ")
}

pub fn to_component(value: String) -> option.Option(Component) {
  case value {
    "background" -> Bg |> option.Some
    "h1" -> H1 |> option.Some
    "h2" -> H2 |> option.Some
    "paragraph" -> P |> option.Some
    "table-border" -> TableBorder |> option.Some
    "table-heading" -> TableHeading |> option.Some
    "table-cell" -> TableCell |> option.Some
    "label-text" -> LabelText |> option.Some
    "input-bg" -> InputBg |> option.Some
    "input-text" -> InputText |> option.Some
    "button-bg" -> ButtonBg |> option.Some
    "button-text" -> ButtonText |> option.Some
    _ -> option.None
  }
}

pub fn encode_layout(layout: Layout) -> String {
  case layout {
    Simple -> "simple"
  }
}

pub fn default_color(component: Component) -> Color {
  case component {
    Bg -> "#282828"
    H1 -> "#b8bb26"
    H2 -> "#d3869b"
    P -> "#ebdbb2"
    TableBorder -> "#41403e"
    TableCell -> "#83a598"
    TableHeading -> "#fabd2f"
    LabelText -> "#fabd2f"
    InputBg -> "#3d3d3d"
    InputText -> "#ebdbb2"
    ButtonBg -> "#fb4934"
    ButtonText -> "#282828"
  }
}

pub fn default_colors() -> Colors {
  components()
  |> list.map(get_color_tuple)
  |> dict.from_list
}

fn get_color_tuple(component: Component) -> #(Component, Color) {
  #(component, component |> default_color)
}

pub fn init_model() -> Model {
  Model(layout: Simple, colors: default_colors(), debug: False)
}

pub fn encode_model(model: Model) -> String {
  ["- layout: " <> model.layout |> encode_layout]
  |> string.join("\n")
}
