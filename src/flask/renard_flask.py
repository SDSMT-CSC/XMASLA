import sqlite3
from flask import *


#config
DATABASE = 'C:/users/1003603/flask/xmas.sqlite'
DEBUG = True
SECRET_KEY = 'interactive lighting'
USERNAME = 'sdsmt'
PASSWORD = 'xmas'


app = Flask(__name__)
app.config.from_object(__name__)



sqliteDB = '/home/ubuntu/flask/xmas.sqlite'


def connect_db():
	return sqlite3.connect(app.config['DATABASE'])


@app.before_request
def before_request():
	g.db = connect_db()
	g.cv = chan_vals

@app.teardown_request
def teardown_request(exception):
	g.db.close()
	chan_vals = g.cv

#routing

@app.route('/')
def index():
	return 'Interactive Lighting'

@app.route('/songs', methods=['POST', 'GET'])
def _songs():
	if request.method == 'POST':
		print request.json
		s = request.json
		t = ''
		a = None
		dsc = None
		if 'artist' in s:
			a = s['artist']
		if 'desc' in s:
			dsc = s['desc']
		if 'title' in s:
			t = s['title']
			g.db.execute('insert into songs (title, artist, desc) values (?, ?, ?)', 
				[t, a, dsc])
			g.db.commit()
	cur = g.db.execute('select * from songs')
	sngs = [dict(songId=row[0], title=row[1], artist=row[2], desc=row[3]) for row in cur.fetchall()]
	return jsonify(songs=sngs)


@app.route('/lights', methods=['POST', 'GET'])
def _lights():
	if request.method == 'POST':
		print request.json
		s = request.json
		dsc = ''
		sid = None
		seq = None
		if 'songId' in s:
			sid = s['songId']
		if 'sequence' in s:
			seq = json.dumps(s['sequence'])
		if 'desc' in s:
			dsc = s['desc']
			g.db.execute('insert into lights (desc, songId, sequence) values (?, ?, ?)',
				[dsc, sid, seq])
			g.db.commit()
	cur = g.db.execute('select * from lights')
	lghts = [dict(lightId=row[0], desc=row[1], songId=row[2], sequence=row[3]) for row in cur.fetchall()]
	return jsonify(lights=lghts)

#{"play" : "Carol of the Bells"}
#@app.route('/player', methods['POST', 'GET'])
#def _player():


@app.route('/channels', methods=['POST', 'GET'])
def _channels():
	if request.method == 'POST':
		s = request.json
		if 'vals' in s:
			v = json.dumps(s['vals'])
			g.db.execute('update channels set vals = ? where id = 1', [v])
			g.db.commit()
	cur = g.db.execute('select vals from channels where id = 1')
	vls = [dict(vals=row[0]) for row in cur.fetchall()]
	return jsonify(vals=vls[0]['vals'])



if __name__ == '__main__':
	app.run('0.0.0.0')

