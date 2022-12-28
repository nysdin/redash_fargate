#########################################
#
# Code Pipeline
#
#########################################

# resource "aws_codepipeline" "main" {
#   name     = "redash_fargate_pipeline"
#   artifact_store {
#     location = aws_s3_bucket.redash_fargate_artifact.bucket
#     type = "s3"
#   }

#   stage {

#   }
# }
