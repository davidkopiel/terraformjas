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
# Providers
# ================================================================

# Artifactory provider
provider "artifactory" {
  url           = "http://172.16.10.122/artifactory"
  access_token  = "eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJRTGRSQktKaDVxMUdxdDRpT1E2WWlaMU96Y0FQMV9FMEtpN05Td2R5SGNvIn0.eyJpc3MiOiJqZmZlQDAxanJ0OGc1dGEwYnFxMDY5ODNjMXMwdjFyIiwic3ViIjoiamZhY0AwMWpydDhnNXRhMGJxcTA2OTgzYzFzMHYxci91c2Vycy9hZG1pbiIsInNjcCI6ImFwcGxpZWQtcGVybWlzc2lvbnMvYWRtaW4iLCJhdWQiOiIqQCoiLCJpYXQiOjE3NjA1OTgzNDUsImp0aSI6ImY3MTU3MjQ3LWMwZGYtNDVlNS05MjRjLTg0Mzc0YTRjNzllYiJ9.BY1rQIGQ8DWrlyrRZoPVCLK9nR3gwNqy1LCHRsi7I5eO1nu1oO6JgClZWYqay4HWqI7fKIE6Ubkle-HPK8vRu_wNrFgFphYEqr3KT3dYSGIIZwcBMDkXpdiXkFUCdoONVP_gVG7ncA-QOPXM4DVqntC71cagn7zzc-dLd4ml9d_Oat7LrOuH2fkPG4M787GHYgIVtrbFX13GqY2_rzwbR96cFtNG-7ZGxB7Tqf2ILfPgKfvf1Q82lRFrHhOBwaVGoGCQjHj-3xyZ4Im4D6qgojEMw33f8tdjVb6KnmDH_hYmeCDKMxd7SPCzir3ZruiRFXKMBLvHA5QTKTqGD-bgGg"
}

# Xray provider
provider "xray" {
  url           = "http://172.16.10.122/xray"
  access_token  = "eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJRTGRSQktKaDVxMUdxdDRpT1E2WWlaMU96Y0FQMV9FMEtpN05Td2R5SGNvIn0.eyJpc3MiOiJqZmZlQDAxanJ0OGc1dGEwYnFxMDY5ODNjMXMwdjFyIiwic3ViIjoiamZhY0AwMWpydDhnNXRhMGJxcTA2OTgzYzFzMHYxci91c2Vycy9hZG1pbiIsInNjcCI6ImFwcGxpZWQtcGVybWlzc2lvbnMvYWRtaW4iLCJhdWQiOiIqQCoiLCJpYXQiOjE3NjA1OTgzNDUsImp0aSI6ImY3MTU3MjQ3LWMwZGYtNDVlNS05MjRjLTg0Mzc0YTRjNzllYiJ9.BY1rQIGQ8DWrlyrRZoPVCLK9nR3gwNqy1LCHRsi7I5eO1nu1oO6JgClZWYqay4HWqI7fKIE6Ubkle-HPK8vRu_wNrFgFphYEqr3KT3dYSGIIZwcBMDkXpdiXkFUCdoONVP_gVG7ncA-QOPXM4DVqntC71cagn7zzc-dLd4ml9d_Oat7LrOuH2fkPG4M787GHYgIVtrbFX13GqY2_rzwbR96cFtNG-7ZGxB7Tqf2ILfPgKfvf1Q82lRFrHhOBwaVGoGCQjHj-3xyZ4Im4D6qgojEMw33f8tdjVb6KnmDH_hYmeCDKMxd7SPCzir3ZruiRFXKMBLvHA5QTKTqGD-bgGg"
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
