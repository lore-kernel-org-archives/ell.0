Content-Type: multipart/mixed; boundary="===============3373714004185332089=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dbus: explicitly handle messages with NULL interface
Date: Wed, 20 Jan 2021 11:16:38 -0600
Message-ID: <8ac4a903-85a7-bdca-023b-b6d524f79a67@gmail.com>
In-Reply-To: <20210119232646.430146-1-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3373714004185332089==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On 1/19/21 5:26 PM, James Prestwood wrote:
> It was assumed that the DBus daemon would filter messages with
> no interfaces set, but some daemons do not (dbus-broker). This
> leads to the potential for a crash if the method call has no
> interface set. A crash can be seen in IWD with a few lines of
> python:
> =

> bus =3D dbus.SystemBus()
> obj =3D bus.get_object("net.connman.iwd", "/")
> print(obj.FooBar())
> =

> The above isn't necissarily a 'valid' way of doing things, but
> it does result in a crash which traces back to ELL. The actual
> method call (FooBar in this case) is arbitrary and could be
> anything.
> =

> ++++++++ backtrace ++++++++
> 0  0x7f532cda6a70 in /lib64/libc.so.6
> 1  0x47c4d2 in _dbus_object_tree_dispatch() at ell/dbus-service.c:1755
> 2  0x473f23 in message_read_handler() at ell/dbus.c:284
> 3  0x46be0c in io_callback() at ell/io.c:118
> 4  0x46b12d in l_main_iterate() at ell/main.c:471 (discriminator 2)
> 5  0x46b1dc in l_main_run() at ell/main.c:520
> 6  0x46b3ec in l_main_run_with_signal() at ell/main.c:648
> 7  0x403ea9 in main() at src/main.c:490
> 8  0x7f532cd91042 in /lib64/libc.so.6
> +++++++++++++++++++++++++++
> =

> The DBus spec does mention the possibility of the interface field
> being empty. It does not recommend doing this, but does not
> explicitly forbid it. Handling of this case is left up to the
> implementation.
> =

> The fix is simple: check that the message has an interface set and
> if not return an error.
> ---
>   ell/dbus-service.c | 10 ++++++++++
>   1 file changed, 10 insertions(+)
> =


Applied, thanks.

Regards,
-Denis

--===============3373714004185332089==--

