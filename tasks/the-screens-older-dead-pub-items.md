---
name: "The screens keep a few dead pub items from before the binary went"
description: "rm2k-snes-screens has pub functions, methods and fields that nothing in the workspace reads —convert::hex, message_window's convert, font_bytes and font_reach, a few of custom_menu's and cells'—, invisible to rustc because their modules are pub"
type: refactor
game: advocate
status: draft
assignee: taro
agents: [Carpintero]
author: carpintero
links:
  found-in: [the-screens-reference-drawing-has-no-caller]
---

Found by Carpintero on 2026-11-27, doing
[`the-screens-reference-drawing-has-no-caller`](the-screens-reference-drawing-has-no-caller.md),
on the-advocate's `carpintero-dead-render` (from `ab885b29`).

**What is seen**: with every module of `rm2k-snes-screens` but `answer`
and `request` made `pub(crate)` for a moment, and what the converter,
the emission and the crate's tests call re-exported from `lib.rs` as
roots, rustc still names as never used, after the reference drawing
went:

* `convert::hex`;
* `message_window::convert` —the converter calls `convert_with`—,
  `font_bytes` —only a unit test calls it; the converter calls
  `font_bytes_with`— and `font_reach` —the converter calls
  `font_reach_with`—;
* `custom_menu`: the field `replaces_common`, the methods `befores` and
  `variables`, and the field `layouts`;
* `layout`: `Variant::ALL`, and the variants `None` and `Left`, which
  only a unit test builds;
* `cells`: `Counts::is_empty`, `get` and `contains`, and
  `Bank::is_empty` —each `is_empty` is what clippy's
  `len_without_is_empty` asks of a `pub` `len`, so they go only if the
  module stops being `pub` or `len` goes too—.

None of them was reached by the binary that went in step 3 of
[`tests-without-the-stages-subcommands`](tests-without-the-stages-subcommands.md):
they are older, and rustc did not see them because their modules are
`pub`.

**How to reproduce**: in `rm2k-snes/screens/src/lib.rs`, `pub mod` to
`pub(crate) mod` for every module but `answer` and `request`, and at the
end

    pub use crate::boxes::Reflowed;
    pub use crate::checks::Vram;
    pub use crate::layout::{ITEM_NAME_WIDTH, MESSAGE_WIDTH};
    pub use crate::stage::{boxes as stage_boxes, convert as stage_convert, faces, window, Place};

then `cargo build -p rm2k-snes-screens`.

**What to do**: what `git blame` shows was left by a subcommand that went
is deleted, with the ROMs byte for byte the same; what is there on
purpose —the `is_empty`s— stays. Mechanical, nothing seen or heard
changes.

## Log
