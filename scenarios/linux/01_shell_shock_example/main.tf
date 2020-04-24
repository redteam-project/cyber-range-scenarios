// Configure the Google Cloud provider
provider "google" {
 // credentials = file(var.credentials)
 // project     = var.project
 region      = var.region
 zone        = var.zone
}

// Blue Team Google Cloud Engine instance
resource "google_compute_instance" "blue35370" {
 name         = "blue-35370"
 machine_type = "n1-standard-1"
 allow_stopping_for_update = "true"

 boot_disk {
   initialize_params {
   image = "rhel-cloud/rhel-7-v20200403"
   }
 }
 
tags = ["blue"]

service_account {
   scopes = ["https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append"]
}

// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = <<EOF
 							FILE=/.initialboot
 						   	if [ -f "$FILE" ]; then
								exit;
 						   	else 
								  touch /.initialboot
 								  yum install -y -q gcc git ansible python-pip wget;
								  curl -X GET http://www.stainedproductions.com/~math/utils/shellshock_test.sh > shellshock_test.sh;
								  chmod 755 shellshock_test.sh;
 							fi
							EOF
							
metadata = {
	enable-oslogin = "FALSE"
}		

scheduling {
  automatic_restart   = false
}	

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}

// Blue Team Google Cloud Engine instance
resource "google_compute_instance" "blue37292" {
 name         = "blue-37292"
 machine_type = "n1-standard-1"
 allow_stopping_for_update = "true"

 boot_disk {
   initialize_params {
    // Load 3.16.0-28-generic
    image = "ubuntu-os-cloud/ubuntu-1404-trusty-v20141212"
   }
 }
 
tags = ["blue"]

service_account {
   scopes = ["https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append"]
}

// Make sure flask is installed on all new instances for later steps
//  								sudo yum update -y -q; 
 metadata_startup_script = <<EOF
 							FILE=/.initialboot
 						   	if [ -f "$FILE" ]; then
								  exit;
 						   	else 
								  touch /.initialboot

                  apt-get -qy update                  
                  apt-get -qy install gcc
 							fi
							EOF
							
metadata = {
	enable-oslogin = "FALSE"
}		

scheduling {
  automatic_restart   = false
}	

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}

// Red Team Google Cloud Engine instance
resource "google_compute_instance" "red" {
 name         = "red-1"
 machine_type = "n1-standard-1"
 allow_stopping_for_update = "true"

 boot_disk {
   initialize_params {
     image = "rhel-cloud/rhel-7-v20200403"
   }
 }
 
tags = ["red"]

// Make sure flask is installed on all new instances for later steps
 metadata_startup_script =  <<EOF
							FILE=/.initialboot
							if [ -f "$FILE" ]; then
								exit;
							else 
								touch /.initialboot
 								yum update -y -q;
 								yum install -y -q git ansible python-pip nmap-ncat;
								rpm -vhU https://nmap.org/dist/nmap-7.80-1.x86_64.rpm;
								pip install lem;
							fi
							EOF
							
metadata = {
	enable-oslogin = "TRUE"
}	

scheduling {
  automatic_restart   = false
}	
							
 service_account {
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append"]
 }

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}

resource "google_compute_firewall" "redfw" {
  name    = "red-allow-4444"
  network = "default"

  source_ranges = ["10.150.0.0/32"]
  target_tags = ["red"]
  direction = "INGRESS"
  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = ["4444"]
  }
}

resource "google_compute_firewall" "bluefw" {
  name    = "blue-allow-http"
  network = "default"

  source_ranges = ["10.150.0.0/32"]
  target_tags = ["blue"]
  direction = "INGRESS"
  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
