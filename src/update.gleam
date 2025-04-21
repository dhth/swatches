import effects.{
  clear_copied_component_entry, copy_component_color, copy_to_clipboard,
  reset_copy_all_button,
}
import gleam/dict
import gleam/option
import lustre/effect.{type Effect}
import types.{
  type Model, type Msg, Model, change_controls_height, colors_to_string,
  default_color, to_component,
}

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
    types.YankComponentColorButtonClicked(component) -> {
      #(
        Model(..model, yanked_component: component |> option.Some),
        effect.none(),
      )
    }
    types.PasteComponentColorButtonClicked(component) -> {
      case model.yanked_component {
        option.None -> #(model, effect.none())
        option.Some(yanked_component) ->
          case model.colors |> dict.get(yanked_component) {
            Error(_) -> #(model, effect.none())
            Ok(color) -> #(
              Model(
                ..model,
                colors: model.colors
                  |> dict.insert(component, color),
              ),
              effect.none(),
            )
          }
      }
    }

    types.ResetYankComponentButtonClicked -> #(
      Model(..model, yanked_component: option.None),
      effect.none(),
    )
    types.ResetAllButtonClicked -> #(
      Model(..model, colors: types.default_colors()),
      effect.none(),
    )
    types.CopyAllButtonClicked -> #(
      model,
      copy_to_clipboard(model.colors |> colors_to_string),
    )
    types.CopyAllAttempted(copy_result) ->
      case copy_result {
        Error(_) -> #(model, effect.none())
        Ok(_) -> #(Model(..model, copied_all: True), reset_copy_all_button())
      }
    types.ResetCopyAllButton -> #(
      Model(..model, copied_all: False),
      effect.none(),
    )
    types.ChangeControlsHeightButtonClicked(change_type) -> #(
      Model(
        ..model,
        controls_height_percent: model.controls_height_percent
          |> change_controls_height(change_type),
      ),
      effect.none(),
    )
  }
}
