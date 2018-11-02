
# Google Terraform code for 3 Tier

Hi. The code that came up now is how to configure GCP IaaS using Terraform. 
The examples here are **3-Tier(WEB-WAS-DB)** configurations, WEB and WAS configured as Managed Instance Groups, and Firewall rules applied.  
  
Since I'm still new, I made it without using the module. Please refer.  
  
What you need here  
**GCP Service Account** and the **SSL key that you created (cert.key, cert.csr, cert.crt)**, **security key (public key, private key)**  
  
I was struggling too, but I am still proud to turn it around without any errors.


## Architecture

![enter image description here](https://lh3.googleusercontent.com/ZQJ2cWmUl1uWN6y8anLWiPXRXGv6QCSrYPN38r2_oYucbER-I9hw6n4xpUmL0G-kc3Lmoh3bI5w=s10000 "gcp-architecture")

This is the GCP architecture written with that code.

