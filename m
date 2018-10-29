Content-Type: multipart/mixed; boundary="===============8821709831773412775=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH 4/5] ell: Make tls-private.h header self-contained.
Date: Mon, 29 Oct 2018 14:49:03 -0700
Message-ID: <CAPyD+=Crq=gPXiAoCUu2WPCbt_zxAXRQUyFZjaumGySYCw3brQ@mail.gmail.com>
In-Reply-To: <2b306d44-5d15-3594-431d-fd42802dd678@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8821709831773412775==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On Mon, Oct 29, 2018 at 1:49 PM Denis Kenzior <denkenz@gmail.com> wrote:
> Hmm, our general practice is not to include anything inside private
> headers, so this goes fully counter to that practice.  Why is
> tls-private.h being used anyway?

It's used in tools/certchain-verify.c, but I'm not sure why it's used
there since I wasn't involved with its implementation.  I ran across
several warnings and errors when attempting to build ELL with -std=3Dc99
(not the norm, I know), some of which could only be corrected by
making sure the appropriate feature test macro was defined by before
including some ELL and system headers, e.g.:

  CC       tools/certchain-verify.o
In file included from ./ell/ell.h:32:0,
                 from tools/certchain-verify.c:39:
./ell/signal.h:39:40: error: unknown type name =E2=80=98sigset_t=E2=80=99
 struct l_signal *l_signal_create(const sigset_t *mask,
                                        ^~~~~~~~
Makefile:1621: recipe for target 'tools/certchain-verify.o' failed

I don't need to build ELL with C99, and only attempted to do so when
attempting to track down C99 related build errors in my own
application.   In any case, replacing the <ell/ell.h> include
directive with only the required ELL headers corrected the above
error, but I then ended up with other warnings and errors:

  CC       tools/certchain-verify.o
In file included from tools/certchain-verify.c:39:0:
./ell/tls-private.h:41:21: error: field =E2=80=98l_id=E2=80=99 has incomple=
te type
  enum l_cipher_type l_id;
                     ^~~~
./ell/tls-private.h:49:23: error: field =E2=80=98l_id=E2=80=99 has incomple=
te type
  enum l_checksum_type l_id;
                       ^~~~
./ell/tls-private.h:53:39: warning: =E2=80=98struct l_tls=E2=80=99 declared=
 inside
parameter list will not be visible outside of this definition or
declaration
 typedef bool (*tls_get_hash_t)(struct l_tls *tls, uint8_t tls_id,
                                       ^~~~~
./ell/tls-private.h:64:42: warning: =E2=80=98struct l_tls=E2=80=99 declared=
 inside
parameter list will not be visible outside of this definition or
declaration
  bool (*send_client_key_exchange)(struct l_tls *tls);
                                          ^~~~~
./ell/tls-private.h:65:44: warning: =E2=80=98struct l_tls=E2=80=99 declared=
 inside
parameter list will not be visible outside of this definition or
declaration
  void (*handle_client_key_exchange)(struct l_tls *tls,
                                            ^~~~~
./ell/tls-private.h:68:25: warning: =E2=80=98struct l_tls=E2=80=99 declared=
 inside
parameter list will not be visible outside of this definition or
declaration
  ssize_t (*sign)(struct l_tls *tls, uint8_t *out, size_t len,
                         ^~~~~
./ell/tls-private.h:70:24: warning: =E2=80=98struct l_tls=E2=80=99 declared=
 inside
parameter list will not be visible outside of this definition or
declaration
  bool (*verify)(struct l_tls *tls, const uint8_t *in, size_t len,
                        ^~~~~
./ell/tls-private.h:76:23: error: field =E2=80=98hmac_type=E2=80=99 has inc=
omplete type
  enum l_checksum_type hmac_type;
                       ^~~~~~~~~
./ell/tls-private.h:135:2: error: unknown type name =E2=80=98l_tls_write_cb=
_t=E2=80=99
  l_tls_write_cb_t tx, rx;
  ^~~~~~~~~~~~~~~~
./ell/tls-private.h:136:2: error: unknown type name =E2=80=98l_tls_ready_cb=
_t=E2=80=99
  l_tls_ready_cb_t ready_handle;
  ^~~~~~~~~~~~~~~~
./ell/tls-private.h:137:2: error: unknown type name =E2=80=98l_tls_disconne=
ct_cb_t=E2=80=99
  l_tls_disconnect_cb_t disconnected;
  ^~~~~~~~~~~~~~~~~~~~~
./ell/tls-private.h:216:45: warning: =E2=80=98enum l_tls_alert_desc=E2=80=
=99 declared
inside parameter list will not be visible outside of this definition
or declaration
 void tls_disconnect(struct l_tls *tls, enum l_tls_alert_desc desc,
                                             ^~~~~~~~~~~~~~~~
Makefile:1621: recipe for target 'tools/certchain-verify.o' failed

This patch corrects these build warnings and errors.  However, I
understand your point about the header being private, so I won't push
for this patch any further.

Thanks,
-Ossama

--===============8821709831773412775==--

