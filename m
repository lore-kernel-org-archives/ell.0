Content-Type: multipart/mixed; boundary="===============7319970638411331288=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: RFC: DBus send_with_reply wrapper doesn't time out
Date: Fri, 10 Apr 2020 23:06:45 +0000
Message-ID: <9a3292457b6d53eff29cf8ad4c87f808014a10ab.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7319970638411331288==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


In Bluetooth Mesh, we have a particular interaction between the mesh daemon=
, and Applications where we need to
ensure that the application has received a critical piece of data (the node=
 token), and if it doesn't, we need
to destroy the newly created node.

Specifically we have the JoinComplete() method, that the Application is req=
uired to implement, and it is
invoked by the daemon with l_dbus_send_with_reply().

This *mostly* works, in that the daemon gets any responses that the App sen=
ds, and is alerted if the App
crashes in such a way the it's dbus socket gets closed.

However:  If the Application has a bug in that it *never* responds (for ins=
tance, it returns NULL in the
JoinComplete() message handler, and never responds asyncronously either), t=
hen the mesh daemon never receives a
call on it's callback function.  I had always assumed that the dbus-daemon =
would timeout on responses, but this
does not appear to be the case.

Is timing out reply required methods the dbus daemon responsibility?  Is it=
 the l_dbus_send_with_reply()
responsibility?  The mesh daemon responsibility?  Ideally, the App just res=
ponds, but we have no control over
how Apps respond to method calls.

--===============7319970638411331288==--

