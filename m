Content-Type: multipart/mixed; boundary="===============1030122982016327574=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] dhcp: Free the old transport when setting, not the new one
Date: Mon, 29 Oct 2018 18:36:50 -0500
Message-ID: <b25930fa-bad8-2fcb-4b43-91074e87b2a1@gmail.com>
In-Reply-To: <20181029221612.4455-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1030122982016327574==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 10/29/2018 05:16 PM, Mat Martineau wrote:
> _dhcp_client_set_transport() would mistakenly free the new transport if
> the client had an existing transport. This private function is only used
> in a unit test, and only with a client that has an empty transport, so
> it was a latent bug.
> ---
>   ell/dhcp.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)

Applied, thanks.

Regards,
-Denis


--===============1030122982016327574==--

