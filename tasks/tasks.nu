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
  # `assignee` es quién la tiene ahora —taro, cuando pasa a testing—, y
  # `agents` todos los que trabajaron en ella, que no se borra.
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

# Para comparar nombres: minúsculas y sin tildes.
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

# Las tareas viven todas en esta carpeta, y su estado es el `status` del
# frontmatter: draft, todo, doing, testing, done o wishlist. Con
# `--status "*"`, todas, agrupadas por estado.
#
# Con `--assignee`, sólo las que tiene o en las que trabajó ése —su
# `assignee` o su lista `agents`—: un sub-agente busca así lo suyo, de
# cualquier estado con `-s "*"`. Sin distinguir mayúsculas ni tildes, para
# que "huron" encuentre a Hurón.
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

# Todas las tareas de la carpeta, leídas: la de este script, así se puede
# correr desde cualquier lado.
def all_tasks [] {
  ls ($env.FILE_PWD | path join '*.md' | into glob) | where type == file | get name | each { parse_file $in }
}

# Elegir una tarea con filtro difuso y abrirla en $EDITOR.
def "main open" [
  --status (-s): string = "*"
] {
  let tasks = all_tasks
    | where { $status == "*" or $in.status == $status }
    | sort-by { $in.status == done } status task_type

  let chosen = $tasks | input list --fuzzy --display { |t| [$t.status '  ' ($t | task_title) '  ' (ansi dark_gray) $t.description (ansi reset)] | str join } "Tarea:"
  if ($chosen | is-empty) { return }

  run-external ($env.EDITOR? | default micro) $chosen.file
}
