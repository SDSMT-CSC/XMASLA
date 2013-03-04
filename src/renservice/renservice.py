import httplib2
import jsonrpclib
import json

oscuri = 'http://107.22.230.121:50000/'

h = httplib2.Http()

def getlightvals():
	resp, content = h.request(oscuri)
	lightvals = []
	if resp['status'] == '200':
		lightvals = json.loads(content)
	return lightvals

