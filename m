Content-Type: multipart/mixed; boundary="===============1087638293947032389=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 1/4] tls: Print only one tls_cert_domains_match_mask debug
 msg
Date: Thu, 17 Dec 2020 13:33:48 -0600
Message-ID: <d0125272-6d2b-b264-e217-6cf1b38d04f8@gmail.com>
In-Reply-To: <20201217013225.821303-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1087638293947032389==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 12/16/20 7:32 PM, Andrew Zaborowski wrote:
> Change tls_cert_domains_match_mask to compile one error message string
> instead of printing messages at different step.  The rest of the TLS debug
> log tries to be concise when there's no errors so try to be concise here
> too.
> ---
> This is the tls_cert_domains_match_mask version I had in my tree and
> thought I might just send it.
> =

>   ell/tls.c | 71 +++++++++++++++++++++++++++++++++++--------------------
>   1 file changed, 45 insertions(+), 26 deletions(-)
> =


Applied, thanks.

Regards,
-Denis

--===============1087638293947032389==--

