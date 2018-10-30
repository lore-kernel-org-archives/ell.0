Content-Type: multipart/mixed; boundary="===============2650173455558955405=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH 0/5] C99 related fixes
Date: Tue, 30 Oct 2018 08:58:51 -0700
Message-ID: <CAPyD+=AyNM4b_EvYMReG7GAChoK+Z-cfg1NxrLdDq4Bn6ZA4=Q@mail.gmail.com>
In-Reply-To: <C2DE29CB-EECA-41ED-878C-EBDDFC5A6A47@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2650173455558955405==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

On Tue, Oct 30, 2018 at 1:29 AM Marcel Holtmann <marcel@holtmann.org> wro=
te:
> so besides including two of your patches, I fixed the rest by adding
> the correct headers and using _GNU_SOURCE to active the features. So
> with -std99 we should be fine now. I have to look into -ansi and if
> that is worth while supporting. However I hope that I didn=E2=80=99t break
> things for the musl builds.

Thanks for making those changes.  ELL itself now builds with -std=3Dc99
for me.  However, the __sigset_t type used in <ell/signal.h> is still
flagged as an unknown type in my code when compiling with -std=3Dc99,
without explicitly defining any feature test macros.  For example, a
trivial code snippet that only includes <ell/ell.h> fails:

foo.c:
#include <ell/ell.h>

$ gcc -std=3Dc99 -fsyntax-only foo.c
In file included from /usr/local/include/ell/ell.h:32:0,
                from foo.c:1:
/usr/local/include/ell/signal.h:39:40: error: unknown type name =E2=80=98__=
sigset_t=E2=80=99
struct l_signal *l_signal_create(const __sigset_t *mask,
                                       ^~~~~~~~~~

Should the appropriate feature test macro be added to ELL's Cflags
variable in the ell.pc pkg-config file?

Thanks,
-Ossama

--===============2650173455558955405==--

