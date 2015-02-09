Content-Type: multipart/mixed; boundary="===============8517854239726397667=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 0/2] Cipher infrastructure
Date: Mon, 09 Feb 2015 09:40:25 -0600
Message-ID: <54D8D4E9.3070506@gmail.com>
In-Reply-To: <1423226363-5025-1-git-send-email-tomasz.bursztyka@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8517854239726397667==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Tomasz,

On 02/06/2015 06:39 AM, Tomasz Bursztyka wrote:
> Hi,
>
> Looks like we need to re-inject the keys to the master socket (the one wh=
ich
> is binded so the selected crypto) once before an operation type, so first=
 encrypt
> and/or first decrypt.
> Now it seems to work. Should it handle an initialization vector?
>
> Tomasz Bursztyka (2):
>    cipher: Add a basic infrastructure for kernel based cipher operations
>    unit: Add unit test for the cipher infrastructure
>
>   Makefile.am        |  11 ++-
>   ell/cipher.c       | 221 ++++++++++++++++++++++++++++++++++++++++++++++=
+++++++
>   ell/cipher.h       |  52 +++++++++++++
>   ell/ell.h          |   1 +
>   unit/test-cipher.c | 107 ++++++++++++++++++++++++++
>   5 files changed, 389 insertions(+), 3 deletions(-)
>   create mode 100644 ell/cipher.c
>   create mode 100644 ell/cipher.h
>   create mode 100644 unit/test-cipher.c
>

I went ahead and applied both patches, but I reworked the implementation =

afterward.  I tried to explain the reasoning in the commit message, let =

me know if I succeeded :)

Regards,
-Denis

--===============8517854239726397667==--

