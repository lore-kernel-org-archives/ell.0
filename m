Content-Type: multipart/mixed; boundary="===============0749754232961308436=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp6: Fix uninitialized variable build warning
Date: Thu, 20 Aug 2020 14:36:47 -0500
Message-ID: <72317b94-1ad6-c6e5-e644-0e3e6b14b05f@gmail.com>
In-Reply-To: <20200820193801.264181-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0749754232961308436==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 8/20/20 2:38 PM, Mat Martineau wrote:
> Commit 17f79c855e61 added a variable 'r' to dhcp6_client_rx_message()
> that holds either a new dhcp6_state or an error (negative value). 'r'
> was not set in several client states, but it appears that the unit tests
> only cover cases where it is set.
> =

> It appears that the new code at the end of dhcp6_client_rx_message() is
> only intended for the cases where 'r' was set, so initialize 'r' to the
> current client->state and rely on the existing state check to preserve
> old behavior.

Ah thanks for this.  I still have some pending changes that masked it on my=
 end. =

  I need to be more careful.

> ---
> =

> Denis, I don't have enough background knowledge about DHCPv6 to be 100%
> sure this patch does the right thing. Is my guess correct about the
> intended use of the new code at the end of dhcp6_client_rx_message()?

The fix is fine for now.  I think eventually all cases will be handled such=
 that =

r is always set, but I'm not there yet.

> =

> =

>   ell/dhcp6.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

Applied, thanks.

Regards,
-Denis
--===============0749754232961308436==--

