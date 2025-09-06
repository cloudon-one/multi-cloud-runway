resource "google_folder" "level_1" {
  for_each     = toset(var.folders.level1)
  display_name = each.key
  parent       = var.org_parent_folder != "" ? data.google_folder.org_parent_folder.0.id : data.google_organization.org.name
}

locals {
  level2 = [for folder in var.folders.level2 : "${folder.parent}/${folder.name}"]
}
resource "google_folder" "level_2" {
  for_each     = toset(local.level2)
  display_name = split("/", each.key)[1]
  parent       = google_folder.level_1[join("/", slice(split("/", each.key), 0, 1))].name
}

locals {
  level3 = [for folder in var.folders.level3 : "${folder.parent}/${folder.name}"]
}
resource "google_folder" "level_3" {
  for_each     = toset(local.level3)
  display_name = split("/", each.key)[2]
  parent       = google_folder.level_2[join("/", slice(split("/", each.key), 0, 2))].name
}

locals {
  level4 = [for folder in var.folders.level4 : "${folder.parent}/${folder.name}"]
}
resource "google_folder" "level_4" {
  for_each     = toset(local.level4)
  display_name = split("/", each.key)[3]
  parent       = google_folder.level_3[join("/", slice(split("/", each.key), 0, 3))].name
}

locals {
  level5 = [for folder in var.folders.level5 : "${folder.parent}/${folder.name}"]
}
resource "google_folder" "level_5" {
  for_each     = toset(local.level5)
  display_name = split("/", each.key)[4]
  parent       = google_folder.level_4[join("/", slice(split("/", each.key), 0, 4))].name
}
