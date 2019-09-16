Content-Type: multipart/mixed; boundary="===============6075457276668861173=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 0/2] Correct l_uintset_isempty() logic
Date: Mon, 16 Sep 2019 15:43:18 -0500
Message-ID: <54919aa1-90e4-ea7c-2796-8bc1f50a94c6@gmail.com>
In-Reply-To: <20190916203610.19722-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6075457276668861173==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Ossama,

On 9/16/19 3:36 PM, Ossama Othman wrote:
> The loop iteration over the 'bits' array in l_uintset_isempty()
> exceeded the maximum offset for the given l_uintset, resulting in
> out-of-bounds bits being considered for emptiness.  Add a test that
> demonstrates the problem, and correct the maximum offset when
> iterating over the l_uintset 'bits' field.
> =

> Ossama Othman (2):
>    unit: Add l_uintset_isempty() test
>    uintset: Do not exceed max offset in empty check
> =

>   ell/uintset.c       |  5 ++++-
>   unit/test-uintset.c | 17 +++++++++++++++++
>   2 files changed, 21 insertions(+), 1 deletion(-)
> =


Nice catch, both applied.

Regards,
-Denis

--===============6075457276668861173==--

