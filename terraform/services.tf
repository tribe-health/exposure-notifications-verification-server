# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

locals {
  gcp_config = {
    PROJECT_ID = var.project
  }

  csrf_config = {
    CSRF_AUTH_KEY = "secret://${google_secret_manager_secret_version.csrf-token-version.id}"
  }

  database_config = {
    DB_HOST        = google_sql_database_instance.db-inst.private_ip_address
    DB_NAME        = google_sql_database.db.name
    DB_PASSWORD    = "secret://${google_secret_manager_secret_version.db-secret-version["password"].id}"
    DB_SSLCERT     = "secret://${google_secret_manager_secret_version.db-secret-version["sslcert"].id}?target=file"
    DB_SSLKEY      = "secret://${google_secret_manager_secret_version.db-secret-version["sslkey"].id}?target=file"
    DB_SSLMODE     = "verify-ca"
    DB_SSLROOTCERT = "secret://${google_secret_manager_secret_version.db-secret-version["sslrootcert"].id}?target=file"
    DB_USER        = google_sql_user.user.name
  }

  firebase_config = {
    FIREBASE_API_KEY           = data.google_firebase_web_app_config.default.api_key
    FIREBASE_APP_ID            = google_firebase_web_app.default.app_id
    FIREBASE_AUTH_DOMAIN       = data.google_firebase_web_app_config.default.auth_domain
    FIREBASE_DATABASE_URL      = lookup(data.google_firebase_web_app_config.default, "database_url")
    FIREBASE_MEASUREMENT_ID    = lookup(data.google_firebase_web_app_config.default, "measurement_id")
    FIREBASE_MESSAGE_SENDER_ID = lookup(data.google_firebase_web_app_config.default, "messaging_sender_id")
    FIREBASE_PROJECT_ID        = google_firebase_web_app.default.project
    FIREBASE_STORAGE_BUCKET    = lookup(data.google_firebase_web_app_config.default, "storage_bucket")
  }

  signing_config = {
    CERTIFICATE_SIGNING_KEY = trimprefix(data.google_kms_crypto_key_version.certificate-signer-version.id, "//cloudkms.googleapis.com/v1/")
    TOKEN_SIGNING_KEY       = trimprefix(data.google_kms_crypto_key_version.token-signer-version.id, "//cloudkms.googleapis.com/v1/")
  }
}
