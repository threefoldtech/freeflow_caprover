terraform {
  required_providers {
    grid = {
      source = "threefoldtech/grid"
      version = "0.1.8"
    }
  }
}

provider "grid" {
    twin_id = 29
    mnemonics = "" 
}

resource "grid_network" "net2" {
    nodes = [4]
    ip_range = "10.1.0.0/16"
    name = "network"
    description = "newer network"
}

resource "grid_deployment" "d2" {
  node = 4
  network_name = grid_network.net2.name
  ip_range = grid_network.net2.nodes_ip_range["4"]
  disks {
    name        = "data2"
    # will hold images, volumes etc. modify the size according to your needs
    size        = 20
    description = "volume holding docker data"
  }

  vms {
    name = "caprover"
    flist = "https://hub.grid.tf/samehabouelsaad.3bot/abouelsaad-caprover-zinit-v1.2.flist"
    # modify the cores according to your needs
    cpu = 2
    publicip = true
    # modify the memory according to your needs
    memory = 2048
    entrypoint = "/sbin/zinit init"
    mounts {
      disk_name   = "data2"
      mount_point = "/var/lib/docker"
    }
    env_vars {
      key = "PUBLIC_KEY"
      value = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9MI7fh4xEOOEKL7PvLvXmSeRWesToj6E26bbDASvlZnyzlSKFLuYRpnVjkr8JcuWKZP6RQn8+2aRs6Owyx7Tx+9kmEh7WI5fol0JNDn1D0gjp4XtGnqnON7d0d5oFI+EjQQwgCZwvg0PnV/2DYoH4GJ6KPCclPz4a6eXrblCLA2CHTzghDgyj2x5B4vB3rtoI/GAYYNqxB7REngOG6hct8vdtSndeY1sxuRoBnophf7MPHklRQ6EG2GxQVzAOsBgGHWSJPsXQkxbs8am0C9uEDL+BJuSyFbc/fSRKptU1UmS18kdEjRgGNoQD7D+Maxh1EbmudYqKW92TVgdxXWTQv1b1+3dG5+9g+hIWkbKZCBcfMe4nA5H7qerLvoFWLl6dKhayt1xx5mv8XhXCpEC22/XHxhRBHBaWwSSI+QPOCvs4cdrn4sQU+EXsy7+T7FIXPeWiC2jhFd6j8WIHAv6/rRPsiwV1dobzZOrCxTOnrqPB+756t7ANxuktsVlAZaM= sameh@sameh-inspiron-3576"
    }
    # SWM_NODE_MODE env var is required, should be "leader" or "worker"
    # leader: check the wroker terrafrom file example.
    # worker: will run sshd, containerd, dockerd as zinit services plus caprover service in orker mode which only join the swarm cluster. 
    env_vars {
      key = "SWM_NODE_MODE"
      value = "worker"
    }
    # from the leader node (the one running caprover) run `docker swarm join-token worker`
    # you must add the generated token to SWMTKN env var and the leader public ip to LEADER_PUBLIC_IP env var
    env_vars {
      key = "SWMTKN"
      # make sure to update this
      value = "SWMTKN-1-522cdsyhknmavpdok4wi86r1nihsnipioc9hzfw9dnsvaj5bed-8clrf4f2002f9wziabyxzz32d"
    }
    env_vars {
      key = "LEADER_PUBLIC_IP"
      # make sure to update this
      value = "185.206.122.38"
    }
  }
}

output "wg_config" {
    value = grid_network.net2.access_wg_config
}
output "ygg_ip" {
    value = grid_deployment.d2.vms[0].ygg_ip
}
output "vm_ip" {
    value = grid_deployment.d2.vms[0].ip
}
output "vm_public_ip" {
    value = grid_deployment.d2.vms[0].computedip
}
