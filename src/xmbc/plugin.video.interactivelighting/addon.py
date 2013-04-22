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
show = Show()
sequence = Sequence()
schedule = sched.scheduler(time.time, time.sleep)
xsets = xbmcaddon.Addon('plugin.video.interactivelighting')
seq_location = xsets.getSetting('sequence location')
config = xsets.getSetting('controller config')
audio_path = xsets.getSetting('audio location')

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
    {'label': 'Manual Control', 'path': plugin.url_for('man_control') },
    {'label': 'Remote Play', 'path': plugin.url_for('remote_play')}
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
	
	#dir_contents = dircache.listdir(seq_location)
	#dir_contents = fnmatch.filter(dir_contents, '*.lseq')
	fullpath = xbmc.translatePath(seq_location + '/' + url)
	seqs = [{'label': url, 'path': plugin.url_for('play_sequence', url=fullpath)}]
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
		serport.close()
	except Exception:
		print "serial port failed"

	
@plugin.route('/remote/')
def remote_play():
	utils.clearStatus()
	ss = utils.getPlayerStatus()
	csong = ss['song']
	psong = ss['song']
	cstatus = ss['status']
	pstatus = ss['status']
	isplaying = False
	eventlist = []
	while (not xbmc.abortRequested):
		ss = utils.getPlayerStatus()
		#psong = csong
		pstatus = cstatus
		csong = ss['song']
		cstatus = ss['status']
		if psong == csong:
			if pstatus != cstatus:
				isplaying = not isplaying
				if isplaying:
					#resume the song
					xbmc.log('resuming song %s' % csong)
					xbmc.executebuiltin('XBMC.PlayerControl(Play)')
					for e in eventlist:
						schedule.enter(e[0], e[1], e[2], e[3])
					eventlist = []
					schedule.run()
					#show.networks['lights'].close()

				else:
					#stop/pause the song
					xbmc.log('stopping song: %s' % csong)
					xbmc.executebuiltin('XBMC.PlayerControl(Play)')
					for e in schedule.queue:
						eventlist.append(e)
						schedule.cancel(e)

		else:
			#start new song
			xbmc.log('start new song: %s' % csong)
			for e in schedule.queue:
				schedule.cancel(e)

			if csong == 'Carol of the Bells':
				psong = csong
				fullpath = xbmc.translatePath(seq_location + '/cotb.lseq')
				play_sequence(fullpath)

			elif csong == 'Rock Around the Christmas Tree':
				psong = csong
				fullpath = xbmc.translatePath(seq_location + '/rock_ar.lseq')
				play_sequence(fullpath)

			elif csong == 'O Little Town of Bethlehem':
				psong = csong
				fullpath = xbmc.translatePath(seq_location + '/bethlehem.lseq')
				play_sequence(fullpath)

			elif csong == 'The First Noel':
				psong = csong
				fullpath = xbmc.translatePath(seq_location + '/noel.lseq')
				play_sequence(fullpath)








@plugin.route('/sequences/play/<url>')
def play_sequence(url):
	plugin.log.info('Playing url: %s' % url)
	xbmc.log('playing url: %s' % url)
	plugin.set_resolved_url(url)
	show = Show()
	
	show.load_file(config)
	sequence.load_file(url, show.controllers)
	schedule = sched.scheduler(time.time, time.sleep)
	for time_stamp, method, arglist in sequence.compile(keep_state=True):
		schedule.enter(time_stamp / 1000.0, 0, method, arglist)

	if sequence.audio is not None:
		audio_fullpath = xbmc.translatePath(audio_path + '/' + sequence.audio.filename)
		xbmc.log('playing audio: %s' % audio_fullpath)
		xbmc.executebuiltin('XBMC.PlayMedia('+audio_fullpath+')')
	else:
		xbmc.log('audio was none')
	schedule.run()
	show.networks['lights'].close()
	
if __name__ == '__main__':
    plugin.run()
