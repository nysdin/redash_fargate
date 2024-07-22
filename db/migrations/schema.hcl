table "users" {
  schema = schema.nikki
  column "id" {
    null           = false
    type           = bigint
    auto_increment = true
  }
  column "name" {
    null = false
    type = varchar(255)
  }
  column "age" {
    null = false
    type = int
  }
  column "sex" {
    null = false
    type = varchar(255)
  }
  primary_key {
    columns = [column.id]
  }
}
schema "nikki" {
  charset = "utf8mb4"
  collate = "utf8mb4_unicode_ci"
}
