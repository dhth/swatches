import gleam/dict
import gleam/option
import types.{type Model, type Msg, Model, default_color, to_component}

pub fn update(model: Model, msg: Msg) -> Model {
  case msg {
    types.ColorChanged2(component, color) -> {
      // TODO: add validation for color
      Model(..model, colors: model.colors |> dict.insert(component, color))
    }
    types.ResetColor2(component_str) -> {
      case component_str |> to_component {
        option.None -> model
        option.Some(component) ->
          Model(
            ..model,
            colors: model.colors
              |> dict.insert(component, component |> default_color),
          )
      }
    }
    types.InputSubmitted -> model
  }
}
