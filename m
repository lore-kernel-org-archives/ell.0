Content-Type: multipart/mixed; boundary="===============0342830687738027917=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: l_dbus_message_set_arguments
Date: Wed, 15 May 2019 18:16:43 +0000
Message-ID: <1557944201.32584.9.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0342830687738027917==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


When creating a response to a D-Bus message with =


reply =3D l_dbus_message_new_method_return(msg);

where the original method has an empty (void) return list, is it neccessary=
 to set the arguments:

l_dbus_message_set_arguments(reply, "");

or can I just:

return l_dbus_message_new_method_return(msg);

from within the message handler? (without setting non-existant arguments)
--===============0342830687738027917==--

