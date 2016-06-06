Content-Type: multipart/mixed; boundary="===============2514024805075325788=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 08/11] cipher: Update for current kernel akcipher interface
Date: Mon, 06 Jun 2016 18:55:00 -0500
Message-ID: <57560D54.8010603@gmail.com>
In-Reply-To: <20160606205450.23615-8-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2514024805075325788==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 06/06/2016 03:54 PM, Mat Martineau wrote:
> There are some significant differences in the current iteration of
> kernel AF_ALG akcipher support:
>   * Kernel handles padding

Are you sure?  Talking with Andrew a while ago, he didn't think this was =

the case.  My impression was that it was implemented as a template.

The unit test we have for L_CIPHER_RSA_PKCS1_V1_5 is not really reliable =

either.

Regards,
-Denis

--===============2514024805075325788==--

