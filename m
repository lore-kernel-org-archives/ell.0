Content-Type: multipart/mixed; boundary="===============4500856746608059008=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] ell/cipher.c: fix build on uclibc
Date: Tue, 19 Jan 2021 09:49:14 -0600
Message-ID: <a3366372-eabf-f893-5e87-61ce29be69e2@gmail.com>
In-Reply-To: <20210117134618.343640-1-fontaine.fabrice@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4500856746608059008==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Fabrice,

On 1/17/21 7:46 AM, Fabrice Fontaine wrote:
> Include missing.h to avoid a build failure when explicit_bzero is
> missing
> =

> Signed-off-by: Fabrice Fontaine <fontaine.fabrice@gmail.com>
> ---
>   ell/cipher.c | 1 +
>   1 file changed, 1 insertion(+)
> =


Applied (without the S-o-B tag), thanks.

Regards,
-Denis

--===============4500856746608059008==--

