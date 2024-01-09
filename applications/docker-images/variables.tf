variable "github" {
  type = object({
    access-token = string
    owner = string
  })
}