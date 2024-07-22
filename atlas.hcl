lint {
  non_linear {
    error = true # detects non-linear changes and cause migration linting to fail.
  }
  destructive {
    error = false # detects destuctive changes but not cause migration linting to fail
  }
  data_depend {
    error = false # detects data dependent changes but not cause migration linting to fail
  }
  incompatible {
    error = false # detects incompatible changes but not cause migration linting to fail
  }
}

variable "database_url" {
  type    = string
  default = getenv("DATABASE_URL")
}

env "dev" {
  src = "file://db/migrations/schema.hcl"                     # The URL of or reference to for the desired schema of this environment.
  url = var.database_url # The URL of the target database. In Production, This URL is Productin Database URL.
  dev = "docker://mariadb/10.7"                 # Dev Database URL.
  schemas = [
    "nikki"
  ]
  migration {
    dir      = "file://db/migrations" # The URL to the migration directory. ex: file://db/migrations
    baseline = "20240722023537"       # baseline - An optional version to start the migration history from
  }
  diff {
    skip {
      drop_table  = false # true: do not generate `drop table SQL` migration file.
      drop_schema = true  # true: do not generate `drop schema SQL` migration file.
    }
  }
}

env "ci" {
  src = "file://db/migrations/schema.hcl"                     # The URL of or reference to for the desired schema of this environment.
  url = var.database_url # The URL of the target database. In Production, This URL is Productin Database URL.
  dev = "docker://mariadb/10.7"                 # Dev Database URL.
  schemas = [
    "nikki"
  ]
  migration {
    dir      = "file://db/migrations" # The URL to the migration directory. ex: file://db/migrations
    baseline = "20240722023537"       # baseline - An optional version to start the migration history from
  }
  diff {
    skip {
      drop_table  = false # true: do not generate `drop table SQL` migration file.
      drop_schema = true  # true: do not generate `drop schema SQL` migration file.
    }
  }
}
