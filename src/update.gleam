import effects.{clear_copied_component_entry, copy_component_color}
import gleam/dict
import gleam/option
import lustre/effect.{type Effect}
import types.{type Model, type Msg, Model, default_color, to_component}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    types.ColorChanged2(component, color) -> {
      // TODO: add validation for color
      #(
        Model(..model, colors: model.colors |> dict.insert(component, color)),
        effect.none(),
      )
    }
    types.ResetColor2(component_str) -> {
      case component_str |> to_component {
        option.None -> #(model, effect.none())
        option.Some(component) -> #(
          Model(
            ..model,
            colors: model.colors
              |> dict.insert(component, component |> default_color),
          ),
          effect.none(),
        )
      }
    }
    types.InputSubmitted -> #(model, effect.none())
    types.CopyComponentColorButtonClicked(component) -> {
      let effect = case model.colors |> dict.get(component) {
        Error(_) -> effect.none()
        Ok(color) -> copy_component_color(color, component)
      }

      #(model, effect)
    }
    types.CopyComponentColorAttempted(copy_result) ->
      case copy_result {
        #(_, Error(_)) -> #(model, effect.none())
        #(component, Ok(_)) -> #(
          Model(..model, component_just_copied: option.Some(component)),
          clear_copied_component_entry(),
        )
      }
    types.ClearCopiedComponentEntry -> #(
      Model(..model, component_just_copied: option.None),
      effect.none(),
    )
  }
}
