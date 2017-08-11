Content-Type: multipart/mixed; boundary="===============8364676107024688061=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 04/10] tls: Report error if private key loading fails
Date: Fri, 11 Aug 2017 11:18:41 -0500
Message-ID: <e5bea589-e65b-ba6a-6b05-9db65cbf8889@gmail.com>
In-Reply-To: <20170810231016.29445-4-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8364676107024688061==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 08/10/2017 06:10 PM, Andrew Zaborowski wrote:
> Cleanup: drop the unneeded priv_key initialization and don't wait for
> the next l_key_get_info() to fail when a private key was set but can't
> be loaded.
> ---
>   ell/tls.c | 10 +++++-----
>   1 file changed, 5 insertions(+), 5 deletions(-)
> =


Applied, thanks.

Regards,
-Denis


--===============8364676107024688061==--

