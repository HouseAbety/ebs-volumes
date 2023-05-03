terraform {
  backend "remote" {
    organization = "company"
    workspaces {
      name = "lambda"
    }
  }
}