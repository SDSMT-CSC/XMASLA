import xbmc
import xbmcgui
import httplib2
import json
import serial
import time
#get actioncodes from https://github.com/xbmc/xbmc/blob/master/xbmc/guilib/Key.h
ACTION_PREVIOUS_MENU = 10
ACTION_SELECT_ITEM = 7
ACTION_MOUSE_LEFT_CLICK = 100
ACTION_MOUSE_RIGHT_CLICK = 101
pb = 0x7D #pad byte
sb = 0x7E #sync byte
cb = 0x80 #command byte
pad_offset = 100

#url with ip address and port to access web service
oscuri = 'http://107.22.230.121:50000/'

h = httplib2.Http()

def getlightvals():
	resp, content = h.request(oscuri)
	lightvals = []
	if resp['status'] == '200':
		lightvals = json.loads(content)
	return lightvals


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



class MyClass(xbmcgui.Window):
  def __init__(self):
    self.strActionInfo = xbmcgui.ControlLabel(100, 120, 200, 200, '', 'font13', '0xFFFF00FF')
    self.addControl(self.strActionInfo)
    self.strActionInfo.setLabel('Push BACK to quit - A to reset text')
    self.strActionFade = xbmcgui.ControlFadeLabel(100, 300, 500, 200, 'font13', '0xFFFFFF00')
    self.addControl(self.strActionFade)
    self.strActionFade.addLabel(str(getlightvals()))
    self.serport = serial.Serial('COM7', '57600', timeout=2)


  def onAction(self, action):
    if action == ACTION_PREVIOUS_MENU:
    	self.serport.close()
      	self.close()
    if action == ACTION_SELECT_ITEM:
      	self.strActionFade.reset()
      	self.strActionFade.addLabel(str(getlightvals()))
    	while True:
			self.lvals = getlightvals()
			self.plvals = package_bytes(self.lvals, 32)
			self.serport.write(bytearray(self.plvals))
			time.sleep(0.1)
 
mydisplay = MyClass()
mydisplay .doModal()
del mydisplay