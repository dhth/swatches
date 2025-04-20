import gleam/javascript/promise
import lustre/effect.{type Effect}
import plinth/browser/clipboard
import plinth/javascript/global
import types.{
  type Color, type Component, type Msg, ClearCopiedComponentEntry,
  CopyComponentColorAttempted,
}

pub fn copy_component_color(color: Color, component: Component) -> Effect(Msg) {
  effect.from(copy_component_color_to_clipboard(_, color, component))
}

fn copy_component_color_to_clipboard(
  dispatch: fn(Msg) -> Nil,
  color: Color,
  component: Component,
) -> Nil {
  {
    use copy_result <- promise.map(clipboard.write_text(color))
    dispatch(CopyComponentColorAttempted(#(component, copy_result)))
  }

  Nil
}

pub fn clear_copied_component_entry() -> effect.Effect(Msg) {
  effect.from(fn(dispatch) {
    global.set_timeout(1000, fn() { dispatch(ClearCopiedComponentEntry) })
    Nil
  })
}
