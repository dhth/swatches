import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import utils

const fallback_color = "#ffffff"

const controls_section_min_height = 10

const controls_section_max_height = 80

const controls_section_change_percent = 5

pub type Color =
  String

pub type Layout {
  Simple
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

pub opaque type ControlsHeightPercent {
  ControlsHeightPercent(value: Int)
}

pub type DimensionChangeType {
  DimensionIncrease
  DimensionDecrease
}

pub type Model {
  Model(
    controls_height_percent: ControlsHeightPercent,
    layout: Layout,
    colors: Colors,
    component_just_copied: option.Option(Component),
    yanked_component: option.Option(Component),
    copied_all: Bool,
    debug: Bool,
  )
}

pub type Msg {
  ColorChanged2(Component, Color)
  ResetAllButtonClicked
  ResetColor2(String)
  InputSubmitted
  CopyComponentColorButtonClicked(Component)
  CopyComponentColorAttempted(#(Component, Result(Nil, String)))
  ClearCopiedComponentEntry
  YankComponentColorButtonClicked(Component)
  PasteComponentColorButtonClicked(Component)
  ResetYankComponentButtonClicked
  CopyAllButtonClicked
  CopyAllAttempted(Result(Nil, String))
  ResetCopyAllButton
  ChangeControlsHeightButtonClicked(DimensionChangeType)
}

pub fn controls_section_can_shrink(height: ControlsHeightPercent) -> Bool {
  height.value > controls_section_min_height
}

pub fn controls_section_can_grow(height: ControlsHeightPercent) -> Bool {
  height.value < controls_section_max_height
}

pub fn height_to_int(height: ControlsHeightPercent) -> Int {
  height.value
}

pub fn change_controls_height(
  height: ControlsHeightPercent,
  change_type: DimensionChangeType,
) -> ControlsHeightPercent {
  case change_type {
    DimensionDecrease ->
      height.value - controls_section_change_percent
      |> int.max(controls_section_min_height)
    DimensionIncrease ->
      height.value + controls_section_change_percent
      |> int.min(controls_section_max_height)
  }
  |> ControlsHeightPercent
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
  Model(
    controls_height_percent: 40 |> ControlsHeightPercent,
    layout: Simple,
    colors: default_colors(),
    component_just_copied: option.None,
    yanked_component: option.None,
    copied_all: False,
    debug: False,
  )
}

fn encode_colors(colors: Colors) -> String {
  colors
  |> dict.to_list
  |> list.map(fn(tuple) {
    let #(component, color) = tuple
    "  - "
    <> { component |> component_to_string |> utils.right_pad_trim(12, False) }
    <> ": "
    <> color
  })
  |> string.join("\n")
}

pub fn colors_to_string(colors: Colors) -> String {
  colors
  |> dict.to_list
  |> list.map(fn(tuple) {
    let #(component, color) = tuple
    { component |> component_to_string |> utils.right_pad_trim(16, False) }
    <> " \""
    <> color
    <> "\""
  })
  |> string.join("\n")
}

pub fn encode_model(model: Model) -> String {
  [
    "- layout: " <> model.layout |> encode_layout,
    " - colors:\n" <> model.colors |> encode_colors,
  ]
  |> string.join("\n")
}

pub fn get_bg_class(color: Color) -> String {
  "bg-[" <> color <> "]"
}

pub fn get_text_class(color: Color) -> String {
  "text-[" <> color <> "]"
}

pub fn get_border_class(color: Color) -> String {
  "border-[" <> color <> "]"
}
