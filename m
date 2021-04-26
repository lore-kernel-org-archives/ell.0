Content-Type: multipart/mixed; boundary="===============3634390373910889063=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 2/2] util: Add l_steal_ptr
Date: Mon, 26 Apr 2021 11:43:56 -0500
Message-ID: <7d3ee95d-fc48-6c89-306d-a9dbb6ea9fdd@gmail.com>
In-Reply-To: <20210426160622.761540-2-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3634390373910889063==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 4/26/21 11:06 AM, Andrew Zaborowski wrote:
> Add the l_steal_ptr macro, similar to g_steal_pointer except for being a
> macro and taking the variable name as a parameter, rather than a
> pointer to that variable.  From g_steal_pointer(pp) documentation:
> =

>> Sets `pp` to `NULL`, returning the value that was there before.
>>
>> Conceptually, this transfers the ownership of the pointer from the
>> referenced variable to the "caller" of the macro (ie: "steals" the
>> reference).
> ---
>   ell/util.h | 3 +++
>   1 file changed, 3 insertions(+)
> =


Applied, thanks.

Regards,
-Denis

--===============3634390373910889063==--

