Content-Type: multipart/mixed; boundary="===============5779207295662424746=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/3] dbus: Default empty signature for method return
 messages
Date: Tue, 21 Feb 2017 10:55:31 -0600
Message-ID: <325ac145-48e2-c23a-5874-2d8afc1d8486@gmail.com>
In-Reply-To: <20170220233036.8741-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5779207295662424746==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 02/20/2017 05:30 PM, Andrew Zaborowski wrote:
> Allow Dbus method or setter handlers to return the result of a
> l_dbus_message_new_method_return call directly without calling
> l_dbus_message_set_arguments on the result.  This will result in an
> empty signature message being built inside l_dbus_send.
>
> Note l_dbus_send now modifies the message being passed to it.
>
> Instead of checking if the signature returned by
> l_dbus_message_get_signature is NULL we could also just call
> l_dbus_message_builder_new and write an empty message.
> l_dbus_message_builder_new would return NULL if message->sealed was
> true.
> ---
>  ell/dbus.c | 5 +++++
>  1 file changed, 5 insertions(+)
>

All three applied, thanks.

Regards,
-Denis


--===============5779207295662424746==--

