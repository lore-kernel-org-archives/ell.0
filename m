Content-Type: multipart/mixed; boundary="===============6671271173239825332=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] unit: Add runtime check for TLS suite cipher support
Date: Sun, 17 Feb 2019 20:43:10 -0600
Message-ID: <364ff69a-b34f-e191-6453-4e5b4eaf0dca@gmail.com>
In-Reply-To: <20190215220137.7592-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6671271173239825332==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 02/15/2019 04:01 PM, Mat Martineau wrote:
> Skip TLS suite tests where the currently running kernel does not have
> support for the necessary cipher. Checksums types already have runtime
> validation.
> ---
>   unit/test-tls.c | 21 ++++++++++++++++++---
>   1 file changed, 18 insertions(+), 3 deletions(-)

Applied, thanks.

Regards,
-Denis


--===============6671271173239825332==--

