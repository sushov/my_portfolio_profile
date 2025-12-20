# ☁️ Serverless Static Website on Google Cloud Platform (GCP)

This repository contains the **Infrastructure as Code (IaC)** required to deploy a scalable, high-performance static website on Google Cloud Platform using **Terraform**.

The architecture uses a serverless approach, leveraging Google Cloud Storage for hosting and a Global Load Balancer with CDN for delivery.

## 🏗️ Architecture

**User** ➡ **Global Load Balancer** (Anycast IP) ➡ **Cloud CDN** (Cache) ➡ **Cloud Storage** (Origin)

### Resources Created
* **Google Cloud Storage (GCS):** Stores the static HTML/CSS/JS files.
* **Cloud CDN:** Caches content at the edge for low latency global access.
* **Cloud Load Balancing:** HTTP(S) Load Balancer to route traffic.
* **Cloud DNS:** Manages the domain (`sushov.com`) and A-records.
* **IAM:** Securely manages public access permissions (Uniform Bucket Level Access).

## 🛠️ Prerequisites

* [Terraform](https://www.terraform.io/downloads) installed (v1.0+).
* [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) (`gcloud`) installed.
* A Google Cloud Platform Project.
* A registered domain name (e.g., `sushov.com`).

## 🚀 How to Deploy

### 1. Authentication
Login to Google Cloud so Terraform can access your project:
```bash
gcloud auth application-default login
