resource "aws_ecr_repository" "gh_actions_dispatcher" {
  name                 = "gh-actions-dispatcher"
  image_tag_mutability = "MUTABLE"
}
