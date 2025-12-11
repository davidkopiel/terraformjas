# ================================================================
# Terraform configuration for JFrog Artifactory & Xray
# ================================================================
terraform {
  required_providers {
    artifactory = {
      source  = "jfrog/artifactory"
      version = "12.10.1"
    }

    xray = {
      source  = "jfrog/xray"
      version = "3.1.1"
    }
  }

  required_version = ">= 0.13"
}
# ================================================================
# VULNERABLE TEST RESOURCE FOR FROGBOT IAC SCAN
# ================================================================
resource "aws_security_group" "vulnerable_example" {
  name        = "allow_ssh_public"
  description = "Allow SSH inbound traffic from everywhere"

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # VIOLATION: Opening port 22 to the entire world (0.0.0.0/0)
    cidr_blocks = ["0.0.0.0/0"] 
  }
}
# ================================================================
# Providers
# ================================================================

# Artifactory provider
provider "artifactory" {
  url           = "http://172.16.10.122/artifactory"
  access_token  = var.artifactory_access_token
}

# Xray provider
provider "xray" {
  url           = "http://172.16.10.122/xray"
  access_token  = var.xray_access_token
}
provider "aws" {
  region = "us-east-1"
}
# ================================================================
# Artifactory repository example
# ================================================================
resource "xray_repository_config" "xray-repo-config" {
  repo_name   = "davidko-docker-local"
  jas_enabled = true

  config {
    vuln_contextual_analysis = true

    exposures {
      scanners_category {
        applications = true
        iac          = true
        secrets      = true
        services     = true
      }
    }

    retention_in_days = 90
  }

  paths_config {
    pattern {
      include             = "core/**"
      exclude             = "core/internal/**"
      index_new_artifacts = true
      retention_in_days   = 60
    }

    pattern {
      include             = "core/**"
      exclude             = "core/external/**"
      index_new_artifacts = true
      retention_in_days   = 45
    }

    all_other_artifacts {
      index_new_artifacts = true
      retention_in_days   = 60
    }
  }
}

resource "artifactory_remote_maven_repository" "remoteservice_maven_central" {
  key                                   = "davidko-maven-remote"
  url                                   = "https://repo1.maven.org/maven2/"
  repo_layout_ref                       = "maven-2-default"  
  excludes_pattern                      = "com/bmw/**"
  unused_artifacts_cleanup_period_hours = 480
  xray_index                            = true
  curated                               = true

  lifecycle {
    ignore_changes = [
      project_environments,
      project_key
    ]
  }
}

resource "artifactory_remote_npm_repository" "npm-remote" {
  key         = "davidko-npm-remote"
  url         = "https://registry.npmjs.org"
  curated = true
}

resource "artifactory_remote_nuget_repository" "nuget-remote" {
  key         = "davidko-nuget-remote"
  url         = "https://www.nuget.org"
  curated = true
}
resource "artifactory_remote_gradle_repository" "gradle-remote" {
  key         = "davidko-gradle-remote"
  url         = "https://repo1.maven.org/maven2/"
  curated = true
}
