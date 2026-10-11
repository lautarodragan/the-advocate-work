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
