Content-Type: multipart/mixed; boundary="===============1046858849977804087=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Re: [PATCH v2 1/2] time: basic utility for getting the system time
Date: Wed, 23 Jan 2019 16:20:01 -0800
Message-ID: <CAPyD+=B74kXJ6ERChXYLvaS42=OTU6pVs=0WEBDJ=-UUCgTPZA@mail.gmail.com>
In-Reply-To: <20190123221159.24449-1-james.prestwood@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============1046858849977804087==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 23, 2019 at 2:07 PM James Prestwood
<james.prestwood@linux.intel.com> wrote:
> +/**
> + * l_time_offset
> + *
> + * @time: Start time to calculate offset
> + * @offset: Amount of time to add to 'time'
> + *
> + * Adds an offset to a time value. This checks for overflow, and if dete=
cted
> + * returns ULONG_MAX.
> + *
> + * Returns: A time value 'time' + 'offset'. Or ULONG_MAX if time + offset
> + * exceeds ULONG_MAX.

This isn't valid for platforms where long is 32 bits (those that
implement LP32, ILP32 and LLP64 data models).  Since you're returning
an uint64_t I think you should return UINT64_MAX instead.

> +static inline bool l_time_after(uint64_t a, uint64_t b)
> +{
> +       if ((int64_t)(b - a) < 0)
> +               return true;
> +
> +       return false;

This doesn't behave as documented in all cases.  For example, both
assertions in the below code will being triggered (manually comment
out one at time :)):

#include <stdint.h>
#include <stdbool.h>
#include <assert.h>

static inline bool l_time_after(uint64_t a, uint64_t b)
{
    if ((int64_t)(b - a) < 0) {
        return true;
    }
    return false;
}

int main()
{
    uint64_t a =3D UINT64_MAX;
    uint64_t b =3D UINT64_MAX / 2;

    assert(l_time_after(a, b));
    assert(!l_time_after(b, a));
}

Since both 'a' and 'b' are of the same type, why not check if a > b
instead?  Also, there is no need for the branch:

static inline bool l_time_after(uint64_t a, uint64_t b)
{
    return a > b;
}

> +}
> +
> +static inline bool l_time_before(uint64_t a, uint64_t b)
> +{
> +       return l_time_after(b, a);
> +}
> +
> +static inline uint64_t l_time_offset(uint64_t time, uint64_t offset)
> +{
> +       /* check overflow */
> +       if ((int64_t)(time + offset) <=3D 0)

What if both time and offset are zero?  Shouldn't zero be returned?  I
understand that a time of zero is a problem in and of itself. :)

Also, this will only overflow in one case, i.e. (time + offset) =3D=3D
UINT64_MAX + 1 since your casting the uint64_t typed result of (time +
offset) to int64_t.  This means that the addition will always be >=3D 0.
Something like the following should work:

static inline uint64_t l_time_offset(uint64_t time, uint64_t offset)
{
       /* check overflow */
      if (offset > UINT64_MAX - time)
          return UINT64_MAX;

      return time + offset;
}

> +               return ULONG_MAX;

As I mentioned earlier, this isn't valid for platforms where long is
32 bits (those that implement LP32, ILP32 and LLP64 data models).
Since you're returning an uint64_t I think you should return
UINT64_MAX instead.

HTH,
-Ossama

--===============1046858849977804087==--

