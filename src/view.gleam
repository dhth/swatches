import gleam/dict
import gleam/list
import gleam/option
import lustre/attribute
import lustre/element
import lustre/element/html
import lustre/event
import types.{
  type Color, type Colors, type Component, type Model, type Msg,
  component_to_string, encode_model, get_color_for_component,
}
import utils.{get_bg_class, get_border_class, get_text_class, right_pad_trim}

const component_name_max_width = 13

pub fn view(model: Model) -> element.Element(Msg) {
  html.div([], [
    model |> debug_div,
    model |> controls_section,
    model |> preview_section,
  ])
}

fn debug_div(model: Model) -> element.Element(Msg) {
  case model.debug {
    True ->
      html.div(
        [attribute.class("debug bg-gray-800 text-white p-4 overflow-auto mb-5")],
        [
          html.pre([attribute.class("whitespace-pre-wrap")], [
            model |> encode_model |> element.text,
          ]),
        ],
      )
    False -> element.none()
  }
}

fn controls_section(model: Model) -> element.Element(Msg) {
  html.div(
    [
      attribute.id("controls-section"),
      attribute.class(
        "sticky resize-y border-b-4 border-[#4a4c4d] top-0 bg-[#1d2021] pt-8 pb-10 h-[50vh] overflow-y-scroll",
      ),
    ],
    [
      html.div([attribute.class("mx-auto w-4/5")], [
        main_heading(),
        controls_heading(),
        model |> color_controls,
      ]),
    ],
  )
}

fn main_heading() -> element.Element(Msg) {
  html.h1([attribute.class("text-[#d3869b] text-4xl font-bold")], [
    element.text("swatches"),
  ])
}

fn controls_heading() -> element.Element(Msg) {
  html.h1([attribute.class("text-[#fabd2f] text-2xl mt-4 font-semibold")], [
    element.text("Controls"),
  ])
}

fn color_controls(model: Model) -> element.Element(Msg) {
  html.div(
    [attribute.id("controls"), attribute.class("pt-2 columns-2")],
    model.colors
      |> dict.to_list
      |> list.map(fn(tuple) {
        let #(component, _) = tuple
        let was_copied =
          model.component_just_copied
          |> option.map(fn(c) { c == component })
          |> option.unwrap(False)

        component_color_details(tuple, was_copied)
      }),
  )
}

fn component_color_details(
  tuple: #(Component, Color),
  was_copied: Bool,
) -> element.Element(Msg) {
  let #(component, color) = tuple
  let #(copy_button_class, copy_button_text, copy_button_disabled) = case
    was_copied
  {
    False -> #("bg-[#fabd2f]", "copy", False)
    True -> #("bg-[#b8bb26]", "done", True)
  }
  html.div(
    [attribute.class("flex items-center space-x-2 pt-2 text-[#ebdbb2]")],
    [
      html.label([attribute.for("color1-input")], [
        element.text(
          component
          |> component_to_string
          |> right_pad_trim(component_name_max_width),
        ),
      ]),
      html.input([
        attribute.class("h-8 w-32"),
        attribute.id("color1-input"),
        attribute.type_("color"),
        attribute.placeholder("HEX color"),
        attribute.value(color),
        event.on_input(fn(value) { types.ColorChanged2(component, value) }),
      ]),
      html.p([attribute.class("font-semibold")], [element.text(color)]),
      html.button(
        [
          attribute.class(
            "font-semibold px-4 py-1 ml-4 bg-[#d3869b] text-[#282828]",
          ),
          event.on_click(types.ResetColor2(component |> component_to_string)),
        ],
        [element.text("reset")],
      ),
      html.button(
        [
          attribute.class(
            "font-semibold px-4 py-1 ml-4 text-[#282828] transition duration-150 ease-linear "
            <> copy_button_class,
          ),
          attribute.disabled(copy_button_disabled),
          event.on_click(types.CopyComponentColorButtonClicked(component)),
        ],
        [element.text(copy_button_text)],
      ),
    ],
  )
}

fn preview_section(model: Model) -> element.Element(Msg) {
  html.div(
    [
      attribute.id("preview-section"),
      attribute.class(
        model.colors
        |> get_color_for_component(types.Bg)
        |> get_bg_class,
      ),
    ],
    [
      html.div(
        [
          attribute.class(
            model.colors
            |> get_color_for_component(types.H1)
            |> get_text_class
            <> " mx-auto w-4/5 pt-8 pb-50",
          ),
        ],
        [
          model.colors
            |> get_color_for_component(types.H1)
            |> heading,
          model.colors
            |> get_color_for_component(types.P)
            |> paragraph,
          model.colors |> table,
          model.colors |> input_section,
        ],
      ),
    ],
  )
}

fn heading(color: String) -> element.Element(Msg) {
  html.h1([attribute.class("font-bold text-3xl " <> color |> get_text_class)], [
    element.text("The Matrix"),
  ])
}

fn paragraph(color: String) -> element.Element(Msg) {
  html.div([attribute.class(color |> get_text_class)], [
    html.p([attribute.class("mt-8")], [
      element.text(
        "The Matrix is a groundbreaking science fiction film that explores the nature of reality and human existence. Directed by the Wachowskis, the movie follows Neo, a computer hacker who discovers that the world he knows is a simulated reality created by intelligent machines. As he joins a group of rebels led by Morpheus, Neo learns to bend the rules of the simulation and confronts the oppressive system controlling humanity.",
      ),
    ]),
    html.p([attribute.class("mt-4")], [
      element.text(
        "At its core, The Matrix is a philosophical journey that delves into themes of free will, perception, and the search for truth. The iconic red pill and blue pill choice symbolizes the decision to embrace reality, no matter how harsh, or to remain in comfortable ignorance. With its innovative visual effects, compelling narrative, and thought-provoking ideas, The Matrix has left an indelible mark on both pop culture and the science fiction genre.",
      ),
    ]),
  ])
}

fn table(colors: Colors) -> element.Element(Msg) {
  let cell_color =
    colors
    |> get_color_for_component(types.TableCell)
  let heading_color =
    colors
    |> get_color_for_component(types.TableHeading)
  let border_color =
    colors
    |> get_color_for_component(types.TableBorder)
  let border_class = border_color |> get_border_class
  let h2_color = colors |> get_color_for_component(types.H2)

  html.div([], [
    html.h2(
      [
        attribute.class(
          h2_color |> get_text_class <> " text-2xl mt-8 font-semibold",
        ),
      ],
      [element.text("Programs and their purposes")],
    ),
    html.table(
      [
        attribute.class(
          "mt-4 table-auto w-full border-2 border-[#838ba7] font-semibold "
          <> cell_color |> get_text_class,
        ),
      ],
      [
        ["Program", "Purpose", "Notable Feature"]
          |> table_heading(heading_color |> get_text_class, border_class),
        html.tbody(
          [],
          [
            [
              "The Matrix", "Simulated reality for humans",
              "Keeps humans docile and unaware",
            ],
            [
              "The Oracle", "Guide for The One",
              "Provides cryptic advice to Neo",
            ],
            [
              "The Agents", "Enforce control within The Matrix",
              "Can take over any human body",
            ],
            [
              "The Sentinels", "Hunt humans in the real world",
              "Deadly and relentless machines",
            ],
          ]
            |> list.map(fn(row) { row |> table_row(border_class) }),
        ),
      ],
    ),
  ])
}

fn table_heading(
  headers: List(String),
  heading_class: String,
  border_class: String,
) -> element.Element(Msg) {
  html.thead([attribute.class(heading_class)], [
    html.tr(
      [attribute.class("text-lg")],
      headers
        |> list.map(fn(header) {
          html.th(
            [attribute.class("py-2 border-2 text-left pl-2 " <> border_class)],
            [html.text(header)],
          )
        }),
    ),
  ])
}

fn table_row(row: List(String), border_class: String) -> element.Element(Msg) {
  html.tr(
    [],
    row
      |> list.map(fn(element) {
        html.td(
          [attribute.class("py-2 border-2 text-left pl-2 " <> border_class)],
          [html.text(element)],
        )
      }),
  )
}

fn input_section(colors: Colors) -> element.Element(Msg) {
  let h2_color = colors |> get_color_for_component(types.H2)

  // TODO: remove code duplication here
  let label_text_class =
    colors
    |> get_color_for_component(types.LabelText)
    |> get_text_class

  let input_text_class =
    colors
    |> get_color_for_component(types.InputText)
    |> get_text_class

  let input_bg_class =
    colors
    |> get_color_for_component(types.InputBg)
    |> get_bg_class

  let buttons_bg_class =
    colors
    |> get_color_for_component(types.ButtonBg)
    |> get_bg_class

  let buttons_text_class =
    colors
    |> get_color_for_component(types.ButtonText)
    |> get_text_class

  let button_classes = buttons_bg_class <> " " <> buttons_text_class
  let input_classes = input_bg_class <> " " <> input_text_class

  html.div([], [
    html.h2(
      [
        attribute.class(
          h2_color |> get_text_class <> " text-2xl mt-8 font-semibold",
        ),
      ],
      [element.text("Form")],
    ),
    html.div([attribute.class("font-semibold mt-4 " <> label_text_class)], [
      html.label([attribute.class("block mb-2"), attribute.for("name")], [
        html.text("Name:"),
      ]),
      html.input([
        attribute.class("w-full p-2 mb-4 " <> input_classes),
        attribute.required(True),
        attribute.placeholder("Thomas Anderson"),
        attribute.value("Thomas Anderson"),
        attribute.name("name"),
        attribute.id("name"),
        attribute.type_("text"),
      ]),
      html.label([attribute.class("block mb-2"), attribute.for("alias")], [
        html.text("Alias (Optional):"),
      ]),
      html.input([
        attribute.class("w-full p-2 mb-4 " <> input_classes),
        attribute.placeholder("Neo"),
        attribute.value("Neo"),
        attribute.name("alias"),
        attribute.id("alias"),
        attribute.type_("text"),
      ]),
      html.label([attribute.class("block mb-2"), attribute.for("email")], [
        html.text("Email:"),
      ]),
      html.input([
        attribute.class("w-full p-2 mb-4 " <> input_classes),
        attribute.required(True),
        attribute.placeholder("Enter your email"),
        attribute.value("neo@thematrixhasyou.com"),
        attribute.name("email"),
        attribute.id("email"),
        attribute.type_("email"),
      ]),
      html.label([attribute.class("block mb-2"), attribute.for("reason")], [
        html.text("Why do you want to join the resistance?"),
      ]),
      html.textarea(
        [
          attribute.class("w-full p-2 mb-4 " <> input_classes),
          attribute.required(True),
          attribute.placeholder("Your reason..."),
          attribute.rows(4),
          attribute.name("reason"),
          attribute.id("reason"),
        ],
        "",
      ),
      html.label([attribute.class("block mb-2"), attribute.for("captcha")], [
        html.text("What is 2 + 2? (Prove you're human):"),
      ]),
      html.input([
        attribute.class("w-full p-2 mb-4 " <> input_classes),
        attribute.required(True),
        attribute.placeholder("Enter the answer"),
        attribute.name("captcha"),
        attribute.id("captcha"),
        attribute.type_("text"),
      ]),
      html.button(
        [attribute.class("w-full p-2 font-bold  " <> button_classes)],
        [html.text("Take the Red Pill")],
      ),
    ]),
  ])
}
