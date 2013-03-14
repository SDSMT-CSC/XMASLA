

from flask import *
app = Flask(__name__)


chan_vals = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

songs = ['Jingle Bells', 'Another Song']

lightSequences = {}



#routing

@app.route('/')
def index():
	return 'Interactive Lighting'



@app.route('/get_channel_vals')
def get_channel_vals():
	return jsonify(vals=chan_vals)

@app.route('/set_channel_vals', methods=['POST'])
def set_channel_vals():
	chan_vals = json.loads(request.json)['vals']

@app.route('')

if __name__ == '__main__':
	app.debug = True
	app.run('0.0.0.0')

