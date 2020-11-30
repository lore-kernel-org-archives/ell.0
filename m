Content-Type: multipart/mixed; boundary="===============3124271668961329133=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/2] Fix "NLA_F_NESTED is missing" error
Date: Mon, 30 Nov 2020 12:56:41 -0600
Message-ID: <637bcd88-f32c-c954-4a8f-ca42a8a16131@gmail.com>
In-Reply-To: <20201130185736.30474-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3124271668961329133==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 11/30/20 12:57 PM, Ossama Othman wrote:
> This set of patches addresses a "NLA_F_NESTED is missing" error under
> strict nested netlink attribute validation by the kernel.  Users can
> work around the error by explicitly setting the NLA_F_NESTED bit in
> the type passed to l_genl_msg_enter_nested(), but having ELL
> transparently set the bit seems more appropriate.
> =

> Ossama Othman (2):
>    genl: Add missing NLA_F_NESTED bit
>    unit: Update expected nested netlink attr data
> =

>   ell/genl.c           | 2 +-
>   unit/test-genl-msg.c | 6 +++---
>   2 files changed, 4 insertions(+), 4 deletions(-)
> =


Both applied, thanks.

Regards,
-Denis
--===============3124271668961329133==--

