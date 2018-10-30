Content-Type: multipart/mixed; boundary="===============3591593626078786639=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 0/5] C99 related fixes
Date: Tue, 30 Oct 2018 09:29:29 +0100
Message-ID: <C2DE29CB-EECA-41ED-878C-EBDDFC5A6A47@holtmann.org>
In-Reply-To: <20181029200715.28427-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3591593626078786639==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

> This set of patches addresses some issues related to C library
> features that were disabled, or were at least affected, by explicitly
> enabling C99 in gcc via the -std=3Dc99 command line option.
> =

> ELL itself won't build cleanly when constrained solely to C99.  A
> successful build in that case requires defining the appropriate
> feature test macro(s) (e.g. _POSIX_SOURCE, _POSIX_C_SOURCE, etc)
> either in ELL's config.h header, the build command line, or individual
> source files that require the disabled C library feature.

so besides including two of your patches, I fixed the rest by adding the co=
rrect headers and using _GNU_SOURCE to active the features. So with -std99 =
we should be fine now. I have to look into -ansi and if that is worth while=
 supporting. However I hope that I didn=E2=80=99t break things for the musl=
 builds.

Regards

Marcel


--===============3591593626078786639==--

