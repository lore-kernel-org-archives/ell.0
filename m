Content-Type: multipart/mixed; boundary="===============2168014635293131951=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH] queue: Fix an l_queue_insert corner case
Date: Tue, 02 Mar 2021 09:03:06 -0600
Message-ID: <5542e25b-28f7-9450-255e-b485b9ff5b13@gmail.com>
In-Reply-To: <20210301225746.742230-1-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2168014635293131951==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 3/1/21 4:57 PM, Andrew Zaborowski wrote:
> The comment doc for the function says:
> =

>   * Inserts @data pointer at a position in the queue determined by the
>   * compare @function.  @function should return > 0 if the @data (first
>   * parameter) should be inserted after the current entry (second paramet=
er).
> =


Right.  But the docs don't say anything about treatment of 0 returns.

> however the function would insert @data after entries for which
> @function returned a >=3D 0 value.  Change the check to > 0 to align with
> the docs.

The intent is that values that are 'equal' (@function returns 0) are insert=
ed =

_after_ any entries already in the queue.  While not documented explicitly,=
 I'm =

pretty sure that this is the only sensible behavior (and likely something w=
e =

implicitly rely on).  So, I'm not sure this is the right fix?

> ---
>   ell/queue.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> =


Regards,
-Denis
--===============2168014635293131951==--

