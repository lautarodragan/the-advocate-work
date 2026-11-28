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
  found-in: found
  found: found-in
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
  advocate: "Advocate"
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

# What taro wrote from the tasks page —or by hand— that Hornero has not
# answered yet: every log entry `### <date>, taro: <what>` with no
# `### <date>, Hornero: …` after it in the same task, whatever the task's
# state. Hornero reads it at the start of a session, with `doing` and
# `testing` (AGENTS.md).
def "main inbox" [] {
  let found = all_tasks | each { |t|
    let lines = $t.raw | lines
    # The conversation lives in `## Comments`, above the log; a task
    # without that section —the `done` ones, older than it— has it in its
    # `## Log`.
    let c_at = $lines | enumerate | where item == "## Comments" | get -o 0.index
    let l_at = $lines | enumerate | where item == "## Log" | get -o 0.index
    let section = if $c_at != null {
      $lines | skip ($c_at + 1) | take while { $in != "## Log" }
    } else if $l_at != null {
      $lines | skip ($l_at + 1)
    } else { return [] }
    mut open = []
    mut current = {}
    for l in $section {
      let h = $l | parse --regex '^### (?<date>\d{4}-\d{2}-\d{2}), (?<who>[^:]+):\s*(?<what>.*)$'
      if ($h | is-not-empty) {
        if ($current | is-not-empty) { $open = $open | append $current }
        let who = $h.0.who | normalize
        if $who == "hornero" { $open = [] }
        $current = if $who == "taro" { {task: $t.id, status: $t.status, date: $h.0.date, what: $h.0.what, text: ""} } else { {} }
      } else if ($current | is-not-empty) and ($current.text | is-empty) and ($l | str starts-with '>') {
        $current = $current | update text ($l | str replace --regex '^>\s?' '')
      }
    }
    if ($current | is-not-empty) { $open = $open | append $current }
    $open
  } | flatten
  if ($found | is-empty) { print "Nothing from taro waiting."; return }
  $found | sort-by date | each { |e|
    print $"(ansi green)($e.status)(ansi reset) ($e.task).md"
    print $"  ($e.date): ($e.what)"
    if ($e.text | is-not-empty) { print $"  (ansi dark_gray)> ($e.text)(ansi reset)" }
  }
  print $"($found | length) entries."
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
#
# With `--strict` it fails when any of those last three finds something,
# which is how CI runs it (`.github/workflows/check.yml`): the tasks page
# commits straight to `main`, and a task it breaks has to show. The
# log-like headings stay a report there too: they are judged by reading.
def "main check" [
  --status (-s): string = "*"
  --docs: string    # the-advocate-docs checkout, for the book's links; by default the one next to this repo
  --strict          # exit 1 when a task has no author, a link does not hold or a link is broken
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
      mut in_comments = false
      mut comments_seen = false
      mut defined_next = false
      mut problems = []
      for l in ($lines | enumerate) {
        let text = $l.item
        if ($text | str starts-with '```') { $fence = not $fence; continue }
        if $fence { continue }
        if $text == "## Log" {
          if $log_at >= 0 { $problems = $problems | append {line: ($l.index + 1), heading: $text, why: "a second ## Log"} }
          $log_at = $l.index
          $in_comments = false
          continue
        }
        # `## Comments` goes right above `## Log`, and what is in it is
        # entries like the log's: the conversation with taro.
        if $text == "## Comments" {
          if $log_at >= 0 {
            $problems = $problems | append {line: ($l.index + 1), heading: $text, why: "## Comments after ## Log"}
          } else if $comments_seen {
            $problems = $problems | append {line: ($l.index + 1), heading: $text, why: "a second ## Comments"}
          }
          $in_comments = true
          $comments_seen = true
          continue
        }
        if $in_comments {
          if ($text | str starts-with '## ') or ($text | str starts-with '# ') {
            $problems = $problems | append {line: ($l.index + 1), heading: $text, why: "a section between ## Comments and ## Log"}
          }
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

  let bad = ($authorless | length) + (check_relations $tasks) + (check_prose_links $tasks $status $docs)
  if $strict and $bad > 0 { exit 1 }
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
  $problems | length
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
  $found | length
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
# Adds an entry to a task's `## Comments` (README, "A task's comments"):
# `### <today>, <who>: <title>`, then what comes on stdin. The section is
# made right above `## Log` if the task has none. For Hornero's and the
# agents' answers and questions; the tasks page writes taro's the same
# way.
def "main comment" [
  task: string   # the task's file name, with or without .md
  who: string    # who writes it: taro, Hornero, Cardón…
  title: string  # what the entry is about
] {
  # The text comes on stdin, which a script's `main` does not get as `$in`.
  let text = ^cat | str trim
  let file = $env.FILE_PWD | path join $"($task | str replace --regex '\.md$' '').md"
  let raw = open --raw $file
  let entry = $"### (date now | format date '%Y-%m-%d'), ($who): ($title)\n\n($text)\n"
  $raw | add_comment $entry | save --raw --force $file
}

# `text` with `entry` at the end of its `## Comments`, made above `## Log`
# —or at the end— when missing.
def add_comment [entry: string] {
  let lines = $in | str trim --right | lines
  let c_at = $lines | enumerate | where item == "## Comments" | get -o 0.index
  let l_at = $lines | enumerate | where item == "## Log" | get -o 0.index
  let block = $entry | str trim --right | lines
  if $c_at != null {
    let end = if $l_at != null and $l_at > $c_at { $l_at } else { $lines | length }
    let before = $lines | first $end | str join "\n" | str trim --right
    let after = $lines | skip $end
    [$before "" ...$block "" ...$after] | str join "\n" | $in + "\n" | str replace --regex '\n+$' "\n"
  } else if $l_at != null {
    let before = $lines | first $l_at | str join "\n" | str trim --right
    [$before "" "## Comments" "" ...$block "" ...($lines | skip $l_at)] | str join "\n" | $in + "\n" | str replace --regex '\n+$' "\n"
  } else {
    [($lines | str join "\n") "" "## Comments" "" ...$block] | str join "\n" | $in + "\n"
  }
}

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

  # The page comes already filtered as the script would leave it with no
  # filter in the URL: the first state with any task, every type, game and
  # author. The rest is in the page, hidden, for the script to show.
  let default = $states | get -o 0 | default "all"
  let html = $states | each { |s|
    let shown = $default in [$s all]
    let items = $tasks | where status == $s | sort-by name | sort-by --reverse { |t| if ($t.changed | is-empty) { 0 } else { $t.changed | into datetime | into int } } | each { task_html $index $shown } | str join "\n"
    $"<section data-status=\"($s | escape)\"(if $shown { '' } else { ' hidden' })>\n<h2>($s | escape)</h2>\n($items)\n</section>"
  } | str join "\n"

  let page = open --raw ($root | path join site index.html)
    | str replace '<!-- FILTERS -->' ($tasks | filters_html $states $default)
    | str replace '<!-- TASKS -->' $html
    | str replace '<!-- COMMIT -->' $"<meta name=\"tasks-commit\" content=\"(git -C $root log -1 --format='%H %cI' | str trim)\">"
  mkdir ($root | path join $out)
  $page | save --force ($root | path join $out index.html)
  # The page's icon, which `index.html` names next to it.
  cp ($root | path join site favicon.png) ($root | path join $out favicon.png)
  # The tasks' images, at the same path relative to the page as to the
  # tasks in the repo, so one `images/<task>/x.png` works in both.
  let images = $root | path join tasks images
  if ($images | path exists) { cp -r $images ($root | path join $out) }
}

# The filter buttons, which the page's script used to make and now finds
# in the page: one row per state —in the build's order, with their totals,
# and `all` last—, and one per type, game and author —the most used first
# over every task, so that the order does not jump when the state changes;
# counted in the default state, the one the page shows first; `none` last
# for the tasks that name no game or author—. In the page as it is served,
# so that they are there on the first paint and nothing moves when the
# script arrives.
def filters_html [states: list, default: string] {
  let tasks = $in
  let shown = if $default == all { $tasks } else { $tasks | where status == $default }
  let status = $states | each { |s| filter_button status $s $s ($tasks | where status == $s | length) ($s == $default) false }
    | append (filter_button status all all ($tasks | length) ($default == all) false)
  let types = [all] | append ($tasks | get task_type | by_use) | each { |ty|
    let n = if $ty == all { $shown | length } else { $shown | where task_type == $ty | length }
    filter_button type $ty $ty $n ($ty == all) true
  }
  let games = [all] | append ($tasks | get games | flatten | by_use) | append [none] | each { |g|
    let n = match $g { all => ($shown | length), none => ($shown | where { $in.games | is-empty } | length), _ => ($shown | where { $g in $in.games } | length) }
    filter_button game $g ($g | game_label) $n ($g == all) true
  }
  let authors = [all] | append ($tasks | get author | where $it != "" | by_use) | append [none] | each { |a|
    let n = match $a { all => ($shown | length), none => ($shown | where author == "" | length), _ => ($shown | where author == $a | length) }
    filter_button author $a $a $n ($a == all) true
  }
  [
    (filter_row filters "Filter by status" $status)
    (filter_row types "Filter by type" $types)
    (filter_row games "Filter by game" $games)
    (filter_row authors "Filter by author" $authors)
  ] | str join "\n"
}

def filter_row [id: string, label: string, buttons: list] {
  $"<nav class=\"filters\" id=\"($id)\" aria-label=\"($label)\">($buttons | str join '')</nav>"
}

# The values most used first, and by name among those used as much.
def by_use [] {
  # Not `--reverse`, which turns the ties around too.
  $in | uniq --count | sort-by value | sort-by { |r| 0 - $r.count } | get value
}

# One filter button. `empty` dims what has no task in the state shown; the
# states' own row never says it.
def filter_button [attr: string, value: string, label: string, count: int, pressed: bool, dim: bool] {
  let class = if $dim and $count == 0 { ' class="empty"' } else { '' }
  $"<button type=\"button\"($class) data-($attr)=\"($value | escape)\" aria-pressed=\"($pressed)\">($label | escape)<span class=\"count\">($count)</span></button>"
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
# page carries no Markdown library; its script only puts the HTML in when
# the task is opened. Raw HTML in a task comes out escaped,
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

# The `### ` entries of a task's `## Comments`, the conversation with
# taro.
def comment_entries [] {
  let lines = $in | lines
  let at = $lines | enumerate | where item == "## Comments" | get -o 0.index
  if $at == null { return 0 }
  $lines | skip ($at + 1) | take while { $in != "## Log" } | where { $in | str starts-with "### " } | length
}

# A task's body, with its comments and its log apart: what comes before
# the exact line `## Comments` —or `## Log`, without it— defines the task
# and is rendered as it is; the comments, the conversation with taro, go
# in a box of their own, open; the log, its history, one `### <date>,
# <who>: <what>` entry per step (README, "A task's log"), folded in
# another, closed, saying how many entries it has. A task without either
# line is all definition.
def body_html [links: string] {
  let body = $in
  let lines = $body | lines
  let at = $lines | enumerate | where item == "## Log" | get -o 0.index
  let c_at = $lines | enumerate | where item == "## Comments" | get -o 0.index
  let defined_end = if $c_at != null { $c_at } else if $at != null { $at } else { $lines | length }
  let comments = if $c_at == null { "" } else {
    let c = $lines | skip ($c_at + 1) | take while { $in != "## Log" }
    let n = $c | where { $in | str starts-with "### " } | length
    let label = match $n { 0 => "", 1 => " · 1", _ => $" · ($n)" }
    $"<details class=\"log comments\" open><summary>Comments($label)</summary><div class=\"log-body\">($c | str join "\n" | render_body)</div></details>"
  }
  let log = if $at == null { "" } else {
    let l = $lines | skip ($at + 1)
    let n = $l | where { $in | str starts-with "### " } | length
    # Logs older than the convention may have no `### ` entries: just "Log".
    let label = match $n { 0 => "", 1 => " · 1 entry", _ => $" · ($n) entries" }
    $"<details class=\"log\"><summary>Log($label)</summary><div class=\"log-body\">($l | str join "\n" | render_body)</div></details>"
  }
  [
    ($lines | first $defined_end | str join "\n" | render_body)
    $links
    $comments
    $log
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

# One task, closed, and hidden unless `shown` —in the state the page shows
# first—: its anchor is its file name, which never changes, so
# `#<name>` links it from outside. The summary's button copies that name
# —what taro pastes into a conversation to point at a task—; it is in the
# summary so that it works with the task closed. The body is not HTML
# until the task is opened: see below.
def task_html [index: record, shown: bool] {
  let t = $in
  let id = $t.file | path parse | get stem
  let agents = if ($t.listed_agents | is-empty) { "" } else { $" · agents: ($t.listed_agents | str join ', ' | escape)" }
  # In a span of its own, which the page's script rewrites when a change
  # to it waits in the queue (see "Writing back" in `site/index.html`).
  let assignee = if ($t.assignee | is-empty) { "" } else { $"<span class=\"assignee\"> · assignee: ($t.assignee | escape)</span>" }
  let author = if ($t.author | is-empty) { "" } else { $" · author: ($t.author | escape)" }
  let changed = if ($t.changed | is-empty) { "" } else { $" · changed <time datetime=\"($t.changed)\">($t.changed | str substring 0..9)</time>" }
  let source = $"https://github.com/lautarodragan/the-advocate-work/blob/main/tasks/($id).md"
  let games = $t.games | each { |g| $"<span class=\"game\" data-game=\"($g | escape)\">($g | game_label | escape)</span>" } | str join ''
  # The body goes as the text of a script the browser does not run, and
  # the page's script makes it HTML when the task is opened: as elements
  # it is nine in ten of the page's nodes, and parsing them held a
  # phone's main thread for half a second at a time. A `</script` would
  # end that text, and a `<script` after a `<!--` —cmark-gfm writes
  # `<!-- raw HTML omitted -->` for a task's raw HTML— would change how it
  # is read; cmark-gfm escapes the `<` of what the task writes, so this
  # only guards.
  # How many comments it has, on the folded summary too, so a task with a
  # conversation going is seen without opening it.
  let entries = $t.body | comment_entries
  let count = if $entries == 0 { "" } else { $"<span class=\"entries\" title=\"($entries) comment(if $entries == 1 { '' } else { 's' })\">($entries)</span>" }
  let body = $t.body | body_html ($t.links | links_html $index)
    | str replace --all --regex '(?i)<(/?script)' '&lt;$1'
  [
    $"<details class=\"task\" id=\"($id | escape)\" data-status=\"($t.status | escape)\" data-type=\"($t.task_type | escape)\" data-game=\"($t.games | str join ' ' | escape)\" data-author=\"($t.author | escape)\" data-assignee=\"($t.assignee | escape)\"(if $shown { '' } else { ' hidden' })>"
    $"<summary><button type=\"button\" class=\"copy\" data-copy=\"($id | escape)\" title=\"Copy the task's file name\">copy</button><button type=\"button\" class=\"pick\" data-id=\"($id | escape)\" aria-pressed=\"false\" title=\"Add the task to the selection, to copy several at once\">select</button><span class=\"type\">($t.task_type | escape)</span>($games)<span class=\"name\">($t.name | escape)</span>($count)"
    $"<span class=\"desc\">($t.description | escape)</span></summary>"
    $"<p class=\"meta\"><a href=\"#($id)\">#</a> · <a href=\"($source)\">($id).md</a>($changed)($author)($assignee)($agents)</p>"
    $"<script type=\"text/x-task-body\" class=\"body\">($body)</script>"
    "</details>"
  ] | str join ''
}
