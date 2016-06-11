#!/bin/bash
set -e

VERSION=$1
DEVICE=$2

# Add Devicecheck to updater-script
case $DEVICE in
  sumire)
cat <<EOT > zipme/META-INF/com/google/android/updater-script
assert(getprop("ro.product.device") == "sumire" || getprop("ro.build.product") == "sumire" || getprop("ro.product.device") == "E6653" || getprop("ro.build.product") == "E6653" || getprop("ro.product.device") == "E6603" || getprop("ro.build.product") == "E6603" || getprop("ro.product.device") == "E6633" || getprop("ro.build.product") == "E6633" || getprop("ro.product.device") == "E6683" || getprop("ro.build.product") == "E6683" || abort("This package is for device: sumire, E6603, E6653, E6633, E6683; this device is " + getprop("ro.product.device") + "."););
EOT
  ;;
  suzuran)
cat <<EOT > zipme/META-INF/com/google/android/updater-script
assert(getprop("ro.product.device") == "suzuran" || getprop("ro.build.product") == "suzuran" || getprop("ro.product.device") == "E5823" || getprop("ro.build.product") == "E5823" || getprop("ro.product.device") == "E5803" || getprop("ro.build.product") == "E5803" || abort("This package is for device: suzuran, E5823, E5803; this device is " + getprop("ro.product.device") + "."););
EOT
  ;;
  *)
    echo "wrong Device specified. You set $DEVICE, it needs to be sumire or suzuran"
    exit 1
  ;;
esac

# Add Common Flashing script
cat <<EOT2 >> zipme/META-INF/com/google/android/updater-script
ui_print("Flashing kernel");
ui_print(" ");
ui_print("OM5Z Kernel by oshmoun and Myself5");
ui_print("based on Zombie Kernel by Tommy-Geenexus");
ui_print(" ");
show_progress(0.500000, 0);
ui_print("Flashing kernel...");
package_extract_file("OM5Z_boot.img", "/dev/block/bootdevice/by-name/boot");
ui_print("Done!");
show_progress(0.100000, 0);
EOT2

mkdir -p RELEASE/$DEVICE

KERNEL_UNSIGNED=OM5Z-Kernel-V$VERSION-unsigned-$DEVICE.zip
KERNEL_FALSE_SIGNED=OM5Z-Kernel-V$VERSION-false_signed-$DEVICE.zip
KERNEL_ADJUSTED_UNSIGNED=OM5Z-Kernel-V$VERSION-adjusted_unsigned-$DEVICE.zip
KERNEL_NAME=OM5Z-Kernel-V$VERSION-M-$DEVICE.zip
zip -r $KERNEL_UNSIGNED zipme/*

java -Xmx2048m -jar signing/signapk.jar -w signing/testkey.x509.pem signing/testkey.pk8 $KERNEL_UNSIGNED $KERNEL_FALSE_SIGNED
rm -f $KERNEL_UNSIGNED
signing/zipadjust $KERNEL_FALSE_SIGNED $KERNEL_ADJUSTED_UNSIGNED
rm -f $KERNEL_FALSE_SIGNED
java -Xmx2048m -jar signing/minsignapk.jar signing/testkey.x509.pem signing/testkey.pk8 $KERNEL_ADJUSTED_UNSIGNED RELEASE/$DEVICE/$KERNEL_NAME
rm -f $KERNEL_ADJUSTED_UNSIGNED
echo "M5 Kernel for $DEVICE Sucessfully Packed and Signed as $KERNEL_NAME"
