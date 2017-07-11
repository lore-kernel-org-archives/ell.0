Content-Type: multipart/mixed; boundary="===============6304979338494762464=="
MIME-Version: 1.0
From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 0/5] Bug fixes, new compiler warnings,
 and test enhancements
Date: Wed, 12 Jul 2017 01:34:45 +0200
Message-ID: <DB2E6DB8-6B30-468C-8AB7-CC7C88306A0A@holtmann.org>
In-Reply-To: <20170711230501.5419-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6304979338494762464==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Mat,

> When I tried to build ELL using gcc 7.1.1 it failed due to some switch ca=
se
> fall-throughs. One of those was an actual bug.
> =

> Patches 1 and 2 are the most critical. They fix the settings bug and add =
test
> code to trigger the bug and verify the fix.
> =

> Patch 3 does not change run-time behavior, but does fix siphash compilati=
on
> under gcc 7.
> =

> The last two patches are test enhancements that I sent previously but wer=
e not
> applied.
> =

> Mat Martineau (5):
>  settings: Fix string escaping bug
>  unit: Better coverage of escaped characters in settings strings
>  siphash: Fix fallthrough compiler warnings
>  unit: Add DH test case where results have leading zeros
>  unit: Make checksum unit tests verify checksum results
> =

> ell/settings.c       |  1 +
> ell/siphash.c        |  6 +++++
> unit/test-checksum.c | 66 +++++++++++++++++++++++++++--------------------=
-----
> unit/test-key.c      | 19 +++++++++++++++
> unit/test-settings.c | 10 ++++++++
> 5 files changed, 70 insertions(+), 32 deletions(-)

all 5 patches have been applied.

Regards

Marcel


--===============6304979338494762464==--

