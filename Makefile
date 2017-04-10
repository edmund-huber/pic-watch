watch.hex: watch.asm
	gpasm watch.asm -o watch.hex

.PHONY: flash
flash: watch.hex
	sudo pk2cmd -PPIC16F690 -M -F watch.hex
