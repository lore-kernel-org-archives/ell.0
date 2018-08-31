Content-Type: multipart/mixed; boundary="===============0266450929622596739=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 1/2][RFC] dbus: Don't automatically emit PropertyChanged
 after Set
Date: Sat, 01 Sep 2018 01:05:31 +0200
Message-ID: <CAOq732+C41hnEboWqsVw1qSBOjjGbjEyTeusmt3RsLkji6jVPw@mail.gmail.com>
In-Reply-To: <a8adca6f-ab15-26c8-98f4-d75cf2d84578@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0266450929622596739==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,
[resending to the list]

On Fri, 31 Aug 2018 at 17:49, Denis Kenzior <denkenz@gmail.com> wrote:
> On 08/29/2018 08:05 PM, Andrew Zaborowski wrote:
> > Remove the _dbus_object_tree_property_changed call in the complete
> > handler for property setters so a PropertyChanged/PropertiesChanged
> > signal is not sent for every successful Set().  This means that the
> > setter functions will have to emit the signals when the property's value
> > has changed so it affects ell's clients.  This attempts to allow clients
> > to solve an issue where PropertyChanged signals were generated even if
> > Set was called with a value equal to the property's current value so the
> > values was not effectively chaning.
>
> So if we do it this way, do we even need the complete callback at all?
> All it does is just sends a reply now.  This can be easily done by the
> caller by issuing a dbus_pending_reply or l_dbus_send...

Yes, although I'm not sure that's better.  Perhaps it was never a good
idea for the complete callback to be an opaque pointer instead of an
api call but at least it builds the reply for you.
>
> >
> > I'm not 100% convinced this small benefit is worth the added work for
> > clients.  Another possibilty would be for the setter functions to give
> > the complete callback some hint when they want an property change to be
> > signalled.  For example an additional parameter or always when the
>
> I thought about this and I'm afraid this would be unreadable.  The
> callback already includes 3 pointers and one of the pointers can be
> NULL.  There's already way too much magic and parameters in there.  The
> GDBus approach of pending_property_success/error is actually more
> readable and clear.  But it still comes down to a dbus_send in the end.

With a direct l_dbus_send call you have to know exactly what the
method's signature was, it's not difficult but it's nicer when you
don't have to care like in the GDBus case.

Best regards

--===============0266450929622596739==--

