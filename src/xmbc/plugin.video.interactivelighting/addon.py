from xbmcswift2 import Plugin, xbmc, xbmcaddon
import serial
import sys
import sched
import time

_id='plugin.video.interactivelighting'
_resdir = "special://home/addons/" + _id + "/resources"
sys.path.append( _resdir + "/lib/")

import resources.lib.utils as utils
# import resources.lib.Lumos as Lumos
import Lumos
from Lumos.Show import Show
from Lumos.Sequence import Sequence
from Lumos.TimeRange import TimeRange

import dircache
import fnmatch

plugin = Plugin()

def wait_for(minutes, query=False):
    mm = TimeRange(minutes).list
    compare_point = time.localtime()
    if query:
        return compare_point.tm_min in mm

    while compare_point.tm_min not in mm:
        time.sleep(60 - compare_point.tm_sec)
        compare_point = time.localtime()




@plugin.route('/')
def main_menu():
    items = [{'label': 'Sequences', 'path': plugin.url_for('show_sequences') },
    {'label': 'Manual Control', 'path': plugin.url_for('man_control') }
        ]
    return items


@plugin.route('/sequences/')
def show_sequences():
	seqs = utils.getSequences()

	items = [{
		'label': s['desc'],
		'path': plugin.url_for('show_seq_info', url=s['sequence'])
		} for s in seqs]

	si = sorted(items, key=lambda item: item['label'])
	return si


@plugin.route('/sequences/<url>/')
def show_seq_info(url):
	xsets = xbmcaddon.Addon('plugin.video.interactivelighting')
	seq_location = xsets.getSetting('sequence location')
	#dir_contents = dircache.listdir(seq_location)
	#dir_contents = fnmatch.filter(dir_contents, '*.lseq')
	fullpath = xbmc.translatePath(seq_location + '/' + url)
	seqs = [{'label': url, 'path': plugin.url_for('play_sequence', url=fullpath), 'is_playable': True}]
	return seqs
	# for f in dir_contents:
	# 	xbmc.log(f)
	# 	if f.count(url) > 0:
	# 		fullpath = xbmc.translatePath(seq_location + '/' + f)
	# 		seqs.append({'label': f, 'path': plugin.url_for('play_sequence', url=fullpath), 'is_playable': True})



@plugin.route('/manual/')
def man_control():
	xmod = xbmcaddon.Addon('plugin.video.interactivelighting')
	sport = xmod.getSetting('serial port')
	try:
		serport = serial.Serial(sport, '57600', timeout=2)
		while True:
			lvals = utils.getlightvals()
			plvals = utils.package_bytes(lvals, 32)
			print 'writing to channels'
			serport.write(bytearray(plvals))
			xbmc.sleep(100)
	except Exception:
		print "serial port failed"
	

@plugin.route('/sequences/play/<url>')
def play_sequence(url):
	plugin.log.info('Playing url: %s' % url)
	xbmc.log('playing url: %s' % url)
	plugin.set_resolved_url(url)
	show = Show()
	xsets = xbmcaddon.Addon('plugin.video.interactivelighting')
	config = xsets.getSetting('controller config')

	show.load_file(config)
	sequence = Sequence()
	sequence.load_file(url, show.controllers)
	schedule = sched.scheduler(time.time, time.sleep)
	for time_stamp, method, arglist in sequence.compile(keep_state=True):
		schedule.enter(time_stamp / 1000.0, 0, method, arglist)

	schedule.run()

if __name__ == '__main__':
    plugin.run()
