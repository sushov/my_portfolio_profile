# ☁️ Serverless Portfolio Infrastructure on Google Cloud

This repository demonstrates the use of **Infrastructure as Code (IaC)** to deploy a highly scalable, globally distributed static website on Google Cloud Platform (GCP).

The goal of this project was to move away from manual server configuration and embrace a fully automated, declarative infrastructure approach using **Terraform**.

## 🛠 Tech Stack

* **Infrastructure as Code:** Terraform (HCL)
* **Cloud Provider:** Google Cloud Platform (GCP)
* **Storage:** Google Cloud Storage (GCS)
* **Networking:** Cloud DNS, Global Load Balancing, Cloud CDN
* **Security:** Cloud IAM (Uniform Bucket Level Access)

## 🏗 Architecture Overview

The infrastructure is designed for high availability and low latency. Instead of running on a single server, the content is distributed to Google's edge locations worldwide.

**Data Flow:**
`User` ➡ `Global Load Balancer (Anycast IP)` ➡ `Cloud CDN (Edge Cache)` ➡ `Cloud Storage Bucket (Origin)`

### Key Components Provisioned:

1.  **Global Load Balancer (HTTP Proxy):**
    * Acts as the entry point for all traffic.
    * Routes incoming requests to the nearest edge node.
    * Manages the mapping between the static IP and the backend storage.

2.  **Cloud CDN (Content Delivery Network):**
    * Enabled on the backend to cache static assets (HTML/CSS/JS) at the edge.
    * Reduces latency for global users and minimizes egress costs.

3.  **Cloud Storage (GCS):**
    * Serves as the "Origin" for the website files.
    * Configured with **Uniform Bucket Level Access** for strict security compliance.
    * Utilizes IAM bindings (`roles/storage.objectViewer`) to securely expose content without legacy ACLs.

4.  **Cloud DNS:**
    * Managed DNS Zone configuration for the custom domain.
    * Automated A-Record management pointing to the Load Balancer's Anycast IP.

## 💡 Engineering Decisions

* **Why Terraform?**
    * To ensure the environment is reproducible and version-controlled.
    * To eliminate "configuration drift" often caused by manual console edits.
    * To treat infrastructure changes with the same rigor as application code updates.

* **Why Serverless (GCS + LB)?**
    * Chosen over a standard VM (Compute Engine) to remove the need for OS patching and maintenance.
    * Provides automatic scaling during traffic spikes without manual intervention.

## 🔒 Security Practices

* **Zero-Trust Identity:** No Service Account keys are stored in this repository. Deployment is handled via local authenticated sessions (ADC).
* **Principle of Least Privilege:** Bucket permissions are scoped strictly to `objectViewer` for public users, preventing unauthorized modifications.
* **State Management:** Terraform state is excluded from version control to prevent sensitive data leakage.

---
*This project is deployed and live at [sushov.com](http://sushov.com)*
