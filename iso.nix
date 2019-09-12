{ lib, ... }:

with lib;

{

  # boot.loader.grub.forcei686 = true;
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

}
