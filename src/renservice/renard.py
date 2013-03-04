import serial
import renservice
import time

pb = 0x7D #pad byte
sb = 0x7E #sync byte
cb = 0x80 #command byte
pad_offset = 100

def special_replace(n):
	if n == 0x7D:
		return 0x7C
	elif n == 0x7E:
		return 0x7C
	elif n == 0x7F:
		return 0x80
	else:
		return n

def package_bytes(light_values, channels):
	"""Packages the light dimming values into a readable format for the renard controller"""
	pv = map(special_replace, light_values)
	#insert a pad byte every pad_offset byte
	if len(pv) > pad_offset:
		for i in range(pad_offset, len(pv), pad_offset):
			pv.insert(i, pb)

	if len(pv) > channels:
		a = len(pv) - (len(pv) % channels)
		for i in range(a, 0, -channels):
			pv.insert(i,cb)
			pv.insert(i,sb)

	pv.insert(0, cb)
	pv.insert(0, sb)

	return pv

serport = serial.Serial('COM7', '57600', timeout=2)

while True:
	lvals = renservice.getlightvals()
	plvals = package_bytes(lvals, 32)
	serport.write(bytearray(plvals))
	time.sleep(0.5)
