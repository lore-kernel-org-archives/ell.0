Content-Type: multipart/mixed; boundary="===============6332767879964507931=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] settings: Overwrite values before freeing memory
Date: Mon, 30 Apr 2018 10:49:14 -0500
Message-ID: <14b7bc52-17b2-9d48-7b47-77ae2eeaf665@gmail.com>
In-Reply-To: <20180428022542.4289-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6332767879964507931==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 04/27/2018 09:25 PM, Andrew Zaborowski wrote:
> Since there may be sensitive data in the setting values, wipe the
> value memory before freeing.
> ---
>   ell/settings.c | 1 +
>   1 file changed, 1 insertion(+)
> =


Applied, thanks.

Regards,
-Denis


--===============6332767879964507931==--

