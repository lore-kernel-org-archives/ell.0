Content-Type: multipart/mixed; boundary="===============6575739381811738698=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [RFC PATCH 3/8] dbus: Don't show Introspectable on intermediate
 nodes
Date: Mon, 25 Jan 2016 09:48:47 -0600
Message-ID: <56A643DF.7040104@gmail.com>
In-Reply-To: <1453517972-22833-3-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6575739381811738698==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 01/22/2016 08:59 PM, Andrew Zaborowski wrote:
> org.freedesktop.* service implementations don't seem to report any
> interfaces on non-object paths in the tree, neither does bluez.
> http://dbus.freedesktop.org/doc/dbus-specification.html#standard-interfac=
es-introspectable
> doesn't say much about this so this is up for discussion.
> ---
>   ell/dbus-service.c | 9 ++++++---
>   1 file changed, 6 insertions(+), 3 deletions(-)
>

You're correct, most org.freedesktop implementations don't do this.
However, its a bit bizarre to me that this behavior exists.  Just think =

about it, you're calling Introspect on an object and that object doesn't =

say it supports Introspect.

e.g.

dbus-send --session --dest=3Dorg.PulseAudio1 --type=3Dmethod_call =

--print-reply / org.freedesktop.DBus.Introspectable.Introspect
method return sender=3D:1.15 -> dest=3D:1.69 reply_serial=3D2
    string "<!DOCTYPE node PUBLIC "-//freedesktop//DTD D-BUS Object =

Introspection 1.0//EN"
"http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd">
<node>
   <node name=3D"org"/>
</node>
"

The Qt implementations seem to always include Introspect.  Maybe because =

they add a bunch of extra interfaces by default.  E.g.:

dbus-send --session --dest=3Dorg.ofono.phonesim --type=3Dmethod_call =

--print-reply /some/deep org.freedesktop.DBus.Introspectable.Introspect
method return sender=3D:1.73 -> dest=3D:1.76 reply_serial=3D2
    string "<!DOCTYPE node PUBLIC "-//freedesktop//DTD D-BUS Object =

Introspection 1.0//EN"
"http://www.freedesktop.org/standards/dbus/1.0/introspect.dtd">
<node>
   <interface name=3D"org.freedesktop.DBus.Introspectable">
     <method name=3D"Introspect">
       <arg name=3D"xml_data" type=3D"s" direction=3D"out"/>
     </method>
   </interface>
   <interface name=3D"org.freedesktop.DBus.Peer">
     <method name=3D"Ping"/>
     <method name=3D"GetMachineId">
       <arg name=3D"machine_uuid" type=3D"s" direction=3D"out"/>
     </method>
   </interface>
   <node name=3D"path"/>
</node>
"

In the end I think having it is more correct than not, but I'm fine =

going either way.

Regards,
-Denis

--===============6575739381811738698==--

