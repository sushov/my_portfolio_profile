# 1. Create the Bucket with Uniform Access Enabled
resource "google_storage_bucket" "website" {
  name     = "sushov-portfolio-website"
  location = "US"

  uniform_bucket_level_access = true
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# 2. Upload the html file to bucket
resource "google_storage_bucket_object" "static_site_src" {
  name   = "index.html"
  source = "../website/index.html"
  bucket = google_storage_bucket.website.name
}

# 3. Make the bucket Public using IAM (The Modern Way)
resource "google_storage_bucket_iam_member" "public_rule" {
  bucket = google_storage_bucket.website.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

#Reserve a static external ip Address
resource "google_compute_global_address" "website_ip" {
  name = "website-lb-ip"
}


# Create the DNS Zone for sushov.com
resource "google_dns_managed_zone" "website_zone" {
  name        = "sushov-zone"
  dns_name    = "sushov.com." # <--- IMPORTANT: Must end with a dot (.)
  description = "DNS zone for sushov portfolio"
  visibility  = "public"
}

# Add the A-Record (Points domain -> IP)
resource "google_dns_record_set" "website_a" {
  name         = google_dns_managed_zone.website_zone.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.website_zone.name

  # This points to the Static IP created earlier
  rrdatas = [google_compute_global_address.website_ip.address]
}
output "name_servers" {
  description = "The name servers to configure in your domain registrar"
  value       = google_dns_managed_zone.website_zone.name_servers
}


# 1. Backend Bucket
# This wraps your Storage Bucket so the Load Balancer knows how to talk to it.
resource "google_compute_backend_bucket" "website_backend" {
  name        = "website-backend"
  description = "Contains the static website files"
  bucket_name = google_storage_bucket.website.name
  enable_cdn  = true # Makes your site faster by caching it globally
}

# 2. URL Map
# This acts like a traffic cop. It says "All traffic goes to the backend bucket".
resource "google_compute_url_map" "website_map" {
  name            = "website-url-map"
  default_service = google_compute_backend_bucket.website_backend.id
}

# 3. HTTP Proxy
# This receives the actual web request from the user.
resource "google_compute_target_http_proxy" "website_proxy" {
  name    = "website-http-proxy"
  url_map = google_compute_url_map.website_map.id
}

# 4. Forwarding Rule (The Final Glue)
# This connects the Public IP Address -> to the HTTP Proxy.
resource "google_compute_global_forwarding_rule" "default" {
  name       = "website-forwarding-rule"
  target     = google_compute_target_http_proxy.website_proxy.id
  port_range = "80"
  ip_address = google_compute_global_address.website_ip.address
}


# 1. Create the Google-Managed SSL Certificate
resource "google_compute_managed_ssl_certificate" "website_ssl" {
  name = "website-ssl-cert-v2"

  managed {
    domains = ["sushov.com.", "www.sushov.com."]
  }

  # 2. ADD THIS BLOCK (Prevents this error in the future)
  lifecycle {
    create_before_destroy = true
  }
}

# 2. Create the HTTPS Proxy (The secure counterpart to your HTTP Proxy)
resource "google_compute_target_https_proxy" "website_https_proxy" {
  name             = "website-https-proxy"
  url_map          = google_compute_url_map.website_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.website_ssl.id]
}

# 3. Create a Forwarding Rule for HTTPS (Port 443)
resource "google_compute_global_forwarding_rule" "default_https" {
  name       = "website-forwarding-rule-https"
  target     = google_compute_target_https_proxy.website_https_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.website_ip.address
}



# Add the CNAME record for 'www'
resource "google_dns_record_set" "website_www" {
  name         = "www.${google_dns_managed_zone.website_zone.dns_name}"
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.website_zone.name

  # This tells www to "copy" whatever sushov.com is doing
  rrdatas = ["sushov.com."]
}
