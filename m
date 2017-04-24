Content-Type: multipart/mixed; boundary="===============0080872693216674367=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] netlink: Include <stdint.h> for fixed width types
Date: Mon, 24 Apr 2017 15:58:05 -0500
Message-ID: <3ed8117e-aa45-3df4-93c0-fb1e186a6b7b@gmail.com>
In-Reply-To: <1493062828-21327-1-git-send-email-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0080872693216674367==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 04/24/2017 02:40 PM, Ossama Othman wrote:
> The prototypes in the ELL netlink.h header use the C99 fixed width
> integer types.  Include <stdint.h> to make netlink.h self-contained.
> ---
>  ell/netlink.h | 1 +
>  1 file changed, 1 insertion(+)
>

Applied, thanks.

Regards,
-Denis


--===============0080872693216674367==--

