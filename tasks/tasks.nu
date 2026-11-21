#! /bin/env nu

def main [] {
  
}

def parse_file [file: string] {
  # let file = $in | path basename
    
  let yml = open $file
    | where element == yaml
    | first
    | get -o content

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
  # `assignee` is who has it now —taro, when it moves to testing—, and
  # `agents` everyone who worked on it, which is never erased.
  let agents = $yml | get -o agents | default [] | append $assignee | where { $in != "" }
  # `game`: the ports' directory of the game where it was seen and where it
  # has to be played to close it —one, or a list—. Without it, the file
  # name's prefix says it when it has one (`abl-…`, `zounds-…`); the rest
  # —the tools' own, or a game the name does not say— has none.
  let games = $yml | get -o game | default (game_of_name ($file | path parse | get stem)) | append [] | where { $in != "" }
  
  return {
    file: $file,
    name: $name,
    task_type: $task_type,
    status: $status,
    description: $task_description,
    assignee: $assignee,
    agents: $agents,
    listed_agents: ($yml | get -o agents | default []),
    games: $games,
  }
}

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
# the frontmatter: draft, todo, doing, testing, done or wishlist. With
# `--status "*"`, all of them, grouped by state.
#
# With `--assignee`, only those that one has or worked on —their
# `assignee` or their `agents` list—: this is how a sub-agent finds its
# own, in any state with `-s "*"`. Ignoring case and accents, so that
# "huron" finds Hurón.
def "main ls" [
  --status (-s): string = "doing"
  --assignee (-a): string
] {
  let tasks = all_tasks
    | where { $status == "*" or $in.status == $status }
    | where { |t| $assignee == null or ($t.agents | any { ($in | normalize) == ($assignee | normalize) }) }

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
# tasks are left out unless asked for with `--status`.
#
# A heading reads like an entry when it starts with a word of the log
# —Done, Checked, Verified, What was done, When merging…—, when it is
# `Defined` with a date or an agent after it (a bare `## Defined` is the
# definition's own heading), when it carries a date, or when it starts
# with an agent's name or ends with one alone in parentheses —`(Cardón)`—.
# The date and the agent do not count in a heading that names taro: taro's words and
# decisions define the task.
def "main check" [
  --status (-s): string = "*"
] {
  let agents = ls ($env.FILE_PWD | path dirname | path join .claude agents '*.md' | into glob)
    | get name | each { path parse | get stem } | append hornero
  let agent_re = $agents | str join '|'
  let word = '^(done|doing|checked|reviewed|verified|verification|work|what was done|what was run|what ran|status|left|where it was left|closed|measured|measured again|delivered|result|taken|seen again|changed under it|merged|merging|when merging|on merging|for merging|to merge|to install|what to install|after merging|red after merging|tested|how it was verified|handed back|resumed)\b'
  let date = '\d{4}-\d{2}-\d{2}'

  let found = all_tasks
    | where { |t| if $status == "*" { $t.status != done } else { $t.status == $status } }
    | each { |t|
      let lines = open --raw $t.file | lines
      mut fence = false
      mut log_at = -1
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
        # without a heading. `**Done** means` is the definition's.
        let b = $text | parse --regex '^\*\*(?<lead>[^*]+)\*\*'
        if $log_at < 0 and ($b | is-not-empty) {
          let lead = $b.0.lead | normalize
          if (not ($lead =~ '\btaro\b') and ($lead =~ $date
              or $lead =~ $"^\(($agent_re)\)\\b"
              or $lead =~ '^(checked|verified|reviewed|measured|measured again|seen again)\b')) {
            $problems = $problems | append {line: ($l.index + 1), heading: ($text | str substring 0..60), why: "a bold entry, above ## Log"}
          }
          continue
        }
        let h = $text | parse --regex '^(?<hashes>#{2,6}) (?<title>.*)$'
        if ($h | is-empty) { continue }
        let title = $h.0.title | normalize
        if $log_at >= 0 {
          if $h.0.hashes == "##" {
            $problems = $problems | append {line: ($l.index + 1), heading: $text, why: "a ## section after ## Log"}
          }
          continue
        }
        let by_taro = $title =~ '\btaro\b'
        let entry = ($title =~ $word
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

  if ($found | is-empty) { print "Nothing to move to a ## Log."; return }
  $found | group-by file | items { |file, ps|
    print $"(ansi green)($ps.0.status)(ansi reset) ($file)"
    $ps | each { |p| print $"  ($p.line): ($p.heading)  (ansi dark_gray)\(($p.why)\)(ansi reset)" }
  }
  print $"($found | get file | uniq | length) tasks, ($found | length) headings."
}

# Pick a task with a fuzzy filter and open it in $EDITOR.
def "main open" [
  --status (-s): string = "*"
] {
  let tasks = all_tasks
    | where { $status == "*" or $in.status == $status }
    | sort-by { $in.status == done } status task_type

  let chosen = $tasks | input list --fuzzy --display { |t| [$t.status '  ' ($t | task_title) '  ' (ansi dark_gray) $t.description (ansi reset)] | str join } "Task:"
  if ($chosen | is-empty) { return }

  run-external ($env.EDITOR? | default micro) $chosen.file
}

# The tasks as a static page: replaces the TASKS marker of
# `site/index.html` with one section per state and writes it to
# `<out>/index.html`. It is what `.github/workflows/pages.yml` publishes;
# locally it is looked at by opening the file.
def "main html" [
  --out (-o): string = "_site"
] {
  let root = $env.FILE_PWD | path dirname
  let order = [doing testing todo draft wishlist done]

  let changed = last_changes $root
  let tasks = all_tasks | each { |t|
    let id = $t.file | path parse | get stem
    $t | insert body (task_body $t.file) | insert changed ($changed | get -o $id | default "")
  }
  let states = $tasks | get status | uniq
    | sort-by { |s| $order | enumerate | where item == $s | get -o 0.index | default 99 }

  let html = $states | each { |s|
    let items = $tasks | where status == $s | sort-by name | sort-by --reverse { |t| if ($t.changed | is-empty) { 0 } else { $t.changed | into datetime | into int } } | each { task_html } | str join "\n"
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
def body_html [] {
  let body = $in
  let lines = $body | lines
  let at = $lines | enumerate | where item == "## Log" | get -o 0.index
  if $at == null { return ($body | render_body) }
  let log = $lines | skip ($at + 1)
  let n = $log | where { $in | str starts-with "### " } | length
  # Logs older than the convention may have no `### ` entries: just "Log".
  let label = match $n { 0 => "", 1 => " · 1 entry", _ => $" · ($n) entries" }
  [
    ($lines | first $at | str join "\n" | render_body)
    $"<details class=\"log\"><summary>Log($label)</summary><div class=\"log-body\">($log | str join "\n" | render_body)</div></details>"
  ] | str join ''
}

# What comes after the frontmatter.
def task_body [file: string] {
  open --raw $file | str replace --regex '(?s)\A---\n.*?\n---\n' '' | str trim
}

def escape [] {
  $in | into string | str replace --all '&' '&amp;' | str replace --all '<' '&lt;'
    | str replace --all '>' '&gt;' | str replace --all '"' '&quot;'
}

# One task, closed: its anchor is its file name, which never changes, so
# `#<name>` links it from outside. The summary's button copies that name
# —what taro pastes into a conversation to point at a task—; it is in the
# summary so that it works with the task closed.
def task_html [] {
  let t = $in
  let id = $t.file | path parse | get stem
  let agents = if ($t.listed_agents | is-empty) { "" } else { $" · agents: ($t.listed_agents | str join ', ' | escape)" }
  let assignee = if ($t.assignee | is-empty) { "" } else { $" · assignee: ($t.assignee | escape)" }
  let changed = if ($t.changed | is-empty) { "" } else { $" · changed <time datetime=\"($t.changed)\">($t.changed | str substring 0..9)</time>" }
  let source = $"https://github.com/lautarodragan/the-advocate-work/blob/main/tasks/($id).md"
  let games = $t.games | each { |g| $"<span class=\"game\" data-game=\"($g | escape)\">($g | game_label | escape)</span>" } | str join ''
  [
    $"<details class=\"task\" id=\"($id | escape)\" data-status=\"($t.status | escape)\" data-type=\"($t.task_type | escape)\" data-game=\"($t.games | str join ' ' | escape)\">"
    $"<summary><button type=\"button\" class=\"copy\" data-copy=\"($id | escape)\" title=\"Copy the task's file name\">copy</button><button type=\"button\" class=\"pick\" data-id=\"($id | escape)\" aria-pressed=\"false\" title=\"Add the task to the selection, to copy several at once\">select</button><span class=\"type\">($t.task_type | escape)</span>($games)<span class=\"name\">($t.name | escape)</span>"
    $"<span class=\"desc\">($t.description | escape)</span></summary>"
    $"<p class=\"meta\"><a href=\"#($id)\">#</a> · <a href=\"($source)\">($id).md</a>($changed)($assignee)($agents)</p>"
    $"<div class=\"body\">($t.body | body_html)</div>"
    "</details>"
  ] | str join ''
}
