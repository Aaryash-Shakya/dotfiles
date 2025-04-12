sudo umount /dev/sda1
sudo ntfsfix /dev/sda1
sudo mkdir -p /run/media/aaryash-f/Tech\ Disk
sudo mount -t ntfs-3g /dev/sda1 /run/media/aaryash-f/Tech\ Disk
