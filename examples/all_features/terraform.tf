terraform {}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      ManagedBy     = "terraform"
      RepositoryUrl = "github.com/kasaikou/terraform-kasaikou-awsvpc"
    }
  }
}
