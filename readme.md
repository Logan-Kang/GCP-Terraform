
# Google Terraform code for 3 Tier

Hi. The code that came up now is how to configure GCP IaaS using Terraform. 
The examples here are **3-Tier(WEB-WAS-DB)** configurations, WEB and WAS configured as Managed Instance Groups, and Firewall rules applied.  
  
Since I'm still new, I made it without using the module. Please refer.  
  
What you need here  
**GCP Service Account** and the **SSL key that you created (cert.key, cert.csr, cert.crt)**, **security key (public key, private key)**  
  
I was struggling too, but I am still proud to turn it around without any errors.


## Architecture

![enter image description here](https://lh3.googleusercontent.com/GYp-mtbg-HdZycpQByv4hjPucsfcEk609HFbTUXuyJhTMnVYHg4IxKTt7VZQ_ZFLnFiM_L7xzmc "GCP 3-Tier Architecture")
This is the GCP architecture written with that code.

