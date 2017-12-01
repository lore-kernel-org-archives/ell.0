Content-Type: multipart/mixed; boundary="===============2612547669564864187=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [RFC 5/6] dbus: Add support for setting properties on D-Bus proxy
 interface
Date: Fri, 01 Dec 2017 09:50:18 -0600
Message-ID: <7ac3a66c-7d45-d3c5-7a2d-a1d7630335fa@gmail.com>
In-Reply-To: <8844831.h3fZ7XXDys@ix>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2612547669564864187==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Szymon,

>> So its a bit weird that a proxy_removed might have been called, yet an >=
> outstanding call for that proxy is ongoing...  No idea how to fix this
>> nicely but some options:
>>
>> - cancel all pending requests when the proxy is destroyed
>> - set a destroyed flag on the proxy and don't bother calling the
>> callback in set_prop_reply
>> - something else?
> =

> Right, I've miss that. I'll go with queue of pending calls and cancel tho=
se
> when proxy is destroyed.
> =


So another option would be to introduce l_dbus_cancel_by_group, similar =

to how ofono.git/drivers/mbimmodem/mbim.h does things.  The idea is that =

we add a group parameter to dbus_send_full and store the gid as part of =

the dbus message_callback.  Then you can cancel all pending messages =

with a given gid.

Proxy would then obtain a unique gid when its created and we could get =

rid of the queue for the proxy's pending messages.

Roughly:
uint32_t _dbus_send_with_reply_full(struct l_dbus *dbus,
                                 struct l_dbus_message *message,
				uint32_t gid,
                                 l_dbus_message_func_t function,
                                 void *user_data,
				l_dbus_destroy_func_t destroy);
bool _dbus_cancel_group(struct l_dbus *dbus, uint32_t gid);

uint32_t _dbus_generate_gid(struct l_dbus *dbus);

Regards,
-Denis

--===============2612547669564864187==--

