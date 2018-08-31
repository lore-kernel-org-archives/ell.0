Content-Type: multipart/mixed; boundary="===============6314661949985995836=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2][RFC] unit: Emit PropertyChanged in setters in
 test-dbus-service
Date: Fri, 31 Aug 2018 10:38:06 -0500
Message-ID: <c1569ec3-6f27-e597-ae5f-bb1c72bc4380@gmail.com>
In-Reply-To: <20180830010541.8687-2-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6314661949985995836==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/29/2018 08:05 PM, Andrew Zaborowski wrote:
> Send the property change signals in the setter now that it's not done
> automatically.  Note that the signals are now sent before the Set method
> return message.

Hmm, aren't we able to control the order of signals by issuing the =

complete callback prior to the property changed call?  Obviously we =

can't do so if l_dbus_message_new_method_return() is used as the return =

value due to the clashing of property changed coalescing logic and the =

signal flushing logic inside dbus_send.

The way around this, is for the implementer to use complete() if a =

synchronous method call is being implemented and the property change is =

immediate.  Not a common case for us, but still ugly...  Not sure what =

else we can do though?

By the way, looking at test_string_setter again, I actually don't get =

how its supposed to work.  Shouldn't it return at least some errors =

somewhere?

Regards,
-Denis

--===============6314661949985995836==--

