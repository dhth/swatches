import lustre
import types.{type Model, init_model}
import update
import view

pub fn main() {
  let app = lustre.simple(init, update.update, view.view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

fn init(_) -> Model {
  init_model()
}
