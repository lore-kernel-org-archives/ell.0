Content-Type: multipart/mixed; boundary="===============0436547011092085869=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] cipher: add AES-CMAC hashing support
Date: Tue, 28 May 2019 20:32:13 -0500
Message-ID: <77166303-c2ea-5822-e36a-d52517e79840@gmail.com>
In-Reply-To: <20190529004949.25387-1-brian.gix@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0436547011092085869==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

On 05/28/2019 07:49 PM, Brian Gix wrote:
> The algorythm is supported in the kernel, and it is used heavily by
> Bluetooth Mesh, and is the one Mesh required algorythm missing from ELL.
> ---
>   ell/cipher.c       | 88 +++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/cipher.h       | 16 ++++++++++
>   unit/test-cipher.c | 74 +++++++++++++++++++++++++++++++++++++++++++++
>   3 files changed, 178 insertions(+)
> =


Please be aware of our patch submission guidelines found in HACKING. =

E.g. the unit test should be in a separate commit.

Have you checked whether l_checksum_new_cmac_aes() satisfies your needs?

Regards,
-Denis

--===============0436547011092085869==--

