# AviSynth script to add a highly customizable timer to your video.
#
# Written by djcj <djcj@gmx.de>
# Last update: July 14th 2013
#
# Requires:
# Gavino's GRunT plugin - http://forum.doom9.org/showthread.php?t=139337
# Trim2(), found in stickboy's jdl-util - http://www.avisynth.nl/users/stickboy/jdl-util.avsi
#
#    mode =
#    hmmss: 0:04:17
#     mmss:   04:17
#      mss:    4:17
#   mssms1:    4:17.3
#   mssms2:    4:17.37
#   mssms3:    4:17.375
#    mssms:    4:17.375
#  mmssms1:   04:17.3
#  mmssms2:   04:17.37
#  mmssms3:   04:17.375
#   mmssms:   04:17.375
# hmmssms1: 0:04:17.3
# hmmssms2: 0:04:17.37
# hmmssms3: 0:04:17.375
#  hmmssms: 0:04:17.375

function formattime(int ms, string mode)
{
_s  = ms / 1000
_ms = ms % 1000
_m  = _s / 60
_s  = _s % 60
_h  = _m / 60
_m  = _m % 60

h   = string(_h)
m   = string(_m, "%2.0f")
mm  = string(_m, "%02.0f")
ss  = string(_s, "%02.0f")
ms  = string(_ms, "%03.0f")
ms1 = leftstr(string(_ms, "%03.0f"), 1)
ms2 = leftstr(string(_ms, "%03.0f"), 2)

formattime = \
mode=="hmmss"    ? h+":"+mm+":"+ss : \
mode=="mmss"     ?       mm+":"+ss : \
mode=="mss"      ?        m+":"+ss : \
mode=="mssms1"   ?        m+":"+ss+"."+ms1 : \
mode=="mssms2"   ?        m+":"+ss+"."+ms2 : \
mode=="mssms3"   ?        m+":"+ss+"."+ms : \
mode=="mssms"    ?        m+":"+ss+"."+ms : \
mode=="mmssms1"  ?       mm+":"+ss+"."+ms1 : \
mode=="mmssms2"  ?       mm+":"+ss+"."+ms2 : \
mode=="mmssms3"  ?       mm+":"+ss+"."+ms : \
mode=="mmssms"   ?       mm+":"+ss+"."+ms : \
mode=="hmmssms1" ? h+":"+mm+":"+ss+"."+ms1 : \
mode=="hmmssms2" ? h+":"+mm+":"+ss+"."+ms2 : \
mode=="hmmssms3" ? h+":"+mm+":"+ss+"."+ms : \
mode=="hmmssms"  ? h+":"+mm+":"+ss+"."+ms : nop()

return formattime
}

function timer(clip clp, string "mode", bool "reverse", int "color", float "size", int "x", int "y", int "align")
{
mode    = default(mode, "hmmss")
reverse = default(reverse, false)
color   = default(color, $ffffff)

reverse==true ? clp.reverse() : clp
scriptclip(last, """
  subtitle(formattime(round((current_frame * 1000) / framerate), mode), text_color=color, size=size, x=x, y=y, align=align)
""", args="mode,color,size,x,y,align", local=true)
reverse==true ? last.reverse() : last

return audiodubex(last, clp)
}

function timer_cut(clip clp,
\               string  "mode", int "start", int    "end", bool   "reverse", bool "showstart",
\               bool "showend", int "color", float "size", int "x", int "y", int  "align")
{
mode      = default(mode, "hmmss")
reverse   = default(reverse, false)
showstart = default(showstart, false)
showend   = default(showend, false)
color     = default(color, $ffffff)

isint(start)==false || isint(end)==false ? eval("""
    start = round(clp.framecount / 3)
    end = 2*round(clp.framecount / 3)
    clp = clp.subtitle("No value set for parameter START and/or END!", align=2, size=round(clp.width * 0.05))
""") : nop()

finaltime = round(((end-start) * 1000) / clp.framerate)
zero      = reverse==true    ? formattime(finaltime, mode) : formattime(0, mode)
time      = reverse==true    ? formattime(0, mode) : formattime(finaltime, mode)
zero      = showstart==false ? "" : zero
time      = showend==false   ? "" : time

clp.trim2(0, length=start).subtitle(zero, text_color=color, size=size, x=x, y=y, align=align)++\
clp.trim(start, end).timer(mode=mode, reverse=reverse, color=color, size=size, x=x, y=y, align=align)++\
clp.trim2(end+1, clp.framecount).subtitle(time, text_color=color, size=size, x=x, y=y, align=align)

return last
}
