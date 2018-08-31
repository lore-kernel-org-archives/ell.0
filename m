Content-Type: multipart/mixed; boundary="===============8858917359491870919=="
MIME-Version: 1.0
From: Andrew Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 2/2][RFC] unit: Emit PropertyChanged in setters in
 test-dbus-service
Date: Sat, 01 Sep 2018 01:19:06 +0200
Message-ID: <CAOq732JHz66OH1rPXDwmy_iqw_en7w_sV7wy0xwf_myFgvgcoA@mail.gmail.com>
In-Reply-To: <c1569ec3-6f27-e597-ae5f-bb1c72bc4380@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8858917359491870919==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Fri, 31 Aug 2018 at 17:38, Denis Kenzior <denkenz@gmail.com> wrote:
> On 08/29/2018 08:05 PM, Andrew Zaborowski wrote:
> > Send the property change signals in the setter now that it's not done
> > automatically.  Note that the signals are now sent before the Set method
> > return message.
>
> Hmm, aren't we able to control the order of signals by issuing the
> complete callback prior to the property changed call?

Yes, it's just for convenience here.  Since the complete callback
unrefs "message", we'd need to ref/unref it once or use an extra
variable to send the reply after.

>  Obviously we
> can't do so if l_dbus_message_new_method_return() is used as the return
> value due to the clashing of property changed coalescing logic and the
> signal flushing logic inside dbus_send.
>
> The way around this, is for the implementer to use complete() if a
> synchronous method call is being implemented and the property change is
> immediate.  Not a common case for us, but still ugly...  Not sure what
> else we can do though?

I don't think the orders matters if the change is immediate, clients
should be able to handle both cases.

>
> By the way, looking at test_string_setter again, I actually don't get
> how its supposed to work.  Shouldn't it return at least some errors
> somewhere?

We only use this property to test the success case and we test the
error cases using the "SetError" and "Readonly" properties.

Best regards

--===============8858917359491870919==--

