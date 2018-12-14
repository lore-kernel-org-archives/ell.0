Content-Type: multipart/mixed; boundary="===============0152556124936641324=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 3/9] tls: Add TLS version number printf macros
Date: Fri, 14 Dec 2018 09:53:32 -0600
Message-ID: <ab96eccf-b6bf-dfd8-e8a2-545207d8aa19@gmail.com>
In-Reply-To: <20181213195746.32144-3-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0152556124936641324==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 12/13/2018 01:57 PM, Andrew Zaborowski wrote:
> ---
>   ell/tls-private.h |  3 +++
>   ell/tls.c         | 17 +++++++++++------
>   2 files changed, 14 insertions(+), 6 deletions(-)
> =


ell/tls.c: In function =E2=80=98tls_cipher_suite_is_compatible=E2=80=99:
ell/tls.c:540:34: error: =E2=80=98L_TLS_V12=E2=80=99 undeclared (first use =
in this =

function); did you mean =E2=80=98TLS_V12=E2=80=99?
    if (negotiated && negotiated < L_TLS_V12) {
                                   ^~~~~~~~~
                                   TLS_V12
ell/tls.c:540:34: note: each undeclared identifier is reported only once =

for each function it appears in

I know we allow breaking compilation if unavoidable, but I think here =

this can be easily avoided.

Can this patch be sent out of order prior to L_TLS_V refactoring and =

then fixed up there?

Regards,
-Denis

--===============0152556124936641324==--

