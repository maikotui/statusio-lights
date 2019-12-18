# statusio-lights

A project I worked on for a company I worked at. This script installs the necessary prerequisites for a raspberry pi to use an IR Remote Shield to communicate with LED lights around the building. These lights will change based on the overall status of the company using the status.io API. 

### Dependencies

This is intended for Raspberry Pi 3 b+ devices using a GPIO IR Remote Shield. This program uses the following dependencies:
* crontab
* curl
* jq
* lirc
* ufw

### Executing program

* To install, run
```
sudo bash install.sh
```

## Help

LIRC will fail on initial install. It's installed twice in the script after fixing some files.

## Authors

Maiko Tuitupou (maikotui)

## Version History

* 0.1
    * Initial Public Release after in-production testing

## License

This project is not licensed. Do what you want with it :)

## Acknowledgments

Inspiration, code snippets, etc.
* [user1200233](https://stackoverflow.com/questions/57437261/setup-ir-remote-control-using-lirc-for-the-raspberry-pi-rpi)
