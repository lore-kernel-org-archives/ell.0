Content-Type: multipart/mixed; boundary="===============4367005874289987592=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v3 3/9] gvariant: New gvariant message format support
Date: Mon, 18 Apr 2016 14:25:36 -0500
Message-ID: <571534B0.4080809@gmail.com>
In-Reply-To: <1460680442-15201-3-git-send-email-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4367005874289987592==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/14/2016 07:33 PM, Andrew Zaborowski wrote:
> Make the builder write a complete struct enclosed in a variant and add a
> utility to add the final framing offset to produce a single parseable
> GVariant blob.
> ---
>   ell/gvariant-private.h |  4 ++++
>   ell/gvariant-util.c    | 44 ++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 48 insertions(+)
>

Applied, thanks.

Regards,
-Denis


--===============4367005874289987592==--

