#!/usr/bin/env python2
# -*- coding: utf-8 -*-

"""
Testing drawing of Chinese characters
"""

from __future__ import division

from psychopy import core, visual, event

# Create a window to draw in
win = visual.Window((1000, 800), monitor='testMonitor', allowGUI=False, color='black')

image1file = 'images/left1.png'
image2file= 'images/right2.png'
# Initialize some stimuli
image1 = visual.ImageStim(win, image=image1file, flipHoriz=False, pos=(0, 5), units='pix')
image2 = visual.ImageStim(win, image=image2file, mask=None,
    pos=(image1.size[0], 5), size=None,  # will be the size of the original image in pixels
    units='pix', interpolate=True, autoLog=False)
print "original image size:", image2.size
image2ALPHA = visual.GratingStim(win, pos=(-0.7, -0.5),
    tex="sin", mask=image2file, color=[1.0, 1.0, -1.0],
    size=(0.5, 0.5), units="norm", autoLog=False)
message = visual.TextStim(win, pos=(-0.95, -0.95),
    text='[Esc] to quit', color='white', alignHoriz='left', alignVert='bottom')

trialClock = core.Clock()
t = lastFPSupdate = 0
win.recordFrameIntervals = True
keys = []
while not ( 'escape' in keys or 'space' in keys ):
    t = trialClock.getTime()
    # Images can be manipulated on the fly
    #image2.ori += 1  # advance ori by 1 degree
    # 1 0 0, 
    # 2 0 0
    # 3  0
    # 4 1
    #5 1
    #6 1
    
    addend =( round(t * 1000 / 100 ) % 2) *2 -1  #every 100 ms , reverse direction
    print(addend)
    image2.draw()
    pos = image2.pos
    image2.pos = [pos[0]+addend,pos[1]]
    
    image2ALPHA.phase += 0.01  # advance phase by 1/100th of a cycle
    image2ALPHA.draw()
    
    pos = image1.pos
    image1.draw()
    image1.pos= [ pos[0]+addend, pos[1]]
    image1.color = [.0, 1.0, -1.0]
    
    # update fps once per second
    if t - lastFPSupdate > 1.0:
        lastFPS = win.fps()
        lastFPSupdate = t
        message.text = "%ifps, [Esc] to quit" % lastFPS
    message.draw()

    win.flip()
    event.clearEvents('mouse')  # only really needed for pygame windows
    keys = event.getKeys()
win.close()
core.quit()

# The contents of this file are in the public domain.
