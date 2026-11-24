#! /bin/env nu

def main [] {
  
}

def parse_file [file: string] {
  # The frontmatter is cut out with a regex and not with `open`, which
  # parses the whole Markdown to get at it: forty times slower, two seconds
  # of every `check` over the folder.
  let raw = open --raw $file
  let yml = $raw | parse --regex '(?s)\A---\n(?<y>.*?)\n---\n' | get -o 0.y

  let yml = if ($yml | is-not-empty) {
    $yml | from yml
  } else {
    null
  }

  let name = $yml | get -o name | default "(Not Named)"
  let task_type = $yml | get -o type | default "(no task type assigned)"
  let task_description = $yml | get -o description | default "(no task description)"
  let status = $yml | get -o status | default "(no status)"
  let assignee = $yml | get -o assignee | default ""
  # `author`: who the task comes from —taro for their reports and
  # requests, even when Hornero wrote the file; the agent that found it for
  # its own drafts—, lowercase and ASCII as in the trailers' addresses. Not
  # who wrote the file: git says that.
  let author = $yml | get -o author | default ""
  # `assignee` is who has it now —taro, when it moves to testing—, and
  # `agents` everyone who worked on it, which is never erased.
  let agents = $yml | get -o agents | default [] | append $assignee | where { $in != "" }
  # `game`: the ports' directory of the game where it was seen and where it
  # has to be played to close it —one, or a list—. Without it, the file
  # name's prefix says it when it has one (`abl-…`, `zounds-…`); the rest
  # —the tools' own, or a game the name does not say— has none.
  let games = $yml | get -o game | default (game_of_name ($file | path parse | get stem)) | append [] | where { $in != "" }
  # `links`: the typed relations to other tasks, `{<relation>: [<task>…]}`
  # (README, "A task's frontmatter"), flattened to one row per link. What
  # is not a mapping is kept as it came, for `check` to say so.
  let links_yml = $yml | get -o links
  let links = if ($links_yml | describe | str starts-with record) {
    $links_yml | items { |rel, tasks| $tasks | append [] | each { |t| {relation: $rel, task: ($t | into string)} } } | flatten
  } else { [] }

  return {
    file: $file,
    id: ($file | path parse | get stem),
    raw: $raw,
    name: $name,
    task_type: $task_type,
    status: $status,
    description: $task_description,
    assignee: $assignee,
    author: $author,
    agents: $agents,
    listed_agents: ($yml | get -o agents | default []),
    games: $games,
    links: $links,
    bad_links: ($links_yml != null and not ($links_yml | describe | str starts-with record)),
  }
}

# The relations between tasks, each with its inverse (README, "A task's
# frontmatter"): `link` writes both ends, `check` wants both, and the page
# shows them in this order. Few on purpose; one more is added when one is
# missing.
const RELATIONS = {
  blocked-by: blocks
  blocks: blocked-by
  part-of: has-part
  has-part: part-of
  duplicates: duplicated-by
  duplicated-by: duplicates
  relates: relates
}

# Where this repo's tasks and the book are published, to tell their links
# apart from any other URL.
const WORK_GITHUB = "https://github.com/lautarodragan/the-advocate-work/"
const BOOK_PAGES = "https://lautarodragan.github.io/the-advocate-docs/"
const BOOK_GITHUB = "https://github.com/lautarodragan/the-advocate-docs/"

# The ports' games, by their directory, and the name the page shows. The
# file-name prefixes the tasks have used for each, the longest first.
const GAMES = {
  abl: "A Blurred Line"
  book-of-three: "The Book of Three"
  desert-nightmare: "Desert Nightmare"
  dooms2: "Dooms 2"
  el-dorado: "El Dorado"
  frozen-world: "The Frozen World"
  sunset-over-imdahl: "Sunset Over Imdahl"
  vampires-dawn: "Vampires Dawn"
  zounds: "Zounds"
  test-game: "The test game"
}
const GAME_PREFIXES = [
  [the-test-game- test-game]
  [book-of-three- book-of-three]
  [desert-nightmare- desert-nightmare]
  [sunset-over-imdahl- sunset-over-imdahl]
  [vampires-dawn- vampires-dawn]
  [frozen-world- frozen-world]
  [el-dorado- el-dorado]
  [dooms-2- dooms2]
  [dooms2- dooms2]
  [sunset- sunset-over-imdahl]
  [zounds- zounds]
  [abl- abl]
]

def game_of_name [stem: string] {
  $GAME_PREFIXES | where { |p| $stem | str starts-with $p.0 } | get -o 0.1 | default ""
}

def game_label [] {
  let g = $in
  $GAMES | get -o $g | default $g
}

# To compare names: lowercase and without accents.
def normalize [] {
  $in | str lowercase | str replace --all --regex '[áà]' 'a' | str replace --all --regex '[éè]' 'e'
    | str replace --all --regex '[íì]' 'i' | str replace --all --regex '[óò]' 'o'
    | str replace --all --regex '[úùü]' 'u' | str replace --all 'ñ' 'n'
}

def task_title [] {
  [(ansi green) $in.task_type (ansi reset) ': ' (ansi red_bold) $in.name (ansi reset)] | str join
}

def print_task [] {
  print ('  ' + ($in | task_title))
  # print (['    ' (ansi reset) $file (ansi reset)] | str join)
  print (['    ' (ansi reset) $in.description (ansi reset)] | str join)
  print '' 
}

# The tasks all live in this folder, and their state is the `status` in
# the frontmatter: draft, todo, doing, testing, done, wishlist or
# cancelled. With
# `--status "*"`, all of them, grouped by state.
#
# With `--assignee`, only those that one has or worked on —their
# `assignee` or their `agents` list—: this is how a sub-agent finds its
# own, in any state with `-s "*"`. Ignoring case and accents, so that
# "huron" finds Hurón.
#
# With `--author`, only those that come from that one —their `author`—, the
# same way: `-u taro -s "*"` is everything taro asked for.
def "main ls" [
  --status (-s): string = "doing"
  --assignee (-a): string
  --author (-u): string
] {
  let tasks = all_tasks
    | where { $status == "*" or $in.status == $status }
    | where { |t| $assignee == null or ($t.agents | any { ($in | normalize) == ($assignee | normalize) }) }
    | where { |t| $author == null or ($t.author | normalize) == ($author | normalize) }

  $tasks | group-by status | items { |group, parsed|
    if $status == "*" {
      print ([(ansi green) ($group | str uppercase) (ansi reset)] | str join)
    }
    $parsed | sort-by task_type | each { print_task }
    print ''
  };

  ();
}

# All the tasks in the folder, parsed: this script's folder, so it can be
# run from anywhere.
def all_tasks [] {
  ls ($env.FILE_PWD | path join '*.md' | into glob) | where type == file | get name | each { parse_file $in }
}

# The tasks whose history is not in their `## Log` (README, "A task's
# log"): a heading above it that reads like a log entry —or a paragraph
# that opens with one in bold—, or a `## Log` that is not the last `##`
# section. A report, not a gate: a heading it lists
# may be the task's definition, and that is judged by reading it. `done`
# and `cancelled`
# tasks are left out unless asked for with `--status`.
#
# A heading reads like an entry when it starts with a word of the log
# —Done, Checked, Verified, What was done, When merging…—, when it is
# `Defined` with a date or an agent after it (a bare `## Defined` is the
# definition's own heading), when it carries a date, or when it starts
# with an agent's name or ends with one alone in parentheses —`(Cardón)`—.
# The date and the agent do not count in a heading that names taro: taro's
# words and decisions define the task. The older tasks' `#` headings count
# too.
#
# Then the tasks without an `author`, the typed links that do not hold
# —see `check_relations`— and the broken links in the prose —see
# `check_prose_links`—. Without the network, so that it stays fast and
# does not fail at random.
def "main check" [
  --status (-s): string = "*"
  --docs: string    # the-advocate-docs checkout, for the book's links; by default the one next to this repo
] {
  let agents = ls ($env.FILE_PWD | path dirname | path join .claude agents '*.md' | into glob)
    | get name | each { path parse | get stem } | append hornero
  let agent_re = $agents | str join '|'
  let word = '^(done|doing|checked|reviewed|verified|verification|work|what was done|what was run|what ran|status|left|where it was left|closed|measured|measured again|delivered|result|taken|seen again|changed under it|merged|merging|when merging|on merging|for merging|to merge|to install|what to install|after merging|red after merging|tested|how it was verified|handed back|resumed)\b'
  let date = '\d{4}-\d{2}-\d{2}'
  let tasks = all_tasks

  let found = $tasks
    | where { |t| if $status == "*" { $t.status not-in [done cancelled] } else { $t.status == $status } }
    | each { |t|
      let lines = $t.raw | lines
      mut fence = false
      mut log_at = -1
      mut defined_next = false
      mut problems = []
      for l in ($lines | enumerate) {
        let text = $l.item
        if ($text | str starts-with '```') { $fence = not $fence; continue }
        if $fence { continue }
        if $text == "## Log" {
          if $log_at >= 0 { $problems = $problems | append {line: ($l.index + 1), heading: $text, why: "a second ## Log"} }
          $log_at = $l.index
          continue
        }
        # A paragraph that opens with a bold entry —`**Checked on
        # 2026-10-16** by Cardón:`, `**2026-10-16, Hurón**`— is an entry
        # without a heading, and so is a bold lead followed by `(<agent>,
        # <date>)`. `**Done** means` is the definition's, and a bare
        # `**Measured**` or `**Since <date>**` is usually the finding
        # itself. So is the first paragraph under a bare `## Defined`, which
        # dates the definition: `**2026-10-16, Hurón**, checked against…`.
        let b = $text | parse --regex '^\*\*(?<lead>[^*]+)\*\*(?<paren> \([^)]*\))?'
        let opens_defined = $defined_next
        if ($text | str trim | is-not-empty) { $defined_next = false }
        if $log_at < 0 and ($b | is-not-empty) and not $opens_defined {
          let lead = $b.0.lead | normalize
          let paren = $b.0.paren? | default "" | normalize
          if (not ($lead =~ '\btaro\b') and (($lead =~ $date and not ($lead =~ '^since\b'))
              or ($paren =~ $date and $paren =~ $"\\b\(($agent_re)\)\\b")
              or $lead =~ $"^\(($agent_re)\)\\b"
              or $lead =~ '^(checked|verified|reviewed|measured again|seen again)\b')) {
            $problems = $problems | append {line: ($l.index + 1), heading: ($text | str substring 0..60), why: "a bold entry, above ## Log"}
          }
          continue
        }
        let h = $text | parse --regex '^(?<hashes>#{1,6}) (?<title>.*)$'
        if ($h | is-empty) { continue }
        let title = $h.0.title | normalize
        $defined_next = $h.0.hashes == "##" and $title == "defined"
        if $log_at >= 0 {
          if ($h.0.hashes | str length) <= 2 {
            $problems = $problems | append {line: ($l.index + 1), heading: $text, why: "a section after ## Log"}
          }
          continue
        }
        # The older tasks' `# Status` is a line of where the task stands
        # —"Noted, not started"—: when it is a step's history instead, that
        # is judged by reading it.
        if $h.0.hashes == "#" and $title == "status" { continue }
        let by_taro = $title =~ '\btaro\b'
        # `## Done means`, like `**Done** means`, is the definition's.
        let entry = (($title =~ $word and not ($title =~ '^done means\b'))
          or $title =~ '^defined\b.+'
          or (not $by_taro and $title =~ $date)
          or (not $by_taro and $title =~ $"^\(($agent_re)\)\\b")
          or (not $by_taro and $title =~ $"\\\(\(($agent_re)\)\\\)$"))
        if $entry {
          $problems = $problems | append {line: ($l.index + 1), heading: $text, why: "log-like, above ## Log"}
        }
      }
      $problems | each { |p| $p | insert file ($t.file | path basename) | insert status $t.status }
    }
    | flatten

  if ($found | is-empty) {
    print "Nothing to move to a ## Log."
  } else {
    $found | group-by file | items { |file, ps|
      print $"(ansi green)($ps.0.status)(ansi reset) ($file)"
      $ps | each { |p| print $"  ($p.line): ($p.heading)  (ansi dark_gray)\(($p.why)\)(ansi reset)" }
    }
    print $"($found | get file | uniq | length) tasks, ($found | length) headings."
  }

  # Every task says who it comes from, `done` ones included (README, "A
  # task's frontmatter"): those that do not are listed, whatever their
  # state, unless `--status` asks for one.
  let authorless = $tasks
    | where { |t| $status == "*" or $t.status == $status }
    | where { $in.author | is-empty }
  if ($authorless | is-not-empty) {
    print ''
    print $"(ansi yellow)Without an author:(ansi reset)"
    $authorless | sort-by status file | each { |t| print $"  (ansi green)($t.status)(ansi reset) ($t.file | path basename)" }
    print $"($authorless | length) tasks."
  }

  check_relations $tasks
  check_prose_links $tasks $status $docs
}

# The typed links of every task, whatever its state: a relation that is not
# one of RELATIONS, a link to a task that does not exist or to itself, and
# a link whose other end does not carry its inverse —`link` writes both—.
def check_relations [tasks: list] {
  let ids = $tasks | get id
  let edges = $tasks | each { |t| $t.links | each { |l| {from: $t.id, relation: $l.relation, to: $l.task} } } | flatten
  # A record as a set: looking each inverse up in a list is quadratic.
  let written = $edges | reduce --fold {} { |e, acc| $acc | upsert $"($e.from) ($e.relation) ($e.to)" true }
  let id_set = $ids | reduce --fold {} { |i, acc| $acc | insert $i true }
  let problems = $tasks | where bad_links | each { |t| {file: $t.id, why: "`links` is not a mapping of relation: [tasks]"} }
    | append ($edges | each { |e|
      if $e.relation not-in $RELATIONS {
        {file: $e.from, why: $"unknown relation `($e.relation)` \(to ($e.to)\)"}
      } else if ($id_set | get -o $e.to) == null {
        {file: $e.from, why: $"($e.relation): no task `($e.to)`"}
      } else if $e.to == $e.from {
        {file: $e.from, why: $"($e.relation): itself"}
      } else {
        let inverse = $RELATIONS | get $e.relation
        if ($written | get -o $"($e.to) ($inverse) ($e.from)") == null {
          {file: $e.from, why: $"($e.relation): ($e.to), which lacks `($inverse): [($e.from)]`"}
        }
      }
    } | compact)
  if ($problems | is-empty) {
    print $"Typed links: ($edges | length), all with both ends."
  } else {
    print ''
    print $"(ansi yellow)Typed links that do not hold:(ansi reset)"
    $problems | group-by file | items { |file, ps|
      print $"  ($file).md"
      $ps | each { |p| print $"    ($p.why)" }
    }
    print $"($problems | length) links. `nu tasks/tasks.nu link A <relation> B` writes both ends."
  }
}

# The links in the tasks' prose that lead nowhere, without the network:
# relative ones —another task, an image—, this repo's files on GitHub, and
# the published book's pages, against the book's `src/` in a checkout of
# the-advocate-docs —`<path>.html` is `src/<path>.md`, `index.html` its
# folder's README, and an old name in `book.toml`'s redirects still
# holds—. Without that checkout the book's are skipped, saying so. Any
# other URL is not checked: it needs the network and fails at random. What
# is inside code —fenced or between backticks— is not a link. Like the log
# check, `done` and `cancelled` tasks only with `--status`: their history
# is not rewritten.
def check_prose_links [tasks: list, status: string, docs?: string] {
  let root = $env.FILE_PWD | path dirname
  let docs = if $docs != null { $docs | path expand } else {
    # Next to this repo's main checkout: from a worktree, its parent is not.
    let common = try { git -C $root rev-parse --path-format=absolute --git-common-dir | str trim } catch { $root | path join .git }
    $common | path dirname | path dirname | path join the-advocate-docs
  }
  let has_docs = ($docs | path join src | path exists)
  let redirects = if $has_docs and ($docs | path join book.toml | path exists) {
    open --raw ($docs | path join book.toml) | from toml | get -o output.html.redirect | default {} | columns
  } else { [] }

  let found = $tasks
    | where { |t| if $status == "*" { $t.status not-in [done cancelled] } else { $t.status == $status } }
    | each { |t|
      let body = $t.raw | str replace --regex '(?s)\A---\n.*?\n---\n' ''
        | str replace --all --regex '(?ms)^[ \t]*```.*?^[ \t]*```' ''
        | str replace --all --regex '`[^`\n]*`' ''
      let relative = $body | parse --regex '\]\((?<t>[^)\s]+)' | get t
        | where { not ($in =~ '^([a-z]+:|#)') }
        | where { |l| let p = $l | str replace --regex '[#?].*$' ''; ($p | is-not-empty) and not ($env.FILE_PWD | path join $p | path exists) }
      let urls = $body | parse --regex '(?<u>https?://[^\s)<>\]"`]+)' | get u
        | each { str replace --regex '[.,;:!?\x27*_]+$' '' } | uniq
      let work = $urls | where { str starts-with $WORK_GITHUB } | where { |u|
        let p = $u | str substring ($WORK_GITHUB | str length).. | parse --regex '^(?:blob|tree)/main/(?<p>[^#?]+)' | get -o 0.p
        $p != null and not ($root | path join $p | path exists)
      }
      let book = if not $has_docs { [] } else {
        let pages = $urls | where { str starts-with $BOOK_PAGES } | where { |u|
          let p = $u | str substring ($BOOK_PAGES | str length).. | str replace --regex '[#?].*$' ''
          let p = if ($p | str ends-with '/') { $"($p)index.html" } else { $p }
          # The book's root is its first chapter, whatever its file.
          let ok = if ($p | is-empty) or $p == "index.html" { true } else if ($p | str ends-with '.html') {
            let stem = $p | str replace --regex '\.html$' ''
            (($docs | path join src $"($stem).md" | path exists)
              or ($stem =~ '(^|/)index$' and ($docs | path join src ($stem | str replace --regex 'index$' 'README.md') | path exists))
              or $"/($p)" in $redirects)
          } else { $docs | path join src $p | path exists }
          not $ok
        }
        let sources = $urls | where { str starts-with $BOOK_GITHUB } | where { |u|
          let p = $u | str substring ($BOOK_GITHUB | str length).. | parse --regex '^(?:blob|tree)/main/(?<p>[^#?]+)' | get -o 0.p
          $p != null and not ($docs | path join $p | path exists)
        }
        $pages | append $sources
      }
      $relative | append $work | append $book | each { |l| {file: $t.id, status: $t.status, link: $l} }
    }
    | flatten

  print ''
  if not $has_docs {
    print $"(ansi yellow)The book's links were not checked:(ansi reset) no the-advocate-docs at ($docs) \(--docs\)."
  }
  if ($found | is-empty) {
    print "No broken links."
  } else {
    print $"(ansi yellow)Broken links:(ansi reset)"
    $found | group-by file | items { |file, ls|
      print $"  (ansi green)($ls.0.status)(ansi reset) ($file).md"
      $ls | each { |l| print $"    ($l.link)" }
    }
    print $"($found | get file | uniq | length) tasks, ($found | length) links."
  }
}

# Pick a task with a fuzzy filter and open it in $EDITOR.
def "main open" [
  --status (-s): string = "*"
] {
  let tasks = all_tasks
    | where { $status == "*" or $in.status == $status }
    | sort-by { $in.status in [done cancelled] } status task_type

  let chosen = $tasks | input list --fuzzy --display { |t| [$t.status '  ' ($t | task_title) '  ' (ansi dark_gray) $t.description (ansi reset)] | str join } "Task:"
  if ($chosen | is-empty) { return }

  run-external ($env.EDITOR? | default micro) $chosen.file
}

# Relate two tasks: `link A blocks B` writes `blocks: [B]` in A's `links`
# and `blocked-by: [A]` in B's —both ends, which `check` asks for—. The
# tasks go by file name, with or without `.md`. Whatever is already in the
# frontmatter stays as it was, in its order; a link already written is not
# written twice.
def "main link" [
  a: string
  relation: string
  b: string
] {
  let a = $a | path basename | str replace --regex '\.md$' ''
  let b = $b | path basename | str replace --regex '\.md$' ''
  if $relation not-in $RELATIONS {
    error make --unspanned {msg: $"Unknown relation `($relation)`: one of ($RELATIONS | columns | str join ', ')."}
  }
  if $a == $b { error make --unspanned {msg: "A task is not related to itself."} }
  for t in [$a $b] {
    if not ($env.FILE_PWD | path join $"($t).md" | path exists) {
      error make --unspanned {msg: $"No task `($t)` in tasks/."}
    }
  }
  add_link ($env.FILE_PWD | path join $"($a).md") $relation $b
  add_link ($env.FILE_PWD | path join $"($b).md") ($RELATIONS | get $relation) $a
}

# Write `<relation>: [<task>]` into a file's `links`, touching only that:
# into the relation's line when it is there —flow `[a, b]` or a block of
# `- a` items—, as a new line at the end of `links` when the relation is
# not, and as a new `links` at the end of the frontmatter when there is
# none.
def add_link [file: string, relation: string, task: string] {
  let raw = open --raw $file
  let m = $raw | parse --regex '(?s)\A---\n(?<fm>.*?)\n---\n(?<rest>.*)\z'
  if ($m | is-empty) { error make --unspanned {msg: $"($file) has no frontmatter."} }
  let fm = $m.0.fm | lines
  let at = $fm | enumerate | where item =~ '^links:\s*$' | get -o 0.index
  let fm = if $at == null {
    $fm | append ["links:" $"  ($relation): [($task)]"]
  } else {
    # The block: the indented lines after `links:`.
    let block = $fm | skip ($at + 1) | take while { $in =~ '^\s' }
    let end = $at + ($block | length)          # its last line
    let indent = $block | get -o 0 | default "  " | parse --regex '^(?<i>\s*)' | get 0.i
    let rel_re = $"^\\s+($relation):"
    let r = $block | enumerate | where item =~ $rel_re | get -o 0.index
    if $r == null {
      $fm | insert ($end + 1) $"($indent)($relation): [($task)]"
    } else {
      let line = $block | get $r
      let i = $at + 1 + $r
      let flow = $line | parse --regex '^(?<pre>\s*[\w-]+:\s*)\[(?<items>.*)\]\s*$'
      if ($flow | is-not-empty) {
        let items = $flow.0.items | split row ',' | str trim | where { $in != "" }
        if $task in $items { return }
        $fm | update $i $"($flow.0.pre)[($items | append $task | str join ', ')]"
      } else {
        # `relation:` and its `- item` lines under it.
        let items = $block | skip ($r + 1) | take while { $in =~ '^\s+- ' }
        if ($items | any { ($in | str replace --regex '^\s+- ' '' | str trim) == $task }) { return }
        let item_indent = $items | get -o 0 | default $"($indent)  - " | parse --regex '^(?<i>\s+- )' | get 0.i
        $fm | insert ($i + ($items | length) + 1) $"($item_indent)($task)"
      }
    }
  }
  $"---\n($fm | str join "\n")\n---\n($m.0.rest)" | save --force --raw $file
}

# The tasks as a static page: replaces the TASKS marker of
# `site/index.html` with one section per state and writes it to
# `<out>/index.html`. It is what `.github/workflows/pages.yml` publishes;
# locally it is looked at by opening the file.
def "main html" [
  --out (-o): string = "_site"
] {
  let root = $env.FILE_PWD | path dirname
  let order = [doing testing todo draft wishlist done cancelled]

  let changed = last_changes $root
  let tasks = all_tasks | each { |t|
    $t | insert body (task_body $t.raw) | insert changed ($changed | get -o $t.id | default "")
  }
  # Each task's name and state, for the other tasks' list of links.
  let index = $tasks | reduce --fold {} { |t, acc| $acc | insert $t.id {name: $t.name, status: $t.status} }
  let states = $tasks | get status | uniq
    | sort-by { |s| $order | enumerate | where item == $s | get -o 0.index | default 99 }

  let html = $states | each { |s|
    let items = $tasks | where status == $s | sort-by name | sort-by --reverse { |t| if ($t.changed | is-empty) { 0 } else { $t.changed | into datetime | into int } } | each { task_html $index } | str join "\n"
    $"<section data-status=\"($s | escape)\">\n<h2>($s | escape)</h2>\n($items)\n</section>"
  } | str join "\n"

  let page = open --raw ($root | path join site index.html) | str replace '<!-- TASKS -->' $html
  mkdir ($root | path join $out)
  $page | save --force ($root | path join $out index.html)
  # The page's icon, which `index.html` names next to it.
  cp ($root | path join site favicon.png) ($root | path join $out favicon.png)
  # The tasks' images, at the same path relative to the page as to the
  # tasks in the repo, so one `images/<task>/x.png` works in both.
  let images = $root | path join tasks images
  if ($images | path exists) { cp -r $images ($root | path join $out) }
}

# When each task last changed, from git: `{<stem>: <ISO date>}`. The page
# puts the most recent first, so that what moved is what one sees. A task
# not committed yet has no entry, and goes last. It needs the whole history:
# the workflow checks out with `fetch-depth: 0` for that.
def last_changes [root: string] {
  git -C $root log --format=@%cI --name-only -- tasks/*.md
  | split row "@" | where $it != ""
  | each { |c| let l = $c | lines | where $it != ""; $l | skip 1 | each { |f| {id: ($f | path parse | get stem), date: $l.0} } }
  | flatten | uniq-by id
  | reduce --fold {} { |r, acc| $acc | insert $r.id $r.date }
}

# A task's body as HTML, with cmark-gfm —GitHub's own Markdown, so the page
# reads like the file on GitHub—: built here and not in the browser, so the
# page needs no script to be read. Raw HTML in a task comes out escaped,
# cmark-gfm's default. A link to another task —`other.md`, as they are
# written in the repo— goes to its anchor in the page. An image is shown
# small and is a link to itself, which opens it whole (a tap, on a phone);
# `loading="lazy"` so that a closed task does not fetch its images.
def render_body [] {
  $in | ^cmark-gfm --extension table --extension autolink --extension strikethrough
    | str replace --all --regex 'href="(?:\./)?([\w-]+)\.md(?:#[^"]*)?"' 'href="#$1"'
    | str replace --all --regex '<img src="([^"]*)"' '<a class="shot" href="$1"><img loading="lazy" src="$1"'
    | str replace --all --regex '(<a class="shot"[^>]*><img [^>]*>)' '$1</a>'
}

# A task's body, with its log apart: what comes before the exact line
# `## Log` defines the task and is rendered as it is; what comes after is
# its history, one `### <date>, <who>: <what>` entry per step (README, "A
# task's log"), and goes folded in a box of its own, closed, saying how
# many entries it has. A task without that line is all definition.
def body_html [links: string] {
  let body = $in
  let lines = $body | lines
  let at = $lines | enumerate | where item == "## Log" | get -o 0.index
  if $at == null { return ([($body | render_body) $links] | str join '') }
  let log = $lines | skip ($at + 1)
  let n = $log | where { $in | str starts-with "### " } | length
  # Logs older than the convention may have no `### ` entries: just "Log".
  let label = match $n { 0 => "", 1 => " · 1 entry", _ => $" · ($n) entries" }
  [
    ($lines | first $at | str join "\n" | render_body)
    $links
    $"<details class=\"log\"><summary>Log($label)</summary><div class=\"log-body\">($log | str join "\n" | render_body)</div></details>"
  ] | str join ''
}

# A task's typed links (README, "A task's frontmatter"), as the list the
# page shows before its log: one line per relation, in RELATIONS' order,
# and each task with its state, so that whether what blocks it is done is
# seen without opening it. Empty for a task without links.
def links_html [index: record] {
  let links = $in
  if ($links | is-empty) { return "" }
  let rows = $RELATIONS | columns | each { |rel|
    let ts = $links | where relation == $rel | get task
    if ($ts | is-empty) { return null }
    let items = $ts | each { |id|
      let t = $index | get -o $id
      if $t == null {
        $"<li><span class=\"missing\">($id | escape)</span></li>"
      } else {
        $"<li><a href=\"#($id | escape)\">($t.name | escape)</a> <span class=\"status\" data-status=\"($t.status | escape)\">($t.status | escape)</span></li>"
      }
    } | str join ''
    $"<dt>($rel | str replace '-' ' ' | escape)</dt><dd><ul>($items)</ul></dd>"
  } | compact | str join ''
  # A `div` and not a `section`: the page's script takes every section in
  # it for a state's.
  $"<div class=\"links\"><h2>Links</h2><dl>($rows)</dl></div>"
}

# What comes after the frontmatter.
def task_body [raw: string] {
  $raw | str replace --regex '(?s)\A---\n.*?\n---\n' '' | str trim
}

def escape [] {
  $in | into string | str replace --all '&' '&amp;' | str replace --all '<' '&lt;'
    | str replace --all '>' '&gt;' | str replace --all '"' '&quot;'
}

# One task, closed: its anchor is its file name, which never changes, so
# `#<name>` links it from outside. The summary's button copies that name
# —what taro pastes into a conversation to point at a task—; it is in the
# summary so that it works with the task closed.
def task_html [index: record] {
  let t = $in
  let id = $t.file | path parse | get stem
  let agents = if ($t.listed_agents | is-empty) { "" } else { $" · agents: ($t.listed_agents | str join ', ' | escape)" }
  let assignee = if ($t.assignee | is-empty) { "" } else { $" · assignee: ($t.assignee | escape)" }
  let author = if ($t.author | is-empty) { "" } else { $" · author: ($t.author | escape)" }
  let changed = if ($t.changed | is-empty) { "" } else { $" · changed <time datetime=\"($t.changed)\">($t.changed | str substring 0..9)</time>" }
  let source = $"https://github.com/lautarodragan/the-advocate-work/blob/main/tasks/($id).md"
  let games = $t.games | each { |g| $"<span class=\"game\" data-game=\"($g | escape)\">($g | game_label | escape)</span>" } | str join ''
  [
    $"<details class=\"task\" id=\"($id | escape)\" data-status=\"($t.status | escape)\" data-type=\"($t.task_type | escape)\" data-game=\"($t.games | str join ' ' | escape)\" data-author=\"($t.author | escape)\">"
    $"<summary><button type=\"button\" class=\"copy\" data-copy=\"($id | escape)\" title=\"Copy the task's file name\">copy</button><button type=\"button\" class=\"pick\" data-id=\"($id | escape)\" aria-pressed=\"false\" title=\"Add the task to the selection, to copy several at once\">select</button><span class=\"type\">($t.task_type | escape)</span>($games)<span class=\"name\">($t.name | escape)</span>"
    $"<span class=\"desc\">($t.description | escape)</span></summary>"
    $"<p class=\"meta\"><a href=\"#($id)\">#</a> · <a href=\"($source)\">($id).md</a>($changed)($author)($assignee)($agents)</p>"
    $"<div class=\"body\">($t.body | body_html ($t.links | links_html $index))</div>"
    "</details>"
  ] | str join ''
}
