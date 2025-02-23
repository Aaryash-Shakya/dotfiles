echo "Enter drive path (Eg: /dev/sda1): "
read drive
sudo umount $drive
sudo ntfsfix $drive
sudo mkdir -p /media/aaryash-u/$drive
sudo mount -t ntfs-3g $drive /media/aaryash-u/$drive
