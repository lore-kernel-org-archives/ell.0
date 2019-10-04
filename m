Content-Type: multipart/mixed; boundary="===============7194880004862454370=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH v8 4/4] unit: fix memory leak in test-pem
Date: Fri, 04 Oct 2019 12:36:10 -0700
Message-ID: <CAPyD+=CkxnCjUYrbc4f-_1R6SGjkgGoDTGRQi04VayDBGz5GBA@mail.gmail.com>
In-Reply-To: <20191004185307.22707-4-prestwoj@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7194880004862454370==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi James,

On Fri, Oct 4, 2019 at 11:55 AM James Prestwood <prestwoj@gmail.com> wrot=
e:
>         if (!test->valid) {
> +               if (label)
> +                       l_free(label);

Checking for NULL before calling l_free() is unnecessary and
redundant.  l_free() and the underlying free() are no-ops when the
pointer argument is NULL.

-Ossama
--===============7194880004862454370==--

