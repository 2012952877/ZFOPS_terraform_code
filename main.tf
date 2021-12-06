# 声明Provider
terraform {
  required_providers {
    azuredevops = {
      source = "microsoft/azuredevops"
      version = ">= 0.1.8"
    }
  }
}

# Or set url and token in here
/* provider "azuredevops" {
  version = ">= 0.1.0"
  org_service_url = "https://dev.azure.com/<>/"
  personal_access_token = ""
} */


# 创建Project 
# https://registry.terraform.io/providers/microsoft/azuredevops/latest/docs/resources/project
resource "azuredevops_project" "project" {
  name               = "ZFold" #project的名字不能和repo一样，terraform目前不支持这部分操作
  description        = "ZF Terraform Deploy"
  visibility         = "public"             # Options: private, public
  version_control    = "Git"                # Options: Git, Tfvc
  work_item_template = "Agile"              # Options: Agile, Basic, CMMI, Scrum
/*   features = {
      "boards" = "enabled"
      "repositories" = "enabled"
      "pipelines" = "enabled"
      "testplans" = "enabled"
      "artifacts" = "enabled"
  } */
}

# 从public的repo里导入
resource "azuredevops_git_repository" "repo" {
  project_id = azuredevops_project.project.id
  name       = "ZFnew" # 只会在ZFold中创建一个名为ZFnew的branch
  initialization {
    init_type   = "Import"
    source_type = "Git"
    source_url  = "https://github.com/2012952877/ZFCode"
  }
}

# 创建CI Pipeline
resource "azuredevops_build_definition" "DeployPipeline" {
  project_id      = azuredevops_project.project.id
  name = "ZFnewCI"
  # agent_pool_name = "Hosted Ubuntu 1604"
  
  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit" # Description  : Get sources from a repository. Supports Git, TfsVC, and SVN repositories.
    repo_id     = azuredevops_git_repository.repo.id
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = "/ZFnew-CI.yml"
  }
}

# 创建CD Pipeline
resource "azuredevops_build_definition" "DeployPipeline2" {
  project_id      = azuredevops_project.project.id
  name = "ZFnewCD"
  # agent_pool_name = "Hosted Ubuntu 1604"
  
  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit" # Description  : Get sources from a repository. Supports Git, TfsVC, and SVN repositories.
    repo_id     = azuredevops_git_repository.repo.id
    branch_name = azuredevops_git_repository.repo.default_branch
    yml_path    = "/ZFnew-CD.yml"
  }
}