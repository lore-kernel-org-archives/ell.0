Content-Type: multipart/mixed; boundary="===============0185327134426703217=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2] uuid: Added l_uuid_from_string
Date: Thu, 07 Feb 2019 11:22:45 -0600
Message-ID: <40ecdc4b-53cc-cae4-38c0-d24d8c687e9a@gmail.com>
In-Reply-To: <20190204104107.17893-1-michal.lowas-rzechonek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0185327134426703217==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Micha=C5=82,

On 02/04/2019 04:41 AM, Micha=C5=82 'Khorne' Lowas-Rzechonek wrote:
> From: Micha=C5=82 Lowas-Rzechonek <michal.lowas-rzechonek@silvair.com>
> =

> This commit adds API complementary to l_uuid_to_string, allowing parsing
> canonical string representation into a byte array.
> ---
>   ell/ell.sym      |  1 +
>   ell/uuid.c       | 34 +++++++++++++++++++++++++
>   ell/uuid.h       |  1 +
>   unit/test-uuid.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++
>   4 files changed, 100 insertions(+)
> =


I split this up into two commits to be in compliance with our patch =

submission guidelines (see HACKING, pt 3).

I also massaged the style of test data in the unit test a bit.  Please =

review and make sure I didn't screw anything up accidentally.

Applied, thanks.

Regards,
-Denis


--===============0185327134426703217==--

