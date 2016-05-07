all: clean build

build:
	-mkdir build
	avr-as -mmcu=attiny13a -o ./build/main.o ./src/main.s
	avr-ld -o ./build/main.elf ./build/main.o
	avr-objcopy -O ihex ./build/main.elf ./build/main.hex

clean:
	-rm -r build

upload:
	avrdude -c arduino -p t13 -P /dev/tty.usbmodem12341 -u -U flash:w:./build/main.hex
