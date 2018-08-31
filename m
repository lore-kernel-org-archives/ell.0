Content-Type: multipart/mixed; boundary="===============0379632642210017715=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/2][RFC] dbus: Don't automatically emit PropertyChanged
 after Set
Date: Fri, 31 Aug 2018 10:48:58 -0500
Message-ID: <a8adca6f-ab15-26c8-98f4-d75cf2d84578@gmail.com>
In-Reply-To: <20180830010541.8687-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0379632642210017715==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/29/2018 08:05 PM, Andrew Zaborowski wrote:
> Remove the _dbus_object_tree_property_changed call in the complete
> handler for property setters so a PropertyChanged/PropertiesChanged
> signal is not sent for every successful Set().  This means that the
> setter functions will have to emit the signals when the property's value
> has changed so it affects ell's clients.  This attempts to allow clients
> to solve an issue where PropertyChanged signals were generated even if
> Set was called with a value equal to the property's current value so the
> values was not effectively chaning.

So if we do it this way, do we even need the complete callback at all? =

All it does is just sends a reply now.  This can be easily done by the =

caller by issuing a dbus_pending_reply or l_dbus_send...

> =

> I'm not 100% convinced this small benefit is worth the added work for
> clients.  Another possibilty would be for the setter functions to give
> the complete callback some hint when they want an property change to be
> signalled.  For example an additional parameter or always when the

I thought about this and I'm afraid this would be unreadable.  The =

callback already includes 3 pointers and one of the pointers can be =

NULL.  There's already way too much magic and parameters in there.  The =

GDBus approach of pending_property_success/error is actually more =

readable and clear.  But it still comes down to a dbus_send in the end.

> 'reply' parameter is NULL (as opposed to an successful method return

Readability wise I hate this.  You should not be left wondering whether =

something is going to be done and have to look it up.  It should be =

immediately apparent when looking at the code...

> message).  It could also be argued that a Set with a new value same as
> old value should return an error reply but that's probably best left to
> the client to decide.

Could be argued, yes.  But I would argue that a Set succeeding and =

having no PropertyChanged being emitted is nicer.  And our projects =

already do this all the time.

Regards,
-Denis

--===============0379632642210017715==--

