# Framework-Driver-Bundle-Deploy
A better way to deploy Framework Laptop Driver Bundles.

All these scripts do is download the appropriate driver bundle, unpack the archive, and execute the `install_drivers.bat` file with the unattended flag. In the case of the 11th-gen script, it makes use of a modified `install_drivers.bat` because the unattended flag is missing, and a baseboard check is included (albeit with only one known baseboard prefix).

Feel free to submit pull requests as driver bundles are updated, or if you feel something could be done better.
