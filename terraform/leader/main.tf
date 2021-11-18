terraform {
  required_providers {
    grid = {
      source = "threefoldtech/grid"
    }
  }
}

provider "grid" {
    mnemonics = ""
}

resource "grid_network" "net0" {
    nodes = [4]
    ip_range = "10.1.0.0/16"
    name = "network"
    description = "newer network"
}

resource "grid_deployment" "d0" {
  node = 4
  network_name = grid_network.net0.name
  ip_range = grid_network.net0.nodes_ip_range["4"]
  disks {
    name        = "data0"
    # will hold images, volumes etc. modify the size according to your needs
    size        = 20
    description = "volume holding docker data"
  }
  disks {
    name        = "data1"
    # will hold data reltaed to caprover conf, nginx stuff, lets encrypt stuff.
    size        = 5
    description = "volume holding captain data"
  }

  vms {
    name = "caprover"
    flist = "https://hub.grid.tf/tf-official-apps/tf-caprover-main.flist"
    # modify the cores according to your needs
    cpu = 4
    publicip = true
    # modify the memory according to your needs
    memory = 8192
    entrypoint = "/sbin/zinit init"
    mounts {
      disk_name   = "data0"
      mount_point = "/var/lib/docker"
    }
    mounts {
      disk_name   = "data1"
      mount_point = "/captain"
    }
    env_vars {
      key = "PUBLIC_KEY"
      value = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9MI7fh4xEOOEKL7PvLvXmSeRWesToj6E26bbDASvlZnyzlSKFLuYRpnVjkr8JcuWKZP6RQn8+2aRs6Owyx7Tx+9kmEh7WI5fol0JNDn1D0gjp4XtGnqnON7d0d5oFI+EjQQwgCZwvg0PnV/2DYoH4GJ6KPCclPz4a6eXrblCLA2CHTzghDgyj2x5B4vB3rtoI/GAYYNqxB7REngOG6hct8vdtSndeY1sxuRoBnophf7MPHklRQ6EG2GxQVzAOsBgGHWSJPsXQkxbs8am0C9uEDL+BJuSyFbc/fSRKptU1UmS18kdEjRgGNoQD7D+Maxh1EbmudYqKW92TVgdxXWTQv1b1+3dG5+9g+hIWkbKZCBcfMe4nA5H7qerLvoFWLl6dKhayt1xx5mv8XhXCpEC22/XHxhRBHBaWwSSI+QPOCvs4cdrn4sQU+EXsy7+T7FIXPeWiC2jhFd6j8WIHAv6/rRPsiwV1dobzZOrCxTOnrqPB+756t7ANxuktsVlAZaM= sameh@sameh-inspiron-3576"
    }
    # SWM_NODE_MODE env var is required, should be "leader" or "worker"
    # leader: will run sshd, containerd, dockerd as zinit services plus caprover service in leader mode which start caprover, lets encrypt, nginx containers.
    # worker: will run sshd, containerd, dockerd as zinit services plus caprover service in orker mode which only join the swarm cluster. check the wroker terrafrom file example.
    env_vars {
      key = "SWM_NODE_MODE"
      value = "leader"
    }
    # CAPROVER_ROOT_DOMAIN is optional env var, by providing it you can access the captain dashboard after vm initilization by visiting http://captain.your-root-domain
    # otherwise you will have to add the root domain manually from the captain dashboard by visiting http://{publicip}:3000 to access the dashboard
    env_vars {
      key = "CAPROVER_ROOT_DOMAIN"
      value = "roverapps.grid.tf"
    }
  }
}

output "wg_config" {
    value = grid_network.net0.access_wg_config
}
output "ygg_ip" {
    value = grid_deployment.d0.vms[0].ygg_ip
}
output "vm_ip" {
    value = grid_deployment.d0.vms[0].ip
}
output "vm_public_ip" {
    value = grid_deployment.d0.vms[0].computedip
}
