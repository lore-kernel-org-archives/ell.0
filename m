Content-Type: multipart/mixed; boundary="===============2852245334546814440=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v5 2/4] dbus: Add AddMatch and RemoveMatch support
Date: Mon, 23 Feb 2015 11:08:39 -0600
Message-ID: <54EB5E97.1070708@gmail.com>
In-Reply-To: <1424692500-21681-3-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2852245334546814440==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/23/2015 05:54 AM, Jukka Rissanen wrote:
> We do not check for errors as they are typically unrecoverable
> in this case and in most cases ignored anyway.
>
> This is the comment from libdbus API documentation for
> dbus_bus_add_match() about error checking:
>
> "If you pass NULL for the error, this function will not block;
> the match thus won't be added until you flush the connection,
> and if there's an error adding the match you won't find out
> about it. This is generally acceptable, since the possible
> errors (including a lack of resources in the bus, the connection
> having exceeded its quota of active match rules, or the match
> rule being unparseable) are generally unrecoverable."
> ---
>   ell/dbus.c | 26 ++++++++++++++++++++++++++
>   1 file changed, 26 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============2852245334546814440==--

