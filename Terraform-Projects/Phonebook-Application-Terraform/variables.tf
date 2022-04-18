variable "awsprops" {
  type = map(string)
  default = {
    keyname      = "firstkey"
    instancetype = "t2.micro"

  }

}

variable "dbprops" {   
  type = map(string)
  default = {
    identifier = ""
    DbName     = "clarusway_phonebook"
    username   = "admin"
    password   = "123456789"  #Here we didn't use this password, we used var.db_password variable and this variable wants the user to enter its own password...
  }

}

variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}