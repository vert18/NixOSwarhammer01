{
  disko.devices = {
    disk = {
      nvme1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            lvm = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "mylm";
              };
            };
          };
        };
      };
      nvme2 = {
        type = "disk";
        device = "/dev/nvme2n1";
        content = {
          type = "gpt";
          partitions = {
            lvm = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "mylm";
              };
            };
          };
        };
      };
    };
    lvm_vg = {
      mylm = {
        type = "lvm_vg";
        lvs = {
          mylmd = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/mnt/mylm";
              mountOptions = [ "noatime" ]; # Optimized for NVMe lifespans
            };
          };
        };
      };
    };
  };
}
