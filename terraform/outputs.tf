output "rds_end_point" {
  value = split(":", module.rds.rds_end_point)[0]
}
