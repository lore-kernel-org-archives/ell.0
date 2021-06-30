Content-Type: multipart/mixed; boundary="===============3307757120106404310=="
MIME-Version: 1.0
From: Martin =?unknown-8bit?q?Hundeb=C3=B8ll?= <martin@geanix.com>
Subject: Re: [PATCH 3/3] util: Add l_streq0
Date: Wed, 30 Jun 2021 21:18:02 +0200
Message-ID: <20210630191802.2sts74grb5oc3szb@xps.localdomain>
In-Reply-To: <20210630185108.263533-3-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3307757120106404310==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 30, 2021 at 08:51:08PM +0200, Andrew Zaborowski wrote:
> diff --git a/ell/util.h b/ell/util.h
> index bdf6935..d56c2a5 100644
> --- a/ell/util.h
> +++ b/ell/util.h
> @@ -276,6 +276,7 @@ size_t l_strlcpy(char* dst, const char *src, size_t l=
en);
>  =

>  bool l_str_has_prefix(const char *str, const char *prefix);
>  bool l_str_has_suffix(const char *str, const char *suffix);
> +bool l_streq0(const char *a, const char *b);

Should l_streq0 be added to ell.sym?

// Martin
--===============3307757120106404310==--

