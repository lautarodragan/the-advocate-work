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
  
  return {
    file: $file,
    name: $name,
    task_type: $task_type,
    status: $status,
    description: $task_description,
    assignee: $assignee,
    agents: $agents,
    listed_agents: ($yml | get -o agents | default []),
  }
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
# written in the repo— goes to its anchor in the page.
def render_body [] {
  $in | ^cmark-gfm --extension table --extension autolink --extension strikethrough
    | str replace --all --regex 'href="(?:\./)?([\w-]+)\.md(?:#[^"]*)?"' 'href="#$1"'
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
# `#<name>` links it from outside.
def task_html [] {
  let t = $in
  let id = $t.file | path parse | get stem
  let agents = if ($t.listed_agents | is-empty) { "" } else { $" · agents: ($t.listed_agents | str join ', ' | escape)" }
  let assignee = if ($t.assignee | is-empty) { "" } else { $" · assignee: ($t.assignee | escape)" }
  let changed = if ($t.changed | is-empty) { "" } else { $" · changed <time datetime=\"($t.changed)\">($t.changed | str substring 0..9)</time>" }
  let source = $"https://github.com/lautarodragan/the-advocate-work/blob/main/tasks/($id).md"
  [
    $"<details class=\"task\" id=\"($id | escape)\" data-status=\"($t.status | escape)\" data-type=\"($t.task_type | escape)\">"
    $"<summary><span class=\"type\">($t.task_type | escape)</span><span class=\"name\">($t.name | escape)</span>"
    $"<span class=\"desc\">($t.description | escape)</span></summary>"
    $"<p class=\"meta\"><a href=\"#($id)\">#</a> · <a href=\"($source)\">($id).md</a>($changed)($assignee)($agents)</p>"
    $"<div class=\"body\">($t.body | render_body)</div>"
    "</details>"
  ] | str join ''
}
