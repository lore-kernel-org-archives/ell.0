Content-Type: multipart/mixed; boundary="===============2615571510737411718=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2] build: Undefine _FORTIFY_SOURCE when building without
 optimization
Date: Thu, 11 Feb 2016 13:56:12 -0600
Message-ID: <56BCE75C.7070705@gmail.com>
In-Reply-To: <1455148122-20449-2-git-send-email-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2615571510737411718==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

On 02/10/2016 05:48 PM, Mat Martineau wrote:
> './configure --disable-optimization --enable-maintainer-mode' would
> claim that signalfd was not available. _FORTIFY_SOURCE requires that
> optimization is enabled and issues a compile-time warning which is
> treated as an error. Disabling optimization takes precedence over
> fortification in this case, since it is being explicitly requested.
> ---
>   configure.ac | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>

Applied, thanks.

Regards,
-Denis


--===============2615571510737411718==--

