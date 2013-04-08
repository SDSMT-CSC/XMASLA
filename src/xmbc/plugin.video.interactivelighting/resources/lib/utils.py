import httplib2
import json
import serial

pb = 0x7D #pad byte
sb = 0x7E #sync byte
cb = 0x80 #command byte
pad_offset = 100

#url with ip address and port to access web service
oscuri = 'http://107.22.230.121:50000/'
flaskuri = 'http://107.22.230.121:5000'
playeruri = flaskuri + '/player'
channeluri = flaskuri + '/channels'
songuri = flaskuri + '/songs'
lituri = flaskuri + '/lights'


h = httplib2.Http()

def getlightvals():
	resp, content = h.request(channeluri)
	lightvals = []
	if resp['status'] == '200':
		lv = json.loads(content)
		lightvals = eval(lv['vals'])
	return lightvals

def getPlayerStatus():
	resp, content = h.request(playeruri)
	ps = {}
	if resp['status'] == '200':
		ps = json.loads(content)
	return ps


def getSequences():
	resp, content = h.request(lituri)
	seqs = []
	if resp['status'] == '200':
		ls = json.loads(content)
		seqs = ls['lights']
	return seqs




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